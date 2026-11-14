import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../design_system/widgets/navi_chrome_style.dart';
import '../../domain/playback/auto_play_profile.dart';
import '../../domain/library/song_filter.dart';

enum HomeContentFocus { songs, albums }

enum HomeHeaderStyle { wordmark, logo }

enum HomeSectionKind {
  recentlyPlayed,
  quickPicks,
  recentlyAdded,
  mostPlayed,
  fromLibrary,
}

class V2ExperiencePreferences extends ChangeNotifier {
  static const _legacyHomeFocusKey = 'v2_home_content_focus';
  static const _homeSectionContentKey = 'v2_home_section_content';
  static const _homeOrderKey = 'v2_home_section_order';
  static const _homeEnabledKey = 'v2_home_enabled_sections';
  static const _homeHeaderStyleKey = 'v2_home_header_style';
  // The recommendation keys keep their historical names so values users have
  // already tuned survive the rename of the Dart API.
  static const _recommendationExplorationKey = 'v2_audiomuse_exploration';
  static const _recommendationArtistLimitKey = 'v2_audiomuse_artist_limit';
  static const _recommendationInitialCountKey = 'v2_audiomuse_initial_count';
  static const _lastPlaylistIdKey = 'v2_last_playlist_id';
  static const _quickPicksIntroducedKey = 'v2_quick_picks_introduced';
  static const _favoriteSectionKey = 'v2_favorite_section';
  static const _favoriteSongFilterKey = 'v2_favorite_song_filter';
  static const _favoriteAlbumSortKey = 'v2_favorite_album_sort';
  static const _favoriteArtistSortKey = 'v2_favorite_artist_sort';
  static const _topBarTransparencyKey = 'v2_top_bar_transparency';
  static const _lyricsSyncOffsetKey = 'v2_lyrics_sync_offset_ms';
  static const _topBarBlurKey = 'v2_top_bar_blur_sigma';

  static const defaultHomeOrder = <HomeSectionKind>[
    HomeSectionKind.recentlyPlayed,
    HomeSectionKind.quickPicks,
    HomeSectionKind.recentlyAdded,
    HomeSectionKind.mostPlayed,
    HomeSectionKind.fromLibrary,
  ];

  static const defaultHomeContent = <HomeSectionKind, HomeContentFocus>{
    HomeSectionKind.recentlyPlayed: HomeContentFocus.songs,
    HomeSectionKind.quickPicks: HomeContentFocus.songs,
    // Recently added leads with albums: the record is the unit the listener
    // picks from, and the shelf mirrors Navidrome's own newest-album order.
    HomeSectionKind.recentlyAdded: HomeContentFocus.albums,
    HomeSectionKind.mostPlayed: HomeContentFocus.songs,
    HomeSectionKind.fromLibrary: HomeContentFocus.albums,
  };

  Map<HomeSectionKind, HomeContentFocus> homeSectionContent = Map.of(
    defaultHomeContent,
  );
  List<HomeSectionKind> homeSectionOrder = List.of(defaultHomeOrder);
  Set<HomeSectionKind> enabledHomeSections = Set.of(defaultHomeOrder);
  HomeHeaderStyle homeHeaderStyle = HomeHeaderStyle.wordmark;
  double recommendationExploration = 0.25;
  int recommendationMaxSongsPerArtist = 2;
  int recommendationInitialCandidateCount = 20;
  String? lastPlaylistId;
  String favoriteSection = 'songs';
  SongFilter favoriteSongFilter = defaultFavoriteSongFilter;
  String favoriteAlbumSort = 'title';
  String favoriteArtistSort = 'name';
  double topBarTransparency = NaviChromeStyle.defaultTopBarTransparency;

  /// Manual lyric offset, positive moves the lyrics later. It covers the
  /// latency a Bluetooth or AirPlay route adds, which the app cannot measure.
  Duration lyricsSyncOffset = Duration.zero;
  static const maxLyricsSyncOffset = Duration(seconds: 2);
  double topBarBlurSigma = NaviChromeStyle.defaultTopBarBlurSigma;

  AutoPlayProfile get autoPlayProfile => AutoPlayProfile(
    exploration: recommendationExploration,
    maxSongsPerArtist: recommendationMaxSongsPerArtist,
    initialCandidateCount: recommendationInitialCandidateCount,
  );

  HomeContentFocus homeContentFor(HomeSectionKind section) =>
      homeSectionContent[section] ?? defaultHomeContent[section]!;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final storedContent = preferences.getStringList(_homeSectionContentKey);
    if (storedContent == null) {
      final legacy = _enumByName(
        HomeContentFocus.values,
        preferences.getString(_legacyHomeFocusKey),
      );
      homeSectionContent = legacy == null
          ? Map.of(defaultHomeContent)
          : {for (final section in HomeSectionKind.values) section: legacy};
    } else {
      final parsed = <HomeSectionKind, HomeContentFocus>{};
      for (final value in storedContent) {
        final separator = value.indexOf(':');
        if (separator <= 0 || separator == value.length - 1) continue;
        final section = _enumByName(
          HomeSectionKind.values,
          value.substring(0, separator),
        );
        final content = _enumByName(
          HomeContentFocus.values,
          value.substring(separator + 1),
        );
        if (section != null && content != null) parsed[section] = content;
      }
      homeSectionContent = {
        for (final section in HomeSectionKind.values)
          section: parsed[section] ?? defaultHomeContent[section]!,
      };
    }

    final storedOrder = preferences.getStringList(_homeOrderKey) ?? const [];
    final parsedOrder = <HomeSectionKind>[];
    for (final name in storedOrder) {
      final section = _enumByName(HomeSectionKind.values, name);
      if (section != null && !parsedOrder.contains(section)) {
        parsedOrder.add(section);
      }
    }
    for (final section in defaultHomeOrder) {
      if (!parsedOrder.contains(section)) parsedOrder.add(section);
    }
    homeSectionOrder = parsedOrder;
    homeHeaderStyle =
        _enumByName(
          HomeHeaderStyle.values,
          preferences.getString(_homeHeaderStyleKey),
        ) ??
        HomeHeaderStyle.wordmark;

    final storedEnabled = preferences.getStringList(_homeEnabledKey);
    if (storedEnabled == null) {
      enabledHomeSections = Set.of(defaultHomeOrder);
    } else {
      enabledHomeSections = {
        for (final name in storedEnabled)
          ?_enumByName(HomeSectionKind.values, name),
      };
      if (enabledHomeSections.isEmpty) {
        enabledHomeSections = {HomeSectionKind.recentlyPlayed};
      }
    }
    if (!(preferences.getBool(_quickPicksIntroducedKey) ?? false)) {
      enabledHomeSections.add(HomeSectionKind.quickPicks);
      await preferences.setBool(_quickPicksIntroducedKey, true);
      await preferences.setStringList(
        _homeEnabledKey,
        homeSectionOrder
            .where(enabledHomeSections.contains)
            .map((section) => section.name)
            .toList(),
      );
    }

    recommendationExploration =
        (preferences.getDouble(_recommendationExplorationKey) ?? 0.25).clamp(
          0.0,
          1.0,
        );
    recommendationMaxSongsPerArtist =
        (preferences.getInt(_recommendationArtistLimitKey) ?? 2).clamp(1, 5);
    recommendationInitialCandidateCount =
        (preferences.getInt(_recommendationInitialCountKey) ?? 20).clamp(
          10,
          30,
        );
    lastPlaylistId = preferences.getString(_lastPlaylistIdKey);
    favoriteSection = preferences.getString(_favoriteSectionKey) ?? 'songs';
    favoriteAlbumSort = preferences.getString(_favoriteAlbumSortKey) ?? 'title';
    favoriteArtistSort =
        preferences.getString(_favoriteArtistSortKey) ?? 'name';
    topBarTransparency =
        (preferences.getDouble(_topBarTransparencyKey) ??
                NaviChromeStyle.defaultTopBarTransparency)
            .clamp(
              NaviChromeStyle.minTopBarTransparency,
              NaviChromeStyle.maxTopBarTransparency,
            );
    topBarBlurSigma =
        (preferences.getDouble(_topBarBlurKey) ??
                NaviChromeStyle.defaultTopBarBlurSigma)
            .clamp(
              NaviChromeStyle.minBarBlurSigma,
              NaviChromeStyle.maxBarBlurSigma,
            );
    lyricsSyncOffset = Duration(
      milliseconds: (preferences.getInt(_lyricsSyncOffsetKey) ?? 0).clamp(
        -maxLyricsSyncOffset.inMilliseconds,
        maxLyricsSyncOffset.inMilliseconds,
      ),
    );
    final storedFavoriteFilter = preferences.getString(_favoriteSongFilterKey);
    if (storedFavoriteFilter != null) {
      try {
        final decoded = jsonDecode(storedFavoriteFilter);
        if (decoded is Map<String, dynamic>) {
          favoriteSongFilter = SongFilter.fromJson(
            decoded,
          ).withFavoritesOnly(true);
        }
      } on FormatException {
        favoriteSongFilter = defaultFavoriteSongFilter;
      }
    }
    notifyListeners();
  }

  Future<void> setFavoriteSection(String value) async {
    if (favoriteSection == value) return;
    favoriteSection = value;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_favoriteSectionKey, value);
  }

  Future<void> setFavoriteSongFilter(SongFilter value) async {
    final normalized = value.withFavoritesOnly(true).normalized();
    favoriteSongFilter = normalized;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _favoriteSongFilterKey,
      jsonEncode(normalized.toJson()),
    );
  }

  Future<void> setFavoriteAlbumSort(String value) async {
    if (favoriteAlbumSort == value) return;
    favoriteAlbumSort = value;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_favoriteAlbumSortKey, value);
  }

  Future<void> setFavoriteArtistSort(String value) async {
    if (favoriteArtistSort == value) return;
    favoriteArtistSort = value;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_favoriteArtistSortKey, value);
  }

  Future<void> setLastPlaylistId(String? value) async {
    final normalized = value?.trim();
    final next = normalized == null || normalized.isEmpty ? null : normalized;
    if (lastPlaylistId == next) return;
    lastPlaylistId = next;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    if (next == null) {
      await preferences.remove(_lastPlaylistIdKey);
    } else {
      await preferences.setString(_lastPlaylistIdKey, next);
    }
  }

  Future<void> setHomeSectionContent(
    HomeSectionKind section,
    HomeContentFocus value,
  ) async {
    if (section == HomeSectionKind.quickPicks) {
      value = HomeContentFocus.songs;
    }
    if (homeContentFor(section) == value) return;
    homeSectionContent = {...homeSectionContent, section: value};
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_homeSectionContentKey, [
      for (final item in HomeSectionKind.values)
        '${item.name}:${homeContentFor(item).name}',
    ]);
  }

  Future<void> setHomeSectionEnabled(
    HomeSectionKind section,
    bool enabled,
  ) async {
    if (enabled) {
      enabledHomeSections.add(section);
    } else {
      if (enabledHomeSections.length == 1 &&
          enabledHomeSections.contains(section)) {
        return;
      }
      enabledHomeSections.remove(section);
    }
    notifyListeners();
    await _persistHomeSections();
  }

  Future<void> setHomeHeaderStyle(HomeHeaderStyle value) async {
    if (homeHeaderStyle == value) return;
    homeHeaderStyle = value;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_homeHeaderStyleKey, value.name);
  }

  Future<void> setLyricsSyncOffset(Duration value) async {
    final bounded = Duration(
      milliseconds: value.inMilliseconds.clamp(
        -maxLyricsSyncOffset.inMilliseconds,
        maxLyricsSyncOffset.inMilliseconds,
      ),
    );
    if (lyricsSyncOffset == bounded) return;
    lyricsSyncOffset = bounded;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_lyricsSyncOffsetKey, bounded.inMilliseconds);
  }

  Future<void> setTopBarTransparency(double value) async {
    final bounded = value.clamp(
      NaviChromeStyle.minTopBarTransparency,
      NaviChromeStyle.maxTopBarTransparency,
    );
    if (topBarTransparency == bounded) return;
    topBarTransparency = bounded;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setDouble(_topBarTransparencyKey, bounded);
  }

  Future<void> setTopBarBlurSigma(double value) async {
    final bounded = value.clamp(
      NaviChromeStyle.minBarBlurSigma,
      NaviChromeStyle.maxBarBlurSigma,
    );
    if (topBarBlurSigma == bounded) return;
    topBarBlurSigma = bounded;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setDouble(_topBarBlurKey, bounded);
  }

  Future<void> resetChromeTransparency() async {
    topBarTransparency = NaviChromeStyle.defaultTopBarTransparency;
    topBarBlurSigma = NaviChromeStyle.defaultTopBarBlurSigma;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await Future.wait([
      preferences.remove(_topBarTransparencyKey),
      preferences.remove(_topBarBlurKey),
    ]);
  }

  Future<void> reorderHomeSection(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= homeSectionOrder.length) return;
    final target = newIndex.clamp(0, homeSectionOrder.length - 1);
    if (target == oldIndex) return;
    final next = List<HomeSectionKind>.of(homeSectionOrder);
    final section = next.removeAt(oldIndex);
    next.insert(target, section);
    homeSectionOrder = next;
    notifyListeners();
    await _persistHomeSections();
  }

  Future<void> setRecommendationExploration(double value) async {
    final bounded = value.clamp(0.0, 1.0);
    if (recommendationExploration == bounded) return;
    recommendationExploration = bounded;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setDouble(_recommendationExplorationKey, bounded);
  }

  Future<void> setRecommendationMaxSongsPerArtist(int value) async {
    final bounded = value.clamp(1, 5);
    if (recommendationMaxSongsPerArtist == bounded) return;
    recommendationMaxSongsPerArtist = bounded;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_recommendationArtistLimitKey, bounded);
  }

  Future<void> setRecommendationInitialCandidateCount(int value) async {
    final bounded = value.clamp(10, 30);
    if (recommendationInitialCandidateCount == bounded) return;
    recommendationInitialCandidateCount = bounded;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_recommendationInitialCountKey, bounded);
  }

  Future<void> resetRecommendationProfile() async {
    recommendationExploration = 0.25;
    recommendationMaxSongsPerArtist = 2;
    recommendationInitialCandidateCount = 20;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await Future.wait([
      preferences.remove(_recommendationExplorationKey),
      preferences.remove(_recommendationArtistLimitKey),
      preferences.remove(_recommendationInitialCountKey),
    ]);
  }

  Future<void> _persistHomeSections() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.wait([
      preferences.setStringList(
        _homeOrderKey,
        homeSectionOrder.map((section) => section.name).toList(),
      ),
      preferences.setStringList(
        _homeEnabledKey,
        homeSectionOrder
            .where(enabledHomeSections.contains)
            .map((section) => section.name)
            .toList(),
      ),
    ]);
  }

  T? _enumByName<T extends Enum>(Iterable<T> values, String? name) {
    if (name == null) return null;
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }
}
