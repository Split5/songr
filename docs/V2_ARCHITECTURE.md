# Söngr V2 — product and architecture contract

## Purpose

V2 is a controlled rebuild of the app's foundations, not another visual layer
on top of the old providers. The V1 code has been removed: `lib/main.dart`
boots V2 directly through `lib/app/v2/v2_bootstrap.dart`, and there is no
fallback target to build.

Flutter is retained for iOS and later Android. V2 talks only to a Navidrome
server through the Subsonic-compatible API. Last.fm, AudioMuse and other music
services are outside the V2 runtime.

## Product principles

1. Offline first: every screen reads metadata from SQLite. Network responses
   update the database; widgets never depend directly on an HTTP response.
2. One owner per responsibility: playback, queue, sync, downloads and
   recommendations are separate services with narrow interfaces.
3. Stable queue semantics: selecting, reordering or removing an item never
   silently creates a new queue. A new queue is created only by an explicit
   Play, Shuffle or Radio command.
4. Scale: database pagination, lazy widgets and bounded caches must support at
   least 100,000 songs without building all rows or native audio sources.
5. Graceful degradation: cached content remains usable during network and
   server failures. Every empty state explains what happened and offers a
   useful action.
6. A single visual system: true-black media-first surfaces, artwork as the
   colour source, flat controls separated by tone and rules, consistent motion
   and restrained haptics.

## Main navigation

- Home: Recently played, Start listening, Pop/genre shelves and Replay.
- New: recently added albums and songs, grouped by date.
- Radio: saved internet stations, Now Playing station and local Navidrome radio
  entry points.
- Library: Playlists, Artists, Albums, Songs and Downloaded.
- Search: genre grid and segmented song/album/artist/playlist results.

The mini player and tab bar remain visible across feature navigation. The full
player is the deliberate exception and covers the shell.

`My Listening` statistics are not part of Home. The existing long-press
`Flip for info` interaction is retained in the full player.

## Layers and dependency direction

```text
features/widgets
      |
application controllers (small immutable view states)
      |
domain services and repositories
      |
SQLite | Subsonic HTTP | just_audio | file storage | platform media session
```

UI code may call application controllers only. It may not construct audio
sources, make Subsonic calls, mutate queue arrays or write files.

Target module layout:

```text
lib/
  app/                 bootstrap, routing, theme
  core/                errors, result types, clock, logging
  data/local/          SQLite schema and DAOs
  data/navidrome/      Subsonic client and DTO mapping
  domain/library/      entities and library repository
  domain/sync/         reconciliation and pending operations
  domain/playback/     playback and queue contracts
  domain/downloads/    download policy and storage index
  domain/radio/        Radio/AutoPlay candidate selection
  features/...         screens and their controllers
  design_system/       flat surfaces, spacing, motion, artwork
```

## Local database

SQLite is the canonical client-side read model. The initial implementation uses
Drift for typed migrations and paged queries.

Required tables:

- songs, albums, artists and artist aliases
- playlists and playlist entries with stable positions
- favorites
- play history and server play counters
- internet radio stations
- lyrics
- artwork cache index
- downloads and download reasons
- sync state and pending operations
- saved filter presets
- queue sessions and queue entries
- algorithm settings

Every table has a schema version and migration test. Credentials remain in the
platform keychain and are never stored in SQLite.

## Navidrome synchronization

1. On sign-in, validate with `ping` and save credentials in secure storage.
2. Render the last SQLite snapshot immediately.
3. Start a background refresh with bounded concurrency.
4. Page albums/artists/playlists; fetch changed/new album contents and perform a
   periodic full reconciliation to detect removals.
5. Persist each page transactionally and publish database invalidations.
6. Replay queued offline favorite/playlist mutations when online.
7. Pull server state after mutation. On a true conflict, server state wins and
   the client reports that outcome instead of silently diverging.

Two-way entities are favorites, playlists, play count and last played. A play
is submitted exactly once when it reaches the earlier of 50 percent or four
minutes. A non-submission `scrobble` may announce the track start.

## Playback core

`PlaybackCoordinator` is the only owner of `just_audio` and the platform media
session. Its public commands are explicit:

- `replaceQueue(items, startId, shuffle)`
- `playItem(id)`
- `jumpTo(queueEntryId)`
- `move(queueEntryId, beforeEntryId)`
- `remove(queueEntryId)`
- `insertNext(songId)` / `append(songIds)`
- `setRepeat(mode)` / `setShuffle(enabled)`
- `setAutoPlay(enabled)`

The logical queue is persisted independently of just_audio's bounded native
window. Only nearby items are materialized as native audio sources. Jumping to
an existing queue entry changes the playhead and window; it never truncates or
recreates the logical queue.

AutoPlay requests candidates near the end and appends five deduplicated songs
at a time. It never rewrites existing entries. The candidate provider uses
Navidrome `getSimilarSongs2`/radio data when available and a local metadata
fallback otherwise.

All queue commands are serialized. Audio-session callbacks, UI commands and
AutoPlay therefore cannot mutate the native player concurrently.

## Offline and downloads

- Metadata is always offline.
- Songs, albums, playlists and Favorites can be pinned for offline playback.
- An offline playlist continuously reconciles future additions/removals.
- Download files use atomic temporary paths, checksums/length validation and a
  database-backed manifest.
- LRU eviction applies only to cache entries, never explicitly pinned media.
- Artwork and lyrics have separate bounded LRU caches.
- The data-saver stream profile requests Navidrome MP3 transcoding at a user
  selected maximum bitrate.

## Radio and recommendations

No external music API is required.

- Replay All Time: local/server play history with artist diversity.
- Recently Played: chronological history.
- Discover More: unheard/low-play songs related through Navidrome similarity
  and local genre/album context.
- Genre Radio and Artist Radio: explicit seeded sessions.
- Internet Radio: Subsonic radio-station endpoints.

The in-app Algorithm Lab controls documented weights for play count, recency,
genre, artist similarity, popularity and randomness plus AutoPlay batch/pool
sizes. Defaults are versioned. This is a local advanced panel, not a second
backend with undocumented state.

## Filtering

Songs are queried from SQLite with composable filters for bitrate, codec,
Lossless/Hi-Res, genre, year, duration, downloaded and favorite state. Sort and
filter presets can be named and saved. Quality badges are generated from the
stored technical metadata.

## Design system

- True-black base; artwork supplies expressive colour.
- The warm playback accent marks live state and stays out of navigation
  chrome.
- Floating sheets stay opaque so text never competes with obscured artwork.
- Standard radii, spacing, typography and motion tokens live in one package.
- Page transitions use 240–360 ms ease-out motion; list changes use subtle
  size/fade transitions.
- Haptics occur only for intentional state changes. Long-press feedback must
  never alter or duck playback volume.
- Album, playlist and player backgrounds share the same palette pipeline.

## iOS integration

- background audio and interruptions through the audio session
- lock screen and Control Center metadata/progress
- headset previous/play/next commands
- AirPlay route support
- remote shuffle/repeat where the platform exposes it
- restored queue and position after process restart

Lyrics use Navidrome/Subsonic data only. Inactive synchronized lines blur/fade;
plain lyrics degrade to a scrollable text view.

## Release gates

V2 does not replace V1 until all gates pass:

1. Database migrations and a 100,000-song synthetic paging test.
2. Queue contract tests: jump, reorder, removal and AutoPlay never replace the
   logical queue; continuous playback advances correctly.
3. Scrobble exactly-once tests across pause, seek, repeat and track changes.
4. Offline cold-start test with the server unreachable.
5. Download interruption/resume and storage-cap tests.
6. Background/lock-screen/headset tests on a physical iPhone.
7. Full Flutter analyze/test suite and a release build.
8. User acceptance on the physical iPhone before merging to `main`.

## Migration policy

Stable DTO parsing, secure credential storage, download files and well-tested
recommendation helpers may be reused behind new interfaces. Existing giant
providers and UI-driven queue mutations are not carried into the V2 core.

