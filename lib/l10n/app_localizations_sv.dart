// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get appTitle => 'Söngr';

  @override
  String get navHome => 'Hem';

  @override
  String get navNew => 'Nytt';

  @override
  String get navRadio => 'Radio';

  @override
  String get navLibrary => 'Bibliotek';

  @override
  String get navArtists => 'Artister';

  @override
  String get navAlbums => 'Album';

  @override
  String get navPlaylists => 'Spellistor';

  @override
  String get navFavorites => 'Favoriter';

  @override
  String get tooltipSearch => 'Sök';

  @override
  String get tooltipSettings => 'Inställningar';

  @override
  String get dataSaver => 'Dataspar-läge';

  @override
  String get dataSaverSubtitle =>
      'Strömma allt över mp3-kvalitet i mp3-kvalitet istället';

  @override
  String get sectionRecentlyAdded => 'Senast tillagda';

  @override
  String get sectionRecentlyPlayedSongs => 'Senast spelade låtar';

  @override
  String get sectionRecentlyAddedSongs => 'Nyligen tillagda låtar';

  @override
  String get sectionMostPlayedSongs => 'Mest spelade låtar';

  @override
  String get homeRefreshingAlbums => 'Hämtar nya album…';

  @override
  String get homeEmptyHint =>
      'Synka ditt Navidrome-bibliotek för att börja lyssna offline.';

  @override
  String get navSongs => 'Låtar';

  @override
  String get sectionMostPlayedAlbums => 'Mest spelade album';

  @override
  String get sectionRecentlyPlayedAlbums => 'Senast spelade album';

  @override
  String get sectionRecentlyAddedAlbums => 'Nyligen tillagda album';

  @override
  String get sectionFromLibrary => 'Ur ditt bibliotek';

  @override
  String get refreshSelection => 'Nytt urval';

  @override
  String get homeCustomizationTitle => 'Anpassa Hem';

  @override
  String get homeCustomizationSubtitle =>
      'Innehåll, ordning och synlighet per karusell';

  @override
  String get homeHeaderStyleTitle => 'Visa logotyp';

  @override
  String get homeHeaderStyleSubtitle =>
      'Använd logotypen i stället för Soengr högst upp på Hem';

  @override
  String get appearanceSettingsTitle => 'Utseende';

  @override
  String get appearanceSettingsSubtitle =>
      'Genomskinlighet och oskärpa för den övre baren';

  @override
  String get topBarTransparencyTitle => 'Övre baren';

  @override
  String get transparencySettingTitle => 'Genomskinlighet';

  @override
  String get transparencySettingHelp =>
      '0 % ger en mörk yta. 100 % släpper igenom allt bakom.';

  @override
  String get blurSettingTitle => 'Oskärpa';

  @override
  String get blurSettingHelp =>
      '0 ger en helt skarp bakgrund. Högre värden suddar den mer.';

  @override
  String get homeCarouselContentTitle => 'Innehåll per karusell';

  @override
  String get homeCarouselContentHelp =>
      'Välj Låtar eller Album separat för varje hylla. Ordning och synlighet justeras i samma lista.';

  @override
  String get homeFocusSongs => 'Låtar';

  @override
  String get homeFocusAlbums => 'Album';

  @override
  String get homeSectionsTitle => 'Hyllor och ordning';

  @override
  String get homeSectionsHelp =>
      'Visa eller dölj hyllor och dra handtaget för att ändra ordningen. Minst en hylla måste vara synlig.';

  @override
  String get homeSectionRecentlyPlayed => 'Senast spelade';

  @override
  String get homeSectionRecentlyAdded => 'Nyligen tillagda';

  @override
  String get homeSectionMostPlayed => 'Mest spelade';

  @override
  String get recommendationsSettingsTitle => 'Algoritm';

  @override
  String get recommendationsSettingsSubtitle =>
      'Smarta funktioner som styrs av Navidrome och dess plugins';

  @override
  String get recommendationVariationTitle => 'Variation';

  @override
  String get recommendationVariationHelp =>
      'Ett lågt värde håller sig nära utgångslåten. Ett högre värde utforskar djupare bland förslag som fortfarande är besläktade.';

  @override
  String get recommendationArtistVarietyTitle => 'Artistvariation';

  @override
  String get recommendationArtistVarietyHelp =>
      'Begränsar hur många låtar från samma huvudartist som får hamna i varje kandidatbatch.';

  @override
  String recommendationSongsPerArtist(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count låtar per artist',
      one: '1 låt per artist',
    );
    return '$_temp0';
  }

  @override
  String get recommendationInitialQueueTitle => 'Startköns storlek';

  @override
  String get recommendationInitialQueueHelp =>
      'Antal liknande låtar som hämtas när du väljer en ensam låt. AutoPlay fortsätter sedan att fylla på fem åt gången.';

  @override
  String get filters => 'Filter';

  @override
  String get filterQuality => 'Kvalitet';

  @override
  String get filterFormat => 'Format';

  @override
  String get filterGenre => 'Genre';

  @override
  String get filterFavorites => 'Endast favoriter';

  @override
  String get qualityLossless => 'Lossless';

  @override
  String get qualityAny => 'Alla';

  @override
  String get qualityLossy => 'Komprimerat';

  @override
  String get qualityHiRes => 'Hi-Res';

  @override
  String get sortBy => 'Sortera';

  @override
  String get sortTitle => 'Titel';

  @override
  String get sortArtist => 'Artist';

  @override
  String get sortAlbum => 'Album';

  @override
  String get sortYear => 'År';

  @override
  String get sortRecent => 'Senast tillagda';

  @override
  String get sortRecentlyPlayed => 'Senast spelade';

  @override
  String get sortRandom => 'Slumpat';

  @override
  String get sortDuration => 'Längst först';

  @override
  String get sortBitRate => 'Högst bitrate';

  @override
  String get sortPlays => 'Mest spelade';

  @override
  String get shufflingSongs => 'Blandar låtar…';

  @override
  String get sortAlbumCount => 'Flest album';

  @override
  String get clearFilters => 'Rensa filter';

  @override
  String get findSongs => 'Hitta låtar';

  @override
  String get applyFilters => 'Tillämpa';

  @override
  String get resetFilters => 'Återställ';

  @override
  String get close => 'Stäng';

  @override
  String get songsSearchHint => 'Sök låtar, artister eller album…';

  @override
  String get filterYear => 'År';

  @override
  String get filterDurationMinutes => 'Längd (minuter)';

  @override
  String get filterBitRateKbps => 'Bitrate (kbps)';

  @override
  String get filterMinimum => 'Från';

  @override
  String get filterMaximum => 'Till';

  @override
  String get filterGenreHint => 'Pop, rock, jazz…';

  @override
  String get noFilteredSongs => 'Inga låtar matchar filtren.';

  @override
  String get noFilteredSongsHint => 'Prova att ta bort ett eller flera filter.';

  @override
  String get loadingMoreFailed => 'Kunde inte läsa in fler låtar.';

  @override
  String get done => 'Klar';

  @override
  String get showMore => 'Visa mer';

  @override
  String get showMoreHint => 'Dra för att öppna';

  @override
  String couldNotLoadLibrary(String error) {
    return 'Kunde inte ladda biblioteket:\n$error';
  }

  @override
  String get tryAgain => 'Försök igen';

  @override
  String get noPlaylists => 'Inga spellistor.';

  @override
  String get noResults => 'Inga träffar.';

  @override
  String get nothingToShowYet => 'Inget att visa ännu.';

  @override
  String get noSongPlaying => 'Ingen låt spelas.';

  @override
  String get queueEmpty => 'Kön är tom.';

  @override
  String get autoplay => 'Autoplay';

  @override
  String get autoplaySubtitle => 'Lägg till liknande låtar i slutet av kön';

  @override
  String get songsHeader => 'Låtar';

  @override
  String songsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count låtar',
      one: '1 låt',
    );
    return '$_temp0';
  }

  @override
  String albumsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count album',
      one: '1 album',
    );
    return '$_temp0';
  }

  @override
  String artistsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artister',
      one: '1 artist',
    );
    return '$_temp0';
  }

  @override
  String playlistsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spellistor',
      one: '1 spellista',
    );
    return '$_temp0';
  }

  @override
  String get play => 'Spela';

  @override
  String get pause => 'Pausa';

  @override
  String get nextTrack => 'Nästa låt';

  @override
  String get previousTrack => 'Föregående låt';

  @override
  String get favorite => 'Favorit';

  @override
  String get removeFavorite => 'Ta bort favorit';

  @override
  String get nowPlaying => 'Spelas nu';

  @override
  String get queue => 'Kö';

  @override
  String get playlistName => 'Namn';

  @override
  String get save => 'Spara';

  @override
  String get cancel => 'Avbryt';

  @override
  String playlistSaveFailed(String error) {
    return 'Kunde inte spara: $error';
  }

  @override
  String get deletePlaylist => 'Ta bort spellista';

  @override
  String get renamePlaylist => 'Byt namn på spellista';

  @override
  String deletePlaylistConfirm(String name) {
    return 'Ta bort spellistan ”$name”?';
  }

  @override
  String get delete => 'Ta bort';

  @override
  String get addToPlaylist => 'Lägg till i spellista';

  @override
  String get removeFromPlaylistAction => 'Ta bort från spellistan';

  @override
  String addedToPlaylist(String name) {
    return 'Tillagd i ”$name”';
  }

  @override
  String addToNamedPlaylist(String name) {
    return 'Lägg till i ”$name”';
  }

  @override
  String get lastUsedPlaylist => 'Senast använda spellista';

  @override
  String get playlistSuggestions => 'Förslag till spellistan';

  @override
  String get playlistSuggestionsSubtitle =>
      'Utifrån låtarna som redan finns i den';

  @override
  String get similarSuggestionsEmpty => 'Inga nya förslag just nu.';

  @override
  String get similarSuggestionsError => 'Kunde inte hämta förslag just nu.';

  @override
  String get favoriteMix => 'Favoritmix';

  @override
  String get moveFavoritesToPlaylist => 'Flytta favoritlåtar till spellista';

  @override
  String get moveFavoritesToPlaylistTitle =>
      'Flytta favoritlåtar till en spellista?';

  @override
  String get moveFavoritesToPlaylistBody =>
      'Alla favoritlåtar läggs i en ny spellista. Favoritalbum och favoritartister tas bort från Favoriter och kan inte återställas.';

  @override
  String get moveFavoritesToPlaylistConfirm => 'Flytta';

  @override
  String favoritesToPlaylistName(String date) {
    return 'Favoriter $date';
  }

  @override
  String favoritesMovedToPlaylist(String name) {
    return 'Flyttade favoritlåtarna till $name';
  }

  @override
  String favoritesMovedPartially(String name) {
    return 'Flyttade favoritlåtarna till $name, men kunde inte ta bort alla favoritmarkeringar.';
  }

  @override
  String get noFavoritesToMove => 'Inga favoriter att flytta.';

  @override
  String get newPlaylist => 'Ny spellista…';

  @override
  String get createMixFromSong => 'Skapa mix från låt';

  @override
  String get navidromeSimilarSongs => 'Navidrome • liknande låtar';

  @override
  String get playNext => 'Spela härnäst';

  @override
  String get addToQueue => 'Lägg till i kön';

  @override
  String get goToAlbum => 'Gå till album';

  @override
  String get goToArtist => 'Gå till artist';

  @override
  String get share => 'Dela';

  @override
  String get repeat => 'Repeat';

  @override
  String get shuffle => 'Shuffle';

  @override
  String get searchHint => 'Sök artister, album, låtar…';

  @override
  String searchError(String error) {
    return 'Fel: $error';
  }

  @override
  String get settingsTitle => 'Serverinställningar';

  @override
  String get connectToServer => 'Anslut till din Navidrome-server';

  @override
  String get serverUrl => 'Server-URL';

  @override
  String get username => 'Användarnamn';

  @override
  String get password => 'Lösenord';

  @override
  String get connectAndSave => 'Anslut och spara';

  @override
  String couldNotConnect(String error) {
    return 'Kunde inte ansluta: $error';
  }

  @override
  String get offlineSectionTitle => 'Offline';

  @override
  String get offlineStorageCap => 'Lagringsgräns';

  @override
  String get offlineStorageCapUnlimited => 'Obegränsat';

  @override
  String get offlineWifiOnly => 'Bara wifi';

  @override
  String get offlineWifiOnlySubtitle =>
      'Ladda bara ner via wifi; fråga innan mobildata används';

  @override
  String get offlineFavoritesTitle => 'Håll Favoriter offline';

  @override
  String get offlineFavoritesSubtitle =>
      'Ladda automatiskt ner alla låtar du favoritmarkerar';

  @override
  String offlineUsage(String used, String cap) {
    return '$used av $cap använt';
  }

  @override
  String offlineUsageUnlimited(String used) {
    return '$used använt';
  }

  @override
  String get download => 'Ladda ner';

  @override
  String get removeDownload => 'Ta bort nedladdning';

  @override
  String get downloaded => 'Nedladdad';

  @override
  String get keepOffline => 'Håll offline';

  @override
  String get removeOffline => 'Ta bort offline';

  @override
  String get undo => 'Ångra';

  @override
  String get navDownloads => 'Nedladdat';

  @override
  String get downloadsEmptyTitle => 'Inget nedladdat ännu';

  @override
  String get downloadsEmptyHint =>
      'Ladda ner låtar, album eller spellistor för att lyssna offline. De dyker upp här — och i Filer-appen på din iPhone.';

  @override
  String get downloadRemoveSong => 'Ta bort nedladdning';

  @override
  String get create => 'Skapa';

  @override
  String get radioStations => 'Stationer';

  @override
  String get genreRadio => 'Genreradio';

  @override
  String get artistRadio => 'Artistradio';

  @override
  String get radioEmptyHint =>
      'Synka online för att behålla stationer och radiostarter här.';

  @override
  String get invalidRadioStream => 'Radiostationens streamadress stöds inte.';

  @override
  String get lyrics => 'Låttext';

  @override
  String get noLyrics => 'Det finns ingen låttext för den här låten.';

  @override
  String get lyricsSync => 'Synk';

  @override
  String get lyricsSyncEarlier => 'Visa texten tidigare';

  @override
  String get lyricsSyncLater => 'Visa texten senare';

  @override
  String get lyricsSyncReset => 'Nollställ synk';

  @override
  String get removeFromQueue => 'Ta bort från kön';

  @override
  String get holdArtworkForInfo => 'Håll in omslaget för låtinformation';

  @override
  String get sleepTimer => 'Sömntimer';

  @override
  String get sleepTimerDescription =>
      'Uppspelningen pausas när tiden går ut. Kön ligger kvar.';

  @override
  String sleepTimerMinutes(int minutes) {
    return '$minutes minuter';
  }

  @override
  String sleepTimerRemaining(String time) {
    return 'Sömntimer: $time kvar';
  }

  @override
  String get cancelSleepTimer => 'Avbryt sömntimer';

  @override
  String get shareFailed => 'Kunde inte skapa en delningslänk i Navidrome';

  @override
  String get saveFilter => 'Spara filter';

  @override
  String get filterName => 'Namn på filtret';

  @override
  String filterSaved(String name) {
    return 'Filtret \"$name\" sparades';
  }

  @override
  String get playlistRadio => 'Spellisteradio';

  @override
  String get continueWithSimilar => 'Fortsätt med liknande';

  @override
  String get tuneQueue => 'Justera kön';

  @override
  String get moreLikeThis => 'Mer som denna';

  @override
  String get lessLikeThis => 'Mindre som denna';

  @override
  String get queueTuned => 'Kommande låtar justerades';

  @override
  String get albumAudioDetails => 'Albuminformation';

  @override
  String get albumTotalSize => 'Total storlek';

  @override
  String get albumFormats => 'Format';

  @override
  String get albumQualityRange => 'Ljudkvalitet';

  @override
  String get quickPicks => 'Quick Picks';

  @override
  String get swipeActionsHint => 'Svep för snabba åtgärder';

  @override
  String get newPlaylistEllipsis => 'Ny spellista…';

  @override
  String createdPlaylistWithSong(String name) {
    return 'Skapade $name och la till låten';
  }

  @override
  String get createSimilarPlaylist => 'Skapa spellista med liknande låtar';

  @override
  String similarToTitle(String title) {
    return 'Liknar $title';
  }

  @override
  String get nowPlayingLabel => 'Spelas nu';

  @override
  String get clearSearch => 'Rensa';

  @override
  String get playerLyricsShort => 'Text';

  @override
  String get playerQueueShort => 'Kö';

  @override
  String get playerSleepShort => 'Timer';

  @override
  String get playerTuneShort => 'Justera';

  @override
  String get sleepTimerEndOfSong => 'Vid låtens slut';

  @override
  String get likedSong => 'Tillagd i favoriter';

  @override
  String get unlikedSong => 'Borttagen från favoriter';

  @override
  String get serverSetupTitle => 'Installation';

  @override
  String get serverSetupSubtitle =>
      'Tillvalsfunktioner, fjärråtkomst och säkerhet';

  @override
  String get serverSetupIntro =>
      'Använd checklistan för att få mer av servern. Söngr fungerar även när en tillvalsfunktion saknas.';

  @override
  String get serverSetupChecking => 'Kontrollerar serverns funktioner…';

  @override
  String get serverSetupCheckAgain => 'Kontrollera igen';

  @override
  String get serverSetupAllReady => 'Alla rekommenderade kontroller är klara.';

  @override
  String serverSetupActionsRecommended(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count förbättringar rekommenderas',
      one: '1 förbättring rekommenderas',
    );
    return '$_temp0';
  }

  @override
  String get serverSetupReady => 'Klar';

  @override
  String get serverSetupActionRecommended => 'Rekommenderas';

  @override
  String get serverSetupNotDetected =>
      'Ingen motsvarande data hittades i urvalet. Funktionen finns fortfarande att prova.';

  @override
  String get serverSetupTip => 'Tips';

  @override
  String get serverSetupReadGuide => 'Läs installationsguiden';

  @override
  String get serverSetupRemoteTitle => 'Lyssna utanför hemmet';

  @override
  String get serverSetupRemoteLocal =>
      'Den här adressen fungerar i det lokala nätverket. Använd Cloudflare Tunnel eller Tailscale med en HTTPS-adress när du vill nå servern utanför hemmet.';

  @override
  String get serverSetupRemoteReady =>
      'Serverns publika adress är redo för lyssning utanför hemnätverket.';

  @override
  String get serverSetupSmartTitle => 'Smarta mixar';

  @override
  String get serverSetupSmartReady =>
      'Servern returnerar liknande låtar, så radio, köjustering och spellisteförslag är tillgängliga.';

  @override
  String get serverSetupSmartMissing =>
      'Installera AudioMuse AI och aktivera dess Navidrome-plugin för soniska mixar. Quick Picks, vanlig uppspelning och resten av appen fungerar ändå.';

  @override
  String get serverSetupLyricsTitle => 'Låttexter';

  @override
  String get serverSetupLyricsReady =>
      'Servern returnerade låttexter för biblioteket.';

  @override
  String get serverSetupLyricsMissing =>
      'Installera pluginet nd-lyrics eller lägg till låttexter i filerna. Spelaren fungerar fullt ut även utan låttexter.';

  @override
  String get serverSetupSecurityTitle => 'HTTPS';

  @override
  String get serverSetupSecurityReady => 'Serverns adress använder HTTPS.';

  @override
  String get serverSetupSecurityHttp =>
      'Den lokala adressen använder HTTP. Sätt Cloudflare Tunnel eller Tailscale framför servern innan den exponeras mot internet.';

  @override
  String get serverHttpWarning =>
      'HTTP är okrypterat. Använd det bara i ett betrott lokalt nätverk. HTTPS rekommenderas.';

  @override
  String get serverSetupBackupTitle => 'Säkerhetskopiera biblioteket';

  @override
  String get serverSetupBackupBody =>
      'Säkerhetskopiera Navidromes databas och musikfilerna före serveruppdateringar. Appen kan inte kontrollera dina backuper.';

  @override
  String get serverSetupPluginNote =>
      'Kontrollerna använder bara Navidromes vanliga Subsonic-API. Söngr ansluter aldrig direkt till en tillvalsplugin.';

  @override
  String get supportDeveloperTitle => 'Stöd utvecklaren';

  @override
  String get supportDeveloperSubtitle =>
      'Dela appen, skicka feedback eller ställ en fråga';

  @override
  String get supportDeveloperHeadline => 'Gjord för din egen musik';

  @override
  String get supportDeveloperBody =>
      'Söngr har inga annonser, ingen spårning och inget abonnemang. Att visa appen för en annan Navidrome-lyssnare är det bästa sättet att stödja utvecklingen.';

  @override
  String get supportShareTitle => 'Dela Söngr';

  @override
  String get supportShareSubtitle => 'Skicka appsidan till en annan lyssnare';

  @override
  String get supportShareText =>
      'Söngr är en privat, oberoende klient för Navidrome:';

  @override
  String get shareAppFailed => 'Det gick inte att öppna delningen.';

  @override
  String get supportEmailTitle => 'E-posta support';

  @override
  String get supportMailSubject => 'Support: Söngr';

  @override
  String get supportMailBody =>
      'Beskriv din fråga och ta med detaljer som kan hjälpa:\n\n\n\nSkicka aldrig med serverns lösenord.';

  @override
  String get websiteLabel => 'Utvecklarens webbplats';

  @override
  String get bugReportTitle => 'Rapportera fel eller förslag';

  @override
  String get bugReportSubtitle =>
      'Skicka en diagnostiklogg och beskriv vad som hände';

  @override
  String get bugReportMailSubject => 'Söngr: felrapport eller förslag';

  @override
  String get bugReportWhatHappened =>
      'Beskriv vad som hände, vad du förväntade dig och hur felet kan återskapas:';

  @override
  String get bugReportVersion => 'Appversion';

  @override
  String get bugReportPlatform => 'Plattform';

  @override
  String get bugReportSheetTitle => 'Skicka felrapport';

  @override
  String get bugReportDescriptionLabel => 'Vad hände?';

  @override
  String get bugReportDescriptionHint =>
      'Beskriv felet eller förslaget. Berätta gärna vad du gjorde precis innan.';

  @override
  String get bugReportDiagnosticsNote =>
      'Appversion, plattform, lokala sessionsmätvärden och senaste fel loggas automatiskt. Serveradress, användarnamn och lösenord tas bort.';

  @override
  String get bugReportAttachImage => 'Bild';

  @override
  String get bugReportAttachVideo => 'Video';

  @override
  String get bugReportAttachmentHelp =>
      'Bifoga en bild eller video: JPEG, PNG, HEIC, MP4 eller MOV.';

  @override
  String get bugReportAttachmentTooLarge => 'Filen får vara högst 40 MB.';

  @override
  String get bugReportAttachmentUnsupported =>
      'Filen har ett format som inte stöds.';

  @override
  String get bugReportAttachmentPickFailed => 'Filen kunde inte väljas.';

  @override
  String get bugReportRemoveAttachment => 'Ta bort bilaga';

  @override
  String get bugReportSend => 'Skicka rapport';

  @override
  String get bugReportSending => 'Förbereder rapport…';

  @override
  String get bugReportShareFailed => 'Rapporten kunde inte öppnas.';

  @override
  String get bugReportOpened => 'Rapporten är klar att skickas.';

  @override
  String get bugReportEmptyDescription => 'Beskriv kort vad som hände.';

  @override
  String get privacyPolicyTitle => 'Integritetspolicy';

  @override
  String get privacyPolicySubtitle => 'Så hanterar Söngr dina uppgifter';

  @override
  String get requestRefundTitle => 'Begär återbetalning';

  @override
  String get requestRefundSubtitle => 'Öppnar Apples sida Report a Problem';

  @override
  String get openLinkFailed => 'Länken kunde inte öppnas.';

  @override
  String get librarySyncTitle => 'Läs in hela biblioteket';

  @override
  String get librarySyncSubtitle =>
      'Hämtar alla låtar, album, artister och spellistor från servern. Det kan ta en stund.';

  @override
  String get librarySyncLoading => 'Läser in biblioteket…';

  @override
  String get librarySyncComplete => 'Hela biblioteket har uppdaterats.';

  @override
  String get librarySyncFailed =>
      'Biblioteket kunde inte uppdateras helt. Kontrollera anslutningen och försök igen.';

  @override
  String get librarySyncWaiting => 'Väntar på att starta…';

  @override
  String librarySyncSongsProgress(String count) {
    return '$count låtar hämtade';
  }

  @override
  String librarySyncArtistsProgress(String count) {
    return '$count artister hämtade';
  }

  @override
  String librarySyncAlbumsProgress(String count) {
    return '$count album hämtade';
  }

  @override
  String get librarySyncPlaylistsLoading => 'Hämtar spellistor…';

  @override
  String librarySyncPlaylistsProgress(String count, String total) {
    return '$count av $total spellistor hämtade';
  }

  @override
  String get librarySyncFinishing => 'Slutför och uppdaterar biblioteket…';

  @override
  String get librarySyncCanLeave =>
      'Du kan lämna Inställningar och följa förloppet här igen.';
}
