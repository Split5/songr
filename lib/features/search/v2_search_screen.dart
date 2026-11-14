import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/v2/v2_shell.dart';
import '../../design_system/navi_design_tokens.dart';
import '../../design_system/widgets/navi_widgets.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../library/v2_library_screens.dart';
import 'search_controller.dart';

class V2SearchScreen extends StatefulWidget {
  const V2SearchScreen({
    super.key,
    required this.controller,
    required this.onSongTap,
    required this.onAlbumTap,
    required this.onArtistTap,
    required this.onPlaylistTap,
    this.onSongMenu,
    this.artworkBuilder,
    this.nowPlaying,
    this.playing,
  });

  final V2SearchController controller;
  final ValueChanged<Song> onSongTap;
  final ValueChanged<Album> onAlbumTap;
  final ValueChanged<ArtistSummary> onArtistTap;
  final ValueChanged<Playlist> onPlaylistTap;
  final ValueChanged<Song>? onSongMenu;
  final CatalogArtworkBuilder? artworkBuilder;

  /// Id of the song at the playhead; rows mark themselves when it matches.
  final ValueListenable<String?>? nowPlaying;
  final ValueListenable<bool>? playing;

  @override
  State<V2SearchScreen> createState() => _V2SearchScreenState();
}

class _V2SearchScreenState extends State<V2SearchScreen> {
  final TextEditingController _query = TextEditingController();
  final FocusNode _focusNode = FocusNode(debugLabel: 'global-library-search');
  int _lastActivation = -1;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_focusChanged);
    unawaited(widget.controller.initialize());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final activity = V2TabActivity.maybeOf(context);
    if (activity == null ||
        !activity.isActive ||
        activity.activation == _lastActivation) {
      return;
    }
    _lastActivation = activity.activation;
    final compactPhone = MediaQuery.sizeOf(context).shortestSide < 600;
    if (compactPhone) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_focusChanged);
    _focusNode.dispose();
    _query.dispose();
    super.dispose();
  }

  void _focusChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final state = widget.controller.state;
      final l = AppLocalizations.of(context);
      return Scaffold(
        body: NaviArtworkAtmosphere(
          primary: NaviColors.atmospherePlum,
          secondary: NaviColors.atmosphereWine,
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(),
            slivers: [
              NaviSliverHeader(title: Text(l.tooltipSearch)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    NaviSpacing.page,
                    NaviSpacing.md,
                    NaviSpacing.page,
                    NaviSpacing.sm,
                  ),
                  child: _searchControls(l),
                ),
              ),
              if (state.query.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _SearchEmptyState(l: l),
                )
              else if (state.loading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(NaviSpacing.xl),
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
                )
              else if (state.error != null)
                SliverFillRemaining(
                  child: Center(child: Text(l.searchError('${state.error}'))),
                )
              else
                ..._resultSlivers(state, l),
              const SliverToBoxAdapter(child: SizedBox(height: NaviSpacing.xl)),
            ],
          ),
        ),
      );
    },
  );

  Widget _searchControls(AppLocalizations l) => NaviGlass(
    key: const ValueKey('global-search-field-surface'),
    radius: NaviRadii.card,
    padding: const EdgeInsets.symmetric(horizontal: NaviSpacing.xs),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            key: const ValueKey('global-search-field'),
            controller: _query,
            focusNode: _focusNode,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _focusNode.unfocus(),
            onTapOutside: (_) => _focusNode.unfocus(),
            onChanged: (value) {
              widget.controller.setQuery(value);
              setState(() {});
            },
            decoration: InputDecoration(
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: l.searchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: l.clearFilters,
                      onPressed: _clearQuery,
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
        ),
        AnimatedSize(
          duration: NaviMotion.micro,
          curve: NaviMotion.curve,
          child: _focusNode.hasFocus
              ? Padding(
                  padding: const EdgeInsets.only(right: NaviSpacing.xs),
                  child: TextButton(
                    onPressed: _focusNode.unfocus,
                    child: Text(l.done),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    ),
  );

  void _clearQuery() {
    _query.clear();
    widget.controller.setQuery('');
    setState(() {});
  }

  List<Widget> _resultSlivers(SearchViewState state, AppLocalizations l) {
    final widgets = <Widget>[];
    final songs = state.songs;
    final albums = state.albums;
    final artists = state.artists;
    final playlists = state.playlists;
    final sections = _orderedSections(state);
    for (final section in sections) {
      switch (section) {
        case SearchCategory.songs:
          if (songs.isEmpty) continue;
          widgets.addAll([
            _header(l.navSongs),
            SliverList.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                final openMenu = widget.onSongMenu == null
                    ? null
                    : () => _openResult(() => widget.onSongMenu!(song));
                return NaviSongRow(
                  song: song,
                  dense: true,
                  artwork: widget.artworkBuilder?.call(
                    context,
                    song.coverArt,
                    Icons.music_note_rounded,
                  ),
                  nowPlayingListenable: widget.nowPlaying,
                  playingListenable: widget.playing,
                  starred: song.starred,
                  subtitle: '${primaryArtistName(song.artist)} · ${song.album}',
                  onTap: () => _openResult(() => widget.onSongTap(song)),
                  onMenu: openMenu,
                  menuButtonKey: ValueKey('search-song-menu-${song.id}'),
                );
              },
            ),
          ]);
        case SearchCategory.albums:
          if (albums.isEmpty) continue;
          widgets.addAll([
            _header(l.navAlbums),
            SliverList.builder(
              itemCount: albums.length,
              itemBuilder: (context, index) {
                final album = albums[index];
                final details = <String>[
                  album.artist,
                  if (album.year > 0) '${album.year}',
                  l.songsCount(album.songCount),
                ];
                return _SearchResultRow(
                  title: album.name,
                  subtitle: details.join(' · '),
                  artwork: widget.artworkBuilder?.call(
                    context,
                    album.coverArt,
                    Icons.album_rounded,
                  ),
                  fallback: Icons.album_rounded,
                  onTap: () => _openResult(() => widget.onAlbumTap(album)),
                );
              },
            ),
          ]);
        case SearchCategory.artists:
          if (artists.isEmpty) continue;
          widgets.addAll([
            _header(l.navArtists),
            SliverList.builder(
              itemCount: artists.length,
              itemBuilder: (context, index) {
                final artist = artists[index];
                return _SearchResultRow(
                  title: artist.name,
                  subtitle: l.albumsCount(artist.albumCount),
                  artwork: widget.artworkBuilder?.call(
                    context,
                    artist.coverArt,
                    Icons.person_rounded,
                  ),
                  circularArtwork: true,
                  fallback: Icons.person_rounded,
                  onTap: () => _openResult(() => widget.onArtistTap(artist)),
                );
              },
            ),
          ]);
        case SearchCategory.playlists:
          if (playlists.isEmpty) continue;
          widgets.addAll([
            _header(l.navPlaylists),
            SliverList.builder(
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                return _SearchResultRow(
                  title: playlist.name,
                  subtitle: l.songsCount(playlist.songCount),
                  artwork: widget.artworkBuilder?.call(
                    context,
                    playlist.coverArt,
                    Icons.queue_music_rounded,
                  ),
                  fallback: Icons.queue_music_rounded,
                  onTap: () =>
                      _openResult(() => widget.onPlaylistTap(playlist)),
                );
              },
            ),
          ]);
        case SearchCategory.all:
          break;
      }
    }
    if (widgets.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: Text(l.noResults)),
        ),
      ];
    }
    widgets.add(
      const SliverToBoxAdapter(child: SizedBox(height: NaviSpacing.xl)),
    );
    return widgets;
  }

  List<SearchCategory> _orderedSections(SearchViewState state) {
    final sections = <SearchCategory>[
      if (state.albums.isNotEmpty) SearchCategory.albums,
      if (state.artists.isNotEmpty) SearchCategory.artists,
      if (state.songs.isNotEmpty) SearchCategory.songs,
      if (state.playlists.isNotEmpty) SearchCategory.playlists,
    ];
    final fallbackOrder = <SearchCategory, int>{
      SearchCategory.albums: 0,
      SearchCategory.artists: 1,
      SearchCategory.songs: 2,
      SearchCategory.playlists: 3,
    };
    sections.sort((a, b) {
      final score = _sectionMatchScore(
        state,
        a,
      ).compareTo(_sectionMatchScore(state, b));
      if (score != 0) return score;
      return fallbackOrder[a]!.compareTo(fallbackOrder[b]!);
    });
    return sections;
  }

  int _sectionMatchScore(SearchViewState state, SearchCategory category) {
    final query = state.query.trim().toLowerCase();
    final scores = switch (category) {
      SearchCategory.songs => state.songs.map(
        (song) =>
            searchMatchScore(song.title, '${song.artist} ${song.album}', query),
      ),
      SearchCategory.albums => state.albums.map(
        (album) => searchMatchScore(album.name, album.artist, query),
      ),
      SearchCategory.artists => state.artists.map(
        (artist) => searchMatchScore(artist.name, '', query),
      ),
      SearchCategory.playlists => state.playlists.map(
        (playlist) => searchMatchScore(playlist.name, '', query),
      ),
      SearchCategory.all => const <int>[],
    };
    return scores.fold<int>(99, (best, score) => score < best ? score : best);
  }

  void _openResult(VoidCallback action) {
    _focusNode.unfocus();
    action();
  }

  SliverToBoxAdapter _header(String title) => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(
        NaviSpacing.page,
        NaviSpacing.md,
        NaviSpacing.page,
        NaviSpacing.xs,
      ),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    ),
  );
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState({required this.l});

  final AppLocalizations l;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(NaviSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: NaviColors.surfaceRaised,
              borderRadius: BorderRadius.circular(NaviRadii.card),
              border: Border.all(color: NaviColors.glassBorder),
            ),
            child: const Icon(
              Icons.search_rounded,
              size: 30,
              color: NaviColors.textSecondary,
            ),
          ),
          const SizedBox(height: NaviSpacing.md),
          Text(
            l.searchHint,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: NaviColors.textSecondary),
          ),
        ],
      ),
    ),
  );
}

class _SearchResultRow extends StatelessWidget {
  const _SearchResultRow({
    required this.title,
    required this.fallback,
    required this.onTap,
    this.subtitle,
    this.artwork,
    this.circularArtwork = false,
  });

  final String title;
  final String? subtitle;
  final Widget? artwork;
  final IconData fallback;
  final VoidCallback onTap;
  final bool circularArtwork;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: NaviSpacing.page),
    child: DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: NaviColors.glassBorder.withValues(alpha: .4),
          ),
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          enableFeedback: false,
          dense: true,
          visualDensity: const VisualDensity(vertical: -1),
          contentPadding: EdgeInsets.zero,
          minLeadingWidth: 44,
          onTap: onTap,
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(
              circularArtwork ? 22 : NaviRadii.row,
            ),
            child: SizedBox.square(
              dimension: 44,
              child:
                  artwork ??
                  ColoredBox(
                    color: NaviColors.surfaceRaised,
                    child: Icon(fallback, size: 19),
                  ),
            ),
          ),
          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: subtitle == null
              ? null
              : Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: const Icon(Icons.chevron_right_rounded, size: 19),
        ),
      ),
    ),
  );
}
