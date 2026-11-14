// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Soengr';

  @override
  String get navHome => 'Home';

  @override
  String get navNew => 'New';

  @override
  String get navRadio => 'Radio';

  @override
  String get navLibrary => 'Library';

  @override
  String get navArtists => 'Artists';

  @override
  String get navAlbums => 'Albums';

  @override
  String get navPlaylists => 'Playlists';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get tooltipSearch => 'Search';

  @override
  String get tooltipSettings => 'Settings';

  @override
  String get dataSaver => 'Data saver';

  @override
  String get dataSaverSubtitle =>
      'Stream everything above mp3 quality at mp3 quality instead';

  @override
  String get sectionRecentlyAdded => 'Recently added';

  @override
  String get sectionRecentlyPlayedSongs => 'Recently played songs';

  @override
  String get sectionRecentlyAddedSongs => 'Recently added songs';

  @override
  String get sectionMostPlayedSongs => 'Most played songs';

  @override
  String get homeRefreshingAlbums => 'Fetching new albums…';

  @override
  String get homeEmptyHint =>
      'Sync your Navidrome library to start listening offline.';

  @override
  String get navSongs => 'Songs';

  @override
  String get sectionMostPlayedAlbums => 'Most played albums';

  @override
  String get sectionRecentlyPlayedAlbums => 'Recently played albums';

  @override
  String get sectionRecentlyAddedAlbums => 'Recently added albums';

  @override
  String get sectionFromLibrary => 'From your library';

  @override
  String get refreshSelection => 'New selection';

  @override
  String get homeCustomizationTitle => 'Customize Home';

  @override
  String get homeCustomizationSubtitle =>
      'Content, order and visibility per carousel';

  @override
  String get homeHeaderStyleTitle => 'Show logo';

  @override
  String get homeHeaderStyleSubtitle =>
      'Use the logo instead of Soengr at the top of Home';

  @override
  String get appearanceSettingsTitle => 'Appearance';

  @override
  String get appearanceSettingsSubtitle =>
      'Transparency and blur for the top bar';

  @override
  String get topBarTransparencyTitle => 'Top bar';

  @override
  String get transparencySettingTitle => 'Transparency';

  @override
  String get transparencySettingHelp =>
      '0% gives a dark surface. 100% lets everything behind it through.';

  @override
  String get blurSettingTitle => 'Blur';

  @override
  String get blurSettingHelp =>
      '0 gives a completely sharp background. Higher values blur it more.';

  @override
  String get homeCarouselContentTitle => 'Content per carousel';

  @override
  String get homeCarouselContentHelp =>
      'Choose Songs or Albums separately for each shelf. Order and visibility are adjusted in the same list.';

  @override
  String get homeFocusSongs => 'Songs';

  @override
  String get homeFocusAlbums => 'Albums';

  @override
  String get homeSectionsTitle => 'Shelves and order';

  @override
  String get homeSectionsHelp =>
      'Show or hide shelves and drag the handle to change their order. At least one shelf must remain visible.';

  @override
  String get homeSectionRecentlyPlayed => 'Recently played';

  @override
  String get homeSectionRecentlyAdded => 'Recently added';

  @override
  String get homeSectionMostPlayed => 'Most played';

  @override
  String get recommendationsSettingsTitle => 'Algorithm';

  @override
  String get recommendationsSettingsSubtitle =>
      'Smart features controlled by Navidrome and its plugins';

  @override
  String get recommendationVariationTitle => 'Variation';

  @override
  String get recommendationVariationHelp =>
      'A low value stays close to the seed song. A higher value explores deeper among suggestions that are still related.';

  @override
  String get recommendationArtistVarietyTitle => 'Artist variety';

  @override
  String get recommendationArtistVarietyHelp =>
      'Limits how many songs from the same primary artist may appear in each candidate batch.';

  @override
  String recommendationSongsPerArtist(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count songs per artist',
      one: '1 song per artist',
    );
    return '$_temp0';
  }

  @override
  String get recommendationInitialQueueTitle => 'Initial queue size';

  @override
  String get recommendationInitialQueueHelp =>
      'How many related songs are fetched when you select one song. AutoPlay then continues five at a time.';

  @override
  String get filters => 'Filters';

  @override
  String get filterQuality => 'Quality';

  @override
  String get filterFormat => 'Format';

  @override
  String get filterGenre => 'Genre';

  @override
  String get filterFavorites => 'Favorites only';

  @override
  String get qualityLossless => 'Lossless';

  @override
  String get qualityAny => 'Any';

  @override
  String get qualityLossy => 'Lossy';

  @override
  String get qualityHiRes => 'Hi-Res';

  @override
  String get sortBy => 'Sort';

  @override
  String get sortTitle => 'Title';

  @override
  String get sortArtist => 'Artist';

  @override
  String get sortAlbum => 'Album';

  @override
  String get sortYear => 'Year';

  @override
  String get sortRecent => 'Recently added';

  @override
  String get sortRecentlyPlayed => 'Recently played';

  @override
  String get sortRandom => 'Random';

  @override
  String get sortDuration => 'Longest first';

  @override
  String get sortBitRate => 'Highest bitrate';

  @override
  String get sortPlays => 'Most played';

  @override
  String get shufflingSongs => 'Shuffling songs…';

  @override
  String get sortAlbumCount => 'Most albums';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get findSongs => 'Find songs';

  @override
  String get applyFilters => 'Apply';

  @override
  String get resetFilters => 'Reset';

  @override
  String get close => 'Close';

  @override
  String get songsSearchHint => 'Search songs, artists or albums…';

  @override
  String get filterYear => 'Year';

  @override
  String get filterDurationMinutes => 'Duration (minutes)';

  @override
  String get filterBitRateKbps => 'Bitrate (kbps)';

  @override
  String get filterMinimum => 'From';

  @override
  String get filterMaximum => 'To';

  @override
  String get filterGenreHint => 'Pop, rock, jazz…';

  @override
  String get noFilteredSongs => 'No songs match these filters.';

  @override
  String get noFilteredSongsHint => 'Try removing one or more filters.';

  @override
  String get loadingMoreFailed => 'Couldn\'t load more songs.';

  @override
  String get done => 'Done';

  @override
  String get showMore => 'Show more';

  @override
  String get showMoreHint => 'Drag to open';

  @override
  String couldNotLoadLibrary(String error) {
    return 'Couldn\'t load the library:\n$error';
  }

  @override
  String get tryAgain => 'Try again';

  @override
  String get noPlaylists => 'No playlists.';

  @override
  String get noResults => 'No results.';

  @override
  String get nothingToShowYet => 'Nothing to show yet.';

  @override
  String get noSongPlaying => 'No song is playing.';

  @override
  String get queueEmpty => 'The queue is empty.';

  @override
  String get autoplay => 'Autoplay';

  @override
  String get autoplaySubtitle => 'Add similar content to the end of the queue';

  @override
  String get songsHeader => 'Songs';

  @override
  String songsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count songs',
      one: '1 song',
    );
    return '$_temp0';
  }

  @override
  String albumsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count albums',
      one: '1 album',
    );
    return '$_temp0';
  }

  @override
  String artistsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artists',
      one: '1 artist',
    );
    return '$_temp0';
  }

  @override
  String playlistsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count playlists',
      one: '1 playlist',
    );
    return '$_temp0';
  }

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get nextTrack => 'Next track';

  @override
  String get previousTrack => 'Previous track';

  @override
  String get favorite => 'Favorite';

  @override
  String get removeFavorite => 'Remove favorite';

  @override
  String get nowPlaying => 'Now Playing';

  @override
  String get queue => 'Queue';

  @override
  String get playlistName => 'Name';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String playlistSaveFailed(String error) {
    return 'Couldn\'t save: $error';
  }

  @override
  String get deletePlaylist => 'Delete playlist';

  @override
  String get renamePlaylist => 'Rename playlist';

  @override
  String deletePlaylistConfirm(String name) {
    return 'Delete the playlist “$name”?';
  }

  @override
  String get delete => 'Delete';

  @override
  String get addToPlaylist => 'Add to playlist';

  @override
  String get removeFromPlaylistAction => 'Remove from playlist';

  @override
  String addedToPlaylist(String name) {
    return 'Added to “$name”';
  }

  @override
  String addToNamedPlaylist(String name) {
    return 'Add to “$name”';
  }

  @override
  String get lastUsedPlaylist => 'Last used playlist';

  @override
  String get playlistSuggestions => 'Suggestions for this playlist';

  @override
  String get playlistSuggestionsSubtitle => 'Based on the songs already in it';

  @override
  String get similarSuggestionsEmpty => 'No new suggestions right now.';

  @override
  String get similarSuggestionsError => 'Couldn\'t load suggestions right now.';

  @override
  String get favoriteMix => 'Favorites mix';

  @override
  String get moveFavoritesToPlaylist => 'Move favorite songs to playlist';

  @override
  String get moveFavoritesToPlaylistTitle =>
      'Move favorite songs to a playlist?';

  @override
  String get moveFavoritesToPlaylistBody =>
      'All favorite songs are added to a new playlist. Favorite albums and artists are removed from Favorites and can\'t be restored.';

  @override
  String get moveFavoritesToPlaylistConfirm => 'Move';

  @override
  String favoritesToPlaylistName(String date) {
    return 'Favorites $date';
  }

  @override
  String favoritesMovedToPlaylist(String name) {
    return 'Moved favorite songs to $name';
  }

  @override
  String favoritesMovedPartially(String name) {
    return 'Moved favorite songs to $name, but couldn\'t remove every favorite mark.';
  }

  @override
  String get noFavoritesToMove => 'No favorites to move.';

  @override
  String get newPlaylist => 'New playlist…';

  @override
  String get createMixFromSong => 'Create mix from song';

  @override
  String get navidromeSimilarSongs => 'Navidrome • similar songs';

  @override
  String get playNext => 'Play next';

  @override
  String get addToQueue => 'Add to queue';

  @override
  String get goToAlbum => 'Go to album';

  @override
  String get goToArtist => 'Go to artist';

  @override
  String get share => 'Share';

  @override
  String get repeat => 'Repeat';

  @override
  String get shuffle => 'Shuffle';

  @override
  String get searchHint => 'Search artists, albums, songs…';

  @override
  String searchError(String error) {
    return 'Error: $error';
  }

  @override
  String get settingsTitle => 'Server settings';

  @override
  String get connectToServer => 'Connect to your Navidrome server';

  @override
  String get serverUrl => 'Server URL';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get connectAndSave => 'Connect and save';

  @override
  String couldNotConnect(String error) {
    return 'Couldn\'t connect: $error';
  }

  @override
  String get offlineSectionTitle => 'Offline';

  @override
  String get offlineStorageCap => 'Storage limit';

  @override
  String get offlineStorageCapUnlimited => 'Unlimited';

  @override
  String get offlineWifiOnly => 'Wi-Fi only';

  @override
  String get offlineWifiOnlySubtitle =>
      'Only download over Wi-Fi; ask before using cellular data';

  @override
  String get offlineFavoritesTitle => 'Keep Favorites offline';

  @override
  String get offlineFavoritesSubtitle =>
      'Automatically download every song you favorite';

  @override
  String offlineUsage(String used, String cap) {
    return '$used of $cap used';
  }

  @override
  String offlineUsageUnlimited(String used) {
    return '$used used';
  }

  @override
  String get download => 'Download';

  @override
  String get removeDownload => 'Remove download';

  @override
  String get downloaded => 'Downloaded';

  @override
  String get keepOffline => 'Keep offline';

  @override
  String get removeOffline => 'Remove offline';

  @override
  String get undo => 'Undo';

  @override
  String get navDownloads => 'Downloaded';

  @override
  String get downloadsEmptyTitle => 'Nothing downloaded yet';

  @override
  String get downloadsEmptyHint =>
      'Download songs, albums or playlists to listen offline. They will show up here — and in the Files app on your iPhone.';

  @override
  String get downloadRemoveSong => 'Remove download';

  @override
  String get create => 'Create';

  @override
  String get radioStations => 'Stations';

  @override
  String get genreRadio => 'Genre radio';

  @override
  String get artistRadio => 'Artist radio';

  @override
  String get radioEmptyHint =>
      'Sync while online to keep stations and radio seeds available here.';

  @override
  String get invalidRadioStream =>
      'This radio station\'s stream address isn\'t supported.';

  @override
  String get lyrics => 'Lyrics';

  @override
  String get noLyrics => 'No lyrics are available for this song.';

  @override
  String get lyricsSync => 'Sync';

  @override
  String get lyricsSyncEarlier => 'Show lyrics earlier';

  @override
  String get lyricsSyncLater => 'Show lyrics later';

  @override
  String get lyricsSyncReset => 'Reset sync';

  @override
  String get removeFromQueue => 'Remove from queue';

  @override
  String get holdArtworkForInfo =>
      'Press and hold the artwork for song information';

  @override
  String get sleepTimer => 'Sleep timer';

  @override
  String get sleepTimerDescription =>
      'Playback pauses when the timer ends. Your queue stays intact.';

  @override
  String sleepTimerMinutes(int minutes) {
    return '$minutes minutes';
  }

  @override
  String sleepTimerRemaining(String time) {
    return 'Sleep timer: $time left';
  }

  @override
  String get cancelSleepTimer => 'Cancel sleep timer';

  @override
  String get shareFailed => 'Could not create a Navidrome share link';

  @override
  String get saveFilter => 'Save filter';

  @override
  String get filterName => 'Filter name';

  @override
  String filterSaved(String name) {
    return 'Saved filter \"$name\"';
  }

  @override
  String get playlistRadio => 'Playlist Radio';

  @override
  String get continueWithSimilar => 'Continue with similar';

  @override
  String get tuneQueue => 'Tune the queue';

  @override
  String get moreLikeThis => 'More like this';

  @override
  String get lessLikeThis => 'Less like this';

  @override
  String get queueTuned => 'Upcoming songs adjusted';

  @override
  String get albumAudioDetails => 'Album information';

  @override
  String get albumTotalSize => 'Total size';

  @override
  String get albumFormats => 'Formats';

  @override
  String get albumQualityRange => 'Audio quality';

  @override
  String get quickPicks => 'Quick Picks';

  @override
  String get swipeActionsHint => 'Swipe for quick actions';

  @override
  String get newPlaylistEllipsis => 'New playlist…';

  @override
  String createdPlaylistWithSong(String name) {
    return '$name created with the song';
  }

  @override
  String get createSimilarPlaylist => 'Create playlist of similar songs';

  @override
  String similarToTitle(String title) {
    return 'Similar to $title';
  }

  @override
  String get nowPlayingLabel => 'Now playing';

  @override
  String get clearSearch => 'Clear';

  @override
  String get playerLyricsShort => 'Lyrics';

  @override
  String get playerQueueShort => 'Queue';

  @override
  String get playerSleepShort => 'Sleep';

  @override
  String get playerTuneShort => 'Tune';

  @override
  String get sleepTimerEndOfSong => 'End of current song';

  @override
  String get likedSong => 'Added to favorites';

  @override
  String get unlikedSong => 'Removed from favorites';

  @override
  String get serverSetupTitle => 'Installation';

  @override
  String get serverSetupSubtitle =>
      'Optional features, remote access and security';

  @override
  String get serverSetupIntro =>
      'Use this checklist to get more from your server. Playback keeps working when an optional feature is unavailable.';

  @override
  String get serverSetupChecking => 'Checking server features…';

  @override
  String get serverSetupCheckAgain => 'Check again';

  @override
  String get serverSetupAllReady => 'All recommended checks are ready.';

  @override
  String serverSetupActionsRecommended(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count improvements recommended',
      one: '1 improvement recommended',
    );
    return '$_temp0';
  }

  @override
  String get serverSetupReady => 'Ready';

  @override
  String get serverSetupActionRecommended => 'Recommended';

  @override
  String get serverSetupNotDetected =>
      'No matching data was found in the sample. The feature remains available to try.';

  @override
  String get serverSetupTip => 'Tip';

  @override
  String get serverSetupReadGuide => 'Read the setup guide';

  @override
  String get serverSetupRemoteTitle => 'Listen away from home';

  @override
  String get serverSetupRemoteLocal =>
      'This address works on your local network. Use Cloudflare Tunnel or Tailscale with an HTTPS address when you want access outside home.';

  @override
  String get serverSetupRemoteReady =>
      'Your public server address is ready for listening outside your home network.';

  @override
  String get serverSetupSmartTitle => 'Smart mixes';

  @override
  String get serverSetupSmartReady =>
      'Your server is returning similar songs, so radio, tuning and playlist suggestions are available.';

  @override
  String get serverSetupSmartMissing =>
      'Install AudioMuse AI and enable its Navidrome plugin for sonic mixes. Quick Picks, normal playback and the rest of the app still work.';

  @override
  String get serverSetupLyricsTitle => 'Lyrics';

  @override
  String get serverSetupLyricsReady =>
      'Your server returned lyrics for this library.';

  @override
  String get serverSetupLyricsMissing =>
      'Install the nd-lyrics plugin or add lyrics tags to your files. The player remains fully usable without lyrics.';

  @override
  String get serverSetupSecurityTitle => 'HTTPS';

  @override
  String get serverSetupSecurityReady => 'Your server address uses HTTPS.';

  @override
  String get serverSetupSecurityHttp =>
      'This local address uses HTTP. Put Cloudflare Tunnel or Tailscale in front of it before exposing the server to the internet.';

  @override
  String get serverHttpWarning =>
      'HTTP is unencrypted. Use it only on a trusted local network. HTTPS is recommended.';

  @override
  String get serverSetupBackupTitle => 'Keep a library backup';

  @override
  String get serverSetupBackupBody =>
      'Back up the Navidrome database and music files before server upgrades. This app cannot inspect your backups.';

  @override
  String get serverSetupPluginNote =>
      'These checks use only Navidrome\'s standard Subsonic API. Soengr never connects directly to an optional plugin service.';

  @override
  String get supportDeveloperTitle => 'Support the developer';

  @override
  String get supportDeveloperSubtitle =>
      'Share the app, send feedback or ask a question';

  @override
  String get supportDeveloperHeadline => 'Made for your own music';

  @override
  String get supportDeveloperBody =>
      'Soengr has no ads, tracking or subscription. Sharing it with another Navidrome listener is the best way to support its development.';

  @override
  String get supportShareTitle => 'Share Soengr';

  @override
  String get supportShareSubtitle => 'Send the app page to another listener';

  @override
  String get supportShareText =>
      'Soengr is a private, independent client for Navidrome:';

  @override
  String get shareAppFailed => 'Could not open sharing.';

  @override
  String get supportEmailTitle => 'Email support';

  @override
  String get supportMailSubject => 'Support: Soengr';

  @override
  String get supportMailBody =>
      'Describe your question and include any details that may help:\n\n\n\nPlease do not include your server password.';

  @override
  String get websiteLabel => 'Developer website';

  @override
  String get bugReportTitle => 'Report a bug or suggestion';

  @override
  String get bugReportSubtitle =>
      'Send a diagnostic log and describe what happened';

  @override
  String get bugReportMailSubject => 'Soengr: bug report or suggestion';

  @override
  String get bugReportWhatHappened =>
      'Describe what happened, what you expected, and how to reproduce it:';

  @override
  String get bugReportVersion => 'App version';

  @override
  String get bugReportPlatform => 'Platform';

  @override
  String get bugReportSheetTitle => 'Send bug report';

  @override
  String get bugReportDescriptionLabel => 'What happened?';

  @override
  String get bugReportDescriptionHint =>
      'Describe the bug or suggestion. Include what you did just before it happened.';

  @override
  String get bugReportDiagnosticsNote =>
      'App version, platform, local session metrics and recent errors are included automatically. Server address, username and password are removed.';

  @override
  String get bugReportAttachImage => 'Image';

  @override
  String get bugReportAttachVideo => 'Video';

  @override
  String get bugReportAttachmentHelp =>
      'Attach one image or video: JPEG, PNG, HEIC, MP4 or MOV.';

  @override
  String get bugReportAttachmentTooLarge =>
      'The file must be 40 MB or smaller.';

  @override
  String get bugReportAttachmentUnsupported =>
      'This file format is not supported.';

  @override
  String get bugReportAttachmentPickFailed => 'The file could not be selected.';

  @override
  String get bugReportRemoveAttachment => 'Remove attachment';

  @override
  String get bugReportSend => 'Send report';

  @override
  String get bugReportSending => 'Preparing report…';

  @override
  String get bugReportShareFailed => 'The report could not be opened.';

  @override
  String get bugReportOpened => 'The report is ready to send.';

  @override
  String get bugReportEmptyDescription => 'Briefly describe what happened.';

  @override
  String get privacyPolicyTitle => 'Privacy policy';

  @override
  String get privacyPolicySubtitle => 'How Soengr handles your data';

  @override
  String get requestRefundTitle => 'Request a refund';

  @override
  String get requestRefundSubtitle => 'Opens Apple\'s Report a Problem page';

  @override
  String get openLinkFailed => 'The link could not be opened.';

  @override
  String get librarySyncTitle => 'Load entire library';

  @override
  String get librarySyncSubtitle =>
      'Fetches all songs, albums, artists and playlists from the server. This may take a while.';

  @override
  String get librarySyncLoading => 'Loading library…';

  @override
  String get librarySyncComplete => 'The entire library has been updated.';

  @override
  String get librarySyncFailed =>
      'The library could not be fully updated. Check your connection and try again.';

  @override
  String get librarySyncWaiting => 'Waiting to start…';

  @override
  String librarySyncSongsProgress(String count) {
    return '$count songs fetched';
  }

  @override
  String librarySyncArtistsProgress(String count) {
    return '$count artists fetched';
  }

  @override
  String librarySyncAlbumsProgress(String count) {
    return '$count albums fetched';
  }

  @override
  String get librarySyncPlaylistsLoading => 'Fetching playlists…';

  @override
  String librarySyncPlaylistsProgress(String count, String total) {
    return '$count of $total playlists fetched';
  }

  @override
  String get librarySyncFinishing => 'Finishing and updating the library…';

  @override
  String get librarySyncCanLeave =>
      'You can leave Settings and return here to check progress.';
}
