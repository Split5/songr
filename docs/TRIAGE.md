# TRIAGE — avverkad 2026-07-27 (kväll)

Sammanställd av fyra parallella granskningar (kodhygien, UX, säkerhet/release,
webb-research) och avverkad av en 12-agents swarm + integration. Commits:
`a095360` perf, `ac5c2d0` ux, `4a746e0` security, `f67629f` release,
`0f450ee` Song Path. 120/120 tester gröna, analyze rent.

## ✅ P1 — alla klara

- ✅ Död tap-yta i _FeaturedHero (spelknappen fungerade inte) — `ac5c2d0`
- ✅ Död nätverksdata (randomSongs/frequentAlbums, 2 anrop/laddning) — `a095360`
- ✅ Sektionsomräkning per låt → debounce 30 s — `a095360`
- ✅ Filter+sort per rebuild → memoizerad — `a095360` (all_songs_screen)
- ✅ Råa tekniska fel → friendlyError() med l10n — `ac5c2d0`
- ✅ Credentials i klartext → flutter_secure_storage + auto-migrering — `4a746e0`
- ✅ Android-ikoner (var Flutter-default) — `f67629f`
- ✅ Splash (var default) — `f67629f`

## ✅ P2 — alla klara

- ✅ Genre-räkning per rebuild → topGenres i _computeSections — `a095360`
- ✅ albums/artists-getters → cachade + albumForSong/artistForSong — `a095360`
- ✅ FavoritesScreen eager → ListView.builder — `a095360`-paketet
- ✅ Bildcache utan gräns → memCacheWidth/Height — `ac5c2d0`
- ✅ prettyTag duplicerad (4 st) → delad helper — `ac5c2d0`
- ✅ _mostCommonCover duplicerad → MixArtwork.mostCommonCover — `ac5c2d0`
- ✅ Gå-till-album/artist duplicerat → provider-helpers — `ac5c2d0`
- ✅ Laddningsspinner bara Hem → libraryLoader på alla flikar — `ac5c2d0`
- ✅ Pull-to-refresh bara Hem → alla flikar — `ac5c2d0`
- ✅ Misslyckad refresh osynlig → SnackBar en gång/fel — `ac5c2d0`
- ✅ Favorit-hjärta tyst → favoriteFailed-text (Snackbar-stöd i common) — `ac5c2d0`
- ✅ Swipe-borttagning utan ångra → Ångra-action (fanns redan implementerad,
  kompletterad med l10n `undo`) — `ac5c2d0`
- ✅ SongTile utan long-press → showSongMenu — `ac5c2d0`
- ✅ Albumdetalj utan shuffle — fanns redan (verifierad) — `ac5c2d0`
- ✅ getStarred2-refetch per toggle → lokal uppdatering — `a095360`
- ✅ Manifest per låt vid bulk → en persist/operation — `a095360`
- ✅ Döda getters (player queue/hasQueue, död ternary) — `a095360`
- ⬜ Automatiskt offline-läge vid nätverksbortfall — ej hunnit, se "Nästa kväll"

## ✅ P3 — klara delar

- ✅ Tooltips spelarkontroller + miniplayer — `ac5c2d0`
- ✅ Spellist-tomvyn utan CTA → hint-text — `ac5c2d0`
- ⬜ pubspec description ("A new Flutter project") — kvar, litet
- ⬜ Tomma tillstånd med kontextuell CTA (sökfilter) — delvis (spellist-hint gjord)
- ⬜ flutter pub upgrade — kör före nästa release-bygge

## ✅ AI-feature — Song Path levererad

`0f450ee`: /api/find_path-integration ("resa mellan två låtar"), egen vy med
start/slut-väljare, spelbar + sparbar lista, 4 tester. Ingång via
stämningssökens appbar. (Song Alchemy valdes bort denna kväll — Song Path var
unik och billigare; Alchemy nästa etapp.)

## 📌 Dokumenterat — inte ikväll (kräver beslut/mer tid)

- **ATS** — löst med `NSAllowsLocalNetworking` och privata IP-intervall.
- **Sanitering före publik publicering** — docs innehåller personuppgifter;
  repot förblir privat på Forgejo. Vid publik push: squash/filter-repo.
- **App-namn** — löst: Söngr på svenska och Soengr internationellt.
- **Privacy policy-URL** — publicerad på `https://simonbystrom.se/privacy/`.
- **macOS keychain-entitlements** — flutter_secure_storage kräver Keychain
  Sharing på macOS om det blir release-mål (iOS fungerar utan).
- **Filer >500 rader** — ingen refaktor ikväll.

## Nästa kväll (förslag)

1. Automatiskt offline-läge vid nätverksbortfall (connectivity_plus + flagga)
2. Song Alchemy (blanda artister/låtar → mix, /api/alchemy)
3. Pre-caching av kommande kölåtar (gapless offline)
4. pubspec description + pub upgrade + privacy policy-sida
5. Nedladdningskvalitet (maxBitRate på download — serverstöd finns)
