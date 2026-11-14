# APPSTORE — vägen till App Store och TestFlight

Status 2026-10-26. Detta dokument beskriver vad som är klart, vad som återstår
och exakt vilka steg som kräver **användarens eget Apple-konto** (agenterna
loggar aldrig in på användarens konton).

## Klart för releasegranskning

- Appikon utan alpha i fullt iOS- och Android-set, plus matchande launch screen.
- Systemstyrd engelska/svenska i appen och i lokaliserade systemtexter.
- Förklarande iOS-text för åtkomst till lokalnätverket.
- `PrivacyInfo.xcprivacy`: ingen spårning och inga deklarerade datakategorier.
- Supportmejl, inbyggt felrapporteringsblad och integritetspolicy i
  Inställningar.
- Dynamisk serverchecklista för fjärråtkomst, smarta mixar, låttexter och HTTPS.
- Kärnspelaren fungerar utan valfria Navidrome-plugins; endast beroende funktioner
  inaktiveras.
- Publika sidor: `https://simonbystrom.se`, `/soengr/` och `/privacy/`.
- Support: `support@simonbystrom.se`. Integritet: `privacy@simonbystrom.se`.

## Redan klart

- Bundle ID `se.simonbystrom.navimusic`, display-namn "Söngr" på svenska och
  "Soengr" internationellt,
  `CFBundleLocalizations` (sv/en), l10n via ARB.
- Repo saniterat för publicering: engelsk README, ingen default-server-URL,
  inga hemligheter i historiken.
- Release-bygge för enhet fungerar (free Personal Team `LVV8VBC259`,
  7-dagars provisioning) — men se "Kända hinder" om SSH/keychain.
- CarPlay tier 1 (låsskärmskontroller via audio_service). "Riktig" CarPlay-app
  kräver egen entitlement från Apple — ansöks separat, lång handläggning.

## Apple-konto och App Store-post

1. **Apple Developer Program** är aktivt för `simon_b@live.se`.
2. **App Store Connect-posten** är skapad som "Söngr",
   Apple ID `6827109298`, SKU `SONGR001`, kategori Musik.
3. **Integritets-URL** är sparad. Själva integritetsformuläret väntar på
   ägarens svar om datainsamling.
4. **Age rating, Content Rights, pris, DSA och App Review-kontakt** kräver
   ägarens svar eller uppgifter.

## Teknisk checklista innan första archive (agenternas ansvar)

- [x] **App-ikoner** — iPod-inspirerad master utan alpha och genererade set.
- [x] **Launch screen** — identitetsmatchande splash på alla byggda plattformar.
- [x] **Version/build-nummer** i `pubspec.yaml` (`version: 1.0.0+3`).
- [x] Support-, inbyggt felrapporteringsblad och integritetsväg i appen.
- [x] Integritetsmanifest och lokalnätverksbeskrivning på svenska och engelska.
- [x] `flutter build ipa` med molnhanterat Apple Distribution-certifikat.
- [x] Nio svenska App Store-skärmbilder från ägarens riktiga iPhone-bibliotek.
- [x] Skapa appposten i App Store Connect med Apple ID `6827109298`.
- [x] Engelsk butikstext och namnet Soengr för `English (U.S.)`.
- [x] ASO-version av titel, underrubrik, nyckelord och beskrivning.
- [x] Skärmbilder med demonstrationsdata utan serveradress, konto, personliga
      spellistor, lyssningshistorik eller verkliga låttexter.
- [x] `tool/verify_release_privacy.sh` kontrollerar IPA-filen före uppladdning.
- [x] Underlag för App Review och återstående butiksval finns i
      `appstore/app-review-notes.md` och `appstore/asc-decisions.md`.
- [x] Ladda upp build `1.0.0 (3)` och verifiera i App Store Connect.
- [ ] Slutför integritet, åldersklassning, rättigheter, pris och DSA.
- [x] Fyll i App Review-kontakt och ett separat konto med 13 kända album
      från 13 olika artister.
- [x] Publikt appnamn valt: Söngr, internationellt Soengr.

Första uppladdningen stoppades av Apple med felkod `90035`. Den exporterade
IPA-filen använder det molnhanterade distributionscertifikatet, men det finns
ingen lokal Apple Distribution-identitet i inloggningsnyckelringen. Skapa en
lokal identitet i Xcode och exportera om innan nästa uppladdning.

## App Review-notering

Appen är en klient för en Navidrome-server som användaren själv anger och
driver. Det finns inget konto hos utvecklaren, ingen extern musikkatalog och
ingen reklam. App Review använder ett separat konto med 13 kända album från
olika artister.
HTTP tillåts endast för privata nätverksadresser; publika adresser måste
använda HTTPS. ATS är begränsat till lokala nätverk och privata IP-intervall.
Lokalnätverksåtkomst används bara för att nå användarens valda server.

## Kvar för användaren

- Bekräfta integritetsdeklarationen och rättigheterna till innehållet.
- Välj pris, länder, åldersklassning, DSA-status och release-metod.
- Fyll i App Review-kontakt och ett tillfälligt Navidrome-testkonto.
- Eventuell juridisk granskning av integritetspolicy och supportvillkor.

Donationssidan är tillfälligt dold i appen via
`V2SupportLinks.supportPageVisible = false`. Den ska förbli dold till ägaren
har kontrollerat att donationer inte påverkar ersättning eller bidrag.

Refund-länken är också tillfälligt dold via
`V2SupportLinks.refundLinkVisible = false`.

## Kända hinder just nu

- **Codesign via SSH misslyckas** (`errSecInternalComponent`): MacBookens
  login-nyckelring är låst för SSH-sessioner. Bygg för enhet måste antingen
  köras i en GUI-session på MacBooken, eller så låser användaren upp
  nyckelringen först (`security unlock-keychain` i en egen terminal).
  Analyze/test/bygge utan signering (`--no-codesign`) fungerar fint över SSH.
- 7-dagars free provisioning: appen på telefonen slutar starta efter 7 dagar
  tills den installeras om (eller tills betalt team aktiverats).
