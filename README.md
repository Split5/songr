# Söngr (Soengr)

A Flutter client for [Navidrome](https://www.navidrome.org/) / Subsonic
(API v1.16.1) with a fully local, privacy-respecting recommendation engine.

Not affiliated with the Navidrome project.

## Why another client?

Most Subsonic clients are library browsers. This one tries to feel like a
streaming service on top of your own Navidrome server — every suggestion
comes from Navidrome itself (its similar-songs agent), with no third-party
service and no account beyond your server login.

- **Home carousels** — recently played, recently added, your playlists and
  albums as artwork-first shelves instead of one long feed.
- **Quick Picks** — a rotating set of songs seeded from what you play and
  favourite, each with the reason it was picked.
- **Playlist suggestions** — every playlist offers similar songs you can
  add with one tap, plus "playlist radio" and "continue with similar".
- **Song radio / AutoPlay** — start a mix from any song; when the queue
  runs out, Navidrome's similar songs keep it going.
- **Downloads and offline** — keep favourites, albums or whole playlists on
  the device and play them without a connection.
- **Playlist management** — create, rename, reorder and delete playlists.
- **Lyrics, sleep timer, sharing** — synced lyrics in the player, a sleep
  timer that just pauses, and Subsonic share links for songs, albums and
  playlists.

Everything else you'd expect: gapless native queue (play next / add to
queue / drag to reorder / swipe for actions), full playlist management
(create, reorder, delete, add/remove songs), one shared song action menu
on every list, favorites, search, background playback with lock-screen
controls, and English/Swedish localization following the system language.

## Platform status

| Platform | Status |
|---|---|
| iOS | ✅ works (sideload with your own signing; no App Store) |
| macOS | ✅ works |
| Linux | ✅ works (libmpv via media_kit) |
| Android | ⚠️ configured but untested |
| Windows/Web | ❌ not configured |

## Server requirements

- A [Navidrome](https://www.navidrome.org/) server (any recent version;
  developed against 0.63.x).
- Optional: [Last.fm integration](https://www.navidrome.org/docs/usage/external-integrations/)
  on the server enables similar-songs data (song radio, AutoPlay and
  playlist suggestions).

## Building

```bash
flutter pub get

# iOS (needs Xcode; set your team in ios/Runner.xcworkspace →
# Signing & Capabilities first)
flutter build ios --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release

# Android
flutter build apk --release
```

## Architecture

The shipped app is the V2 runtime. `lib/main.dart` (and the
`lib/main_v2.dart` delegate used by `tool/build_ios_v2.sh`) call
`bootstrapV2()` in `lib/app/v2/v2_bootstrap.dart`.

```
lib/
  main.dart / main_v2.dart      V2 bootstrap (both delegate to bootstrapV2)
  app/v2/                       App shell, runtime wiring, server settings,
                                playback/experience preferences
  api/subsonic_api.dart         Subsonic client (token auth, http + crypto)
  models/models.dart            Song/Album/ArtistSummary/Playlist
  data/local/                   Drift (SQLite) database + repositories
  data/navidrome/               Subsonic gateways (sync, lyrics, scrobble,
                                play queue, AutoPlay candidates)
  domain/                       Pure services: playback coordinator + queue,
                                sync, lyrics, downloads, radio, library
                                (incl. navidrome_similarity_service.dart —
                                recommendations built on getSimilarSongs2)
  features/                     Feature screens and controllers: home, new
                                music, radio, library, favorites, search,
                                downloads, player, settings
  design_system/                Tokens, theme and shared widgets
  state/download_provider.dart  Offline downloads (shared with the runtime)
  l10n/                         ARB sources + generated localizations
tool/live_check.dart            Smoke test against a real server
```

Recommendations, song radio and AutoPlay use Navidrome's `getSimilarSongs2`
only. On a server running the AudioMuse-AI Navidrome plugin that endpoint
returns sonic similarity, and the plugin's cluster playlists show up as
ordinary `*_automatic` playlists — the client never talks to AudioMuse
directly and stores no AudioMuse URL or token.

Audio is just_audio + audio_service (background playback); Linux uses
just_audio_media_kit. The password is kept in flutter_secure_storage and never
leaves the device except as Subsonic token auth. If secure storage is
unavailable, the app asks for the password again instead of storing it in
plaintext.

## Testing

```bash
flutter analyze
flutter test        # engine + auth/URL unit tests

# Live smoke test against a real server (no secrets in source):
export NAVI_URL=https://music.example.com NAVI_USER=... NAVI_PASS=...
dart run tool/live_check.dart
```

## Known limitations

- Recommendation engine is developed against a small library (~250
  songs); untested at large scale.
- Local play/skip history is per-device (not synced).
- ATS/cleartext exceptions are enabled so plain-http LAN servers work;
  tighten if you only use https.
- Free Apple provisioning means the iOS app must be reinstalled every
  7 days (a paid Apple Developer account removes the limit).

## License

MIT — see [LICENSE](LICENSE).
