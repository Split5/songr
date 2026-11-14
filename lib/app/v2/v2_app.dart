import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

import '../../design_system/navi_design_tokens.dart';
import '../../design_system/navi_theme.dart';
import '../../design_system/widgets/navi_widgets.dart';
import '../../features/downloads/v2_downloads_screen.dart';
import '../../features/favorites/favorites_move_flow.dart';
import '../../features/favorites/v2_favorites_screen.dart';
import '../../features/home/v2_home_screen.dart';
import '../../features/library/catalog_controllers.dart';
import '../../features/library/songs/songs_controller.dart';
import '../../features/library/songs/v2_songs_screen.dart';
import '../../features/library/v2_artist_screen.dart';
import '../../features/library/v2_library_screens.dart';
import '../../features/new_music/v2_new_music_screen.dart';
import '../../features/player/v2_full_player.dart';
import '../../features/radio/v2_radio_screen.dart';
import '../../features/search/v2_search_screen.dart';
import '../../features/settings/v2_connection_screen.dart';
import '../../features/settings/v2_settings_screen.dart';
import '../../features/settings/library_sync_progress_view.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../state/download_provider.dart';
import '../../domain/library/catalog_repository.dart';
import '../../domain/diagnostics/app_metrics.dart';
import '../../domain/library/playlist_ordering.dart';
import '../../domain/library/song_filter.dart';
import 'v2_artwork_cache.dart';
import 'song_menu_entries.dart';
import 'v2_catalog_scope.dart';
import 'v2_connectivity.dart';
import 'v2_runtime.dart';
import 'v2_experience_preferences.dart';
import 'v2_server_settings.dart';
import 'v2_shell.dart';
import 'v2_splash_fallback.dart';

/// Reorders Library songs randomly with a fresh epoch-ms seed and opens them.
///
/// [now] is injectable so tests can pin the seed; production uses [DateTime.now].
Future<void> openRandomSongs({
  required SongsController songs,
  required BuildContext context,
  required VoidCallback openSongs,
  DateTime Function()? now,
}) async {
  await songs.applyFilter(
    SongFilter(
      sort: SongSort.random,
      randomSeed: (now ?? DateTime.now)().millisecondsSinceEpoch,
    ),
  );
  if (!context.mounted) return;
  openSongs();
}

class NaviMusicV2App extends StatelessWidget {
  const NaviMusicV2App({super.key, required this.settings});

  final V2ServerSettings settings;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: NaviTheme.dark(),
    home: _V2Gate(settings: settings),
  );
}

class _V2Gate extends StatefulWidget {
  const _V2Gate({required this.settings});

  final V2ServerSettings settings;

  @override
  State<_V2Gate> createState() => _V2GateState();
}

class _V2GateState extends State<_V2Gate> with WidgetsBindingObserver {
  static const _catalogScopeKey = 'v2_catalog_scope';

  V2Runtime? _runtime;
  FavoritesMoveFlow? _favoritesMoveFlow;
  V2Runtime? _initializingRuntime;
  Object? _error;
  bool _creating = false;
  bool _nativeSplashRemoved = false;
  String _signature = '';
  String _accountScope = '';
  bool _online = true;
  DateTime _lastRecoverySync = DateTime.fromMillisecondsSinceEpoch(0);
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.settings.addListener(_settingsChanged);
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      final resume = shouldResumeSync(wasOnline: _online, results: results);
      _online = hasNetwork(results);
      if (resume) _syncAfterReconnect();
    });
    unawaited(
      Connectivity().checkConnectivity().then(
        (results) => _online = hasNetwork(results),
      ),
    );
    _settingsChanged();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_connectivitySubscription?.cancel());
    widget.settings.removeListener(_settingsChanged);
    final runtime = _runtime;
    if (runtime != null) unawaited(runtime.dispose());
    super.dispose();
  }

  FavoritesMoveFlow _createFavoritesMoveFlow(V2Runtime runtime) =>
      FavoritesMoveFlow(
        loadSongs: runtime.favorites.allFavoriteSongs,
        loadAlbums: runtime.catalog.allStarredAlbums,
        loadArtists: runtime.catalog.allStarredArtists,
        moveFavorites:
            ({
              required name,
              required songs,
              required albums,
              required artists,
            }) => runtime.mutations.moveFavoritesToPlaylist(
              name: name,
              songs: songs,
              albums: albums,
              artists: artists,
            ),
        setLastPlaylistId: runtime.experience.setLastPlaylistId,
        syncPlaylists: runtime.syncPlaylists,
        refreshFavorites: runtime.favorites.refresh,
      );

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    unawaited(
      Connectivity().checkConnectivity().then((results) {
        _online = hasNetwork(results);
        if (_online) _syncAfterReconnect();
      }),
    );
  }

  void _syncAfterReconnect() {
    final runtime = _runtime;
    if (runtime == null) return;
    final now = DateTime.now();
    if (now.difference(_lastRecoverySync) < const Duration(seconds: 30)) {
      return;
    }
    _lastRecoverySync = now;
    unawaited(() async {
      try {
        // Coming back to the app must not reload the Favourites page; that
        // surface updates on a favourite toggle or a pull instead.
        await runtime.sync(refreshFavorites: false);
      } catch (_) {}
      try {
        await runtime.capabilities.refresh();
      } catch (_) {}
    }());
  }

  void _settingsChanged() {
    if (!widget.settings.isConfigured || _creating) {
      if (mounted) setState(() {});
      return;
    }
    final signature =
        '${widget.settings.url}\u0000${widget.settings.username}\u0000${widget.settings.password}';
    final accountScope = catalogAccountScope(
      widget.settings.url,
      widget.settings.username,
    );
    if (_runtime != null &&
        signature == _signature &&
        accountScope == _accountScope) {
      return;
    }
    unawaited(_createRuntime(signature, accountScope));
  }

  Future<void> _createRuntime(String signature, String accountScope) async {
    final startup = Stopwatch()..start();
    _creating = true;
    final old = _runtime;
    final preferences = await SharedPreferences.getInstance();
    final previousScope = preferences.getString(_catalogScopeKey);
    final clearAccountCache = shouldClearCatalogCache(
      storedScope: previousScope,
      url: widget.settings.url,
      currentScope: accountScope,
      sameSessionAccountChanged: old != null && accountScope != _accountScope,
    );
    _runtime = null;
    _favoritesMoveFlow = null;
    if (mounted) setState(() => _error = null);
    if (old != null) await old.dispose();
    V2Runtime? created;
    try {
      final runtime = created = await V2Runtime.create(
        widget.settings,
        clearAccountCache: clearAccountCache,
      );
      if (!mounted) {
        await runtime.dispose();
        return;
      }
      final initialImport = await runtime.needsInitialLibrarySync();
      if (!mounted) {
        await runtime.dispose();
        return;
      }
      if (initialImport) {
        setState(() => _initializingRuntime = runtime);
        final success = await runtime.syncEntireLibrary();
        if (!success) {
          throw StateError('Initial library import failed');
        }
      }
      if (!mounted) {
        await runtime.dispose();
        return;
      }
      await runtime.home.initialize();
      if (!mounted) {
        await runtime.dispose();
        return;
      }
      await preferences.setString(_catalogScopeKey, accountScope);
      if (!mounted) {
        await runtime.dispose();
        return;
      }
      setState(() {
        _runtime = runtime;
        _favoritesMoveFlow = _createFavoritesMoveFlow(runtime);
        _initializingRuntime = null;
        _signature = signature;
        _accountScope = accountScope;
      });
      AppMetrics.duration('startup_runtime', startup.elapsed);
      if (!initialImport) {
        unawaited(runtime.sync().catchError((_) {}));
      }
    } catch (error) {
      _initializingRuntime = null;
      if (created != null) await created.dispose();
      AppMetrics.duration('startup_runtime', startup.elapsed, success: false);
      if (mounted) setState(() => _error = error);
    } finally {
      _creating = false;
    }
  }

  /// Lets the native splash go the first time there is real content to show
  /// (runtime, error or connection screen).
  void _releaseNativeSplash() {
    if (_nativeSplashRemoved) return;
    _nativeSplashRemoved = true;
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.settings.isConfigured) {
      _releaseNativeSplash();
      return V2ConnectionScreen(settings: widget.settings);
    }
    final runtime = _runtime;
    if (runtime != null) {
      _releaseNativeSplash();
      return _RuntimeView(
        runtime: runtime,
        favoritesMoveFlow: _favoritesMoveFlow!,
      );
    }
    final initializing = _initializingRuntime;
    if (initializing != null) {
      _releaseNativeSplash();
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(NaviSpacing.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).librarySyncLoading,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: NaviSpacing.md),
                    ValueListenableBuilder(
                      valueListenable: initializing.librarySyncProgress,
                      builder: (context, progress, _) =>
                          LibrarySyncProgressView(progress: progress),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    if (_error != null) {
      _releaseNativeSplash();
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(NaviSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppLocalizations.of(context).couldNotConnect('$_error')),
                const SizedBox(height: NaviSpacing.md),
                FilledButton.tonal(
                  style: NaviTheme.tonalButtonStyle,
                  onPressed: () => _settingsChanged(),
                  child: Text(AppLocalizations.of(context).tryAgain),
                ),
              ],
            ),
          ),
        ),
      );
    }
    // The fallback uses the native splash's black canvas. Hand over after its
    // first frame so every platform shows the same small loading mark.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _releaseNativeSplash();
    });
    return const V2SplashFallback();
  }
}

class _RuntimeView extends StatelessWidget {
  const _RuntimeView({required this.runtime, required this.favoritesMoveFlow});

  final V2Runtime runtime;
  final FavoritesMoveFlow favoritesMoveFlow;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([
      runtime.playback,
      runtime.experience,
      runtime.capabilities,
    ]),
    builder: (context, _) {
      final l = AppLocalizations.of(context);
      return V2Shell(
        tabs: [
          V2TabSpec(
            destination: NaviDockDestination(
              label: l.navHome,
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
            ),
            rootBuilder: _home,
          ),
          V2TabSpec(
            destination: NaviDockDestination(
              label: l.navFavorites,
              icon: Icons.favorite_border_rounded,
              selectedIcon: Icons.favorite_rounded,
              accentColor: NaviColors.accent,
            ),
            rootBuilder: _favorites,
          ),
          V2TabSpec(
            destination: NaviDockDestination(
              label: l.navNew,
              icon: Icons.auto_awesome_outlined,
              selectedIcon: Icons.auto_awesome_rounded,
            ),
            rootBuilder: _newMusic,
          ),
          V2TabSpec(
            destination: NaviDockDestination(
              label: l.navLibrary,
              icon: Icons.library_music_outlined,
              selectedIcon: Icons.library_music_rounded,
            ),
            rootBuilder: _library,
          ),
          V2TabSpec(
            destination: NaviDockDestination(
              label: l.tooltipSearch,
              icon: Icons.search_rounded,
              selectedIcon: Icons.manage_search_rounded,
            ),
            rootBuilder: _search,
          ),
        ],
        nowPlaying: _miniPlayer(context),
        onOpenPlayer:
            runtime.playback.currentSong == null &&
                runtime.playback.currentStation == null
            ? null
            : () => _openPlayer(context),
        onTogglePlayback: () => unawaited(runtime.playback.togglePlayback()),
        onSkipPrevious: () => unawaited(runtime.playback.previous()),
        onSkipNext: () => unawaited(runtime.playback.next()),
        topBarTransparency: runtime.experience.topBarTransparency,
        topBarBlurSigma: runtime.experience.topBarBlurSigma,
      );
    },
  );

  Widget _home(BuildContext context) => V2HomeScreen(
    controller: runtime.home,
    preferences: runtime.experience,
    nowPlaying: runtime.playback.currentSongIdListenable,
    playing: runtime.playback.playingListenable,
    songArtworkBuilder: _songArtwork,
    albumArtworkBuilder: (context, album) =>
        _catalogArtwork(context, album.coverArt, Icons.album_rounded),
    playlistArtworkBuilder: _catalogArtwork,
    artworkWarmer: (coverArt) => _warmCover(
      coverArt,
      coverArtRequestSize(
        logicalSide: 144,
        devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
      ),
    ),
    onSongTap: _playSong,
    onSongMenu: (song) => _showSongMenu(context, song),
    onAlbumTap: (album) => _openAlbum(context, album),
    onPlaylistTap: (playlist) => _openPlaylist(context, playlist),
    onOpenSettings: () => _openSettings(context),
    onRefresh: () async {
      // The gesture must end with a real fetch, never with a silently reused
      // run; the delta path keeps that fetch cheap on large libraries.
      await runtime
          .refreshNow(rotateHomeLibrary: true)
          .timeout(const Duration(seconds: 30), onTimeout: () => false);
    },
    onRotateLibrary: () => runtime.home.refresh(rotateLibrary: true),
    onShowMore: (section, focus) => _showMoreHome(context, section, focus),
  );

  Future<void> _showMoreHome(
    BuildContext context,
    HomeSectionKind section,
    HomeContentFocus focus,
  ) async {
    if (focus == HomeContentFocus.albums ||
        section == HomeSectionKind.recentlyAdded ||
        section == HomeSectionKind.fromLibrary) {
      final sort = switch (section) {
        HomeSectionKind.recentlyPlayed => AlbumSort.recentlyPlayed,
        HomeSectionKind.recentlyAdded => AlbumSort.recentlyAdded,
        HomeSectionKind.mostPlayed => AlbumSort.mostPlayed,
        HomeSectionKind.fromLibrary ||
        HomeSectionKind.quickPicks ||
        HomeSectionKind.playlists => AlbumSort.random,
      };
      await runtime.albums.setSort(
        sort.name,
        randomize: sort == AlbumSort.random,
      );
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => V2AlbumsScreen(
            controller: runtime.albums,
            artworkBuilder: _catalogArtwork,
            onAlbumTap: (album) => _openAlbum(context, album),
          ),
        ),
      );
      return;
    }

    final sort = switch (section) {
      HomeSectionKind.recentlyPlayed => SongSort.recentlyPlayed,
      HomeSectionKind.mostPlayed => SongSort.mostPlayed,
      HomeSectionKind.quickPicks => SongSort.random,
      HomeSectionKind.recentlyAdded ||
      HomeSectionKind.fromLibrary ||
      HomeSectionKind.playlists => SongSort.recentlyPlayed,
    };
    await runtime.songs.applyFilter(
      SongFilter(
        sort: sort,
        randomSeed: sort == SongSort.random
            ? DateTime.now().microsecondsSinceEpoch
            : 0,
      ),
    );
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => V2SongsScreen(
          controller: runtime.songs,
          onRefresh: () => runtime.refreshNow(),
          artworkBuilder: _songArtwork,
          nowPlaying: runtime.playback.currentSongIdListenable,
          playing: runtime.playback.playingListenable,
          onSongTap: (song) {
            final visible = runtime.songs.songs.toList(growable: false);
            unawaited(
              runtime.playback.playSongs(
                visible,
                startIndex: visible.indexWhere((item) => item.id == song.id),
              ),
            );
          },
          onSongMenu: (song) => _showSongMenu(context, song),
          quickSwipeActionBuilder: _quickSwipeAction,
        ),
      ),
    );
  }

  Widget _newMusic(BuildContext context) => V2NewMusicScreen(
    controller: runtime.newMusic,
    onRefresh: () => runtime.refreshNow(),
    nowPlaying: runtime.playback.currentSongIdListenable,
    playing: runtime.playback.playingListenable,
    artworkBuilder: _catalogArtwork,
    onAlbumTap: (album) => _openAlbum(context, album),
    onSongTap: _playSong,
    onSongMenu: (song) => _showSongMenu(context, song),
  );

  Widget _radio(BuildContext context) => V2RadioScreen(
    controller: runtime.radio,
    onRefresh: () => runtime.refreshNow(),
    artworkBuilder: _catalogArtwork,
    onStationTap: runtime.playback.playStation,
    onSongsReady: (songs) =>
        unawaited(runtime.playback.playSongs(songs, shuffle: true)),
  );

  Widget _favorites(BuildContext context) => V2FavoritesScreen(
    controller: runtime.favorites,
    onRefresh: () => runtime.refreshNow(),
    nowPlaying: runtime.playback.currentSongIdListenable,
    playing: runtime.playback.playingListenable,
    songArtworkBuilder: _songArtwork,
    catalogArtworkBuilder: _catalogArtwork,
    onSongTap: (song) {
      final visible = runtime.favorites.songs.songs.toList(growable: false);
      final index = visible.indexWhere((item) => item.id == song.id);
      unawaited(
        runtime.playback.playSongs(visible, startIndex: index < 0 ? 0 : index),
      );
    },
    onSongMenu: (song) => _showSongMenu(context, song),
    onAlbumTap: (album) => _openAlbum(context, album),
    onArtistTap: (artist) => _openArtist(context, artist),
    onPlaySongs: (songs, {required shuffle}) =>
        unawaited(runtime.playback.playSongs(songs, shuffle: shuffle)),
    onPlayMix: (favorites) => _playFavoritesMix(context, favorites),
    onMoveToPlaylist: () => unawaited(_moveFavoritesToPlaylist(context)),
    onFindSongs: () => unawaited(_openRandomSongs(context)),
  );

  Future<void> _openRandomSongs(BuildContext context) async {
    await openRandomSongs(
      songs: runtime.songs,
      context: context,
      openSongs: () => _openSongs(context),
    );
  }

  void _openSongs(BuildContext context) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => V2SongsScreen(
        controller: runtime.songs,
        onRefresh: () => runtime.refreshNow(),
        artworkBuilder: _songArtwork,
        nowPlaying: runtime.playback.currentSongIdListenable,
        playing: runtime.playback.playingListenable,
        onSongTap: (song) {
          final visible = runtime.songs.songs.toList(growable: false);
          unawaited(
            runtime.playback.playSongs(
              visible,
              startIndex: visible.indexWhere((item) => item.id == song.id),
            ),
          );
        },
        onSongMenu: (song) => _showSongMenu(context, song),
        quickSwipeActionBuilder: _quickSwipeAction,
      ),
    ),
  );

  Future<void> _playFavoritesMix(
    BuildContext context,
    List<Song> favorites,
  ) async {
    try {
      final mix = await runtime.recommendations.mixFrom(favorites, limit: 30);
      if (mix.isNotEmpty) await runtime.playback.playSongs(mix);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).similarSuggestionsError),
          ),
        );
      }
    }
  }

  Future<void> _moveFavoritesToPlaylist(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final result = await favoritesMoveFlow.run(
      confirm: () => _confirmMoveFavoritesToPlaylist(context, l),
      playlistName: () =>
          l.favoritesToPlaylistName(_favoritesPlaylistDate(DateTime.now())),
    );
    switch (result.status) {
      case FavoritesMoveStatus.cancelled:
      case FavoritesMoveStatus.busy:
        return;
      case FavoritesMoveStatus.empty:
        messenger.showSnackBar(SnackBar(content: Text(l.noFavoritesToMove)));
        break;
      case FavoritesMoveStatus.moved:
        messenger.showSnackBar(
          SnackBar(
            content: Text(l.favoritesMovedToPlaylist(result.playlistName!)),
          ),
        );
        break;
      case FavoritesMoveStatus.movedPartially:
        messenger.showSnackBar(
          SnackBar(
            content: Text(l.favoritesMovedPartially(result.playlistName!)),
          ),
        );
        break;
      case FavoritesMoveStatus.failed:
        messenger.showSnackBar(
          SnackBar(content: Text(l.playlistSaveFailed('${result.error}'))),
        );
        break;
    }
  }

  Future<bool> _confirmMoveFavoritesToPlaylist(
    BuildContext context,
    AppLocalizations l,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.moveFavoritesToPlaylistTitle),
        content: Text(l.moveFavoritesToPlaylistBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: NaviColors.destructive,
              foregroundColor: NaviColors.canvas,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l.moveFavoritesToPlaylistConfirm),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  String _favoritesPlaylistDate(DateTime now) =>
      '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';

  Widget _playlists(BuildContext context) => V2PlaylistsScreen(
    controller: runtime.library,
    onRefresh: () => runtime.refreshNow(),
    artworkBuilder: _catalogArtwork,
    onPlaylistTap: (playlist) => _openPlaylist(context, playlist),
    onCreatePlaylist: () => unawaited(_createPlaylist(context)),
    onDeletePlaylist: (playlist) => _confirmDeletePlaylist(context, playlist),
  );

  Widget _library(BuildContext context) => V2LibraryScreen(
    controller: runtime.library,
    onPrepareArtists: () => _prepareArtists(context),
    artworkBuilder: _catalogArtwork,
    onAlbumTap: (album) => _openAlbum(context, album),
    onOpenPlaylists: () => Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: _playlists)),
    onOpenRadio: () =>
        Navigator.of(context).push(MaterialPageRoute<void>(builder: _radio)),
    onOpenArtists: () => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => V2ArtistsScreen(
          controller: runtime.artists,
          artworkBuilder: (context, coverArt, fallback) =>
              _artwork(context, coverArt, fallback, pixels: 160),
          onArtistTap: (artist) => _openArtist(context, artist),
        ),
      ),
    ),
    onOpenAlbums: () => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => V2AlbumsScreen(
          controller: runtime.albums,
          artworkBuilder: _catalogArtwork,
          onAlbumTap: (album) => _openAlbum(context, album),
        ),
      ),
    ),
    onOpenSongs: () => _openSongs(context),
    onOpenDownloads: () => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => V2DownloadsScreen(
          controller: runtime.downloaded,
          artworkBuilder: _downloadArtwork,
          onOpenSettings: () => _openSettings(context),
          nowPlaying: runtime.playback.currentSongIdListenable,
          playing: runtime.playback.playingListenable,
          onSongTap: (entry) {
            final visible = runtime.downloaded.visibleEntries;
            final index = visible.indexWhere((item) => item.key == entry.key);
            unawaited(
              runtime.playback.playDownloaded(
                visible,
                startIndex: index < 0 ? 0 : index,
              ),
            );
          },
          onPlayAll: (entries) =>
              unawaited(runtime.playback.playDownloaded(entries)),
          onSongMenu: (entry) {
            if (entry.accountScope == runtime.downloads.accountScope) {
              _showSongMenu(context, entry.song!);
            } else {
              _showDownloadedOnlyMenu(context, entry);
            }
          },
        ),
      ),
    ),
  );

  Widget _search(BuildContext context) => V2SearchScreen(
    controller: runtime.search,
    nowPlaying: runtime.playback.currentSongIdListenable,
    playing: runtime.playback.playingListenable,
    artworkBuilder: _catalogArtwork,
    onSongTap: _playSong,
    onSongMenu: (song) => _showSongMenu(context, song),
    onAlbumTap: (album) => _openAlbum(context, album),
    onArtistTap: (artist) => _openArtist(context, artist),
    onPlaylistTap: (playlist) => _openPlaylist(context, playlist),
  );

  void _openAlbum(BuildContext context, Album album) => _openCollection(
    context,
    title: album.name,
    subtitle: album.artist,
    coverArt: album.coverArt,
    loader: () => runtime.catalog.songsForAlbum(album),
    album: album,
  );

  void _openArtist(BuildContext context, ArtistSummary artist) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => V2ArtistScreen(
            artist: artist,
            catalog: runtime.catalog,
            onRefresh: () => runtime.refreshNow(),
            artworkBuilder: _catalogArtwork,
            onAlbumTap: (album) => _openAlbum(context, album),
            onSongTap: _playSong,
            onPlay: (songs) => unawaited(runtime.playback.playSongs(songs)),
            onShuffle: (songs) =>
                unawaited(runtime.playback.playSongs(songs, shuffle: true)),
            onSongMenu: (song) => _showSongMenu(context, song),
            nowPlaying: runtime.playback.currentSongIdListenable,
            playing: runtime.playback.playingListenable,
          ),
        ),
      );

  void _openPlaylist(BuildContext context, Playlist playlist) =>
      _openCollection(
        context,
        title: playlist.name,
        coverArt: playlist.coverArt,
        loader: () => runtime.catalog.songsForPlaylist(playlist.id),
        playlist: playlist,
      );

  void _openCollection(
    BuildContext context, {
    required String title,
    required Future<List<Song>> Function() loader,
    String? subtitle,
    String? coverArt,
    Album? album,
    Playlist? playlist,
  }) {
    final controller = SongCollectionController(loader);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _OwnedCollection(
          controller: controller,
          downloads: runtime.downloads,
          builder: (context) {
            final playlistOffline =
                playlist != null &&
                runtime.downloads.isPlaylistOffline(playlist.id);
            final albumReason = album == null
                ? null
                : albumDownloadReason(album.id);
            final albumOffline =
                albumReason != null &&
                controller.songs.isNotEmpty &&
                controller.songs.every(
                  (song) =>
                      runtime.downloads.entries[song.id]?.reasons.contains(
                        albumReason,
                      ) ==
                      true,
                );
            return V2SongCollectionScreen(
              title: title,
              subtitle: subtitle,
              coverArt: coverArt,
              album: album,
              controller: controller,
              artworkBuilder: _catalogArtwork,
              nowPlaying: runtime.playback.currentSongIdListenable,
              playing: runtime.playback.playingListenable,
              offline: playlistOffline || albumOffline,
              onToggleOffline: playlist != null
                  ? () => runtime.downloads.setPlaylistOffline(
                      !playlistOffline,
                      playlist,
                      controller.songs,
                      runtime.settings.api!,
                    )
                  : album != null
                  ? () async {
                      if (albumOffline) {
                        await runtime.downloads.removeReasonFromAll(
                          controller.songs.map((song) => song.id),
                          albumReason,
                        );
                      } else {
                        await runtime.downloads.downloadSongs(
                          controller.songs,
                          runtime.settings.api!,
                          albumReason!,
                          label: album.name,
                        );
                      }
                    }
                  : null,
              onSongTap: (song) {
                final index = controller.songs.indexWhere(
                  (item) => item.id == song.id,
                );
                unawaited(
                  runtime.playback.playSongs(
                    controller.songs,
                    startIndex: index < 0 ? 0 : index,
                  ),
                );
              },
              onSongMenu: (song) => _showSongMenu(
                context,
                song,
                sourcePlaylist: playlist,
                sourceSongs: controller.songs,
              ),
              quickSwipeActionBuilder: _quickSwipeAction,
              suggestionLoader:
                  playlist == null || runtime.capabilities.smartMixesDisabled
                  ? null
                  : (source, {refresh = false}) => runtime.recommendations
                        .recommendations(source, limit: 12, refresh: refresh),
              onAddSuggestion: playlist == null
                  ? null
                  : (song) async {
                      await runtime.mutations.addToPlaylist(song, playlist);
                      await runtime.experience.setLastPlaylistId(playlist.id);
                      unawaited(runtime.syncPlaylists().catchError((_) {}));
                    },
              onPlaylistRadio:
                  playlist == null || runtime.capabilities.smartMixesDisabled
                  ? null
                  : () => _playPlaylistRadio(controller.songs),
              onContinueSimilar:
                  playlist == null || runtime.capabilities.smartMixesDisabled
                  ? null
                  : () => _continuePlaylistWithSimilar(controller.songs),
              additionalActions: [
                if (album != null || playlist != null)
                  IconButton(
                    tooltip: AppLocalizations.of(context).share,
                    onPressed: playlist != null && controller.songs.isEmpty
                        ? null
                        : () => unawaited(
                            _shareItems(
                              context,
                              ids: album != null
                                  ? [album.id]
                                  : controller.songs
                                        .map((song) => song.id)
                                        .toList(growable: false),
                              description: album?.name ?? playlist!.name,
                            ),
                          ),
                    icon: const Icon(Icons.ios_share_rounded),
                  ),
                if (playlist != null)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'rename':
                          unawaited(_renamePlaylist(context, playlist));
                        case 'delete':
                          unawaited(_deletePlaylist(context, playlist));
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'rename',
                        child: Text(
                          AppLocalizations.of(context).renamePlaylist,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          AppLocalizations.of(context).deletePlaylist,
                        ),
                      ),
                    ],
                  ),
              ],
              onPlay: () =>
                  unawaited(runtime.playback.playSongs(controller.songs)),
              onShuffle: () => unawaited(
                runtime.playback.playSongs(controller.songs, shuffle: true),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _playPlaylistRadio(List<Song> source) async {
    final mix = await runtime.recommendations.mixFrom(
      source,
      limit: 30,
      refresh: true,
    );
    if (mix.isEmpty) return;
    await runtime.playback.setAutoPlay(true);
    await runtime.playback.playSongs(mix);
  }

  Future<void> _continuePlaylistWithSimilar(List<Song> source) async {
    if (source.isEmpty) return;
    final related = await runtime.recommendations.recommendations(
      source,
      limit: 20,
      refresh: true,
    );
    await runtime.playback.setAutoPlay(true);
    if (source.length == 1) {
      await runtime.playback.playSonicMix(source.single);
      if (related.isNotEmpty) await runtime.playback.appendSongs(related);
      return;
    }
    await runtime.playback.playSongs(source);
    if (related.isNotEmpty) await runtime.playback.appendSongs(related);
  }

  void _openPlayer(BuildContext context) =>
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (playerContext) => V2FullPlayer(
            controller: runtime.playback,
            artworkBuilder: _songArtwork,
            lyricsLoader: runtime.loadLyrics,
            lyricsOffset: () => runtime.experience.lyricsSyncOffset,
            onLyricsOffsetChanged: runtime.experience.setLyricsSyncOffset,
            onTuneQueue: runtime.capabilities.smartMixesDisabled
                ? null
                : _tuneQueue,
            isFavorite: (song) => song.starred,
            onToggleFavorite: (song) => _toggleFavorite(context, song),
            onSongMenu: (menuContext, song) => _showSongMenu(menuContext, song),
            onAlbumTap: (song) {
              Navigator.of(playerContext).pop();
              _openAlbum(
                context,
                Album(
                  id: song.albumId,
                  name: song.album,
                  artist: primaryArtistName(song.artist),
                  artistId: song.artistId,
                  coverArt: song.coverArt,
                ),
              );
            },
            onArtistTap: (song) {
              Navigator.of(playerContext).pop();
              _openArtist(
                context,
                ArtistSummary(
                  id: song.artistId,
                  name: primaryArtistName(song.artist),
                  coverArt: song.coverArt,
                ),
              );
            },
          ),
        ),
      );

  /// Re-plans the upcoming queue around the current song using only
  /// Navidrome's `getSimilarSongs2` (served by the AudioMuse plugin).
  Future<void> _tuneQueue(QueueTuneAction action) async {
    final current = runtime.playback.currentSong;
    if (current == null) return;
    final upcoming = await runtime.playback.queueSongs(upcomingOnly: true);
    List<Song> tuned;
    switch (action) {
      case QueueTuneAction.moreLikeThis:
        tuned = await runtime.recommendations.recommendations(
          [current],
          limit: 20,
          refresh: true,
        );
        break;
      case QueueTuneAction.lessLikeThis:
        var positive = _firstSong(
          upcoming.where(
            (song) =>
                song.id != current.id &&
                primaryArtistName(song.artist).toLowerCase() !=
                    primaryArtistName(current.artist).toLowerCase(),
          ),
        );
        if (positive == null) {
          final discovery = await runtime.recommendations.recommendations(
            [current],
            limit: 12,
            refresh: true,
          );
          positive = _firstSong(
            discovery.where((song) => song.id != current.id),
          );
        }
        if (positive == null) return;
        tuned = await runtime.recommendations.recommendations(
          [positive],
          limit: 20,
          refresh: true,
        );
        final currentArtist = primaryArtistName(current.artist).toLowerCase();
        tuned = tuned
            .where(
              (song) =>
                  primaryArtistName(song.artist).toLowerCase() !=
                      currentArtist &&
                  song.albumId != current.albumId,
            )
            .toList(growable: false);
        break;
    }
    final selected = _diversifySongs(
      tuned.where((song) => song.id != current.id),
      limit: 16,
      maxPerArtist: runtime.experience.recommendationMaxSongsPerArtist,
    );
    if (selected.isEmpty) {
      throw StateError('Navidrome returned no usable similar songs');
    }
    await runtime.playback.setAutoPlay(true);
    await runtime.playback.replaceUpcomingSongs(selected);
  }

  Song? _firstSong(Iterable<Song> songs) {
    for (final song in songs) {
      return song;
    }
    return null;
  }

  List<Song> _diversifySongs(
    Iterable<Song> songs, {
    required int limit,
    required int maxPerArtist,
  }) {
    final selected = <Song>[];
    final seen = <String>{};
    final perArtist = <String, int>{};
    for (final song in songs) {
      if (!seen.add(song.id)) continue;
      final artist = primaryArtistName(song.artist).trim().toLowerCase();
      if ((perArtist[artist] ?? 0) >= maxPerArtist) continue;
      selected.add(song);
      perArtist[artist] = (perArtist[artist] ?? 0) + 1;
      if (selected.length >= limit) break;
    }
    return List.unmodifiable(selected);
  }

  void _openSettings(BuildContext context) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => V2SettingsScreen(
        server: runtime.settings,
        playback: runtime.preferences,
        experience: runtime.experience,
        downloads: runtime.downloads,
        capabilities: runtime.capabilities,
        onSyncLibrary: runtime.syncEntireLibrary,
        librarySyncProgress: runtime.librarySyncProgress,
      ),
    ),
  );

  void _playSong(Song song) {
    if (runtime.capabilities.smartMixesDisabled) {
      unawaited(runtime.playback.playSongs([song]));
      return;
    }
    unawaited(runtime.playback.playSonicMix(song));
  }

  NaviMiniPlayerData? _miniPlayer(BuildContext context) {
    final song = runtime.playback.currentSong;
    final station = runtime.playback.currentStation;
    if (song == null && station == null) return null;
    final l = AppLocalizations.of(context);
    final duration = runtime.playback.duration.inMilliseconds;
    return NaviMiniPlayerData(
      title: song?.title ?? station!.name,
      subtitle: song == null ? l.navRadio : primaryArtistName(song.artist),
      artwork: song == null
          ? const ColoredBox(
              color: NaviColors.surfaceRaised,
              child: Icon(Icons.radio_rounded),
            )
          : _songArtwork(context, song),
      progress: duration <= 0
          ? 0
          : runtime.playback.position.inMilliseconds / duration,
      isPlaying: runtime.playback.playing,
      starting: runtime.playback.startingPlayback,
      tintSource: song == null ? null : _coverTintSource(song),
      playLabel: l.play,
      pauseLabel: l.pause,
      skipNextLabel: l.nextTrack,
      positionListenable: runtime.playback.positionListenable,
      duration: runtime.playback.duration,
    );
  }

  Future<void> _prepareArtists(BuildContext context) async {
    final api = runtime.settings.api;
    final accountScope = runtime.downloads.accountScope;
    await runtime.artists.refresh();
    if (!context.mounted || api == null) return;
    // Warm the first viewport, not thousands of artist portraits.
    await Future.wait([
      for (final artist in runtime.artists.state.items.take(8))
        if (artist.coverArt?.isNotEmpty ?? false)
          precacheImage(
            CachedNetworkImageProvider(
              api.coverArtUrl(artist.coverArt, size: 160)!,
              cacheKey: coverArtCacheKey(
                accountScope: accountScope,
                coverArt: artist.coverArt!,
                size: 160,
              ),
              cacheManager: artworkCacheManager,
            ),
            context,
            onError: (Object _, StackTrace? _) {},
          ),
    ]);
  }

  /// The cover the player bar samples its colour from. A downloaded song
  /// already has its artwork on disk; anything else uses the same disk cache
  /// the artwork widget reads, at a size that is only used for the colour.
  ImageProvider? _coverTintSource(Song song) {
    final current = runtime.playback.currentMedia;
    final currentPath = current?.song.id == song.id
        ? current?.localArtworkPath
        : null;
    final localPath =
        currentPath ?? runtime.downloads.localArtworkPathFor(song.id);
    if (localPath != null && File(localPath).existsSync()) {
      return FileImage(File(localPath));
    }
    final api = runtime.settings.api;
    final coverArt = song.coverArt;
    if (api == null || coverArt == null || coverArt.isEmpty) return null;
    final url = api.coverArtUrl(coverArt, size: 100);
    if (url == null) return null;
    return CachedNetworkImageProvider(
      url,
      cacheKey: coverArtCacheKey(
        accountScope: runtime.downloads.accountScope,
        coverArt: coverArt,
        size: 100,
      ),
      cacheManager: artworkCacheManager,
    );
  }

  Widget _songArtwork(BuildContext context, Song song) {
    final current = runtime.playback.currentMedia;
    final currentPath = current?.song.id == song.id
        ? current?.localArtworkPath
        : null;
    final localPath =
        currentPath ?? runtime.downloads.localArtworkPathFor(song.id);
    if (localPath != null && File(localPath).existsSync()) {
      return Image.file(
        File(localPath),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            NaviArtwork(fallback: Icons.music_note_rounded, radius: 0),
      );
    }
    return _artwork(context, song.coverArt, Icons.music_note_rounded);
  }

  Widget _downloadArtwork(BuildContext context, DownloadedEntry entry) {
    final localPath = runtime.downloads.artworkPathForEntry(entry);
    if (localPath != null) {
      return Image.file(
        File(localPath),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            NaviArtwork(fallback: Icons.music_note_rounded, radius: 0),
      );
    }
    return _artwork(context, entry.song?.coverArt, Icons.music_note_rounded);
  }

  Widget _catalogArtwork(
    BuildContext context,
    String? coverArt,
    IconData fallback,
  ) => _artwork(context, coverArt, fallback);

  /// Unclipped artwork for callers that round their own corners; the neutral
  /// [NaviArtwork] fallback paints when there is no art or it fails to load.
  ///
  /// Without [pixels] the request size follows the space the artwork actually
  /// gets on this device, so a 48 pt row fetches a thumbnail instead of a
  /// 600 px cover. [pixels] pins one server size for callers that precache the
  /// same image (the artist list) and must hit the same cache entry.
  Widget _artwork(
    BuildContext context,
    String? coverArt,
    IconData fallback, {
    int? pixels,
  }) {
    final api = runtime.settings.api;
    if (api == null || coverArt == null) {
      return NaviArtwork(fallback: fallback, radius: 0);
    }
    final accountScope = runtime.downloads.accountScope;

    Widget cover(int size) => CachedNetworkImage(
      imageUrl: api.coverArtUrl(coverArt, size: size)!,
      cacheKey: coverArtCacheKey(
        accountScope: accountScope,
        coverArt: coverArt,
        size: size,
      ),
      cacheManager: artworkCacheManager,
      fit: BoxFit.cover,
      placeholder: (_, _) => const ColoredBox(color: NaviColors.surfaceRaised),
      fadeInDuration: const Duration(milliseconds: 160),
      errorWidget: (_, _, _) => NaviArtwork(fallback: fallback, radius: 0),
    );

    if (pixels != null) return cover(pixels);
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = _artworkSide(constraints);
        if (side == null) return cover(600);
        return cover(
          coverArtRequestSize(
            logicalSide: side,
            devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
          ),
        );
      },
    );
  }

  /// Warm one cover the home carousels are about to show, straight into the
  /// disk cache the cards read from. Runs off the widget tree on purpose: a
  /// warm-up must never depend on a [BuildContext] that may be gone.
  Future<void> _warmCover(String? coverArt, int size) async {
    final api = runtime.settings.api;
    if (api == null || coverArt == null || coverArt.isEmpty) return;
    final url = api.coverArtUrl(coverArt, size: size);
    if (url == null) return;
    try {
      await artworkCacheManager.getSingleFile(
        url,
        key: coverArtCacheKey(
          accountScope: runtime.downloads.accountScope,
          coverArt: coverArt,
          size: size,
        ),
      );
    } catch (_) {
      // A warm-up that fails costs nothing; the card retries when it shows.
    }
  }

  /// The side the artwork will occupy, or null when nothing bounds it.
  double? _artworkSide(BoxConstraints constraints) {
    final width = constraints.hasBoundedWidth ? constraints.maxWidth : null;
    final height = constraints.hasBoundedHeight ? constraints.maxHeight : null;
    if (width == null) return height;
    if (height == null) return width;
    return width < height ? width : height;
  }

  Future<void> _toggleFavorite(BuildContext context, Song song) async {
    try {
      await runtime.mutations.toggleFavorite(
        song,
        onLocalChange: () async {
          runtime.playback.markSongStarred(song.id, song.starred);
          unawaited(_refreshSongSurfaces());
        },
      );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).playlistSaveFailed('$error'),
            ),
          ),
        );
      }
      rethrow;
    }
  }

  void _showDownloadedOnlyMenu(BuildContext context, DownloadedEntry entry) {
    final l = AppLocalizations.of(context);
    showNaviSongMenu(
      context: context,
      song: entry.song!,
      artwork: _songArtwork(context, entry.song!),
      entries: [
        NaviSongMenuEntry(
          icon: Icons.play_arrow_rounded,
          label: l.play,
          onTap: () => unawaited(runtime.playback.playDownloaded([entry])),
        ),
        NaviSongMenuEntry(
          icon: Icons.delete_outline_rounded,
          label: l.downloadRemoveSong,
          destructive: true,
          onTap: () => unawaited(runtime.downloads.removeEntry(entry)),
        ),
      ],
    );
  }

  /// The one song action sheet, shared by every list surface, the swipe-left
  /// gesture and the long-press.
  Future<void> _showSongMenu(
    BuildContext context,
    Song song, {
    Playlist? sourcePlaylist,
    List<Song>? sourceSongs,
  }) {
    final l = AppLocalizations.of(context);
    final downloaded = runtime.downloads.isDownloaded(song.id);
    final lastPlaylist = _playlistById(runtime.experience.lastPlaylistId);
    return showNaviSongMenu(
      context: context,
      song: song,
      artwork: _songArtwork(context, song),
      entries: songMenuEntries(
        l: l,
        song: song,
        downloaded: downloaded,
        lastPlaylist: lastPlaylist,
        actions: SongMenuActions(
          toggleFavorite: () =>
              unawaited(_toggleFavorite(context, song).catchError((_) {})),
          playNext: () => unawaited(runtime.playback.playNext(song)),
          addToQueue: () => unawaited(runtime.playback.appendSongs([song])),
          addToPlaylist: () => unawaited(_showPlaylistPicker(context, song)),
          addToLastPlaylist: (playlist) =>
              unawaited(_addSongToPlaylist(context, song, playlist)),
          goToAlbum: () => _openAlbum(
            context,
            Album(
              id: song.albumId,
              name: song.album,
              artist: primaryArtistName(song.artist),
              artistId: song.artistId,
              coverArt: song.coverArt,
            ),
          ),
          goToArtist: () => _openArtist(
            context,
            ArtistSummary(
              id: song.artistId,
              name: primaryArtistName(song.artist),
              coverArt: song.coverArt,
            ),
          ),
          createMix: runtime.capabilities.smartMixesDisabled
              ? null
              : () => unawaited(runtime.playback.playSonicMix(song)),
          createSimilarPlaylist: runtime.capabilities.smartMixesDisabled
              ? null
              : () => unawaited(_createSimilarPlaylist(context, song)),
          download: () => unawaited(
            runtime.downloads.downloadSong(
              song,
              runtime.settings.api!,
              manualDownloadReason,
            ),
          ),
          removeDownload: () =>
              unawaited(runtime.downloads.removeSong(song.id)),
          share: () => unawaited(
            _shareItems(
              context,
              ids: [song.id],
              description: '${song.title} — ${primaryArtistName(song.artist)}',
            ),
          ),
          removeFromPlaylist: sourcePlaylist == null || sourceSongs == null
              ? null
              : () => unawaited(
                  _removeFromPlaylist(
                    context,
                    sourcePlaylist,
                    sourceSongs,
                    song,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _removeFromPlaylist(
    BuildContext context,
    Playlist playlist,
    List<Song> songs,
    Song song,
  ) async {
    try {
      final index = songs.indexWhere((item) => item.id == song.id);
      if (index < 0) return;
      final occurrence = songs
          .take(index)
          .where((item) => item.id == song.id)
          .length;
      await runtime.mutations.removeFromPlaylist(
        playlist: playlist,
        songId: song.id,
        occurrence: occurrence,
      );
      await runtime.syncPlaylists();
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).playlistSaveFailed('$error'),
            ),
          ),
        );
      }
    }
  }

  /// Builds a playlist from Navidrome's similar songs for [song], named
  /// "Similar to {title}" unless the user renames it.
  Future<void> _createSimilarPlaylist(BuildContext context, Song song) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    List<Song> similar;
    try {
      similar = await runtime.recommendations.recommendations(
        [song],
        limit: 25,
        refresh: true,
      );
    } catch (_) {
      similar = const [];
    }
    if (similar.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l.similarSuggestionsError)),
      );
      return;
    }
    if (!context.mounted) return;
    final name = await showNaviNameDialog(
      context: context,
      title: l.newPlaylist,
      label: l.playlistName,
      confirmLabel: l.create,
      initial: l.similarToTitle(song.title),
    );
    if (name == null) return;
    try {
      final id = await runtime.mutations.createPlaylistWithSongs(name, [
        song,
        ...similar.where((item) => item.id != song.id),
      ]);
      await runtime.experience.setLastPlaylistId(id);
      unawaited(runtime.syncPlaylists().catchError((_) {}));
      messenger.showSnackBar(
        SnackBar(content: Text(l.createdPlaylistWithSong(name))),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(l.playlistSaveFailed('$error'))),
      );
    }
  }

  NaviSwipeAction? _quickSwipeAction(BuildContext context, Song song) {
    final playlist = _playlistById(runtime.experience.lastPlaylistId);
    if (playlist == null) return null;
    final l = AppLocalizations.of(context);
    return NaviSwipeAction(
      icon: Icons.playlist_add_check_rounded,
      label: l.addToNamedPlaylist(playlist.name),
      color: NaviColors.success,
      onInvoke: () async {
        final before = await runtime.catalog.songsForPlaylist(playlist.id);
        await runtime.mutations.addToPlaylist(song, playlist);
        await runtime.experience.setLastPlaylistId(playlist.id);
        await runtime.syncPlaylists();
        return NaviSwipeUndo(
          message: l.addedToPlaylist(playlist.name),
          undo: () async {
            await runtime.mutations.removeFromPlaylist(
              playlist: playlist,
              songId: song.id,
              occurrence: before.where((item) => item.id == song.id).length,
            );
            await runtime.syncPlaylists();
          },
        );
      },
    );
  }

  Future<void> _refreshSongSurfaces() => Future.wait([
    runtime.favorites.refresh(),
    runtime.songs.refresh(),
    runtime.home.refresh(),
  ]);

  Future<void> _showPlaylistPicker(BuildContext context, Song song) =>
      showNaviPlaylistPicker(
        context: context,
        playlists: _orderedPlaylists(),
        lastPlaylistId: runtime.experience.lastPlaylistId,
        onPick: (playlist) =>
            unawaited(_addSongToPlaylist(context, song, playlist)),
        onCreate: (name) =>
            unawaited(_createPlaylistWithSong(context, name, song)),
      );

  Future<void> _createPlaylistWithSong(
    BuildContext context,
    String name,
    Song song,
  ) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final id = await runtime.mutations.createPlaylistWithSongs(name, [song]);
      await runtime.experience.setLastPlaylistId(id);
      unawaited(runtime.syncPlaylists().catchError((_) {}));
      messenger.showSnackBar(
        SnackBar(content: Text(l.createdPlaylistWithSong(name))),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(l.playlistSaveFailed('$error'))),
      );
    }
  }

  List<Playlist> _orderedPlaylists() {
    return prioritizeLastPlaylist(
      runtime.library.state.playlists,
      runtime.experience.lastPlaylistId,
    );
  }

  Playlist? _playlistById(String? id) {
    if (id == null) return null;
    for (final playlist in runtime.library.state.playlists) {
      if (playlist.id == id) return playlist;
    }
    return null;
  }

  Future<void> _addSongToPlaylist(
    BuildContext context,
    Song song,
    Playlist playlist,
  ) async {
    final l = AppLocalizations.of(context);
    try {
      await runtime.mutations.addToPlaylist(song, playlist);
      await runtime.experience.setLastPlaylistId(playlist.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.addedToPlaylist(playlist.name))),
        );
      }
      unawaited(runtime.syncPlaylists().catchError((_) {}));
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.playlistSaveFailed('$error'))));
      }
    }
  }

  Future<void> _shareItems(
    BuildContext context, {
    required List<String> ids,
    required String description,
  }) async {
    try {
      final share = await runtime.settings.api!.createShare(
        ids,
        description: description,
      );
      await SharePlus.instance.share(
        ShareParams(subject: description, text: '$description\n${share.url}'),
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).shareFailed)),
        );
      }
    }
  }

  Future<void> _deletePlaylist(BuildContext context, Playlist playlist) async {
    final deleted = await _confirmDeletePlaylist(context, playlist);
    if (deleted && context.mounted) Navigator.of(context).pop();
  }

  Future<bool> _confirmDeletePlaylist(
    BuildContext context,
    Playlist playlist,
  ) async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.deletePlaylist),
        content: Text(l.deletePlaylistConfirm(playlist.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return false;
    try {
      await runtime.mutations.deletePlaylist(playlist);
      runtime.library.removePlaylist(playlist.id);
      unawaited(runtime.syncPlaylists().catchError((_) {}));
      return true;
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.playlistSaveFailed('$error'))));
      }
      return false;
    }
  }

  Future<void> _renamePlaylist(BuildContext context, Playlist playlist) async {
    final l = AppLocalizations.of(context);
    final name = await showNaviNameDialog(
      context: context,
      title: l.renamePlaylist,
      label: l.playlistName,
      confirmLabel: l.save,
      initial: playlist.name,
    );
    if (name == null || name == playlist.name) return;
    try {
      await runtime.mutations.renamePlaylist(playlist, name);
      await runtime.syncPlaylists().catchError((_) {});
      if (context.mounted) Navigator.of(context).pop();
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.playlistSaveFailed('$error'))));
      }
    }
  }

  Future<void> _createPlaylist(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final name = await showNaviNameDialog(
      context: context,
      title: l.newPlaylist,
      label: l.playlistName,
      confirmLabel: l.create,
    );
    if (name == null) return;
    await runtime.mutations.createPlaylist(name);
    await runtime.syncPlaylists();
  }
}

class _OwnedCollection extends StatefulWidget {
  const _OwnedCollection({
    required this.controller,
    required this.downloads,
    required this.builder,
  });

  final SongCollectionController controller;
  final DownloadProvider downloads;
  final WidgetBuilder builder;

  @override
  State<_OwnedCollection> createState() => _OwnedCollectionState();
}

class _OwnedCollectionState extends State<_OwnedCollection> {
  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([widget.controller, widget.downloads]),
    builder: (context, _) => widget.builder(context),
  );
}
