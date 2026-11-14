import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/local/app_database.dart';
import '../../data/local/drift_catalog_repository.dart';
import '../../data/local/drift_downloaded_library_repository.dart';
import '../../data/local/drift_home_repository.dart';
import '../../data/local/drift_lyrics_cache.dart';
import '../../data/local/drift_playback_history_repository.dart';
import '../../data/local/drift_radio_repository.dart';
import '../../data/local/drift_queue_session_repository.dart';
import '../../data/local/drift_song_library_repository.dart';
import '../../data/local/navidrome_playback_media_resolver.dart';
import '../../data/local/shared_preferences_home_rotation_store.dart';
import '../../data/local/shared_preferences_song_filter_preset_store.dart';
import '../../data/navidrome/navidrome_autoplay_provider.dart';
import '../../data/navidrome/subsonic_lyrics_gateway.dart';
import '../../data/navidrome/subsonic_play_queue_gateway.dart';
import '../../data/navidrome/subsonic_scrobble_sink.dart';
import '../../domain/diagnostics/app_metrics.dart';
import '../../domain/library/song_filter.dart';
import '../../domain/library/catalog_repository.dart';
import '../../domain/home/quick_picks_service.dart';
import '../../domain/library/navidrome_similarity_service.dart';
import '../../domain/library/library_mutation_service.dart';
import '../../domain/lyrics/lyrics_service.dart';
import '../../domain/playback/just_audio_native_port.dart';
import '../../domain/playback/playback_media_resolver.dart';
import '../../domain/playback/playback_coordinator.dart';
import '../../domain/playback/scrobble_tracker.dart';
import '../../domain/sync/catalog_sync_service.dart';
import '../../domain/sync/delta_sync_service.dart';
import '../../domain/sync/library_sync_service.dart';
import '../../domain/sync/library_sync_progress.dart';
import '../../domain/sync/radio_sync_service.dart';
import '../../features/downloads/downloads_controller.dart';
import '../../features/favorites/favorites_controller.dart';
import '../../features/home/home_controller.dart';
import '../../features/library/catalog_controllers.dart';
import '../../features/library/songs/songs_controller.dart';
import '../../features/new_music/new_music_controller.dart';
import '../../features/player/v2_audio_handler.dart';
import '../../features/player/v2_playback_controller.dart';
import '../../features/radio/radio_controller.dart';
import '../../features/search/search_controller.dart';
import '../../models/models.dart';
import '../../state/download_provider.dart';
import 'v2_diagnostics.dart';
import 'v2_experience_preferences.dart';
import 'v2_catalog_scope.dart';
import 'v2_playback_preferences.dart';
import 'v2_server_capabilities.dart';
import 'v2_server_settings.dart';

/// A delta mirror (even a nonempty one) is not a completed first import.
Future<bool> requiresInitialLibrarySync(AppDatabase database) async {
  final completed = await Future.wait([
    database.lastSuccessAt(LibrarySyncService.songsScope),
    database.lastSuccessAt(CatalogSyncService.artistsScope),
    database.lastSuccessAt(CatalogSyncService.albumsScope),
    database.lastSuccessAt(CatalogSyncService.playlistsScope),
  ]);
  return completed.any((time) => time == null);
}

Future<bool> restorePlaybackSessionSafely({
  required Future<bool> Function() restore,
  required Future<void> Function() discard,
  void Function(Object error, StackTrace stackTrace)? onError,
}) async {
  try {
    return await restore();
  } catch (error, stackTrace) {
    onError?.call(error, stackTrace);
    try {
      await discard();
    } catch (_) {
      // The runtime can start with an empty queue even if cleanup also fails.
    }
    return false;
  }
}

class V2Runtime {
  V2Runtime._({
    required this.settings,
    required this.database,
    required this.downloads,
    required this.preferences,
    required this.experience,
    required this.catalog,
    required this.songLibrary,
    required this.playback,
    required this.home,
    required this.newMusic,
    required this.radio,
    required this.library,
    required this.artists,
    required this.albums,
    required this.songs,
    required this.favorites,
    required this.search,
    required this.downloaded,
    required this.mutations,
    required this.recommendations,
    required this.lyrics,
    required this.capabilities,
    required this._librarySync,
    required this._catalogSync,
    required this._deltaSync,
    required this._radioSync,
    this._audioHandler,
  });

  static Future<V2Runtime> create(
    V2ServerSettings settings, {
    bool clearAccountCache = false,
  }) async {
    final api = settings.api;
    if (api == null) throw StateError('Navidrome is not configured');

    final database = AppDatabase();
    if (clearAccountCache) await database.clearAccountCache();
    final downloads = DownloadProvider(
      accountScope: catalogAccountScope(settings.url, settings.username),
    );
    final preferences = V2PlaybackPreferences();
    final experience = V2ExperiencePreferences();
    await Future.wait([
      downloads.load(),
      preferences.load(),
      experience.load(),
    ]);

    final catalog = DriftCatalogRepository(database);
    final songLibrary = DriftSongLibraryRepository(database);
    final mediaResolver = NavidromePlaybackMediaResolver(
      database: database,
      api: api,
      localPathFor: downloads.localPathFor,
      localArtworkPathFor: downloads.localArtworkPathFor,
      localLyricsPathFor: downloads.localLyricsPathFor,
      maximumBitRateFor: (song) =>
          preferences.dataSaverEnabled &&
              song.bitRate > V2PlaybackPreferences.dataSaverMaximumBitRate
          ? V2PlaybackPreferences.dataSaverMaximumBitRate
          : null,
      downloadedMediaResolver: (playbackKey) {
        final entry = downloads.entryForPlaybackKey(playbackKey);
        final song = entry?.song;
        if (entry == null || song == null || !File(entry.path).existsSync()) {
          return null;
        }
        return ResolvedPlaybackMedia(
          song: song,
          uri: Uri.file(entry.path),
          scrobbleSongId: entry.accountScope == downloads.accountScope
              ? song.id
              : null,
          localArtworkPath: downloads.artworkPathForEntry(entry),
          localLyricsPath: downloads.lyricsPathForEntry(entry),
        );
      },
    );
    final support = await getApplicationSupportDirectory();
    final playbackCacheDirectory = Directory('${support.path}/playback-cache');
    await playbackCacheDirectory.create(recursive: true);
    final nativePort = JustAudioNativePort(
      resolver: mediaResolver,
      cacheDirectory: playbackCacheDirectory,
    );
    final coordinator = PlaybackCoordinator(
      nativePort: nativePort,
      autoPlayCandidates: NavidromeAutoPlayProvider(
        api: api,
        database: database,
      ),
      autoPlayProfile: () => experience.autoPlayProfile,
    );
    final playback = V2PlaybackController(
      nativePort: nativePort,
      coordinator: coordinator,
      scrobbleTracker: ScrobbleTracker(
        sink: SubsonicScrobbleSink(api),
        history: DriftPlaybackHistoryRepository(database),
      ),
      queueSessions: DriftQueueSessionRepository(database),
      serverQueue: SubsonicPlayQueueGateway(api),
    );
    await restorePlaybackSessionSafely(
      restore: playback.restoreSession,
      discard: () async {
        await DriftQueueSessionRepository(database).clear();
        try {
          await nativePort.player.stop();
        } catch (_) {
          // A failed source may leave AVPlayer in an error state.
        }
        try {
          await nativePort.player.clearAudioSources();
        } catch (_) {
          // Nothing else is required to let the app start.
        }
      },
      onError: (error, stackTrace) {
        V2Diagnostics.record('Discarding unplayable restored queue: $error');
        debugPrint(
          'Discarding unplayable restored queue: '
          '${V2Diagnostics.sanitizeForLog('$error')}',
        );
        debugPrintStack(
          stackTrace: StackTrace.fromString(
            V2Diagnostics.sanitizeForLog('$stackTrace'),
          ),
        );
      },
    );
    unawaited(playback.reconcileServerQueue().catchError((_) => false));

    final songLookup = DriftDownloadedLibraryRepository(database);
    Uri? artworkUriFor(Song song) {
      final current = playback.currentMedia;
      final localPath = current?.song.id == song.id
          ? current?.localArtworkPath
          : null;
      if (localPath != null && File(localPath).existsSync()) {
        return Uri.file(localPath);
      }
      final downloadedPath = downloads.localArtworkPathFor(song.id);
      if (downloadedPath != null) return Uri.file(downloadedPath);
      final value = api.coverArtUrl(song.coverArt, size: 1000);
      return value == null ? null : Uri.parse(value);
    }

    V2AudioHandler? audioHandler;
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid || Platform.isMacOS)) {
      try {
        audioHandler = await AudioService.init(
          builder: () => V2AudioHandler(
            controller: playback,
            artworkUriFor: artworkUriFor,
          ),
          config: AudioServiceConfig(
            androidNotificationChannelId:
                'se.simonbystrom.navimusic.channel.audio',
            androidNotificationChannelName:
                PlatformDispatcher.instance.locale.languageCode == 'sv'
                ? 'Söngr'
                : 'Soengr',
            androidNotificationOngoing: true,
          ),
        );
      } catch (error) {
        V2Diagnostics.record('V2 audio service unavailable: $error');
        debugPrint(
          'V2 audio service unavailable: '
          '${V2Diagnostics.sanitizeForLog('$error')}',
        );
      }
    }

    final radioRepository = DriftRadioRepository(
      database: database,
      catalog: catalog,
      songs: songLibrary,
    );
    // Sonic similarity comes from Navidrome's getSimilarSongs2, which the
    // AudioMuse-AI Navidrome plugin answers server-side. The client never
    // calls AudioMuse directly.
    final recommendations = NavidromeSimilarityService(
      loadSimilarSongs: (songId, count) =>
          api.getSimilarSongs2(songId, count: count),
    );
    final capabilities = V2ServerCapabilities(
      serverUrl: settings.url,
      sampleSongs: (limit) =>
          songLibrary.page(filter: const SongFilter(), limit: limit, offset: 0),
      loadSimilarSongs: (songId) => api.getSimilarSongs2(songId, count: 4),
      loadLyrics: api.getLyricsLrc,
    );
    const quickPicks = QuickPicksService();
    final runtime = V2Runtime._(
      settings: settings,
      database: database,
      downloads: downloads,
      preferences: preferences,
      experience: experience,
      catalog: catalog,
      songLibrary: songLibrary,
      playback: playback,
      home: HomeController(
        repository: DriftHomeRepository(
          database,
          rotationStore: SharedPreferencesHomeRotationStore(
            scope: '${settings.url}\u0000${settings.username}',
          ),
          // The Home shelf mirrors Navidrome's own "recently added" order
          // instead of a locally derived approximation.
          newestAlbumsLoader: ({required limit}) =>
              api.getAlbumList2(size: limit),
        ),
        quickPicksLoader: (snapshot, rotation) async {
          final favorites = await songLibrary.page(
            filter: const SongFilter(favoritesOnly: true),
            limit: 200,
            offset: 0,
          );
          return quickPicks.build(
            favorites: favorites,
            recentlyPlayed: snapshot.recentlyPlayedSongs,
            mostPlayed: snapshot.mostPlayedSongs,
            recentlyAdded: snapshot.recentlyAddedSongs,
            libraryPool: snapshot.librarySongRotation,
            rotation: rotation,
            maxPerArtist: experience.recommendationMaxSongsPerArtist,
          );
        },
      ),
      newMusic: NewMusicController(catalog: catalog, songs: songLibrary),
      radio: RadioController(repository: radioRepository),
      library: LibraryOverviewController(catalog),
      artists: PagedCatalogController<ArtistSummary>(
        countLoader: (query) => catalog.artistCount(query: query),
        pageLoader: (query, limit, offset) =>
            catalog.artistsPage(query: query, limit: limit, offset: offset),
        initialSort: ArtistSort.name.name,
        sortedPageLoader: (query, limit, offset, sort, randomSeed) =>
            catalog.artistsPage(
              query: query,
              limit: limit,
              offset: offset,
              sort: ArtistSort.values.byName(sort),
              randomSeed: randomSeed,
            ),
      ),
      albums: PagedCatalogController<Album>(
        countLoader: (query) => catalog.albumCount(query: query),
        pageLoader: (query, limit, offset) =>
            catalog.albumsPage(query: query, limit: limit, offset: offset),
        initialSort: AlbumSort.title.name,
        sortedPageLoader: (query, limit, offset, sort, randomSeed) =>
            catalog.albumsPage(
              query: query,
              limit: limit,
              offset: offset,
              sort: AlbumSort.values.byName(sort),
              randomSeed: randomSeed,
            ),
      ),
      songs: SongsController(
        repository: songLibrary,
        presetStore: SharedPreferencesSongFilterPresetStore(
          scope: '${settings.url}\u0000${settings.username}',
        ),
      ),
      favorites: FavoritesController(
        songLibrary: songLibrary,
        catalog: catalog,
        preferences: experience,
      ),
      search: V2SearchController(catalog: catalog, songLibrary: songLibrary),
      downloaded: V2DownloadsController(
        downloads: downloads,
        repository: songLookup,
      ),
      mutations: LibraryMutationService(
        api: api,
        database: database,
        downloads: downloads,
      ),
      recommendations: recommendations,
      lyrics: LyricsService(
        cache: DriftLyricsCache(database),
        gateway: SubsonicLyricsGateway(api),
      ),
      capabilities: capabilities,
      librarySync: LibrarySyncService(
        database: database,
        gateway: SubsonicSongGateway(api),
      ),
      catalogSync: CatalogSyncService(
        database: database,
        gateway: SubsonicCatalogGateway(api),
      ),
      deltaSync: DeltaSyncService(
        database: database,
        gateway: SubsonicDeltaGateway(api),
      ),
      radioSync: RadioSyncService(api: api, database: database),
      audioHandler: audioHandler,
    );
    return runtime;
  }

  final V2ServerSettings settings;
  final AppDatabase database;
  final DownloadProvider downloads;
  final V2PlaybackPreferences preferences;
  final V2ExperiencePreferences experience;
  final DriftCatalogRepository catalog;
  final DriftSongLibraryRepository songLibrary;
  final V2PlaybackController playback;
  final HomeController home;
  final NewMusicController newMusic;
  final RadioController radio;
  final LibraryOverviewController library;
  final PagedCatalogController<ArtistSummary> artists;
  final PagedCatalogController<Album> albums;
  final SongsController songs;
  final FavoritesController favorites;
  final V2SearchController search;
  final V2DownloadsController downloaded;
  final LibraryMutationService mutations;
  final NavidromeSimilarityService recommendations;
  final LyricsService lyrics;
  final V2ServerCapabilities capabilities;
  final LibrarySyncService _librarySync;
  final CatalogSyncService _catalogSync;
  final DeltaSyncService _deltaSync;
  final RadioSyncService _radioSync;
  final V2AudioHandler? _audioHandler;
  Future<void>? _syncInFlight;
  Future<bool>? _serverQueueInFlight;
  Future<bool>? _fullLibrarySyncInFlight;
  bool _disposed = false;
  final librarySyncProgress = ValueNotifier<LibrarySyncProgress?>(null);

  Future<bool> needsInitialLibrarySync() =>
      requiresInitialLibrarySync(database);

  Future<bool> syncEntireLibrary() {
    final active = _fullLibrarySyncInFlight;
    if (active != null) return active;
    _reportLibrarySyncProgress(
      const LibrarySyncProgress(LibrarySyncStage.waiting),
    );
    final run = refreshNow(forceFull: true).whenComplete(() {
      _fullLibrarySyncInFlight = null;
      if (!_disposed) librarySyncProgress.value = null;
    });
    _fullLibrarySyncInFlight = run;
    return run;
  }

  void _reportLibrarySyncProgress(LibrarySyncProgress progress) {
    if (!_disposed) librarySyncProgress.value = progress;
  }

  Future<String?> loadLyrics(Song song) {
    final current = playback.currentMedia;
    final localPath = current?.song.id == song.id
        ? current?.localLyricsPath
        : null;
    return lyrics.load(song.id, localPath: localPath);
  }

  /// Refreshes the local mirror.
  ///
  /// The default path is the cheap delta sync: newest albums only, one request
  /// plus one per changed album, independent of library size. [forceFull] pages
  /// the whole catalogue and is reserved for an account switch or an explicit
  /// "sync everything" action.
  ///
  /// A caller during an in-flight run is queued instead of being handed the
  /// older run. Dropping it is what made pull-to-refresh appear to do nothing
  /// when a background sync happened to be running.
  /// [refreshFavorites] is false for the automatic resume/reconnect sync: the
  /// Favorites page keeps what it already shows and only updates when the user
  /// favourites something, pulls down, or asks for a refresh.
  Future<void> sync({
    bool rotateHomeLibrary = false,
    bool forceFull = false,
    bool refreshFavorites = true,
  }) {
    final active = _syncInFlight;
    if (active != null) {
      // The queued request reports its own result, even if the earlier run failed.
      return active
          .then<void>((_) {}, onError: (Object _, StackTrace _) {})
          .then(
            (_) => sync(
              rotateHomeLibrary: rotateHomeLibrary,
              forceFull: forceFull,
              refreshFavorites: refreshFavorites,
            ),
          );
    }
    final tracked = _performSync(
      rotateHomeLibrary: rotateHomeLibrary,
      forceFull: forceFull,
      refreshFavorites: refreshFavorites,
    ).whenComplete(() => _syncInFlight = null);
    _syncInFlight = tracked;
    return tracked;
  }

  /// Explicit refresh for pull-to-refresh, reconnect and app resume.
  ///
  /// Reports whether the server answered so the UI can say so instead of
  /// spinning and going quiet.
  Future<bool> refreshNow({
    bool rotateHomeLibrary = false,
    bool forceFull = false,
    bool refreshFavorites = true,
  }) async {
    try {
      await sync(
        rotateHomeLibrary: rotateHomeLibrary,
        forceFull: forceFull,
        refreshFavorites: refreshFavorites,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _performSync({
    required bool rotateHomeLibrary,
    required bool forceFull,
    bool refreshFavorites = true,
  }) async {
    final stopwatch = Stopwatch()..start();
    Object? firstError;
    for (final operation in <Future<void> Function()>[
      () => mutations.replayPendingFavorites(),
      if (forceFull)
        () async =>
            _librarySync.syncSongs(onProgress: _reportLibrarySyncProgress),
      if (forceFull)
        () async =>
            _catalogSync.syncAll(onProgress: _reportLibrarySyncProgress),
      if (!forceFull) () async => _deltaSync.syncRecent(),
      () async => _radioSync.refresh(),
    ]) {
      try {
        await operation();
      } catch (error) {
        firstError ??= error;
      }
    }
    if (forceFull) {
      _reportLibrarySyncProgress(
        const LibrarySyncProgress(LibrarySyncStage.finishing),
      );
    }
    await Future.wait([
      // Home's activation/pull already renewed the selection. Metadata arriving
      // later must preserve it; the first empty selection is populated normally.
      home.refresh(rotateLibrary: rotateHomeLibrary, rotateQuickPicks: false),
      newMusic.refresh(),
      radio.refresh(),
      library.refresh(),
      artists.refresh(),
      albums.refresh(),
      songs.refresh(),
      if (refreshFavorites) favorites.refresh(),
      search.initialize(),
      downloaded.refresh(),
    ]);
    AppMetrics.duration(
      'catalog_sync',
      stopwatch.elapsed,
      success: firstError == null,
    );
    if (firstError != null) throw firstError;
    if (_disposed) return;
    // Queue recovery and offline audio downloads must not hold the catalogue
    // refresh indicator (or the first library import) open.
    _serverQueueInFlight ??= playback
        .reconcileServerQueue()
        .catchError((_) => false)
        .whenComplete(() => _serverQueueInFlight = null);
    unawaited(_serverQueueInFlight);
    unawaited(
      _reconcileOfflineMedia().catchError((Object error) {
        V2Diagnostics.record('Offline reconciliation failed: $error');
      }),
    );
    unawaited(capabilities.refresh());
  }

  Future<void>? _playlistSyncInFlight;
  bool _playlistSyncPending = false;

  /// Serialized like [sync]: `_syncPlaylists` swaps a single shared staging
  /// table into place, so two overlapping runs can race and leave the local
  /// table empty (whichever commits last wins with whatever the other run's
  /// `beginPlaylistStaging()` left behind). Concurrent callers share the
  /// in-flight run; one more run is queued after it so a mutation made while
  /// a sync was underway is not lost.
  Future<void> syncPlaylists() {
    final active = _playlistSyncInFlight;
    if (active != null) {
      _playlistSyncPending = true;
      return active;
    }
    final tracked = _runPlaylistSync().whenComplete(() {
      _playlistSyncInFlight = null;
      if (_playlistSyncPending) {
        _playlistSyncPending = false;
        unawaited(syncPlaylists());
      }
    });
    _playlistSyncInFlight = tracked;
    return tracked;
  }

  Future<void> _runPlaylistSync() async {
    await _catalogSync.syncPlaylists();
    await library.refresh();
    await _reconcileOfflineMedia();
  }

  Future<void>? _offlineMediaInFlight;
  bool _offlineMediaPending = false;

  Future<void> _reconcileOfflineMedia() {
    if (_disposed) return Future<void>.value();
    final active = _offlineMediaInFlight;
    if (active != null) {
      _offlineMediaPending = true;
      return active;
    }
    final tracked = _runOfflineMediaReconcile().whenComplete(() {
      _offlineMediaInFlight = null;
      if (_offlineMediaPending && !_disposed) {
        _offlineMediaPending = false;
        unawaited(
          _reconcileOfflineMedia().catchError((Object error) {
            V2Diagnostics.record('Offline reconciliation failed: $error');
          }),
        );
      }
    });
    _offlineMediaInFlight = tracked;
    return tracked;
  }

  Future<void> _runOfflineMediaReconcile() async {
    final api = settings.api;
    if (api == null) return;
    final playlists = await catalog.ownPlaylists();
    final byPlaylist = <String, List<Song>>{};
    for (final playlist in playlists) {
      if (downloads.isPlaylistOffline(playlist.id)) {
        byPlaylist[playlist.id] = await catalog.songsForPlaylist(playlist.id);
      }
    }
    await downloads.syncOfflinePlaylists(byPlaylist, api);

    if (downloads.favoritesOfflineEnabled) {
      final favorites = <Song>[];
      var offset = 0;
      while (true) {
        final page = await songLibrary.page(
          filter: const SongFilter(favoritesOnly: true),
          limit: 500,
          offset: offset,
        );
        favorites.addAll(page);
        if (page.length < 500) break;
        offset += page.length;
      }
      await downloads.syncFavorites(favorites, api);
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    // These jobs still own the player/database/download provider until settled.
    await _serverQueueInFlight;
    await _offlineMediaInFlight?.catchError((_) {});
    librarySyncProgress.dispose();
    _audioHandler?.detach();
    home.dispose();
    newMusic.dispose();
    radio.dispose();
    library.dispose();
    artists.dispose();
    albums.dispose();
    songs.dispose();
    favorites.dispose();
    search.dispose();
    downloaded.dispose();
    await playback.shutdown();
    playback.dispose();
    preferences.dispose();
    experience.dispose();
    capabilities.dispose();
    await downloads.waitForPendingDownloads;
    downloads.dispose();
    await database.close();
  }
}
