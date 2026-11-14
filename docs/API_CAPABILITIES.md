# Navidrome API Capability Report

Empiriskt verifierad 2026-07-16 mot skarp server `http://192.168.0.252:4533`.

- **Server:** Navidrome 0.63.2 (be10f89c), Subsonic API-version **1.16.1**, `openSubsonic: true`
- **Bibliotek:** 237 låtar, 198 mappar, samtliga `.m4a` (audio/mp4), nedladdade via yt-dlp

Alla anrop gjorda med `f=json`. Svar wrappas alltid i `{"subsonic-response": {"status": "ok", ...}}`.

## Autentisering

Token-baserad auth **fungerar**: `u=<user>&t=md5(password+salt)&s=<salt>&v=1.16.1&c=<client>&f=json`.
Verifierad via `/rest/ping` → `status: ok`. (Inga tokens/lösenord i denna rapport.)

## Endpoints — status

| Endpoint | Status | Kommentar |
|---|---|---|
| `ping` | ✅ | Returnerar version + serverVersion |
| `getPlaylists` | ✅ | Alla 7 spellistor, korrekta UTF-8-namn (Vårkänsla, Gillade låtar 2026, ...) |
| `getPlaylist?id=` | ✅ | Full `entry[]` med komplett låtobjekt |
| `getRandomSongs?size=` | ✅ | Perfekt för shuffle-sektion |
| `getStarred2` | ✅ (tom) | Fungerar men 0 stjärnmärkta artister/album/låtar just nu |
| `getAlbumList2?type=frequent/recent/newest/random` | ✅ alla fyra | `frequent`/`recent` bygger på playCount/senast spelad — funkar för Quick Picks/Replay |
| `getTopSongs?artist=` | ⚠️ TOM | Svarar `ok` men `topSongs: {}` — kräver Last.fm, ej konfigurerat |
| `getSimilarSongs2?id=` | ⚠️ TOM | Svarar `ok` men `similarSongs2: {}` — kräver Last.fm |
| `getArtistInfo2?id=` | ⚠️ Delvis | Returnerar ENDAST `smallImageUrl/mediumImageUrl/largeImageUrl` (via /share/img). Ingen `biography`, inga `similarArtist` |
| `search3?query=` | ✅ | UTF-8 verifierat: sökning på "MISSFÖRSTÅTT" träffar album + låt korrekt. Tom query returnerar hela biblioteket (paginering via `songCount`/`songOffset` fungerar) |
| `stream?id=` | ✅ | HTTP 200, `Content-Type: audio/mp4`, `Accept-Ranges: bytes` (seek fungerar) |
| `getCoverArt?id=&size=` | ✅ | HTTP 200, `image/jpeg`, size-parameter accepteras |
| `scrobble` | ✅ finns | Endpoint svarar `ok` (testad med ogiltigt id + `submission=false`, inget skrevs). OBS: ogiltiga id ignoreras tyst — förvänta inga fel vid fel-id |
| `getGenres` | ✅ | Se genre-avsnittet — datat är i praktiken värdelöst |
| `getScanStatus` | ✅ | Bonus: `count: 237`, `lastScan`-tidsstämpel |

## Exempel-JSON (kortfattat)

### getPlaylists → `playlists.playlist[]`
```json
{ "id": "E216g9TakgxjEC6j9rdifu", "name": "Lugn morgon", "songCount": 12,
  "duration": 2820, "owner": "simon_b", "coverArt": "pl-...", "changed": "...", "readonly": false }
```

### getPlaylist → `playlist.entry[]` (samma låtobjekt som search3/getRandomSongs)
```json
{ "id": "...", "title": "...", "artist": "...", "artistId": "...",
  "album": "...", "albumId": "...", "year": 2008, "genre": "Music",
  "duration": 144, "bitRate": 128, "suffix": "m4a", "contentType": "audio/mp4",
  "coverArt": "mf-..._...", "size": 2350172, "path": "Artist/Album/fil.m4a",
  "playCount": 4, "comment": "https://www.youtube.com/watch?v=...",
  "genres": [{"name":"Music"}], "artists": [{"id":"...","name":"..."}],
  "musicBrainzId": "", "bpm": 0, "channelCount": 2, "samplingRate": 44100 }
```
OpenSubsonic-extrafält (`artists[]`, `displayArtist`, `moods`, `replayGain`, `isrc` m.fl.) finns alltid men är mestadels tomma.

### getAlbumList2 → `albumList2.album[]`
Innehåller `id`, `name`, `artist`, `artistId`, `songCount`, `duration`, `playCount`, `year`, `coverArt`.

### search3 → `searchResult3.{artist[], album[], song[]}`
Styr mängder med `artistCount`/`albumCount`/`songCount` + offsets.

## Metadata-täckning (hela biblioteket, 237 låtar)

| Fält | Täckning | Anm |
|---|---|---|
| `title`, `artist`, `album`, `albumId`, `artistId` | 237/237 | Pålitliga. MEN 46/237 har album `[Unknown Album]` |
| `duration`, `bitRate`, `size`, `contentType`, `suffix` | 237/237 | Alla m4a, 128 kbit/s |
| `coverArt` | 237/237 | Alla har omslag (YT-thumbnail) |
| `year` | 237/237 | 2007–2026, men är YouTube-uppladdningsår, inte releaseår |
| `genre` | 237/237 ifyllt men **värdelöst** | YouTube-kategorier: "Music" (231), "People & Blogs" (3), "Entertainment" (2), "Education" (1). Kan INTE användas för genre-baserad Discover |
| `playCount` | 17/237 | Växer med användning; grund för `type=frequent` |
| `comment` | ifyllt | Innehåller YouTube-URL — kan användas för käll-länkning |
| `track`, `discNumber`, `bpm`, `musicBrainzId`, `starred`, `userRating` | 0/237 | Saknas helt |

Not: `getGenres` rapporterar högre songCount (327 "Music") än biblioteket har låtar — räknarna verkar inflaterade; lita på `getScanStatus.count` (237) och search3-paginering.

## Vad som SAKNAS — appen måste bygga själv

1. **Ingen Last.fm-integration**: `getTopSongs` och `getSimilarSongs2` returnerar tomt, `getArtistInfo2` ger bara bild-URL:er (ingen biografi, inga liknande artister). **Discover/radio-funktioner kan inte byggas på dessa endpoints.**
2. **Genre-taggar oanvändbara**: allt är YouTube-kategorier ("Music"). Genre-baserade mixar måste bygga på egen logik (t.ex. spellist-tillhörighet, artist-kluster, egen taggning) eller extern API (Last.fm/MusicBrainz från klienten).
3. **Inga stjärnmärkningar ännu**: `getStarred2` fungerar men är tom — appen kan använda `star`/`unstar` (ej testade, skrivande) för att bygga favoriter.
4. **`year` = uppladdningsår**, inte releaseår — "Retro/årtionde"-sektioner blir missvisande.
5. **`track`/`discNumber` saknas** — albumvyer kan inte sorteras på spårnummer (de flesta "album" är ändå singlar; 46 st `[Unknown Album]`).
6. **Rekommendationsersättning**: Quick Picks kan byggas på `getAlbumList2?type=frequent|recent` + `getRandomSongs` + playCount, vilket allt fungerar. Likhets-/radio-funktion måste appen implementera själv (t.ex. samma artist via `search3`/`getArtist`, eller extern likhetsdata).
7. **Scrobble felrapporterar inte**: ogiltiga id ger `status: ok` — appen kan inte lita på svar för leveransbekräftelse.
