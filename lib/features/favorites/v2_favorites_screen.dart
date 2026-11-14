import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../design_system/navi_design_tokens.dart';
import '../../design_system/navi_theme.dart';
import '../../design_system/widgets/navi_widgets.dart';
import '../../domain/library/song_filter.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../library/songs/song_sort_labels.dart';
import '../library/songs/v2_songs_screen.dart';
import '../library/v2_library_screens.dart';
import 'favorites_controller.dart';

typedef FavoritePlaybackCallback =
    void Function(List<Song> songs, {required bool shuffle});

class V2FavoritesScreen extends StatefulWidget {
  const V2FavoritesScreen({
    super.key,
    required this.controller,
    required this.onSongTap,
    required this.onSongMenu,
    required this.onAlbumTap,
    required this.onArtistTap,
    required this.onPlaySongs,
    required this.onPlayMix,
    this.songArtworkBuilder,
    this.catalogArtworkBuilder,
    this.nowPlaying,
    this.playing,
    this.onRefresh,
  });
  /// Pull must reach the server; the runtime decides how cheap that is.
  final Future<void> Function()? onRefresh;

  final FavoritesController controller;
  final ValueChanged<Song> onSongTap;
  final ValueChanged<Song> onSongMenu;
  final ValueChanged<Album> onAlbumTap;
  final ValueChanged<ArtistSummary> onArtistTap;
  final FavoritePlaybackCallback onPlaySongs;
  final Future<void> Function(List<Song> favorites) onPlayMix;
  final SongArtworkBuilder? songArtworkBuilder;
  final CatalogArtworkBuilder? catalogArtworkBuilder;

  /// Id of the song at the playhead; rows mark themselves when it matches.
  final ValueListenable<String?>? nowPlaying;
  final ValueListenable<bool>? playing;

  @override
  State<V2FavoritesScreen> createState() => _V2FavoritesScreenState();
}

class _V2FavoritesScreenState extends State<V2FavoritesScreen> {
  final TextEditingController _query = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _mixLoading = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_loadNearEnd);
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    await widget.controller.initialize();
    if (!mounted) return;
    final restoredQuery = widget.controller.songs.state.filter.query;
    if (_query.text != restoredQuery) {
      _query.text = restoredQuery;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _query.dispose();
    _scroll
      ..removeListener(_loadNearEnd)
      ..dispose();
    super.dispose();
  }

  void _loadNearEnd() {
    if (widget.controller.section == FavoriteSection.songs &&
        _scroll.hasClients &&
        _scroll.position.extentAfter < 700) {
      unawaited(widget.controller.songs.loadMore());
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([widget.controller, widget.controller.songs]),
    builder: (context, _) {
      final l = AppLocalizations.of(context);
      return Scaffold(
        body: NaviArtworkAtmosphere(
          primary: NaviColors.atmosphereWine,
          secondary: NaviColors.atmospherePlum,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _header(l),
                _search(l),
                _segments(l),
                Expanded(child: _animatedSection(l)),
              ],
            ),
          ),
        ),
      );
    },
  );

  Widget _header(AppLocalizations l) => Padding(
    padding: const EdgeInsets.fromLTRB(
      NaviSpacing.page,
      NaviSpacing.md,
      NaviSpacing.page,
      NaviSpacing.sm,
    ),
    child: Text(
      l.navFavorites,
      style: Theme.of(context).textTheme.displaySmall,
    ),
  );

  Widget _search(AppLocalizations l) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: NaviSpacing.page),
    child: TextField(
      controller: _query,
      onChanged: (value) {
        widget.controller.setQuery(value);
        setState(() {});
      },
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: l.searchHint,
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: _query.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  _query.clear();
                  widget.controller.setQuery('');
                  setState(() {});
                },
                icon: const Icon(Icons.close_rounded, size: 19),
              ),
      ),
    ),
  );

  Widget _segments(AppLocalizations l) => Padding(
    padding: const EdgeInsets.fromLTRB(
      NaviSpacing.page,
      NaviSpacing.sm,
      NaviSpacing.page,
      NaviSpacing.xs,
    ),
    child: NaviGlass(
      radius: NaviRadii.card,
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          _segment(FavoriteSection.songs, l.navSongs),
          _segment(FavoriteSection.albums, l.navAlbums),
          _segment(FavoriteSection.artists, l.navArtists),
        ],
      ),
    ),
  );

  Widget _segment(FavoriteSection section, String label) {
    final selected = widget.controller.section == section;
    return Expanded(
      child: NaviPressable(
        pressedScale: 0.99,
        borderRadius: BorderRadius.circular(NaviRadii.row - 2),
        onTap: () {
          unawaited(widget.controller.select(section));
          if (_scroll.hasClients) _scroll.jumpTo(0);
        },
        child: AnimatedContainer(
          duration: NaviMotion.standard,
          curve: NaviMotion.curve,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? NaviColors.surfaceRaised : Colors.transparent,
            borderRadius: BorderRadius.circular(NaviRadii.row - 2),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: selected
                  ? NaviColors.textPrimary
                  : NaviColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _animatedSection(AppLocalizations l) => AnimatedSwitcher(
    duration: NaviMotion.page,
    switchInCurve: NaviMotion.curve,
    switchOutCurve: Curves.easeInCubic,
    transitionBuilder: (child, animation) =>
        FadeTransition(opacity: animation, child: child),
    child: switch (widget.controller.section) {
      FavoriteSection.songs => _songs(l),
      FavoriteSection.albums => _albums(l),
      FavoriteSection.artists => _artists(l),
    },
  );

  Widget _songs(AppLocalizations l) {
    final state = widget.controller.songs.state;
    if (state.initialLoading && state.songs.isEmpty) {
      return const _FavoriteLoading(key: ValueKey('songs-loading'));
    }
    if (state.error != null && state.songs.isEmpty) {
      return _FavoriteEmpty(
        key: const ValueKey('songs-error'),
        icon: Icons.cloud_off_rounded,
        text: l.couldNotLoadLibrary('${state.error}'),
      );
    }
    final songs = state.songs;
    if (songs.isEmpty) {
      final filtered = state.filter.activeFilterCount > 1;
      return _FavoriteEmpty(
        key: const ValueKey('songs-empty'),
        icon: filtered
            ? Icons.filter_alt_off_rounded
            : Icons.favorite_border_rounded,
        text: filtered ? l.noFilteredSongs : l.nothingToShowYet,
        actionLabel: filtered ? l.clearFilters : null,
        onAction: filtered ? _clearSongFilters : null,
      );
    }
    final letters = state.filter.sort == SongSort.title
        ? _letters(songs.map((song) => song.title))
        : const <String>[];
    return RefreshIndicator.adaptive(
      key: const ValueKey('songs'),
      onRefresh: widget.onRefresh ?? widget.controller.refresh,
      child: Stack(
        children: [
          ListView.builder(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(
              NaviSpacing.page,
              NaviSpacing.xs,
              letters.length >= 6 ? 28 : NaviSpacing.page,
              NaviSpacing.xl,
            ),
            itemCount: songs.length + 2,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _FavoriteCountActions(
                  count:
                      '${l.songsCount(state.totalCount)} · ${songSortLabel(l, state.filter.sort)}',
                  onTune: _openSongFilters,
                  tuneTooltip: l.filters,
                  tuneBadge: _visibleSongFilterCount(state.filter),
                  onPlay: () => _playAll(shuffle: false),
                  onShuffle: () => _playAll(shuffle: true),
                  onMix: _playMix,
                  mixLoading: _mixLoading,
                );
              }
              if (index == songs.length + 1) {
                return state.loadingMore
                    ? const Padding(
                        padding: EdgeInsets.all(NaviSpacing.md),
                        child: LinearProgressIndicator(minHeight: 2),
                      )
                    : const SizedBox(height: NaviSpacing.sm);
              }
              final song = songs[index - 1];
              return NaviSongRow(
                song: song,
                artwork: widget.songArtworkBuilder?.call(context, song),
                nowPlayingListenable: widget.nowPlaying,
                playingListenable: widget.playing,
                starred: true,
                subtitle: '${primaryArtistName(song.artist)} · ${song.album}',
                trailingText: formatDuration(song.duration),
                padding: const EdgeInsets.symmetric(vertical: NaviSpacing.xs),
                onTap: () => widget.onSongTap(song),
                onMenu: () => widget.onSongMenu(song),
              );
            },
          ),
          if (letters.length >= 6)
            Positioned(
              right: 2,
              top: 54,
              bottom: NaviSpacing.sm,
              child: _AlphabetRail(
                letters: letters,
                onSelect: (letter) => _jumpToLetter(songs, letter),
              ),
            ),
        ],
      ),
    );
  }

  Widget _albums(AppLocalizations l) {
    final albums = widget.controller.visibleAlbums;
    if (widget.controller.loadingCatalog && albums.isEmpty) {
      return const _FavoriteLoading(key: ValueKey('albums-loading'));
    }
    if (albums.isEmpty) {
      return _FavoriteEmpty(
        key: const ValueKey('albums-empty'),
        icon: Icons.album_outlined,
        text: l.nothingToShowYet,
      );
    }
    return RefreshIndicator.adaptive(
      key: const ValueKey('albums'),
      onRefresh: widget.onRefresh ?? widget.controller.refresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(
          NaviSpacing.page,
          NaviSpacing.xs,
          NaviSpacing.page,
          NaviSpacing.xl,
        ),
        itemCount: albums.length + 1,
        itemBuilder: (context, index) => index == 0
            ? _FavoriteCountActions(
                count:
                    '${l.albumsCount(albums.length)} · ${_albumSortName(l, widget.controller.albumSort)}',
                onTune: _openAlbumSort,
                tuneTooltip: l.sortBy,
              )
            : _FavoriteAlbumRow(
                album: albums[index - 1],
                artwork: widget.catalogArtworkBuilder?.call(
                  context,
                  albums[index - 1].coverArt,
                  Icons.album_rounded,
                ),
                onTap: () => widget.onAlbumTap(albums[index - 1]),
              ),
      ),
    );
  }

  Widget _artists(AppLocalizations l) {
    final artists = widget.controller.visibleArtists;
    if (widget.controller.loadingCatalog && artists.isEmpty) {
      return const _FavoriteLoading(key: ValueKey('artists-loading'));
    }
    if (artists.isEmpty) {
      return _FavoriteEmpty(
        key: const ValueKey('artists-empty'),
        icon: Icons.person_outline_rounded,
        text: l.nothingToShowYet,
      );
    }
    return RefreshIndicator.adaptive(
      key: const ValueKey('artists'),
      onRefresh: widget.controller.refresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(
          NaviSpacing.page,
          NaviSpacing.xs,
          NaviSpacing.page,
          NaviSpacing.xl,
        ),
        itemCount: artists.length + 1,
        itemBuilder: (context, index) => index == 0
            ? _FavoriteCountActions(
                count:
                    '${l.artistsCount(artists.length)} · ${_artistSortName(l, widget.controller.artistSort)}',
                onTune: _openArtistSort,
                tuneTooltip: l.sortBy,
              )
            : _FavoriteArtistRow(
                artist: artists[index - 1],
                artwork: widget.catalogArtworkBuilder?.call(
                  context,
                  artists[index - 1].coverArt,
                  Icons.person_rounded,
                ),
                onTap: () => widget.onArtistTap(artists[index - 1]),
              ),
      ),
    );
  }

  Future<void> _playAll({required bool shuffle}) async {
    final songs = await widget.controller.allVisibleSongs();
    if (songs.isNotEmpty) widget.onPlaySongs(songs, shuffle: shuffle);
  }

  Future<void> _playMix() async {
    if (_mixLoading) return;
    setState(() => _mixLoading = true);
    try {
      final songs = await widget.controller.allVisibleSongs();
      if (songs.isNotEmpty) await widget.onPlayMix(songs);
    } finally {
      if (mounted) setState(() => _mixLoading = false);
    }
  }

  Future<void> _openSongFilters() async {
    final result = await showSongFilterSheet(
      context,
      initial: widget.controller.songs.state.filter,
      lockFavorites: true,
    );
    if (result == null || !mounted) return;
    final effective = result.withFavoritesOnly(true);
    _query.text = effective.query;
    await widget.controller.applySongFilter(effective);
  }

  void _clearSongFilters() {
    _query.clear();
    widget.controller.setQuery('');
    unawaited(widget.controller.applySongFilter(defaultFavoriteSongFilter));
  }

  Future<void> _openAlbumSort() async {
    final l = AppLocalizations.of(context);
    final selected = await _chooseSort<FavoriteAlbumSort>(
      title: l.sortBy,
      current: widget.controller.albumSort,
      values: [
        for (final value in FavoriteAlbumSort.values)
          (value, _albumSortName(l, value)),
      ],
    );
    if (selected != null) {
      await widget.controller.setAlbumSort(selected);
    }
  }

  Future<void> _openArtistSort() async {
    final l = AppLocalizations.of(context);
    final selected = await _chooseSort<FavoriteArtistSort>(
      title: l.sortBy,
      current: widget.controller.artistSort,
      values: [
        for (final value in FavoriteArtistSort.values)
          (value, _artistSortName(l, value)),
      ],
    );
    if (selected != null) {
      await widget.controller.setArtistSort(selected);
    }
  }

  Future<T?> _chooseSort<T>({
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
                child: Text(
                  title,
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
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

  void _jumpToLetter(List<Song> songs, String letter) {
    final index = songs.indexWhere(
      (song) => _firstLetter(song.title) == letter,
    );
    if (index < 0 || !_scroll.hasClients) return;
    _scroll.animateTo(
      48 + index * 64.0,
      duration: NaviMotion.standard,
      curve: NaviMotion.curve,
    );
  }
}

class _FavoriteCountActions extends StatelessWidget {
  const _FavoriteCountActions({
    required this.count,
    this.onTune,
    this.tuneTooltip,
    this.tuneBadge = 0,
    this.onPlay,
    this.onShuffle,
    this.onMix,
    this.mixLoading = false,
  });

  final String count;
  final VoidCallback? onTune;
  final String? tuneTooltip;
  final int tuneBadge;
  final VoidCallback? onPlay;
  final VoidCallback? onShuffle;
  final VoidCallback? onMix;
  final bool mixLoading;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Expanded(
            child: Text(
              count,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          if (onTune != null)
            Badge(
              isLabelVisible: tuneBadge > 0,
              label: Text('$tuneBadge'),
              child: IconButton.filledTonal(
                tooltip: tuneTooltip,
                visualDensity: VisualDensity.compact,
                onPressed: onTune,
                icon: const Icon(Icons.tune_rounded, size: 19),
              ),
            ),
          if (onMix != null)
            Padding(
              padding: const EdgeInsets.only(left: NaviSpacing.xs),
              child: FilledButton.tonalIcon(
                style: NaviTheme.tonalButtonStyle,
                onPressed: mixLoading ? null : onMix,
                icon: mixLoading
                    ? const SizedBox.square(
                        dimension: 15,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome_rounded, size: 17),
                label: Text(l.favoriteMix),
              ),
            ),
          if (onShuffle != null)
            Padding(
              padding: const EdgeInsets.only(left: NaviSpacing.xs),
              child: IconButton.filledTonal(
                tooltip: l.shuffle,
                visualDensity: VisualDensity.compact,
                onPressed: onShuffle,
                icon: const Icon(Icons.shuffle_rounded, size: 19),
              ),
            ),
          if (onPlay != null) ...[
            const SizedBox(width: NaviSpacing.xs),
            IconButton.filledTonal(
              style: IconButton.styleFrom(
                backgroundColor: NaviColors.surfaceRaised,
                foregroundColor: NaviColors.textPrimary,
              ),
              tooltip: l.play,
              visualDensity: VisualDensity.compact,
              onPressed: onPlay,
              icon: const Icon(Icons.play_arrow_rounded, size: 21),
            ),
          ],
        ],
      ),
    );
  }
}

class _FavoriteAlbumRow extends StatelessWidget {
  const _FavoriteAlbumRow({
    required this.album,
    required this.onTap,
    this.artwork,
  });

  final Album album;
  final Widget? artwork;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => NaviPressable(
    pressedScale: 0.988,
    onTap: onTap,
    child: SizedBox(
      height: 68,
      child: Row(
        children: [
          _rowArtwork(artwork, Icons.album_rounded),
          const SizedBox(width: NaviSpacing.sm),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  album.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  [
                    album.artist,
                    if (album.year > 0) '${album.year}',
                    AppLocalizations.of(context).songsCount(album.songCount),
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 20),
        ],
      ),
    ),
  );
}

class _FavoriteArtistRow extends StatelessWidget {
  const _FavoriteArtistRow({
    required this.artist,
    required this.onTap,
    this.artwork,
  });

  final ArtistSummary artist;
  final Widget? artwork;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => NaviPressable(
    pressedScale: 0.988,
    onTap: onTap,
    child: SizedBox(
      height: 64,
      child: Row(
        children: [
          ClipOval(child: _rowArtwork(artwork, Icons.person_rounded)),
          const SizedBox(width: NaviSpacing.sm),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artist.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  AppLocalizations.of(context).albumsCount(artist.albumCount),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 20),
        ],
      ),
    ),
  );
}

Widget _rowArtwork(Widget? artwork, IconData fallback) => ClipRRect(
  borderRadius: BorderRadius.circular(10),
  child: SizedBox.square(
    dimension: 50,
    child:
        artwork ??
        ColoredBox(
          color: NaviColors.surfaceRaised,
          child: Icon(fallback, size: 20),
        ),
  ),
);

class _AlphabetRail extends StatelessWidget {
  const _AlphabetRail({required this.letters, required this.onSelect});

  final List<String> letters;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) => Center(
    child: NaviGlass(
      radius: 9,
      blur: 14,
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final letter in letters)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelect(letter),
              child: SizedBox(
                width: 16,
                height: 13,
                child: Center(
                  child: Text(
                    letter,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: NaviColors.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _FavoriteLoading extends StatelessWidget {
  const _FavoriteLoading({super.key});

  @override
  Widget build(BuildContext context) => ListView.builder(
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.symmetric(horizontal: NaviSpacing.page),
    itemCount: 7,
    itemBuilder: (context, index) => Padding(
      padding: const EdgeInsets.symmetric(vertical: NaviSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: NaviColors.surfaceRaised,
              borderRadius: BorderRadius.circular(9),
            ),
          ),
          const SizedBox(width: NaviSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(
                  widthFactor: 0.62,
                  child: Container(height: 12, color: NaviColors.surfaceRaised),
                ),
                const SizedBox(height: NaviSpacing.xs),
                FractionallySizedBox(
                  widthFactor: 0.42,
                  child: Container(height: 9, color: NaviColors.surfaceRaised),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _FavoriteEmpty extends StatelessWidget {
  const _FavoriteEmpty({
    super.key,
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => ListView(
    key: key,
    physics: const AlwaysScrollableScrollPhysics(),
    children: [
      const SizedBox(height: 96),
      Icon(icon, size: 28, color: NaviColors.textTertiary),
      const SizedBox(height: NaviSpacing.sm),
      Text(text, textAlign: TextAlign.center),
      if (actionLabel case final label?) ...[
        const SizedBox(height: NaviSpacing.md),
        Center(
          child: FilledButton(onPressed: onAction, child: Text(label)),
        ),
      ],
    ],
  );
}

int _visibleSongFilterCount(SongFilter filter) {
  var count = filter.activeFilterCount;
  if (filter.favoritesOnly) count--;
  if (filter.query.trim().isNotEmpty) count--;
  return count < 0 ? 0 : count;
}

String _albumSortName(AppLocalizations l, FavoriteAlbumSort value) =>
    switch (value) {
      FavoriteAlbumSort.title => l.sortTitle,
      FavoriteAlbumSort.artist => l.sortArtist,
      FavoriteAlbumSort.yearNewest => l.sortYear,
      FavoriteAlbumSort.newest => l.sortRecent,
      FavoriteAlbumSort.mostPlayed => l.sortPlays,
    };

String _artistSortName(AppLocalizations l, FavoriteArtistSort value) =>
    switch (value) {
      FavoriteArtistSort.name => l.sortTitle,
      FavoriteArtistSort.albumCount => l.sortAlbumCount,
    };

List<String> _letters(Iterable<String> values) {
  final result =
      values
          .map(_firstLetter)
          .where((value) => value.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
  return result;
}

String _firstLetter(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? '' : trimmed.substring(0, 1).toUpperCase();
}
