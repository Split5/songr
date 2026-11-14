import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sv.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sv'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Soengr'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get navNew;

  /// No description provided for @navRadio.
  ///
  /// In en, this message translates to:
  /// **'Radio'**
  String get navRadio;

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// No description provided for @navArtists.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get navArtists;

  /// No description provided for @navAlbums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get navAlbums;

  /// No description provided for @navPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get navPlaylists;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @tooltipSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get tooltipSearch;

  /// No description provided for @tooltipSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tooltipSettings;

  /// No description provided for @dataSaver.
  ///
  /// In en, this message translates to:
  /// **'Data saver'**
  String get dataSaver;

  /// No description provided for @dataSaverSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stream everything above mp3 quality at mp3 quality instead'**
  String get dataSaverSubtitle;

  /// No description provided for @sectionRecentlyAdded.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get sectionRecentlyAdded;

  /// No description provided for @sectionRecentlyPlayedSongs.
  ///
  /// In en, this message translates to:
  /// **'Recently played songs'**
  String get sectionRecentlyPlayedSongs;

  /// No description provided for @sectionRecentlyAddedSongs.
  ///
  /// In en, this message translates to:
  /// **'Recently added songs'**
  String get sectionRecentlyAddedSongs;

  /// No description provided for @sectionMostPlayedSongs.
  ///
  /// In en, this message translates to:
  /// **'Most played songs'**
  String get sectionMostPlayedSongs;

  /// No description provided for @homeRefreshingAlbums.
  ///
  /// In en, this message translates to:
  /// **'Fetching new albums…'**
  String get homeRefreshingAlbums;

  /// No description provided for @homeEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Sync your Navidrome library to start listening offline.'**
  String get homeEmptyHint;

  /// No description provided for @navSongs.
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get navSongs;

  /// No description provided for @sectionMostPlayedAlbums.
  ///
  /// In en, this message translates to:
  /// **'Most played albums'**
  String get sectionMostPlayedAlbums;

  /// No description provided for @sectionRecentlyPlayedAlbums.
  ///
  /// In en, this message translates to:
  /// **'Recently played albums'**
  String get sectionRecentlyPlayedAlbums;

  /// No description provided for @sectionRecentlyAddedAlbums.
  ///
  /// In en, this message translates to:
  /// **'Recently added albums'**
  String get sectionRecentlyAddedAlbums;

  /// No description provided for @sectionFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'From your library'**
  String get sectionFromLibrary;

  /// No description provided for @refreshSelection.
  ///
  /// In en, this message translates to:
  /// **'New selection'**
  String get refreshSelection;

  /// No description provided for @homeCustomizationTitle.
  ///
  /// In en, this message translates to:
  /// **'Customize Home'**
  String get homeCustomizationTitle;

  /// No description provided for @homeCustomizationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Content, order and visibility per carousel'**
  String get homeCustomizationSubtitle;

  /// No description provided for @homeHeaderStyleTitle.
  ///
  /// In en, this message translates to:
  /// **'Show logo'**
  String get homeHeaderStyleTitle;

  /// No description provided for @homeHeaderStyleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use the logo instead of Soengr at the top of Home'**
  String get homeHeaderStyleSubtitle;

  /// No description provided for @appearanceSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSettingsTitle;

  /// No description provided for @appearanceSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Transparency and blur for the top bar'**
  String get appearanceSettingsSubtitle;

  /// No description provided for @topBarTransparencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Top bar'**
  String get topBarTransparencyTitle;

  /// No description provided for @transparencySettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Transparency'**
  String get transparencySettingTitle;

  /// No description provided for @transparencySettingHelp.
  ///
  /// In en, this message translates to:
  /// **'0% gives a dark surface. 100% lets everything behind it through.'**
  String get transparencySettingHelp;

  /// No description provided for @blurSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Blur'**
  String get blurSettingTitle;

  /// No description provided for @blurSettingHelp.
  ///
  /// In en, this message translates to:
  /// **'0 gives a completely sharp background. Higher values blur it more.'**
  String get blurSettingHelp;

  /// No description provided for @homeCarouselContentTitle.
  ///
  /// In en, this message translates to:
  /// **'Content per carousel'**
  String get homeCarouselContentTitle;

  /// No description provided for @homeCarouselContentHelp.
  ///
  /// In en, this message translates to:
  /// **'Choose Songs or Albums separately for each shelf. Order and visibility are adjusted in the same list.'**
  String get homeCarouselContentHelp;

  /// No description provided for @homeFocusSongs.
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get homeFocusSongs;

  /// No description provided for @homeFocusAlbums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get homeFocusAlbums;

  /// No description provided for @homeSectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Shelves and order'**
  String get homeSectionsTitle;

  /// No description provided for @homeSectionsHelp.
  ///
  /// In en, this message translates to:
  /// **'Show or hide shelves and drag the handle to change their order. At least one shelf must remain visible.'**
  String get homeSectionsHelp;

  /// No description provided for @homeSectionRecentlyPlayed.
  ///
  /// In en, this message translates to:
  /// **'Recently played'**
  String get homeSectionRecentlyPlayed;

  /// No description provided for @homeSectionRecentlyAdded.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get homeSectionRecentlyAdded;

  /// No description provided for @homeSectionMostPlayed.
  ///
  /// In en, this message translates to:
  /// **'Most played'**
  String get homeSectionMostPlayed;

  /// No description provided for @recommendationsSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Algorithm'**
  String get recommendationsSettingsTitle;

  /// No description provided for @recommendationsSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Smart features controlled by Navidrome and its plugins'**
  String get recommendationsSettingsSubtitle;

  /// No description provided for @recommendationVariationTitle.
  ///
  /// In en, this message translates to:
  /// **'Variation'**
  String get recommendationVariationTitle;

  /// No description provided for @recommendationVariationHelp.
  ///
  /// In en, this message translates to:
  /// **'A low value stays close to the seed song. A higher value explores deeper among suggestions that are still related.'**
  String get recommendationVariationHelp;

  /// No description provided for @recommendationArtistVarietyTitle.
  ///
  /// In en, this message translates to:
  /// **'Artist variety'**
  String get recommendationArtistVarietyTitle;

  /// No description provided for @recommendationArtistVarietyHelp.
  ///
  /// In en, this message translates to:
  /// **'Limits how many songs from the same primary artist may appear in each candidate batch.'**
  String get recommendationArtistVarietyHelp;

  /// No description provided for @recommendationSongsPerArtist.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 song per artist} other{{count} songs per artist}}'**
  String recommendationSongsPerArtist(int count);

  /// No description provided for @recommendationInitialQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'Initial queue size'**
  String get recommendationInitialQueueTitle;

  /// No description provided for @recommendationInitialQueueHelp.
  ///
  /// In en, this message translates to:
  /// **'How many related songs are fetched when you select one song. AutoPlay then continues five at a time.'**
  String get recommendationInitialQueueHelp;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @filterQuality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get filterQuality;

  /// No description provided for @filterFormat.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get filterFormat;

  /// No description provided for @filterGenre.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get filterGenre;

  /// No description provided for @filterFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites only'**
  String get filterFavorites;

  /// No description provided for @qualityLossless.
  ///
  /// In en, this message translates to:
  /// **'Lossless'**
  String get qualityLossless;

  /// No description provided for @qualityAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get qualityAny;

  /// No description provided for @qualityLossy.
  ///
  /// In en, this message translates to:
  /// **'Lossy'**
  String get qualityLossy;

  /// No description provided for @qualityHiRes.
  ///
  /// In en, this message translates to:
  /// **'Hi-Res'**
  String get qualityHiRes;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortBy;

  /// No description provided for @sortTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get sortTitle;

  /// No description provided for @sortArtist.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get sortArtist;

  /// No description provided for @sortAlbum.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get sortAlbum;

  /// No description provided for @sortYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get sortYear;

  /// No description provided for @sortRecent.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get sortRecent;

  /// No description provided for @sortRecentlyPlayed.
  ///
  /// In en, this message translates to:
  /// **'Recently played'**
  String get sortRecentlyPlayed;

  /// No description provided for @sortRandom.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get sortRandom;

  /// No description provided for @sortDuration.
  ///
  /// In en, this message translates to:
  /// **'Longest first'**
  String get sortDuration;

  /// No description provided for @sortBitRate.
  ///
  /// In en, this message translates to:
  /// **'Highest bitrate'**
  String get sortBitRate;

  /// No description provided for @sortPlays.
  ///
  /// In en, this message translates to:
  /// **'Most played'**
  String get sortPlays;

  /// No description provided for @shufflingSongs.
  ///
  /// In en, this message translates to:
  /// **'Shuffling songs…'**
  String get shufflingSongs;

  /// No description provided for @sortAlbumCount.
  ///
  /// In en, this message translates to:
  /// **'Most albums'**
  String get sortAlbumCount;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @findSongs.
  ///
  /// In en, this message translates to:
  /// **'Find songs'**
  String get findSongs;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyFilters;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetFilters;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @songsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search songs, artists or albums…'**
  String get songsSearchHint;

  /// No description provided for @filterYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get filterYear;

  /// No description provided for @filterDurationMinutes.
  ///
  /// In en, this message translates to:
  /// **'Duration (minutes)'**
  String get filterDurationMinutes;

  /// No description provided for @filterBitRateKbps.
  ///
  /// In en, this message translates to:
  /// **'Bitrate (kbps)'**
  String get filterBitRateKbps;

  /// No description provided for @filterMinimum.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get filterMinimum;

  /// No description provided for @filterMaximum.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get filterMaximum;

  /// No description provided for @filterGenreHint.
  ///
  /// In en, this message translates to:
  /// **'Pop, rock, jazz…'**
  String get filterGenreHint;

  /// No description provided for @noFilteredSongs.
  ///
  /// In en, this message translates to:
  /// **'No songs match these filters.'**
  String get noFilteredSongs;

  /// No description provided for @noFilteredSongsHint.
  ///
  /// In en, this message translates to:
  /// **'Try removing one or more filters.'**
  String get noFilteredSongsHint;

  /// No description provided for @loadingMoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load more songs.'**
  String get loadingMoreFailed;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get showMore;

  /// No description provided for @showMoreHint.
  ///
  /// In en, this message translates to:
  /// **'Drag to open'**
  String get showMoreHint;

  /// No description provided for @couldNotLoadLibrary.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the library:\n{error}'**
  String couldNotLoadLibrary(String error);

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @noPlaylists.
  ///
  /// In en, this message translates to:
  /// **'No playlists.'**
  String get noPlaylists;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results.'**
  String get noResults;

  /// No description provided for @nothingToShowYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing to show yet.'**
  String get nothingToShowYet;

  /// No description provided for @noSongPlaying.
  ///
  /// In en, this message translates to:
  /// **'No song is playing.'**
  String get noSongPlaying;

  /// No description provided for @queueEmpty.
  ///
  /// In en, this message translates to:
  /// **'The queue is empty.'**
  String get queueEmpty;

  /// No description provided for @autoplay.
  ///
  /// In en, this message translates to:
  /// **'Autoplay'**
  String get autoplay;

  /// No description provided for @autoplaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add similar content to the end of the queue'**
  String get autoplaySubtitle;

  /// No description provided for @songsHeader.
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get songsHeader;

  /// No description provided for @songsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 song} other{{count} songs}}'**
  String songsCount(int count);

  /// No description provided for @albumsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 album} other{{count} albums}}'**
  String albumsCount(int count);

  /// No description provided for @artistsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 artist} other{{count} artists}}'**
  String artistsCount(int count);

  /// No description provided for @playlistsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 playlist} other{{count} playlists}}'**
  String playlistsCount(int count);

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @nextTrack.
  ///
  /// In en, this message translates to:
  /// **'Next track'**
  String get nextTrack;

  /// No description provided for @previousTrack.
  ///
  /// In en, this message translates to:
  /// **'Previous track'**
  String get previousTrack;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @removeFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove favorite'**
  String get removeFavorite;

  /// No description provided for @nowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Now Playing'**
  String get nowPlaying;

  /// No description provided for @queue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get queue;

  /// No description provided for @playlistName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get playlistName;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @playlistSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save: {error}'**
  String playlistSaveFailed(String error);

  /// No description provided for @deletePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Delete playlist'**
  String get deletePlaylist;

  /// No description provided for @renamePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Rename playlist'**
  String get renamePlaylist;

  /// No description provided for @deletePlaylistConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete the playlist “{name}”?'**
  String deletePlaylistConfirm(String name);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @addToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Add to playlist'**
  String get addToPlaylist;

  /// No description provided for @removeFromPlaylistAction.
  ///
  /// In en, this message translates to:
  /// **'Remove from playlist'**
  String get removeFromPlaylistAction;

  /// No description provided for @addedToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Added to “{name}”'**
  String addedToPlaylist(String name);

  /// No description provided for @addToNamedPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Add to “{name}”'**
  String addToNamedPlaylist(String name);

  /// No description provided for @lastUsedPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Last used playlist'**
  String get lastUsedPlaylist;

  /// No description provided for @playlistSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions for this playlist'**
  String get playlistSuggestions;

  /// No description provided for @playlistSuggestionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Based on the songs already in it'**
  String get playlistSuggestionsSubtitle;

  /// No description provided for @similarSuggestionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No new suggestions right now.'**
  String get similarSuggestionsEmpty;

  /// No description provided for @similarSuggestionsError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load suggestions right now.'**
  String get similarSuggestionsError;

  /// No description provided for @favoriteMix.
  ///
  /// In en, this message translates to:
  /// **'Favorites mix'**
  String get favoriteMix;

  /// No description provided for @moveFavoritesToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Move favorite songs to playlist'**
  String get moveFavoritesToPlaylist;

  /// No description provided for @moveFavoritesToPlaylistTitle.
  ///
  /// In en, this message translates to:
  /// **'Move favorite songs to a playlist?'**
  String get moveFavoritesToPlaylistTitle;

  /// No description provided for @moveFavoritesToPlaylistBody.
  ///
  /// In en, this message translates to:
  /// **'All favorite songs are added to a new playlist. Favorite albums and artists are removed from Favorites and can\'t be restored.'**
  String get moveFavoritesToPlaylistBody;

  /// No description provided for @moveFavoritesToPlaylistConfirm.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get moveFavoritesToPlaylistConfirm;

  /// No description provided for @favoritesToPlaylistName.
  ///
  /// In en, this message translates to:
  /// **'Favorites {date}'**
  String favoritesToPlaylistName(String date);

  /// No description provided for @favoritesMovedToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Moved favorite songs to {name}'**
  String favoritesMovedToPlaylist(String name);

  /// No description provided for @favoritesMovedPartially.
  ///
  /// In en, this message translates to:
  /// **'Moved favorite songs to {name}, but couldn\'t remove every favorite mark.'**
  String favoritesMovedPartially(String name);

  /// No description provided for @noFavoritesToMove.
  ///
  /// In en, this message translates to:
  /// **'No favorites to move.'**
  String get noFavoritesToMove;

  /// No description provided for @newPlaylist.
  ///
  /// In en, this message translates to:
  /// **'New playlist…'**
  String get newPlaylist;

  /// No description provided for @createMixFromSong.
  ///
  /// In en, this message translates to:
  /// **'Create mix from song'**
  String get createMixFromSong;

  /// No description provided for @navidromeSimilarSongs.
  ///
  /// In en, this message translates to:
  /// **'Navidrome • similar songs'**
  String get navidromeSimilarSongs;

  /// No description provided for @playNext.
  ///
  /// In en, this message translates to:
  /// **'Play next'**
  String get playNext;

  /// No description provided for @addToQueue.
  ///
  /// In en, this message translates to:
  /// **'Add to queue'**
  String get addToQueue;

  /// No description provided for @goToAlbum.
  ///
  /// In en, this message translates to:
  /// **'Go to album'**
  String get goToAlbum;

  /// No description provided for @goToArtist.
  ///
  /// In en, this message translates to:
  /// **'Go to artist'**
  String get goToArtist;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @shuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get shuffle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search artists, albums, songs…'**
  String get searchHint;

  /// No description provided for @searchError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String searchError(String error);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Server settings'**
  String get settingsTitle;

  /// No description provided for @connectToServer.
  ///
  /// In en, this message translates to:
  /// **'Connect to your Navidrome server'**
  String get connectToServer;

  /// No description provided for @serverUrl.
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get serverUrl;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @connectAndSave.
  ///
  /// In en, this message translates to:
  /// **'Connect and save'**
  String get connectAndSave;

  /// No description provided for @couldNotConnect.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t connect: {error}'**
  String couldNotConnect(String error);

  /// No description provided for @offlineSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offlineSectionTitle;

  /// No description provided for @offlineStorageCap.
  ///
  /// In en, this message translates to:
  /// **'Storage limit'**
  String get offlineStorageCap;

  /// No description provided for @offlineStorageCapUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get offlineStorageCapUnlimited;

  /// No description provided for @offlineWifiOnly.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi only'**
  String get offlineWifiOnly;

  /// No description provided for @offlineWifiOnlySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only download over Wi-Fi; ask before using cellular data'**
  String get offlineWifiOnlySubtitle;

  /// No description provided for @offlineFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep Favorites offline'**
  String get offlineFavoritesTitle;

  /// No description provided for @offlineFavoritesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically download every song you favorite'**
  String get offlineFavoritesSubtitle;

  /// No description provided for @offlineUsage.
  ///
  /// In en, this message translates to:
  /// **'{used} of {cap} used'**
  String offlineUsage(String used, String cap);

  /// No description provided for @offlineUsageUnlimited.
  ///
  /// In en, this message translates to:
  /// **'{used} used'**
  String offlineUsageUnlimited(String used);

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @removeDownload.
  ///
  /// In en, this message translates to:
  /// **'Remove download'**
  String get removeDownload;

  /// No description provided for @downloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get downloaded;

  /// No description provided for @keepOffline.
  ///
  /// In en, this message translates to:
  /// **'Keep offline'**
  String get keepOffline;

  /// No description provided for @removeOffline.
  ///
  /// In en, this message translates to:
  /// **'Remove offline'**
  String get removeOffline;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @navDownloads.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get navDownloads;

  /// No description provided for @downloadsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing downloaded yet'**
  String get downloadsEmptyTitle;

  /// No description provided for @downloadsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Download songs, albums or playlists to listen offline. They will show up here — and in the Files app on your iPhone.'**
  String get downloadsEmptyHint;

  /// No description provided for @downloadRemoveSong.
  ///
  /// In en, this message translates to:
  /// **'Remove download'**
  String get downloadRemoveSong;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @radioStations.
  ///
  /// In en, this message translates to:
  /// **'Stations'**
  String get radioStations;

  /// No description provided for @genreRadio.
  ///
  /// In en, this message translates to:
  /// **'Genre radio'**
  String get genreRadio;

  /// No description provided for @artistRadio.
  ///
  /// In en, this message translates to:
  /// **'Artist radio'**
  String get artistRadio;

  /// No description provided for @radioEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Sync while online to keep stations and radio seeds available here.'**
  String get radioEmptyHint;

  /// No description provided for @invalidRadioStream.
  ///
  /// In en, this message translates to:
  /// **'This radio station\'s stream address isn\'t supported.'**
  String get invalidRadioStream;

  /// No description provided for @lyrics.
  ///
  /// In en, this message translates to:
  /// **'Lyrics'**
  String get lyrics;

  /// No description provided for @noLyrics.
  ///
  /// In en, this message translates to:
  /// **'No lyrics are available for this song.'**
  String get noLyrics;

  /// No description provided for @lyricsSync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get lyricsSync;

  /// No description provided for @lyricsSyncEarlier.
  ///
  /// In en, this message translates to:
  /// **'Show lyrics earlier'**
  String get lyricsSyncEarlier;

  /// No description provided for @lyricsSyncLater.
  ///
  /// In en, this message translates to:
  /// **'Show lyrics later'**
  String get lyricsSyncLater;

  /// No description provided for @lyricsSyncReset.
  ///
  /// In en, this message translates to:
  /// **'Reset sync'**
  String get lyricsSyncReset;

  /// No description provided for @removeFromQueue.
  ///
  /// In en, this message translates to:
  /// **'Remove from queue'**
  String get removeFromQueue;

  /// No description provided for @holdArtworkForInfo.
  ///
  /// In en, this message translates to:
  /// **'Press and hold the artwork for song information'**
  String get holdArtworkForInfo;

  /// No description provided for @sleepTimer.
  ///
  /// In en, this message translates to:
  /// **'Sleep timer'**
  String get sleepTimer;

  /// No description provided for @sleepTimerDescription.
  ///
  /// In en, this message translates to:
  /// **'Playback pauses when the timer ends. Your queue stays intact.'**
  String get sleepTimerDescription;

  /// No description provided for @sleepTimerMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes'**
  String sleepTimerMinutes(int minutes);

  /// No description provided for @sleepTimerRemaining.
  ///
  /// In en, this message translates to:
  /// **'Sleep timer: {time} left'**
  String sleepTimerRemaining(String time);

  /// No description provided for @cancelSleepTimer.
  ///
  /// In en, this message translates to:
  /// **'Cancel sleep timer'**
  String get cancelSleepTimer;

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create a Navidrome share link'**
  String get shareFailed;

  /// No description provided for @saveFilter.
  ///
  /// In en, this message translates to:
  /// **'Save filter'**
  String get saveFilter;

  /// No description provided for @filterName.
  ///
  /// In en, this message translates to:
  /// **'Filter name'**
  String get filterName;

  /// No description provided for @filterSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved filter \"{name}\"'**
  String filterSaved(String name);

  /// No description provided for @playlistRadio.
  ///
  /// In en, this message translates to:
  /// **'Playlist Radio'**
  String get playlistRadio;

  /// No description provided for @continueWithSimilar.
  ///
  /// In en, this message translates to:
  /// **'Continue with similar'**
  String get continueWithSimilar;

  /// No description provided for @tuneQueue.
  ///
  /// In en, this message translates to:
  /// **'Tune the queue'**
  String get tuneQueue;

  /// No description provided for @moreLikeThis.
  ///
  /// In en, this message translates to:
  /// **'More like this'**
  String get moreLikeThis;

  /// No description provided for @lessLikeThis.
  ///
  /// In en, this message translates to:
  /// **'Less like this'**
  String get lessLikeThis;

  /// No description provided for @queueTuned.
  ///
  /// In en, this message translates to:
  /// **'Upcoming songs adjusted'**
  String get queueTuned;

  /// No description provided for @albumAudioDetails.
  ///
  /// In en, this message translates to:
  /// **'Album information'**
  String get albumAudioDetails;

  /// No description provided for @albumTotalSize.
  ///
  /// In en, this message translates to:
  /// **'Total size'**
  String get albumTotalSize;

  /// No description provided for @albumFormats.
  ///
  /// In en, this message translates to:
  /// **'Formats'**
  String get albumFormats;

  /// No description provided for @albumQualityRange.
  ///
  /// In en, this message translates to:
  /// **'Audio quality'**
  String get albumQualityRange;

  /// No description provided for @quickPicks.
  ///
  /// In en, this message translates to:
  /// **'Quick Picks'**
  String get quickPicks;

  /// No description provided for @swipeActionsHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe for quick actions'**
  String get swipeActionsHint;

  /// No description provided for @newPlaylistEllipsis.
  ///
  /// In en, this message translates to:
  /// **'New playlist…'**
  String get newPlaylistEllipsis;

  /// No description provided for @createdPlaylistWithSong.
  ///
  /// In en, this message translates to:
  /// **'{name} created with the song'**
  String createdPlaylistWithSong(String name);

  /// No description provided for @createSimilarPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Create playlist of similar songs'**
  String get createSimilarPlaylist;

  /// No description provided for @similarToTitle.
  ///
  /// In en, this message translates to:
  /// **'Similar to {title}'**
  String similarToTitle(String title);

  /// No description provided for @nowPlayingLabel.
  ///
  /// In en, this message translates to:
  /// **'Now playing'**
  String get nowPlayingLabel;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearSearch;

  /// No description provided for @playerLyricsShort.
  ///
  /// In en, this message translates to:
  /// **'Lyrics'**
  String get playerLyricsShort;

  /// No description provided for @playerQueueShort.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get playerQueueShort;

  /// No description provided for @playerSleepShort.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get playerSleepShort;

  /// No description provided for @playerTuneShort.
  ///
  /// In en, this message translates to:
  /// **'Tune'**
  String get playerTuneShort;

  /// No description provided for @sleepTimerEndOfSong.
  ///
  /// In en, this message translates to:
  /// **'End of current song'**
  String get sleepTimerEndOfSong;

  /// No description provided for @likedSong.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get likedSong;

  /// No description provided for @unlikedSong.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get unlikedSong;

  /// No description provided for @serverSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Installation'**
  String get serverSetupTitle;

  /// No description provided for @serverSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional features, remote access and security'**
  String get serverSetupSubtitle;

  /// No description provided for @serverSetupIntro.
  ///
  /// In en, this message translates to:
  /// **'Use this checklist to get more from your server. Playback keeps working when an optional feature is unavailable.'**
  String get serverSetupIntro;

  /// No description provided for @serverSetupChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking server features…'**
  String get serverSetupChecking;

  /// No description provided for @serverSetupCheckAgain.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get serverSetupCheckAgain;

  /// No description provided for @serverSetupAllReady.
  ///
  /// In en, this message translates to:
  /// **'All recommended checks are ready.'**
  String get serverSetupAllReady;

  /// No description provided for @serverSetupActionsRecommended.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 improvement recommended} other{{count} improvements recommended}}'**
  String serverSetupActionsRecommended(int count);

  /// No description provided for @serverSetupReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get serverSetupReady;

  /// No description provided for @serverSetupActionRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get serverSetupActionRecommended;

  /// No description provided for @serverSetupNotDetected.
  ///
  /// In en, this message translates to:
  /// **'No matching data was found in the sample. The feature remains available to try.'**
  String get serverSetupNotDetected;

  /// No description provided for @serverSetupTip.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get serverSetupTip;

  /// No description provided for @serverSetupReadGuide.
  ///
  /// In en, this message translates to:
  /// **'Read the setup guide'**
  String get serverSetupReadGuide;

  /// No description provided for @serverSetupRemoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Listen away from home'**
  String get serverSetupRemoteTitle;

  /// No description provided for @serverSetupRemoteLocal.
  ///
  /// In en, this message translates to:
  /// **'This address works on your local network. Use Cloudflare Tunnel or Tailscale with an HTTPS address when you want access outside home.'**
  String get serverSetupRemoteLocal;

  /// No description provided for @serverSetupRemoteReady.
  ///
  /// In en, this message translates to:
  /// **'Your public server address is ready for listening outside your home network.'**
  String get serverSetupRemoteReady;

  /// No description provided for @serverSetupSmartTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart mixes'**
  String get serverSetupSmartTitle;

  /// No description provided for @serverSetupSmartReady.
  ///
  /// In en, this message translates to:
  /// **'Your server is returning similar songs, so radio, tuning and playlist suggestions are available.'**
  String get serverSetupSmartReady;

  /// No description provided for @serverSetupSmartMissing.
  ///
  /// In en, this message translates to:
  /// **'Install AudioMuse AI and enable its Navidrome plugin for sonic mixes. Quick Picks, normal playback and the rest of the app still work.'**
  String get serverSetupSmartMissing;

  /// No description provided for @serverSetupLyricsTitle.
  ///
  /// In en, this message translates to:
  /// **'Lyrics'**
  String get serverSetupLyricsTitle;

  /// No description provided for @serverSetupLyricsReady.
  ///
  /// In en, this message translates to:
  /// **'Your server returned lyrics for this library.'**
  String get serverSetupLyricsReady;

  /// No description provided for @serverSetupLyricsMissing.
  ///
  /// In en, this message translates to:
  /// **'Install the nd-lyrics plugin or add lyrics tags to your files. The player remains fully usable without lyrics.'**
  String get serverSetupLyricsMissing;

  /// No description provided for @serverSetupSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'HTTPS'**
  String get serverSetupSecurityTitle;

  /// No description provided for @serverSetupSecurityReady.
  ///
  /// In en, this message translates to:
  /// **'Your server address uses HTTPS.'**
  String get serverSetupSecurityReady;

  /// No description provided for @serverSetupSecurityHttp.
  ///
  /// In en, this message translates to:
  /// **'This local address uses HTTP. Put Cloudflare Tunnel or Tailscale in front of it before exposing the server to the internet.'**
  String get serverSetupSecurityHttp;

  /// No description provided for @serverHttpWarning.
  ///
  /// In en, this message translates to:
  /// **'HTTP is unencrypted. Use it only on a trusted local network. HTTPS is recommended.'**
  String get serverHttpWarning;

  /// No description provided for @serverSetupBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep a library backup'**
  String get serverSetupBackupTitle;

  /// No description provided for @serverSetupBackupBody.
  ///
  /// In en, this message translates to:
  /// **'Back up the Navidrome database and music files before server upgrades. This app cannot inspect your backups.'**
  String get serverSetupBackupBody;

  /// No description provided for @serverSetupPluginNote.
  ///
  /// In en, this message translates to:
  /// **'These checks use only Navidrome\'s standard Subsonic API. Soengr never connects directly to an optional plugin service.'**
  String get serverSetupPluginNote;

  /// No description provided for @supportDeveloperTitle.
  ///
  /// In en, this message translates to:
  /// **'Support the developer'**
  String get supportDeveloperTitle;

  /// No description provided for @supportDeveloperSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share the app, send feedback or ask a question'**
  String get supportDeveloperSubtitle;

  /// No description provided for @supportDeveloperHeadline.
  ///
  /// In en, this message translates to:
  /// **'Made for your own music'**
  String get supportDeveloperHeadline;

  /// No description provided for @supportDeveloperBody.
  ///
  /// In en, this message translates to:
  /// **'Soengr has no ads, tracking or subscription. Sharing it with another Navidrome listener is the best way to support its development.'**
  String get supportDeveloperBody;

  /// No description provided for @supportShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share Soengr'**
  String get supportShareTitle;

  /// No description provided for @supportShareSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send the app page to another listener'**
  String get supportShareSubtitle;

  /// No description provided for @supportShareText.
  ///
  /// In en, this message translates to:
  /// **'Soengr is a private, independent client for Navidrome:'**
  String get supportShareText;

  /// No description provided for @shareAppFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open sharing.'**
  String get shareAppFailed;

  /// No description provided for @supportEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Email support'**
  String get supportEmailTitle;

  /// No description provided for @supportMailSubject.
  ///
  /// In en, this message translates to:
  /// **'Support: Soengr'**
  String get supportMailSubject;

  /// No description provided for @supportMailBody.
  ///
  /// In en, this message translates to:
  /// **'Describe your question and include any details that may help:\n\n\n\nPlease do not include your server password.'**
  String get supportMailBody;

  /// No description provided for @websiteLabel.
  ///
  /// In en, this message translates to:
  /// **'Developer website'**
  String get websiteLabel;

  /// No description provided for @bugReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report a bug or suggestion'**
  String get bugReportTitle;

  /// No description provided for @bugReportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send a diagnostic log and describe what happened'**
  String get bugReportSubtitle;

  /// No description provided for @bugReportMailSubject.
  ///
  /// In en, this message translates to:
  /// **'Soengr: bug report or suggestion'**
  String get bugReportMailSubject;

  /// No description provided for @bugReportWhatHappened.
  ///
  /// In en, this message translates to:
  /// **'Describe what happened, what you expected, and how to reproduce it:'**
  String get bugReportWhatHappened;

  /// No description provided for @bugReportVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get bugReportVersion;

  /// No description provided for @bugReportPlatform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get bugReportPlatform;

  /// No description provided for @bugReportSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Send bug report'**
  String get bugReportSheetTitle;

  /// No description provided for @bugReportDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get bugReportDescriptionLabel;

  /// No description provided for @bugReportDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the bug or suggestion. Include what you did just before it happened.'**
  String get bugReportDescriptionHint;

  /// No description provided for @bugReportDiagnosticsNote.
  ///
  /// In en, this message translates to:
  /// **'App version, platform, local session metrics and recent errors are included automatically. Server address, username and password are removed.'**
  String get bugReportDiagnosticsNote;

  /// No description provided for @bugReportAttachImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get bugReportAttachImage;

  /// No description provided for @bugReportAttachVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get bugReportAttachVideo;

  /// No description provided for @bugReportAttachmentHelp.
  ///
  /// In en, this message translates to:
  /// **'Attach one image or video: JPEG, PNG, HEIC, MP4 or MOV.'**
  String get bugReportAttachmentHelp;

  /// No description provided for @bugReportAttachmentTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The file must be 40 MB or smaller.'**
  String get bugReportAttachmentTooLarge;

  /// No description provided for @bugReportAttachmentUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This file format is not supported.'**
  String get bugReportAttachmentUnsupported;

  /// No description provided for @bugReportAttachmentPickFailed.
  ///
  /// In en, this message translates to:
  /// **'The file could not be selected.'**
  String get bugReportAttachmentPickFailed;

  /// No description provided for @bugReportRemoveAttachment.
  ///
  /// In en, this message translates to:
  /// **'Remove attachment'**
  String get bugReportRemoveAttachment;

  /// No description provided for @bugReportSend.
  ///
  /// In en, this message translates to:
  /// **'Send report'**
  String get bugReportSend;

  /// No description provided for @bugReportSending.
  ///
  /// In en, this message translates to:
  /// **'Preparing report…'**
  String get bugReportSending;

  /// No description provided for @bugReportShareFailed.
  ///
  /// In en, this message translates to:
  /// **'The report could not be opened.'**
  String get bugReportShareFailed;

  /// No description provided for @bugReportOpened.
  ///
  /// In en, this message translates to:
  /// **'The report is ready to send.'**
  String get bugReportOpened;

  /// No description provided for @bugReportEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Briefly describe what happened.'**
  String get bugReportEmptyDescription;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'How Soengr handles your data'**
  String get privacyPolicySubtitle;

  /// No description provided for @requestRefundTitle.
  ///
  /// In en, this message translates to:
  /// **'Request a refund'**
  String get requestRefundTitle;

  /// No description provided for @requestRefundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Opens Apple\'s Report a Problem page'**
  String get requestRefundSubtitle;

  /// No description provided for @openLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'The link could not be opened.'**
  String get openLinkFailed;

  /// No description provided for @librarySyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Load entire library'**
  String get librarySyncTitle;

  /// No description provided for @librarySyncSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fetches all songs, albums, artists and playlists from the server. This may take a while.'**
  String get librarySyncSubtitle;

  /// No description provided for @librarySyncLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading library…'**
  String get librarySyncLoading;

  /// No description provided for @librarySyncComplete.
  ///
  /// In en, this message translates to:
  /// **'The entire library has been updated.'**
  String get librarySyncComplete;

  /// No description provided for @librarySyncFailed.
  ///
  /// In en, this message translates to:
  /// **'The library could not be fully updated. Check your connection and try again.'**
  String get librarySyncFailed;

  /// No description provided for @librarySyncWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting to start…'**
  String get librarySyncWaiting;

  /// No description provided for @librarySyncSongsProgress.
  ///
  /// In en, this message translates to:
  /// **'{count} songs fetched'**
  String librarySyncSongsProgress(String count);

  /// No description provided for @librarySyncArtistsProgress.
  ///
  /// In en, this message translates to:
  /// **'{count} artists fetched'**
  String librarySyncArtistsProgress(String count);

  /// No description provided for @librarySyncAlbumsProgress.
  ///
  /// In en, this message translates to:
  /// **'{count} albums fetched'**
  String librarySyncAlbumsProgress(String count);

  /// No description provided for @librarySyncPlaylistsLoading.
  ///
  /// In en, this message translates to:
  /// **'Fetching playlists…'**
  String get librarySyncPlaylistsLoading;

  /// No description provided for @librarySyncPlaylistsProgress.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} playlists fetched'**
  String librarySyncPlaylistsProgress(String count, String total);

  /// No description provided for @librarySyncFinishing.
  ///
  /// In en, this message translates to:
  /// **'Finishing and updating the library…'**
  String get librarySyncFinishing;

  /// No description provided for @librarySyncCanLeave.
  ///
  /// In en, this message translates to:
  /// **'You can leave Settings and return here to check progress.'**
  String get librarySyncCanLeave;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sv'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sv':
      return AppLocalizationsSv();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
