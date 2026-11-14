import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../design_system/navi_design_tokens.dart';
import '../../design_system/navi_theme.dart';
import '../../design_system/widgets/navi_widgets.dart';
import '../../domain/library/catalog_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import 'catalog_controllers.dart';

typedef CatalogArtworkBuilder =
    Widget Function(BuildContext context, String? coverArt, IconData fallback);
typedef CollectionSuggestionLoader =
    Future<List<Song>> Function(List<Song> source, {bool refresh});

class V2LibraryScreen extends StatefulWidget {
  const V2LibraryScreen({
    super.key,
    required this.controller,
    required this.onOpenPlaylists,
    required this.onOpenRadio,
    required this.onOpenArtists,
    required this.onOpenAlbums,
    required this.onOpenSongs,
    required this.onOpenDownloads,
    required this.onAlbumTap,
    this.artworkBuilder,
    this.onRefresh,
    this.onPrepareArtists,
  });

  /// Pull must reach the server; the runtime decides how cheap that is.
  final Future<void> Function()? onRefresh;
  final Future<void> Function()? onPrepareArtists;

  final LibraryOverviewController controller;
  final VoidCallback onOpenPlaylists;
  final VoidCallback onOpenRadio;
  final VoidCallback onOpenArtists;
  final VoidCallback onOpenAlbums;
  final VoidCallback onOpenSongs;
  final VoidCallback onOpenDownloads;
  final ValueChanged<Album> onAlbumTap;
  final CatalogArtworkBuilder? artworkBuilder;

  @override
  State<V2LibraryScreen> createState() => _V2LibraryScreenState();
}

class _V2LibraryScreenState extends State<V2LibraryScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(widget.controller.initialize());
    unawaited(widget.onPrepareArtists?.call());
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final l = AppLocalizations.of(context);
      final state = widget.controller.state;
      return Scaffold(
        body: NaviArtworkAtmosphere(
          primary: NaviColors.atmospherePlum,
          secondary: NaviColors.atmosphereWine,
          child: RefreshIndicator.adaptive(
            onRefresh: widget.onRefresh ?? widget.controller.refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                NaviSliverHeader(title: Text(l.navLibrary)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      NaviSpacing.page,
                      NaviSpacing.md,
                      NaviSpacing.page,
                      NaviSpacing.lg,
                    ),
                    child: NaviGlass(
                      radius: NaviRadii.card,
                      child: Column(
                        children: [
                          for (final (index, destination)
                              in _libraryDestinations(l, state).indexed) ...[
                            if (index > 0) const Divider(height: 1, indent: 52),
                            _LibraryDestinationRow(destination: destination),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                if (state.recentlyAddedAlbums.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        NaviSpacing.page,
                        NaviSpacing.xs,
                        NaviSpacing.page,
                        NaviSpacing.sm,
                      ),
                      child: Text(
                        l.sectionRecentlyAddedAlbums,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      NaviSpacing.page,
                      0,
                      NaviSpacing.page,
                      NaviSpacing.xl,
                    ),
                    sliver: SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: NaviSpacing.sm,
                            mainAxisSpacing: NaviSpacing.md,
                            childAspectRatio: 0.78,
                          ),
                      itemCount: state.recentlyAddedAlbums.length,
                      itemBuilder: (context, index) {
                        final album = state.recentlyAddedAlbums[index];
                        return NaviAlbumCard(
                          album: album,
                          artworkBuilder: widget.artworkBuilder,
                          onTap: () => widget.onAlbumTap(album),
                        );
                      },
                    ),
                  ),
                ],
                if (state.loading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: NaviSpacing.xxl,
                        vertical: NaviSpacing.md,
                      ),
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                  ),
                if (state.error != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: NaviSpacing.page,
                      ),
                      child: NaviGlass(
                        padding: const EdgeInsets.all(NaviSpacing.md),
                        child: Text(l.couldNotLoadLibrary('${state.error}')),
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 92)),
              ],
            ),
          ),
        ),
      );
    },
  );

  List<_LibraryDestinationData> _libraryDestinations(
    AppLocalizations l,
    LibraryOverviewState state,
  ) => [
    _LibraryDestinationData(
      icon: Icons.queue_music_rounded,
      title: l.navPlaylists,
      subtitle: l.playlistsCount(state.playlists.length),
      onTap: widget.onOpenPlaylists,
    ),
    _LibraryDestinationData(
      icon: Icons.radio_rounded,
      title: l.navRadio,
      subtitle: l.genreRadio,
      onTap: widget.onOpenRadio,
    ),
    _LibraryDestinationData(
      icon: Icons.people_alt_rounded,
      title: l.navArtists,
      subtitle: l.artistsCount(state.artistCount),
      onTap: widget.onOpenArtists,
    ),
    _LibraryDestinationData(
      icon: Icons.album_rounded,
      title: l.navAlbums,
      subtitle: l.albumsCount(state.albumCount),
      onTap: widget.onOpenAlbums,
    ),
    _LibraryDestinationData(
      icon: Icons.music_note_rounded,
      title: l.navSongs,
      onTap: widget.onOpenSongs,
    ),
    _LibraryDestinationData(
      icon: Icons.download_done_rounded,
      title: l.navDownloads,
      onTap: widget.onOpenDownloads,
    ),
  ];
}

class _LibraryDestinationData {
  const _LibraryDestinationData({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
}

class NaviAlbumCard extends StatelessWidget {
  const NaviAlbumCard({
    super.key,
    required this.album,
    required this.onTap,
    this.artworkBuilder,
  });

  final Album album;
  final VoidCallback onTap;
  final CatalogArtworkBuilder? artworkBuilder;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return KeyedSubtree(
      key: ValueKey('album-card-${album.id}'),
      child: NaviPressable(
        borderRadius: BorderRadius.circular(NaviRadii.card),
        lift: true,
        onTap: onTap,
        child: NaviGlass(
          radius: NaviRadii.card,
          padding: const EdgeInsets.all(NaviSpacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(NaviRadii.row),
                  child: SizedBox.expand(
                    child:
                        artworkBuilder?.call(
                          context,
                          album.coverArt,
                          Icons.album_rounded,
                        ) ??
                        NaviArtwork(
                          coverArt: album.coverArt,
                          fallback: Icons.album_rounded,
                          radius: NaviRadii.row,
                        ),
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
              const SizedBox(height: 2),
              Text(
                album.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: NaviColors.textSecondary,
                ),
              ),
              const SizedBox(height: NaviSpacing.xs),
              Row(
                children: [
                  const Icon(
                    Icons.library_music_outlined,
                    size: 14,
                    color: NaviColors.textSecondary,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      l.songsCount(album.songCount),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                  if (album.year > 0)
                    Text(
                      '${album.year}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: NaviColors.textTertiary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LibraryDestinationRow extends StatelessWidget {
  const _LibraryDestinationRow({required this.destination});

  final _LibraryDestinationData destination;

  @override
  Widget build(BuildContext context) => NaviPressable(
    borderRadius: BorderRadius.circular(NaviRadii.card),
    onTap: destination.onTap,
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 60),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: NaviSpacing.md),
        child: Row(
          children: [
            Icon(destination.icon, size: 20, color: NaviColors.textSecondary),
            const SizedBox(width: NaviSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    destination.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (destination.subtitle != null)
                    Text(
                      destination.subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: NaviColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: NaviColors.textTertiary,
            ),
          ],
        ),
      ),
    ),
  );
}

class V2ArtistsScreen extends StatelessWidget {
  const V2ArtistsScreen({
    super.key,
    required this.controller,
    required this.onArtistTap,
    this.artworkBuilder,
  });

  final PagedCatalogController<ArtistSummary> controller;
  final ValueChanged<ArtistSummary> onArtistTap;
  final CatalogArtworkBuilder? artworkBuilder;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _PagedCatalogList<ArtistSummary>(
      controller: controller,
      title: l.navArtists,
      searchHint: l.searchHint,
      actions: [
        IconButton(
          tooltip: l.sortBy,
          onPressed: () => _showArtistSort(context, controller),
          icon: const Icon(Icons.sort_rounded),
        ),
      ],
      itemBuilder: (context, artist) => ListTile(
        enableFeedback: false,
        leading: SizedBox.square(
          dimension: 52,
          child: _Artwork(
            coverArt: artist.coverArt,
            fallback: Icons.person_rounded,
            builder: artworkBuilder,
          ),
        ),
        title: Text(artist.name, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          AppLocalizations.of(context).albumsCount(artist.albumCount),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => onArtistTap(artist),
      ),
    );
  }
}

class V2AlbumsScreen extends StatelessWidget {
  const V2AlbumsScreen({
    super.key,
    required this.controller,
    required this.onAlbumTap,
    this.artworkBuilder,
    this.title,
  });

  final PagedCatalogController<Album> controller;
  final ValueChanged<Album> onAlbumTap;
  final CatalogArtworkBuilder? artworkBuilder;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _PagedCatalogGrid(
      controller: controller,
      title: title ?? l.navAlbums,
      onAlbumTap: onAlbumTap,
      artworkBuilder: artworkBuilder,
      actions: [
        IconButton(
          tooltip: l.sortBy,
          onPressed: () => _showAlbumSort(context, controller),
          icon: const Icon(Icons.sort_rounded),
        ),
      ],
    );
  }
}

class V2PlaylistsScreen extends StatefulWidget {
  const V2PlaylistsScreen({
    super.key,
    required this.controller,
    required this.onPlaylistTap,
    required this.onCreatePlaylist,
    this.onDeletePlaylist,
    this.artworkBuilder,
    this.onRefresh,
  });

  /// Pull must reach the server; the runtime decides how cheap that is.
  final Future<void> Function()? onRefresh;

  final LibraryOverviewController controller;
  final ValueChanged<Playlist> onPlaylistTap;
  final VoidCallback onCreatePlaylist;
  final Future<bool> Function(Playlist playlist)? onDeletePlaylist;
  final CatalogArtworkBuilder? artworkBuilder;

  @override
  State<V2PlaylistsScreen> createState() => _V2PlaylistsScreenState();
}

class _V2PlaylistsScreenState extends State<V2PlaylistsScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(widget.controller.initialize());
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final l = AppLocalizations.of(context);
      final state = widget.controller.state;
      return Scaffold(
        body: NaviArtworkAtmosphere(
          primary: NaviColors.atmospherePlum,
          secondary: NaviColors.atmosphereWine,
          child: RefreshIndicator.adaptive(
            onRefresh: widget.onRefresh ?? widget.controller.refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                NaviSliverHeader(
                  title: Text(l.navPlaylists),
                  actions: [
                    IconButton(
                      tooltip: l.newPlaylist,
                      onPressed: widget.onCreatePlaylist,
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
                if (state.loading && state.playlists.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  )
                else if (state.playlists.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text(l.noPlaylists)),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      NaviSpacing.page,
                      NaviSpacing.xs,
                      NaviSpacing.page,
                      NaviSpacing.xl,
                    ),
                    sliver: SliverList.separated(
                      itemCount: state.playlists.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: NaviSpacing.xs),
                      itemBuilder: (context, index) {
                        final playlist = state.playlists[index];
                        final row = NaviPressable(
                          onTap: () => widget.onPlaylistTap(playlist),
                          child: NaviGlass(
                            radius: NaviRadii.row,
                            blur: 12,
                            padding: const EdgeInsets.all(NaviSpacing.xs),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    NaviRadii.row - 2,
                                  ),
                                  child: SizedBox.square(
                                    dimension: 48,
                                    child:
                                        widget.artworkBuilder?.call(
                                          context,
                                          playlist.coverArt,
                                          Icons.queue_music_rounded,
                                        ) ??
                                        ColoredBox(
                                          color: NaviColors.surfaceRaised,
                                          child: NaviAbstractArtwork(
                                            seed: playlist.name,
                                          ),
                                        ),
                                  ),
                                ),
                                const SizedBox(width: NaviSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        playlist.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                      Text(
                                        '${l.songsCount(playlist.songCount)} · ${_compactDuration(playlist.duration)}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        );
                        final onDelete = widget.onDeletePlaylist;
                        if (onDelete == null || playlist.readonly) return row;
                        return Dismissible(
                          key: ValueKey('playlist-delete-${playlist.id}'),
                          direction: DismissDirection.endToStart,
                          dismissThresholds: const {
                            DismissDirection.endToStart: 0.35,
                          },
                          confirmDismiss: (_) => onDelete(playlist),
                          background: const SizedBox.shrink(),
                          secondaryBackground: Semantics(
                            button: true,
                            label: l.deletePlaylist,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: NaviColors.destructive,
                                borderRadius: BorderRadius.circular(
                                  NaviRadii.row,
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: NaviSpacing.page,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(l.delete),
                                      const SizedBox(width: NaviSpacing.xs),
                                      const Icon(Icons.delete_outline_rounded),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          child: row,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

String _compactDuration(int seconds) {
  final totalMinutes = seconds ~/ 60;
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  return hours == 0 ? '$minutes min' : '$hours h $minutes min';
}

class V2SongCollectionScreen extends StatefulWidget {
  const V2SongCollectionScreen({
    super.key,
    required this.title,
    required this.controller,
    required this.onSongTap,
    this.subtitle,
    this.coverArt,
    this.album,
    this.artworkBuilder,
    this.onPlay,
    this.onShuffle,
    this.offline = false,
    this.onToggleOffline,
    this.onSongMenu,
    this.additionalActions = const [],
    this.suggestionLoader,
    this.onAddSuggestion,
    this.onPlaylistRadio,
    this.onContinueSimilar,
    this.quickSwipeActionBuilder,
    this.nowPlaying,
    this.playing,
  });

  final String title;
  final String? subtitle;
  final String? coverArt;
  final Album? album;
  final SongCollectionController controller;
  final ValueChanged<Song> onSongTap;
  final CatalogArtworkBuilder? artworkBuilder;
  final VoidCallback? onPlay;
  final VoidCallback? onShuffle;
  final bool offline;
  final Future<void> Function()? onToggleOffline;
  final ValueChanged<Song>? onSongMenu;
  final List<Widget> additionalActions;
  final CollectionSuggestionLoader? suggestionLoader;
  final Future<void> Function(Song song)? onAddSuggestion;
  final Future<void> Function()? onPlaylistRadio;
  final Future<void> Function()? onContinueSimilar;
  final NaviSwipeAction? Function(BuildContext context, Song song)?
  quickSwipeActionBuilder;

  /// Id of the song at the playhead; rows mark themselves when it matches.
  final ValueListenable<String?>? nowPlaying;
  final ValueListenable<bool>? playing;

  @override
  State<V2SongCollectionScreen> createState() => _V2SongCollectionScreenState();
}

class _V2SongCollectionScreenState extends State<V2SongCollectionScreen> {
  List<Song> _suggestions = const [];
  final Set<String> _addingSuggestionIds = {};
  bool _suggestionsLoading = false;
  Object? _suggestionsError;
  int _suggestionGeneration = 0;
  bool _radioStarting = false;
  bool _showAlbumInfo = false;

  @override
  void initState() {
    super.initState();
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    await widget.controller.initialize();
    if (mounted) await _loadSuggestions();
  }

  Future<void> _refresh() async {
    await widget.controller.refresh();
    if (mounted) await _loadSuggestions(refresh: true);
  }

  Future<void> _loadSuggestions({bool refresh = false}) async {
    final loader = widget.suggestionLoader;
    if (loader == null || widget.controller.songs.isEmpty) return;
    final generation = ++_suggestionGeneration;
    setState(() {
      _suggestionsLoading = true;
      _suggestionsError = null;
    });
    try {
      final suggestions = await loader(
        widget.controller.songs,
        refresh: refresh,
      );
      if (!mounted || generation != _suggestionGeneration) return;
      setState(() => _suggestions = List.unmodifiable(suggestions));
    } catch (error) {
      if (!mounted || generation != _suggestionGeneration) return;
      setState(() => _suggestionsError = error);
    } finally {
      if (mounted && generation == _suggestionGeneration) {
        setState(() => _suggestionsLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final l = AppLocalizations.of(context);
      return Scaffold(
        body: RefreshIndicator.adaptive(
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              NaviSliverHeader(
                title: Text(widget.title),
                actions: [
                  if (widget.onToggleOffline != null)
                    IconButton(
                      tooltip: widget.offline ? l.removeOffline : l.keepOffline,
                      onPressed: () => unawaited(widget.onToggleOffline!()),
                      icon: Icon(
                        widget.offline
                            ? Icons.download_done_rounded
                            : Icons.download_for_offline_outlined,
                      ),
                    ),
                  ...widget.additionalActions,
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(NaviSpacing.page),
                  child: Column(
                    children: [
                      SizedBox.square(
                        dimension: 220,
                        child: _albumArtworkFlip(l),
                      ),
                      const SizedBox(height: NaviSpacing.md),
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: NaviSpacing.xs),
                        Text(widget.subtitle!),
                      ],
                      const SizedBox(height: NaviSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FilledButton.icon(
                            onPressed: widget.controller.songs.isEmpty
                                ? null
                                : widget.onPlay,
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: Text(l.play),
                          ),
                          const SizedBox(width: NaviSpacing.sm),
                          FilledButton.tonalIcon(
                            style: NaviTheme.tonalButtonStyle,
                            onPressed: widget.controller.songs.isEmpty
                                ? null
                                : widget.onShuffle,
                            icon: const Icon(Icons.shuffle_rounded),
                            label: Text(l.shuffle),
                          ),
                        ],
                      ),
                      if (widget.onPlaylistRadio != null ||
                          widget.onContinueSimilar != null) ...[
                        const SizedBox(height: NaviSpacing.sm),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: NaviSpacing.xs,
                          runSpacing: NaviSpacing.xs,
                          children: [
                            if (widget.onPlaylistRadio != null)
                              OutlinedButton.icon(
                                onPressed:
                                    widget.controller.songs.isEmpty ||
                                        _radioStarting
                                    ? null
                                    : () => _runRadioAction(
                                        widget.onPlaylistRadio!,
                                      ),
                                icon: const Icon(Icons.sensors_rounded),
                                label: Text(l.playlistRadio),
                              ),
                            if (widget.onContinueSimilar != null)
                              OutlinedButton.icon(
                                onPressed:
                                    widget.controller.songs.isEmpty ||
                                        _radioStarting
                                    ? null
                                    : () => _runRadioAction(
                                        widget.onContinueSimilar!,
                                      ),
                                icon: const Icon(Icons.all_inclusive_rounded),
                                label: Text(l.continueWithSimilar),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (widget.controller.loading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator.adaptive()),
                )
              else if (widget.controller.error != null)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      l.couldNotLoadLibrary('${widget.controller.error}'),
                    ),
                  ),
                )
              else ...[
                SliverList.builder(
                  itemCount: widget.controller.songs.length,
                  itemBuilder: (context, index) {
                    final song = widget.controller.songs[index];
                    final openMenu = widget.onSongMenu == null
                        ? null
                        : () => widget.onSongMenu!(song);
                    return NaviSongSwipeActions(
                      dismissibleKey: ValueKey(
                        'collection-swipe-${song.id}-$index',
                      ),
                      quickAction: widget.quickSwipeActionBuilder?.call(
                        context,
                        song,
                      ),
                      onMore: openMenu,
                      child: NaviSongRow(
                        song: song,
                        leadingText: '${index + 1}',
                        nowPlayingListenable: widget.nowPlaying,
                        playingListenable: widget.playing,
                        starred: song.starred,
                        trailingText: formatDuration(song.duration),
                        onTap: () => widget.onSongTap(song),
                        onMenu: openMenu,
                      ),
                    );
                  },
                ),
                if (widget.suggestionLoader != null) ..._suggestionSlivers(l),
              ],
            ],
          ),
        ),
      );
    },
  );

  Future<void> _runRadioAction(Future<void> Function() action) async {
    if (_radioStarting) return;
    setState(() => _radioStarting = true);
    try {
      await action();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).similarSuggestionsError),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _radioStarting = false);
    }
  }

  Widget _albumArtworkFlip(AppLocalizations l) {
    final canFlip = widget.album != null && widget.controller.songs.isNotEmpty;
    return GestureDetector(
      onLongPress: canFlip
          ? () => setState(() => _showAlbumInfo = !_showAlbumInfo)
          : null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedSwitcher(
            duration: NaviMotion.artworkFlip,
            switchInCurve: NaviMotion.curve,
            switchOutCurve: NaviMotion.curve,
            transitionBuilder: _flipTransition,
            child: _showAlbumInfo
                ? _albumInfoBack(l, key: const ValueKey('album-info-back'))
                : _albumCoverFront(key: const ValueKey('album-cover-front')),
          ),
          if (canFlip)
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: NaviColors.glassOpaque.withValues(alpha: 0.72),
                  shape: BoxShape.circle,
                  border: Border.all(color: NaviColors.glassBorder),
                ),
                child: Icon(
                  _showAlbumInfo
                      ? Icons.album_rounded
                      : Icons.info_outline_rounded,
                  size: 17,
                  color: NaviColors.textPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _flipTransition(Widget child, Animation<double> animation) {
    final rotate = Tween<double>(
      begin: 3.141592653589793,
      end: 0,
    ).animate(CurvedAnimation(parent: animation, curve: NaviMotion.curve));
    return AnimatedBuilder(
      animation: rotate,
      builder: (context, child) => Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0015)
          ..rotateY(rotate.value),
        alignment: Alignment.center,
        child: child,
      ),
      child: child,
    );
  }

  Widget _albumCoverFront({Key? key}) => KeyedSubtree(
    key: key,
    child: _Artwork(
      coverArt: widget.coverArt,
      fallback: Icons.album_rounded,
      builder: widget.artworkBuilder,
      radius: NaviRadii.artwork,
    ),
  );

  Widget _albumInfoBack(AppLocalizations l, {Key? key}) {
    final album = widget.album!;
    final songs = widget.controller.songs;
    final formats = {
      for (final song in songs)
        if (song.suffix.trim().isNotEmpty) song.suffix.trim().toUpperCase(),
    }.toList()..sort();
    final genres = <String>{};
    for (final song in songs) {
      for (final value in (song.genre ?? '').split(RegExp(r'[,;/]'))) {
        final genre = value.trim();
        if (genre.isNotEmpty) genres.add(genre);
      }
    }
    final bitRates = songs
        .map((song) => song.bitRate)
        .where((value) => value > 0)
        .toList();
    final maxDepth = songs.fold<int>(
      0,
      (value, song) => song.bitDepth > value ? song.bitDepth : value,
    );
    final maxRate = songs.fold<int>(
      0,
      (value, song) => song.samplingRate > value ? song.samplingRate : value,
    );
    final totalBytes = songs.fold<int>(
      0,
      (value, song) => value + song.fileSize,
    );
    final totalSeconds = songs.fold<int>(
      0,
      (value, song) => value + song.duration,
    );
    final quality = <String>[
      if (bitRates.isNotEmpty)
        bitRates.reduce((a, b) => a < b ? a : b) ==
                bitRates.reduce((a, b) => a > b ? a : b)
            ? '${bitRates.first} kbps'
            : '${bitRates.reduce((a, b) => a < b ? a : b)}–${bitRates.reduce((a, b) => a > b ? a : b)} kbps',
      if (maxDepth > 0) '$maxDepth-bit',
      if (maxRate > 0)
        '${(maxRate / 1000).toStringAsFixed(maxRate % 1000 == 0 ? 0 : 1)} kHz',
    ].join(' · ');
    final rows = <(String, String)>[
      (l.songsHeader, '${songs.length} · ${_compactDuration(totalSeconds)}'),
      if (album.year > 0) (l.filterYear, '${album.year}'),
      if (formats.isNotEmpty) (l.albumFormats, formats.join(' · ')),
      if (quality.isNotEmpty) (l.albumQualityRange, quality),
      if (totalBytes > 0) (l.albumTotalSize, _compactBytes(totalBytes)),
      if (genres.isNotEmpty) (l.filterGenre, genres.take(3).join(' · ')),
    ];
    return KeyedSubtree(
      key: key,
      child: NaviGlass(
        opaque: true,
        padding: const EdgeInsets.all(NaviSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: NaviColors.textSecondary,
                ),
                const SizedBox(width: NaviSpacing.xxs),
                Expanded(
                  child: Text(
                    l.albumAudioDetails,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: NaviSpacing.xs),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (final row in rows)
                      Padding(
                        padding: const EdgeInsets.only(top: NaviSpacing.xxs),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 84,
                              child: Text(
                                row.$1,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: NaviColors.textSecondary),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                row.$2,
                                textAlign: TextAlign.right,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: NaviColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _compactBytes(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(0)} MB';
  }

  List<Widget> _suggestionSlivers(AppLocalizations l) {
    final message = _suggestionsError != null
        ? l.similarSuggestionsError
        : _suggestions.isEmpty && !_suggestionsLoading
        ? l.similarSuggestionsEmpty
        : null;
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            NaviSpacing.page,
            NaviSpacing.xl,
            NaviSpacing.page,
            NaviSpacing.sm,
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 19),
              const SizedBox(width: NaviSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.playlistSuggestions,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      l.playlistSuggestionsSubtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l.refreshSelection,
                onPressed: _suggestionsLoading
                    ? null
                    : () => unawaited(_loadSuggestions(refresh: true)),
                icon: const Icon(Icons.refresh_rounded, size: 20),
              ),
            ],
          ),
        ),
      ),
      if (_suggestionsLoading)
        const SliverToBoxAdapter(child: NaviInlineProgress())
      else if (message != null)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              NaviSpacing.page,
              NaviSpacing.sm,
              NaviSpacing.page,
              NaviSpacing.xl,
            ),
            child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            NaviSpacing.page,
            0,
            NaviSpacing.page,
            NaviSpacing.xl,
          ),
          sliver: SliverList.separated(
            itemCount: _suggestions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 2),
            itemBuilder: (context, index) {
              final song = _suggestions[index];
              final adding = _addingSuggestionIds.contains(song.id);
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: SizedBox.square(
                  dimension: 44,
                  child: _Artwork(
                    coverArt: song.coverArt,
                    fallback: Icons.music_note_rounded,
                    builder: widget.artworkBuilder,
                    radius: 9,
                  ),
                ),
                title: Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  primaryArtistName(song.artist),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onLongPress: widget.onSongMenu == null
                    ? null
                    : () => widget.onSongMenu!(song),
                trailing: IconButton.filledTonal(
                  tooltip: l.addToPlaylist,
                  onPressed: adding || widget.onAddSuggestion == null
                      ? null
                      : () => unawaited(_addSuggestion(song)),
                  icon: adding
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_rounded, size: 19),
                ),
              );
            },
          ),
        ),
    ];
  }

  Future<void> _addSuggestion(Song song) async {
    final add = widget.onAddSuggestion;
    if (add == null || _addingSuggestionIds.contains(song.id)) return;
    setState(() => _addingSuggestionIds.add(song.id));
    try {
      await add(song);
      if (!mounted) return;
      widget.controller.appendSong(song);
      setState(
        () => _suggestions = List.unmodifiable(
          _suggestions.where((item) => item.id != song.id),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).addedToPlaylist(widget.title),
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).playlistSaveFailed('$error'),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _addingSuggestionIds.remove(song.id));
    }
  }
}

class _PagedCatalogList<T> extends StatefulWidget {
  const _PagedCatalogList({
    required this.controller,
    required this.title,
    required this.searchHint,
    required this.itemBuilder,
    this.actions = const [],
  });

  final PagedCatalogController<T> controller;
  final String title;
  final String searchHint;
  final Widget Function(BuildContext, T) itemBuilder;
  final List<Widget> actions;

  @override
  State<_PagedCatalogList<T>> createState() => _PagedCatalogListState<T>();
}

class _PagedCatalogListState<T> extends State<_PagedCatalogList<T>> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_nearEnd);
    unawaited(widget.controller.initialize());
  }

  void _nearEnd() {
    if (_scroll.hasClients && _scroll.position.extentAfter < 600) {
      unawaited(widget.controller.loadMore());
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final l = AppLocalizations.of(context);
      final state = widget.controller.state;
      return Scaffold(
        body: CustomScrollView(
          controller: _scroll,
          slivers: [
            NaviSliverHeader(
              title: Text(widget.title),
              actions: widget.actions,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(NaviSpacing.page),
                child: TextField(
                  onChanged: widget.controller.setQuery,
                  decoration: InputDecoration(
                    hintText: widget.searchHint,
                    prefixIcon: const Icon(Icons.search_rounded),
                  ),
                ),
              ),
            ),
            if (state.loading && state.items.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator.adaptive()),
              )
            else if (state.error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(NaviSpacing.page),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l.couldNotLoadLibrary('${state.error}'),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: NaviSpacing.md),
                        FilledButton.tonal(
                          style: NaviTheme.tonalButtonStyle,
                          onPressed: state.loading
                              ? null
                              : () => unawaited(widget.controller.refresh()),
                          child: Text(l.tryAgain),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (state.items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text(l.nothingToShowYet)),
              )
            else
              SliverList.builder(
                itemCount: state.items.length,
                itemBuilder: (context, index) =>
                    widget.itemBuilder(context, state.items[index]),
              ),
          ],
        ),
      );
    },
  );
}

class _PagedCatalogGrid extends StatefulWidget {
  const _PagedCatalogGrid({
    required this.controller,
    required this.title,
    required this.onAlbumTap,
    this.artworkBuilder,
    this.actions = const [],
  });

  final PagedCatalogController<Album> controller;
  final String title;
  final ValueChanged<Album> onAlbumTap;
  final CatalogArtworkBuilder? artworkBuilder;
  final List<Widget> actions;

  @override
  State<_PagedCatalogGrid> createState() => _PagedCatalogGridState();
}

class _PagedCatalogGridState extends State<_PagedCatalogGrid> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.hasClients && _scroll.position.extentAfter < 800) {
        unawaited(widget.controller.loadMore());
      }
    });
    unawaited(widget.controller.initialize());
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) => Scaffold(
      body: CustomScrollView(
        controller: _scroll,
        slivers: [
          NaviSliverHeader(title: Text(widget.title), actions: widget.actions),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(NaviSpacing.page),
              child: TextField(
                onChanged: widget.controller.setQuery,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).searchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: NaviSpacing.page),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: NaviSpacing.sm,
                mainAxisSpacing: NaviSpacing.lg,
                childAspectRatio: 0.68,
              ),
              itemCount: widget.controller.state.items.length,
              itemBuilder: (context, index) {
                final album = widget.controller.state.items[index];
                return NaviAlbumCard(
                  album: album,
                  artworkBuilder: widget.artworkBuilder,
                  onTap: () => widget.onAlbumTap(album),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> _showAlbumSort(
  BuildContext context,
  PagedCatalogController<Album> controller,
) async {
  final l = AppLocalizations.of(context);
  final current = AlbumSort.values.firstWhere(
    (value) => value.name == controller.state.sort,
    orElse: () => AlbumSort.title,
  );
  final selected = await _showSortSheet<AlbumSort>(
    context,
    title: l.sortBy,
    current: current,
    values: [
      for (final value in AlbumSort.values)
        (
          value,
          switch (value) {
            AlbumSort.title => l.sortTitle,
            AlbumSort.artist => l.sortArtist,
            AlbumSort.recentlyAdded => l.sortRecent,
            AlbumSort.recentlyPlayed => l.sortRecentlyPlayed,
            AlbumSort.mostPlayed => l.sortPlays,
            AlbumSort.random => l.sortRandom,
          },
        ),
    ],
  );
  if (selected != null) {
    await controller.setSort(
      selected.name,
      randomize: selected == AlbumSort.random,
    );
  }
}

Future<void> _showArtistSort(
  BuildContext context,
  PagedCatalogController<ArtistSummary> controller,
) async {
  final l = AppLocalizations.of(context);
  final current = ArtistSort.values.firstWhere(
    (value) => value.name == controller.state.sort,
    orElse: () => ArtistSort.name,
  );
  final selected = await _showSortSheet<ArtistSort>(
    context,
    title: l.sortBy,
    current: current,
    values: [
      for (final value in ArtistSort.values)
        (
          value,
          switch (value) {
            ArtistSort.name => l.sortTitle,
            ArtistSort.albumCount => l.sortAlbumCount,
            ArtistSort.random => l.sortRandom,
          },
        ),
    ],
  );
  if (selected != null) {
    await controller.setSort(
      selected.name,
      randomize: selected == ArtistSort.random,
    );
  }
}

Future<T?> _showSortSheet<T>(
  BuildContext context, {
  required String title,
  required T current,
  required List<(T, String)> values,
}) => showNaviModalBottomSheet<T>(
  context: context,
  builder: (sheetContext) => NaviModalSurface(
    child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const NaviModalHandle(),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              NaviSpacing.page,
              NaviSpacing.xs,
              NaviSpacing.page,
              NaviSpacing.sm,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          for (final (value, label) in values)
            ListTile(
              leading: Icon(
                value == current
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                color: value == current ? NaviColors.textPrimary : null,
              ),
              title: Text(label),
              onTap: () => Navigator.of(sheetContext).pop(value),
            ),
          const SizedBox(height: NaviSpacing.sm),
        ],
      ),
    ),
  ),
);

class _Artwork extends StatelessWidget {
  const _Artwork({
    required this.coverArt,
    required this.fallback,
    this.builder,
    this.radius = NaviRadii.row,
  });

  final String? coverArt;
  final IconData fallback;
  final CatalogArtworkBuilder? builder;
  final double radius;

  @override
  Widget build(BuildContext context) => NaviArtwork(
    coverArt: coverArt,
    fallback: fallback,
    radius: radius,
    // Without a builder the fallback keeps the row's 52 pt leading size.
    size: builder == null ? 52 : null,
    child: builder?.call(context, coverArt, fallback),
  );
}
