# INSTALL — Så sätter du upp Navidrome-backendn för navimusic

Guide för att återskapa servermiljön bakom navimusic från grunden på en ny
maskin. Alla detaljer är hämtade från den verkliga installationen, inte
generiska rekommendationer. Sökvägar som `/home/siby/Documents/Claude/navidrome`
och `/mnt/HDD1/jellyfin/Music` är maskinspecifika — **anpassa dem** till din
egen miljö, men behåll strukturen.

Relaterade dokument (läs dem istället för att upprepa här):
- `docs/API_CAPABILITIES.md` — empiriskt verifierad Subsonic API-kapacitet.
- `docs/HANDOVER.md` — aktuell driftstatus.
- `../navidrome/scripts/*_HANDOVER.md` — backend-handovers på servermaskinen.

Förutsättningar: Docker + docker compose, en musikkatalog (i vår installation
samma bibliotek som Lidarr hanterar), samt ett externt docker-nätverk `proxy`
(Valfritt — används för att en reverse proxy ska nå containrarna via namn;
skapa med `docker network create proxy` eller ta bort `networks:`-blocken).

---

## 1. Navidrome i Docker (grundinstallation)

Compose-fil: `/home/siby/Documents/Claude/navidrome/docker-compose.yml`.

Nyckelbeslut i den verkliga filen:

- **Image:** `deluan/navidrome:latest` (projektets egen image; det finns ingen
  lscr.io-variant). Plugin-stöd kräver Navidrome **0.61.0+** — vår server kör
  0.63.2. Kör inte en äldre pinnad version.
- **Musikvolymen monteras read-only:** `/mnt/HDD1/jellyfin/Music:/music:ro`.
  Navidrome läser/scannar/streamar bara — den skriver aldrig till biblioteket.
- **Databas/cache i bind-mount** `./data:/data` i projektmappen (måste vara
  skrivbar; ägs av `user: "1000:1000"`).
- **Port:** `4533:4533` (Navidromes standardport). Nås lokalt via
  `http://<host>:4533`.
- **Tidszon — viktig fälla:** Alpine-imagen saknar tzdata helt. Utan
  bind-mountarna nedan ignoreras `TZ` och allt faller tillbaka på UTC, vilket
  fick mood-playlists-pluginets cron-scheman att missa helt. Behåll dem:
  ```yaml
  - /usr/share/zoneinfo:/usr/share/zoneinfo:ro
  - /usr/share/zoneinfo/Europe/Stockholm:/etc/localtime:ro
  ```
- `ND_SCANINTERVAL=1h`, `ND_LOGLEVEL=info`.

Minimerad start (utan plugins/Last.fm än så länge):

```yaml
services:
  navidrome:
    image: deluan/navidrome:latest
    container_name: navidrome
    user: "1000:1000"
    ports:
      - '4533:4533'
    environment:
      - ND_MUSICFOLDER=/music
      - ND_DATAFOLDER=/data
      - ND_SCANINTERVAL=1h
      - ND_LOGLEVEL=info
      - TZ=Europe/Stockholm
    volumes:
      - ./data:/data
      - /mnt/HDD1/jellyfin/Music:/music:ro      # anpassa: din musikkatalog
      - /usr/share/zoneinfo:/usr/share/zoneinfo:ro
      - /usr/share/zoneinfo/Europe/Stockholm:/etc/localtime:ro
    restart: unless-stopped
```

Starta: `docker compose up -d`. Skapa admin-användare via webb-UI:t på
`:4533` och vänta ut första skanningen (se avsnitt 6 för `getScanStatus`).

---

## 2. Plugin-stöd

Två miljövariabler aktiverar plugin-systemet:

```yaml
- ND_PLUGINS_ENABLED=true
- ND_PLUGINS_FOLDER=/data/plugins
```

`.ndp`-filerna (zip-paket med `plugin.wasm` + `manifest.json`) läggs direkt i
`./data/plugins/` på värden — alltså `/data/plugins/` i containern. Navidrome
skapar själv en underkatalog per plugin (t.ex. `plugins/apple-music/`) för
dess KVStore-databaser — rör inte dem.

Verkligt innehåll i vår plugins-mapp:

```
apple-music.ndp      audiomuseai.ndp      nd-lyrics.ndp      mood-playlists/
```

**Verifiera laddning** i loggarna efter omstart:

```bash
docker logs navidrome 2>&1 | grep "Loaded plugin"
```

Förväntat (med samtliga plugins installerade):

```
Loaded plugin ... manifest="Apple Music Metadata Agent" plugin=apple-music
Loaded plugin ... manifest="AudioMuse-AI Instant Mix"   plugin=audiomuseai
Loaded plugin ... manifest=Lyrics                       plugin=nd-lyrics
Loaded plugin ... capabilities=[...Scheduler...]        plugin=mood-playlists
```

Saknas en rad är `.ndp`-filen felplacerad eller korrupt — Navidrome loggar
felet vid uppstart. Godkänn därefter varje plugins permissions under
**Settings → Plugins** i webb-UI:t (de är inaktiva tills dess).

---

## 3. De fyra pluginsen

Agent-prioriteten i vår compose är medveten och ska behållas:

```yaml
- ND_AGENTS=audiomuseai,deezer,lastfm,listenbrainz,apple-music
```

Navidrome använder **första agenten som stödjer sonic similarity** för
Instant Mix (därför audiomuseai först); resten bidrar med bio/bilder.

### 3.1 audiomuseai — klusterspellistor + sonic Instant Mix

- **Källa:** del av AudioMuse-AI-projektet (`ghcr.io/neptunehub/audiomuse-ai`,
  GitHub: NeptuneHub/AudioMuse-AI). Vårt `audiomuseai.ndp` är v9.0.0.
- **Vad appen får:** klusterspellistor med suffix `_automatic`
  (t.ex. "Rock Celebration_automatic") som klienten matchar via
  `isMoodPlaylist`, samt förbättrad `getSimilarSongs2` (sonic similarity).
- **Viktig arkitekturregel:** AudioMuse-AI är en **egen docker-stack**
  (compose: `/home/siby/Documents/Claude/navidrome/audiomuse-ai/docker-compose.yaml`)
  bestående av:
  - `audiomuse-ai-flask-app` (UI + API, host-port **8000**),
  - **12 workers** (`docker compose up -d --scale audiomuse-ai-worker=12` —
    analysen är CPU-bunden och enkeltrådad per låt, så parallella workers ger
    nästan linjär hastighetsökning; 4 av 16 kärnor lämnas fria),
  - `audiomuse-redis` (task queue, 6379) och `audiomuse-postgres` (5432).
  - `.env` i samma mapp: `TZ`, `POSTGRES_USER/PASSWORD`,
    `NAVIDROME_URL/USER/PASSWORD` (kopiera `env.example`).
- **Appen pratar ALDRIG direkt med AudioMuse-API:t.** Integrationen sker
  uteslutande via Navidrome: i AudioMuse-UI:t (`http://<host>:8000`) körs
  analys mot Navidrome och därefter **"Fetch Playlists"**, som skapar
  vanliga Navidrome-spellistor med suffix `_automatic`. Appen läser dem via
  `getPlaylists` som vilka spellistor som helst.
- **Konfiguration:** Settings → Plugins → AudioMuse-AI Instant Mix:
  `apiUrl` (t.ex. `http://audiomuse-ai-flask-app:8000` — båda ligger på
  `proxy`-nätverket, annars `http://<host>:8000`), `apiToken` (se nedan),
  och `server` = `Navidrome` vid multi-server-setup.
- **API-token är obligatoriskt i v9:** AudioMuse-AI:s API kräver Bearer-auth
  (`API_TOKEN` i flask-containerns miljö — utan den svarar API:t 401 på allt,
  även pluginets anrop; Navidrome loggar då `[AudioMuse] ERROR: ... 401`).
  1. Generera ett token (`openssl rand -hex 24`) och lägg `API_TOKEN=<token>`
     i AudioMuse-stackens `.env`.
  2. Lista variabeln i flask-tjänstens `environment:`-block i
     `docker-compose.yaml` (`API_TOKEN: "${API_TOKEN}"`) — blocket är
     explicit, `.env` räcker inte ensamt.
  3. `docker compose up -d --force-recreate audiomuse-ai-flask`
     (vanlig `up -d` återanvänder containern och missar nya variabler).
  4. Klistra in samma token som `apiToken` i pluginets inställningar.
  Verifiera: `curl -H "Authorization: Bearer <token>"
  http://<host>:8000/api/config` ska ge 200, inte 401.

### 3.2 mood-playlists — 13 stämningsspellistor via ljudanalys

- **Källa:** `craiglush/navidrome-mood-plugin` (v0.3.0),
  https://github.com/craiglush/navidrome-mood-plugin — `.ndp` från Releases
  eller byggd från källan. Vår klon: `.../navidrome/mood-analyzer/repo/`.
- **Vad appen får:** 13 färdiga spellistor (Happy, Chill, Energetic,
  Melancholy, Party, Aggressive + Study, Workout, Sleep, Road Trip, Cooking,
  Dining, Background) som dyker upp som vanliga spellistor, samt
  mood-baserad Instant Mix.
- **Kräver extern analyzer-tjänst** — essentia kan inte köras i WASM.
  Compose: `/home/siby/Documents/Claude/navidrome/mood-analyzer/docker-compose.yml`
  bygger `./repo/analyzer-service` (FastAPI + `essentia-tensorflow`,
  Discogs-EffNet-modeller laddas ner i Docker-builden, image ~500 MB).
  Resursgränser i vår installation: **8 CPU-kärnor / 8 GB RAM** (halva
  maskinen) — det kapade analystiden från ~17 s/låt till ~7 s/låt. Musikvolymen
  monteras `:ro`, samma sökväg `/music` som Navidrome ser (analyzer-pluginet
  skickar filsökvägar, tjänsten måste se identiska paths).
- **Installation:**
  1. `cd mood-analyzer && docker compose up -d --build`
  2. Kopiera `repo/mood-playlists.ndp` till Navidromes `./data/plugins/`
     och starta om Navidrome.
  3. Settings → Plugins → Mood Playlists: godkänn permissions, sätt
     **Analyzer Service URL** till `http://mood-analyzer:8000` (samma
     docker-nät) eller `http://<host>:8000`.
- **Scheman (default, cron):** analys av nya låtar **varje natt 02:00**
  (`0 2 * * *`), spellist-rebuild **söndagar 03:00** (`0 3 * * 0`). 30
  låtar/spellista. Tröskelvärden (happy 0.55, energetic 0.6, melancholy
  0.45 m.fl.) justeras i samma UI. Obs: tiderna kräver fungerande TZ —
  se zoneinfo-varningen i avsnitt 1.
- **Poängen lagras i pluginets KVStore** (Navidromes interna databas), aldrig
  i filernas taggar — därför kan Lidarrs retag aldrig störa dem.

### 3.3 apple-music — artistmetadata som komplement

- **Källa:** officiell `navidrome/apple-music-plugin` (v0.2.0),
  https://github.com/navidrome/apple-music-plugin.
- **Vad appen får:** riktiga artistbiografier, bilder, liknande artister och
  topplåtar via `getArtistInfo2`/`getTopSongs` — som **fallback efter**
  Deezer/Last.fm/ListenBrainz (därför sist i `ND_AGENTS`). Rent läsande,
  rör aldrig biblioteket.
- **Installation:** lägg `apple-music.ndp` i `./data/plugins/`, starta om,
  godkänn permissions. Ingen egen konfiguration krävs.

### 3.4 nd-lyrics — låttexter

- **Källa:** `J0R6IT0/navidrome-lyrics-plugin` (v7.1.0),
  https://github.com/J0R6IT0/navidrome-lyrics-plugin.
- **Vad appen får:** låttexter från flera källor via Subsonic-API:t.
- **Konfiguration** i compose (prioritet: inbäddade taggar först, pluginet
  som fallback):
  ```yaml
  - ND_LYRICSPRIORITY=embedded,nd-lyrics
  ```
- **Installation:** `nd-lyrics.ndp` i `./data/plugins/`, omstart, godkänn.

---

## 4. Last.fm API-nyckel

Skapa ett API-konto på https://www.last.fm/api/account/create → du får
API key + shared secret. Sätt i compose:

```yaml
- ND_LASTFM_APIKEY=<din-nyckel>
- ND_LASTFM_SECRET=<din-secret>
```

**Vad det ger:** utan nyckel svarar `getSimilarSongs2` och `getTopSongs`
tomt och `getArtistInfo2` ger bara bild-URL:er (verifierat i
`docs/API_CAPABILITIES.md`). Med nyckel fylls liknande låtar/artister,
topplåtar och biografier via Last.fm-agenten. Committa aldrig nyckeln —
håll den utanför repot (vår `.env`-disciplin, se `AGENTS.md`).

---

## 5. Genre-taxonomin — skriv inte egna genre-värden

`genre`-fältet är en **ren stiltaxonomi som Lidarr äger**. Lidarrs
`RetagArtist`-kommando skriver MusicBrainz-genrer (i vår installation ~215
distinkta värden: Pop, Alternative Rock, Synth-Pop, Trap, Contemporary R&B,
...) och **ersätter HELA fältet vid varje körning**. Allt du skriver in
manuellt — t.ex. stämningsord — försvinner igen. Som sidoeffekt städas
skrapvärden från gamla nedladdningar ("Music", "People & Blogs") bort.

Konsekvenser:

- Använd `genre` för **stil**-mixar (Pop-mix, Rock-mix), aldrig för stämning.
- Stämning hanteras av det separata systemet i avsnitt 3.2 (mood-poäng i
  KVStore + färdiga spellistor + `getSimilarSongs2`) — just eftersom det
  inte kan krocka med Lidarr.
- Bakgrund: `../navidrome/scripts/MOOD_ARCHITECTURE_HANDOVER.md` och
  `TAG_WEIGHT_HANDOVER.md` (Last.fm-taggning nådde bara 4,5 % av biblioteket
  — därför lokal ljudanalys istället).

---

## 6. Verifiering innan appen kopplas in

Alla anrop mot Subsonic API v1.16.1 med token-auth och `f=json`.
Generera token så här (u = användarnamn, t = md5(lösenord+salt), s = salt):

```bash
BASE="http://192.168.0.252:4533/rest"   # anpassa: <host>:4533
USER="<användarnamn>"; PASS="<lösenord>"
SALT=$(head -c 6 /dev/urandom | od -An -tx1 | tr -d ' \n')
TOKEN=$(printf '%s' "${PASS}${SALT}" | md5sum | cut -d' ' -f1)
AUTH="u=${USER}&t=${TOKEN}&s=${SALT}&v=1.16.1&c=installcheck&f=json"
```

**1. Servern lever och auth fungerar:**

```bash
curl -s "${BASE}/ping?${AUTH}"
# {"subsonic-response":{"status":"ok","version":"1.16.1",
#  "type":"navidrome","serverVersion":"0.63.2","openSubsonic":true}}
```

**2. Plugins laddade** — se `docker logs`-kommandot i avsnitt 2.

**3. AudioMuse-klusterspellistor finns:**

```bash
curl -s "${BASE}/getPlaylists?${AUTH}" | grep -o '"name":"[^"]*_automatic"' | wc -l
# Förväntat: 10 i vår installation (efter att "Fetch Playlists" körts i AudioMuse)
```

**4. Skanning klar / biblioteksstorlek:**

```bash
curl -s "${BASE}/getScanStatus?${AUTH}"
# {"scanStatus":{"scanning":false,"count":4222,...}} — ~4100+ låtar hos oss
```

**5. Last.fm kopplat:**

```bash
curl -s "${BASE}/getTopSongs?${AUTH}&artist=<känd artist i ditt bibliotek>"
# Ska returnera topSongs med entries — tomt objekt = Last.fm-nyckel saknas/fel
```

När alla fem är gröna kan appen pekas mot servern (inställningar i appen:
server-URL + användarnamn/lösenord; appen sköter token-auth själv).

---

## 7. Felsökning (kort)

- **Databaser på exFAT fungerar inte.** Navidromes/AudioMuses SQLite-databaser
  måste ligga på ext4 (eller motsvarande POSIX-filsystem) — på exFAT kraschar
  containrarna redan vid `chown`/permissions. Lägg aldrig `./data` eller
  docker-volymerna på en exFAT-disk.
- **Mood-spellistor saknas initialt — det är normalt.** Första fulla
  ljudanalysen tar **~8 h för ~4100 låtar** (med 8 kärnor/8 GB till analyzer)
  och körs schemalagt 02:00. De 13 spellistorna byggs dessutom först vid
  nästa söndagsrebuild 03:00. Räkna med dagar, inte minuter, innan de syns.
- **Cloudflare 1010 via publik URL.** Når du servern genom Cloudflare-proxy
  (hos oss `https://musik.simonbystrom.se`) kan API-klienter blockeras med
  HTTP 1010 (Cloudflares browser-signaturkontroll) — webbläsare går igenom,
  API-anrop inte. Använd LAN-IP:n (`http://192.168.0.252:4533`) för
  API-klienter, eller justera Cloudflare-reglerna för API-sökvägen.
- **Portkollision 8000.** Både mood-analyzerns compose och AudioMuse-AI:s
  Flask-app publicerar host-port 8000. Kör du båda på samma maskin: mappa om
  mood-analyzerns host-port (t.ex. `8001:8000`) eller skippa
  `ports:`-mappningen helt — pluginet når tjänsten via containernamnet
  `http://mood-analyzer:8000` på det delade `proxy`-nätverket, så host-porten
  behövs bara för felsökning.
- **AudioMuse-pluginet loggar 401.** `[AudioMuse] ERROR: AudioMuse-AI
  returned status 401` i Navidromes logg = pluginets `apiUrl`/`apiToken`
  matchar inte AudioMuse-stacken — kontrollera inställningarna under
  Settings → Plugins.
- **Analyzer 404:ar alla låtar ("File not found").** Subsonic-API:ts
  `path`-fält är syntetiskt (byggs från taggar, inte filsystemet) —
  pluginet skickar alltså aldrig riktiga sökvägar. Vår patch
  (`resolve_path()` i `analyzer-service/app.py` + navidrome.db monterad
  read-only som `/navidrome-db`) löser upp det automatiskt; behåll
  volymen `../data:/navidrome-db:ro` i compose.
- **Analysen stannar efter ~7 låtar per körning.** Navidromes
  plugin-scheduler har 30 s deadline per callback. Sätt
  `analyze_schedule` till `*/2 * * * *` under första bulk-fasen
  (~30 h för ~4200 låtar) och återställ till `0 2 * * *` när kvstore
  närmar sig biblioteksstorleken.
- **Cron tyst utebliven?** Kontrollera tidszonen i containern
  (`docker exec navidrome date`). Är den UTC trots `TZ` saknas
  zoneinfo-bind-mountarna från avsnitt 1.
