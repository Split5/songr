import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/v2/v2_experience_preferences.dart';
import '../../design_system/navi_design_tokens.dart';
import '../../design_system/navi_theme.dart';
import '../../design_system/widgets/navi_artwork.dart';
import '../../design_system/widgets/navi_glass.dart';
import '../../domain/home/quick_picks_service.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import 'home_controller.dart';

typedef HomeSongArtworkBuilder =
    Widget Function(BuildContext context, Song song);
typedef HomeAlbumArtworkBuilder =
    Widget Function(BuildContext context, Album album);
typedef HomePlaylistArtworkBuilder =
    Widget Function(BuildContext context, String? coverArt, IconData fallback);
typedef HomeShowMoreCallback =
    Future<void> Function(HomeSectionKind section, HomeContentFocus focus);

class V2HomeScreen extends StatefulWidget {
  const V2HomeScreen({
    super.key,
    required this.controller,
    required this.preferences,
    this.songArtworkBuilder,
    this.albumArtworkBuilder,
    this.playlistArtworkBuilder,
    this.onSongTap,
    this.onSongMenu,
    this.onAlbumTap,
    this.onPlaylistTap,
    this.onOpenSettings,
    this.onRefresh,
    this.onRotateLibrary,
    this.onShowMore,
    this.nowPlaying,
    this.playing,
  });

  final HomeController controller;
  final V2ExperiencePreferences preferences;
  final HomeSongArtworkBuilder? songArtworkBuilder;
  final HomeAlbumArtworkBuilder? albumArtworkBuilder;
  final HomePlaylistArtworkBuilder? playlistArtworkBuilder;
  final ValueChanged<Song>? onSongTap;
  final ValueChanged<Song>? onSongMenu;
  final ValueChanged<Album>? onAlbumTap;
  final ValueChanged<Playlist>? onPlaylistTap;
  final VoidCallback? onOpenSettings;
  final Future<void> Function()? onRefresh;

  final Future<void> Function()? onRotateLibrary;
  final HomeShowMoreCallback? onShowMore;

  /// Id of the song at the playhead and whether it is playing.
  // TODO(navi): use NaviMediaCard(nowPlaying: …) for the song shelves.
  final ValueListenable<String?>? nowPlaying;
  final ValueListenable<bool>? playing;

  @override
  State<V2HomeScreen> createState() => _V2HomeScreenState();
}

class _V2HomeScreenState extends State<V2HomeScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(widget.controller.initialize());
  }

  Future<void> _refresh() async {
    final onRefresh = widget.onRefresh;
    if (onRefresh != null) {
      await widget.controller.refreshQuickPicks();
      if (!mounted) return;
      return onRefresh();
    }
    return widget.controller.refresh(rotateLibrary: true);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([widget.controller, widget.preferences]),
    builder: (context, _) {
      final state = widget.controller.state;
      final l = AppLocalizations.of(context);
      return Scaffold(
        body: NaviArtworkAtmosphere(
          primary: NaviColors.atmosphereWine,
          secondary: NaviColors.atmospherePlum,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              NaviSliverHeader(
                titleSpacing:
                    widget.preferences.homeHeaderStyle == HomeHeaderStyle.logo
                    ? NaviSpacing.xs
                    : NaviSpacing.page,
                title:
                    widget.preferences.homeHeaderStyle == HomeHeaderStyle.logo
                    ? Semantics(
                        label: l.appTitle,
                        image: true,
                        child: SvgPicture.asset(
                          'assets/branding/app-logo.svg',
                          key: const ValueKey('home-brand-mark'),
                          width: 38,
                          height: 38,
                          fit: BoxFit.contain,
                        ),
                      )
                    : Text(l.appTitle),
                actions: [
                  if (widget.onOpenSettings != null)
                    IconButton(
                      tooltip: l.tooltipSettings,
                      onPressed: widget.onOpenSettings,
                      icon: const Icon(Icons.settings_rounded),
                    ),
                ],
              ),
              CupertinoSliverRefreshControl(
                onRefresh: _refresh,
                refreshTriggerPullDistance:
                    MediaQuery.textScalerOf(context).scale(64) + 36,
                refreshIndicatorExtent: MediaQuery.textScalerOf(
                  context,
                ).scale(64),
                builder: (context, mode, pulled, trigger, extent) {
                  if (mode != RefreshIndicatorMode.refresh) {
                    return CupertinoSliverRefreshControl.buildRefreshIndicator(
                      context,
                      mode,
                      pulled,
                      trigger,
                      extent,
                    );
                  }
                  return Semantics(
                    liveRegion: true,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: NaviSpacing.page,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CupertinoActivityIndicator(
                              color: NaviColors.textSecondary,
                              animating: !MediaQuery.disableAnimationsOf(
                                context,
                              ),
                            ),
                            const SizedBox(width: NaviSpacing.sm),
                            Flexible(
                              child: Text(
                                l.homeRefreshingAlbums,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (state.loading && !_hasContent(state))
                ..._loadingShelves()
              else if (state.error != null && !_hasContent(state))
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _HomeMessage(
                    icon: Icons.cloud_off_rounded,
                    title: l.couldNotLoadLibrary('${state.error}'),
                    subtitle: l.homeEmptyHint,
                    actionLabel: l.tryAgain,
                    onAction: widget.controller.refresh,
                  ),
                )
              else if (!_hasContent(state))
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _HomeMessage(
                    icon: Icons.library_music_rounded,
                    title: l.nothingToShowYet,
                    subtitle: l.homeEmptyHint,
                  ),
                )
              else ...[
                if (state.error != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        NaviSpacing.page,
                        0,
                        NaviSpacing.page,
                        NaviSpacing.md,
                      ),
                      child: NaviGlass(
                        padding: const EdgeInsets.all(NaviSpacing.md),
                        child: Row(
                          children: [
                            const Icon(Icons.cloud_off_rounded, size: 20),
                            const SizedBox(width: NaviSpacing.sm),
                            Expanded(
                              child: Text(
                                l.couldNotLoadLibrary('${state.error}'),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            TextButton(
                              onPressed: widget.controller.refresh,
                              child: Text(l.tryAgain),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ..._contentShelves(l, state),
                const SliverToBoxAdapter(
                  child: SizedBox(height: NaviSpacing.xl),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );

  bool _hasContent(HomeViewState state) {
    if (state.recentlyPlayedPlaylists.isNotEmpty) return true;
    for (final section in widget.preferences.homeSectionOrder) {
      if (!widget.preferences.enabledHomeSections.contains(section)) continue;
      final content = widget.preferences.homeContentFor(section);
      final hasItems = switch ((content, section)) {
        (HomeContentFocus.songs, HomeSectionKind.recentlyPlayed) =>
          state.recentlyPlayedSongs.isNotEmpty,
        (HomeContentFocus.songs, HomeSectionKind.quickPicks) =>
          state.quickPicks.isNotEmpty,
        (HomeContentFocus.songs, HomeSectionKind.recentlyAdded) =>
          state.recentlyAddedSongs.isNotEmpty,
        (HomeContentFocus.songs, HomeSectionKind.mostPlayed) =>
          state.mostPlayedSongs.isNotEmpty,
        (HomeContentFocus.songs, HomeSectionKind.fromLibrary) =>
          state.librarySongRotation.isNotEmpty,
        (HomeContentFocus.albums, HomeSectionKind.recentlyPlayed) =>
          state.recentlyPlayedAlbums.isNotEmpty,
        (HomeContentFocus.albums, HomeSectionKind.quickPicks) =>
          state.quickPicks.isNotEmpty,
        (HomeContentFocus.albums, HomeSectionKind.recentlyAdded) =>
          state.recentlyAddedAlbums.isNotEmpty,
        (HomeContentFocus.albums, HomeSectionKind.mostPlayed) =>
          state.mostPlayedAlbums.isNotEmpty,
        (HomeContentFocus.albums, HomeSectionKind.fromLibrary) =>
          state.libraryRotation.isNotEmpty,
      };
      if (hasItems) return true;
    }
    return false;
  }

  List<Widget> _contentShelves(AppLocalizations l, HomeViewState state) => [
    if (state.recentlyPlayedPlaylists.isNotEmpty)
      _playlistShelf(state.recentlyPlayedPlaylists, state.revision),
    for (final section in widget.preferences.homeSectionOrder)
      if (widget.preferences.enabledHomeSections.contains(section))
        _sectionShelf(l, state, section),
  ];

  Widget _playlistShelf(List<Playlist> playlists, int revision) =>
      SliverToBoxAdapter(
        child: _HomePlaylistPager(
          key: ValueKey('home-playlist-pager-$revision'),
          playlists: playlists,
          artworkBuilder: widget.playlistArtworkBuilder,
          onTap: widget.onPlaylistTap,
        ),
      );

  Widget _sectionShelf(
    AppLocalizations l,
    HomeViewState state,
    HomeSectionKind section,
  ) {
    final focus = widget.preferences.homeContentFor(section);
    if (section == HomeSectionKind.quickPicks) {
      return _quickPickShelf(
        l,
        state.quickPicks,
        revision: state.quickPicksRevision,
        onShowMore: widget.onShowMore == null
            ? null
            : () => widget.onShowMore!(section, focus),
      );
    }
    final onRefresh = section == HomeSectionKind.fromLibrary
        ? widget.onRotateLibrary
        : null;
    return focus == HomeContentFocus.songs
        ? _songShelf(
            _songSectionTitle(l, section),
            _songsForSection(state, section),
            revision: state.revision,
            onRefresh: onRefresh,
            onShowMore: widget.onShowMore == null
                ? null
                : () => widget.onShowMore!(section, focus),
          )
        : _albumShelf(
            _albumSectionTitle(l, section),
            _albumsForSection(state, section),
            revision: state.revision,
            onRefresh: onRefresh,
            onShowMore: widget.onShowMore == null
                ? null
                : () => widget.onShowMore!(section, focus),
          );
  }

  String _songSectionTitle(AppLocalizations l, HomeSectionKind section) =>
      switch (section) {
        HomeSectionKind.recentlyPlayed => l.sectionRecentlyPlayedSongs,
        HomeSectionKind.quickPicks => l.quickPicks,
        HomeSectionKind.recentlyAdded => l.sectionRecentlyAddedSongs,
        HomeSectionKind.mostPlayed => l.sectionMostPlayedSongs,
        HomeSectionKind.fromLibrary => l.sectionFromLibrary,
      };

  String _albumSectionTitle(AppLocalizations l, HomeSectionKind section) =>
      switch (section) {
        HomeSectionKind.recentlyPlayed => l.sectionRecentlyPlayedAlbums,
        HomeSectionKind.quickPicks => l.quickPicks,
        HomeSectionKind.recentlyAdded => l.sectionRecentlyAddedAlbums,
        HomeSectionKind.mostPlayed => l.sectionMostPlayedAlbums,
        HomeSectionKind.fromLibrary => l.sectionFromLibrary,
      };

  List<Song> _songsForSection(HomeViewState state, HomeSectionKind section) =>
      switch (section) {
        HomeSectionKind.recentlyPlayed => state.recentlyPlayedSongs,
        HomeSectionKind.quickPicks =>
          state.quickPicks.map((pick) => pick.song).toList(growable: false),
        HomeSectionKind.recentlyAdded => state.recentlyAddedSongs,
        HomeSectionKind.mostPlayed => state.mostPlayedSongs,
        HomeSectionKind.fromLibrary => state.librarySongRotation,
      };

  List<Album> _albumsForSection(HomeViewState state, HomeSectionKind section) =>
      switch (section) {
        HomeSectionKind.recentlyPlayed => state.recentlyPlayedAlbums,
        HomeSectionKind.quickPicks => const [],
        HomeSectionKind.recentlyAdded => state.recentlyAddedAlbums,
        HomeSectionKind.mostPlayed => state.mostPlayedAlbums,
        HomeSectionKind.fromLibrary => state.libraryRotation,
      };

  Widget _albumShelf(
    String title,
    List<Album> albums, {
    int revision = 0,
    Future<void> Function()? onRefresh,
    Future<void> Function()? onShowMore,
  }) {
    if (albums.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              NaviSpacing.page,
              NaviSpacing.sm,
              NaviSpacing.page,
              NaviSpacing.sm,
            ),
            child: _shelfHeader(title, onRefresh: onRefresh),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 220,
            child: ListView.separated(
              key: PageStorageKey('home-albums-$title-$revision'),
              padding: const EdgeInsets.symmetric(horizontal: NaviSpacing.page),
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: albums.length + (onShowMore == null ? 0 : 1),
              separatorBuilder: (_, _) => const SizedBox(width: NaviSpacing.sm),
              itemBuilder: (context, index) {
                if (index == albums.length) {
                  return _ShowMoreCard(onOpen: onShowMore!);
                }
                final album = albums[index];
                return _HomeAlbumCard(
                  album: album,
                  artwork: widget.albumArtworkBuilder?.call(context, album),
                  onTap: widget.onAlbumTap == null
                      ? null
                      : () => widget.onAlbumTap!(album),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _songShelf(
    String title,
    List<Song> songs, {
    int revision = 0,
    Future<void> Function()? onRefresh,
    Future<void> Function()? onShowMore,
  }) {
    if (songs.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              NaviSpacing.page,
              NaviSpacing.sm,
              NaviSpacing.page,
              NaviSpacing.sm,
            ),
            child: _shelfHeader(title, onRefresh: onRefresh),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 220,
            child: ListView.separated(
              key: PageStorageKey('home-songs-$title-$revision'),
              padding: const EdgeInsets.symmetric(horizontal: NaviSpacing.page),
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: songs.length + (onShowMore == null ? 0 : 1),
              separatorBuilder: (_, _) => const SizedBox(width: NaviSpacing.sm),
              itemBuilder: (context, index) {
                if (index == songs.length) {
                  return _ShowMoreCard(onOpen: onShowMore!);
                }
                final song = songs[index];
                return _HomeSongCard(
                  song: song,
                  artwork: widget.songArtworkBuilder?.call(context, song),
                  onTap: widget.onSongTap == null
                      ? null
                      : () => widget.onSongTap!(song),
                  onMenu: widget.onSongMenu == null
                      ? null
                      : () => widget.onSongMenu!(song),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _quickPickShelf(
    AppLocalizations l,
    List<QuickPick> picks, {
    int revision = 0,
    Future<void> Function()? onShowMore,
  }) {
    if (picks.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              NaviSpacing.page,
              NaviSpacing.sm,
              NaviSpacing.page,
              NaviSpacing.sm,
            ),
            child: _shelfHeader(l.quickPicks),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 220,
            child: ListView.separated(
              key: PageStorageKey('home-quick-picks-$revision'),
              padding: const EdgeInsets.symmetric(horizontal: NaviSpacing.page),
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: picks.length + (onShowMore == null ? 0 : 1),
              separatorBuilder: (_, _) => const SizedBox(width: NaviSpacing.sm),
              itemBuilder: (context, index) {
                if (index == picks.length) {
                  return _ShowMoreCard(onOpen: onShowMore!);
                }
                final pick = picks[index];
                return _HomeSongCard(
                  song: pick.song,
                  artwork: widget.songArtworkBuilder?.call(context, pick.song),
                  onTap: widget.onSongTap == null
                      ? null
                      : () => widget.onSongTap!(pick.song),
                  onMenu: widget.onSongMenu == null
                      ? null
                      : () => widget.onSongMenu!(pick.song),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _shelfHeader(String title, {Future<void> Function()? onRefresh}) =>
      Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          if (onRefresh != null)
            IconButton(
              tooltip: AppLocalizations.of(context).refreshSelection,
              visualDensity: VisualDensity.compact,
              onPressed: () => unawaited(onRefresh()),
              icon: const Icon(Icons.shuffle_rounded, size: 19),
            ),
        ],
      );

  List<Widget> _loadingShelves() => [
    for (var shelf = 0; shelf < 2; shelf++) ...[
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            NaviSpacing.page,
            NaviSpacing.md,
            NaviSpacing.page,
            NaviSpacing.sm,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: _SkeletonBlock(width: shelf == 0 ? 150 : 118, height: 22),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: SizedBox(
          height: 220,
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: NaviSpacing.page),
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, _) => const SizedBox(width: NaviSpacing.sm),
            itemBuilder: (_, index) => const SizedBox(
              width: 144,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBlock(width: 144, height: 144),
                  SizedBox(height: NaviSpacing.sm),
                  _SkeletonBlock(width: 132, height: 14),
                  SizedBox(height: NaviSpacing.xs),
                  _SkeletonBlock(width: 92, height: 11),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  ];
}

class _HomePlaylistPager extends StatefulWidget {
  const _HomePlaylistPager({
    super.key,
    required this.playlists,
    this.artworkBuilder,
    this.onTap,
  });

  final List<Playlist> playlists;
  final HomePlaylistArtworkBuilder? artworkBuilder;
  final ValueChanged<Playlist>? onTap;

  @override
  State<_HomePlaylistPager> createState() => _HomePlaylistPagerState();
}

class _HomePlaylistPagerState extends State<_HomePlaylistPager> {
  static const _pageSize = 6;
  static const _gap = NaviSpacing.xs;

  var _page = 0;

  @override
  Widget build(BuildContext context) {
    final pageCount = (widget.playlists.length + _pageSize - 1) ~/ _pageSize;
    return Padding(
      padding: const EdgeInsets.only(
        top: NaviSpacing.md,
        bottom: NaviSpacing.lg,
      ),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth =
                  (constraints.maxWidth - 2 * NaviSpacing.page - _gap) / 2;
              final cardHeight = cardWidth / 2.05;
              return SizedBox(
                height: cardHeight * 3 + _gap * 2,
                child: PageView.builder(
                  key: const ValueKey('home-playlist-pager'),
                  itemCount: pageCount,
                  onPageChanged: (page) => setState(() => _page = page),
                  itemBuilder: (context, page) {
                    final start = page * _pageSize;
                    final end = start + _pageSize < widget.playlists.length
                        ? start + _pageSize
                        : widget.playlists.length;
                    return GridView.builder(
                      key: ValueKey('home-playlist-page-$page'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: NaviSpacing.page,
                      ),
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: _gap,
                            crossAxisSpacing: _gap,
                            childAspectRatio: 2.05,
                          ),
                      itemCount: end - start,
                      itemBuilder: (context, index) {
                        final playlist = widget.playlists[start + index];
                        return _HomePlaylistTile(
                          playlist: playlist,
                          artwork:
                              widget.artworkBuilder?.call(
                                context,
                                playlist.coverArt,
                                Icons.queue_music_rounded,
                              ) ??
                              NaviArtwork(
                                coverArt: playlist.coverArt,
                                fallback: Icons.queue_music_rounded,
                                radius: 0,
                              ),
                          onTap: widget.onTap == null
                              ? null
                              : () => widget.onTap!(playlist),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
          if (pageCount > 1) ...[
            const SizedBox(height: NaviSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var page = 0; page < pageCount; page++)
                  AnimatedContainer(
                    duration: NaviMotion.standard,
                    width: _page == page ? 16 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: _page == page
                          ? NaviColors.textPrimary
                          : NaviColors.textTertiary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _HomePlaylistTile extends StatelessWidget {
  const _HomePlaylistTile({
    required this.playlist,
    required this.artwork,
    this.onTap,
  });

  final Playlist playlist;
  final Widget artwork;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => NaviPressable(
    onTap: onTap,
    borderRadius: BorderRadius.circular(NaviRadii.card),
    child: Container(
      padding: const EdgeInsets.all(NaviSpacing.xs),
      decoration: BoxDecoration(
        color: NaviColors.surface,
        borderRadius: BorderRadius.circular(NaviRadii.card),
        border: Border.all(color: NaviColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox.square(dimension: 58, child: artwork),
          ),
          const SizedBox(width: NaviSpacing.xs),
          Expanded(
            child: Text(
              playlist.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ShowMoreCard extends StatefulWidget {
  const _ShowMoreCard({required this.onOpen});

  final Future<void> Function() onOpen;

  @override
  State<_ShowMoreCard> createState() => _ShowMoreCardState();
}

class _ShowMoreCardState extends State<_ShowMoreCard> {
  static const _threshold = 48.0;
  static const _maxPull = 72.0;

  double _pull = 0;
  bool _opening = false;

  void _drag(DragUpdateDetails details) {
    if (_opening) return;
    setState(() {
      _pull = (_pull - details.delta.dx * 0.45).clamp(0, _maxPull);
    });
  }

  Future<void> _end(DragEndDetails details) async {
    if (_opening) return;
    if (_pull < _threshold) {
      setState(() => _pull = 0);
      return;
    }
    await _open();
  }

  Future<void> _open() async {
    if (_opening) return;
    setState(() {
      _opening = true;
      _pull = _maxPull;
    });
    await Future<void>.delayed(NaviMotion.micro);
    await widget.onOpen();
    if (!mounted) return;
    setState(() {
      _opening = false;
      _pull = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l.showMore,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _open,
        onHorizontalDragUpdate: _drag,
        onHorizontalDragEnd: _end,
        child: SizedBox(
          width: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.translate(
                offset: Offset(-_pull * 0.28, 0),
                child: AnimatedContainer(
                  duration: NaviMotion.micro,
                  height: 144,
                  decoration: BoxDecoration(
                    color: NaviColors.surface,
                    borderRadius: BorderRadius.circular(NaviRadii.artwork),
                    border: Border.all(
                      color: _pull >= _threshold
                          ? NaviColors.textSecondary
                          : NaviColors.border,
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: NaviColors.surfaceRaised,
                            shape: BoxShape.circle,
                            border: Border.all(color: NaviColors.controlBorder),
                          ),
                          child: const Icon(Icons.arrow_forward_rounded),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 10,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: (_pull / _threshold).clamp(0, 1),
                            minHeight: 3,
                            color: NaviColors.textPrimary,
                            backgroundColor: NaviColors.surfaceRaised,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: NaviSpacing.sm),
              Text(l.showMore, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: NaviSpacing.xxs),
              Text(
                l.showMoreHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeSongCard extends StatelessWidget {
  const _HomeSongCard({
    required this.song,
    this.artwork,
    this.onTap,
    this.onMenu,
  });

  final Song song;
  final Widget? artwork;
  final VoidCallback? onTap;
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 144,
    child: NaviPressable(
      onTap: onTap,
      onLongPress: onMenu,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(NaviRadii.artwork),
            child: SizedBox.square(
              dimension: 144,
              child: artwork ?? _SongArtworkFallback(song: song),
            ),
          ),
          const SizedBox(height: NaviSpacing.sm),
          Text(
            song.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: NaviSpacing.xxs),
          Text(
            primaryArtistName(song.artist),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: NaviSpacing.xxs),
          Text(
            [
              song.album,
              if (song.year > 0) '${song.year}',
            ].where((value) => value.isNotEmpty).join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: NaviColors.textTertiary),
          ),
        ],
      ),
    ),
  );
}

class _HomeAlbumCard extends StatelessWidget {
  const _HomeAlbumCard({required this.album, this.artwork, this.onTap});

  final Album album;
  final Widget? artwork;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final trackCount = l.songsCount(album.songCount);
    return SizedBox(
      width: 144,
      child: NaviPressable(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              label: album.name,
              image: true,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(NaviRadii.artwork),
                child: SizedBox.square(
                  dimension: 144,
                  child: artwork ?? _ArtworkFallback(album: album),
                ),
              ),
            ),
            const SizedBox(height: NaviSpacing.sm),
            Text(
              album.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: NaviSpacing.xxs),
            Text(
              primaryArtistName(album.artist),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: NaviSpacing.xxs),
            Row(
              children: [
                const Icon(
                  Icons.library_music_outlined,
                  size: 14,
                  color: NaviColors.textSecondary,
                  semanticLabel: null,
                  key: ValueKey('home-album-count-icon'),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    [
                      trackCount,
                      if (album.year > 0) '${album.year}',
                    ].join(' · '),
                    key: ValueKey('home-album-count-${album.id}'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: NaviColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.35, end: 0.72),
    duration: NaviMotion.page,
    curve: NaviMotion.curve,
    builder: (context, opacity, _) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: NaviColors.surfaceRaised.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(
          height > 40 ? NaviRadii.artwork : NaviRadii.row,
        ),
      ),
    ),
  );
}

class _SongArtworkFallback extends StatelessWidget {
  const _SongArtworkFallback({required this.song});

  final Song song;

  @override
  Widget build(BuildContext context) =>
      _GradientArtworkFallback(id: song.id, icon: Icons.music_note_rounded);
}

class _ArtworkFallback extends StatelessWidget {
  const _ArtworkFallback({required this.album});

  final Album album;

  @override
  Widget build(BuildContext context) =>
      _GradientArtworkFallback(id: album.id, icon: Icons.album_rounded);
}

class _GradientArtworkFallback extends StatelessWidget {
  const _GradientArtworkFallback({required this.id, required this.icon});

  final String id;
  final IconData icon;

  @override
  Widget build(BuildContext context) => NaviArtwork(fallback: icon, radius: 0);
}

class _HomeMessage extends StatelessWidget {
  const _HomeMessage({
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final Future<void> Function()? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(NaviSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: NaviColors.textSecondary),
          const SizedBox(height: NaviSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: NaviSpacing.xs),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: NaviSpacing.md),
            FilledButton.tonal(
              style: NaviTheme.tonalButtonStyle,
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    ),
  );
}
