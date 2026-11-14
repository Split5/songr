import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../design_system/navi_design_tokens.dart';
import '../../../design_system/navi_theme.dart';
import '../../../design_system/widgets/navi_widgets.dart';
import '../../../domain/library/song_filter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import 'song_sort_labels.dart';
import 'songs_controller.dart';

Future<SongFilter?> showSongFilterSheet(
  BuildContext context, {
  required SongFilter initial,
  bool lockFavorites = false,
}) {
  FocusManager.instance.primaryFocus?.unfocus();
  return showNaviModalBottomSheet<SongFilter>(
    context: context,
    isScrollControlled: true,
    builder: (context) =>
        _SongFilterSheet(initial: initial, lockFavorites: lockFavorites),
  );
}

class V2SongsScreen extends StatefulWidget {
  const V2SongsScreen({
    super.key,
    required this.controller,
    this.artworkBuilder,
    this.onSongTap,
    this.onSongMenu,
    this.title,
    this.lockFavorites = false,
    this.quickSwipeActionBuilder,
    this.nowPlaying,
    this.playing,
    this.onRefresh,
  });
  /// Pull must reach the server; the runtime decides how cheap that is.
  final Future<void> Function()? onRefresh;

  final SongsController controller;
  final SongArtworkBuilder? artworkBuilder;
  final ValueChanged<Song>? onSongTap;
  final ValueChanged<Song>? onSongMenu;
  final String? title;
  final bool lockFavorites;
  final NaviSwipeAction? Function(BuildContext context, Song song)?
  quickSwipeActionBuilder;

  /// Id of the song at the playhead; rows mark themselves when it matches.
  final ValueListenable<String?>? nowPlaying;
  final ValueListenable<bool>? playing;

  @override
  State<V2SongsScreen> createState() => _V2SongsScreenState();
}

class _V2SongsScreenState extends State<V2SongsScreen> {
  late final TextEditingController _searchController = TextEditingController(
    text: widget.controller.state.filter.query,
  );
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadNearEnd);
    unawaited(widget.controller.initialize());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController
      ..removeListener(_loadNearEnd)
      ..dispose();
    super.dispose();
  }

  void _loadNearEnd() {
    if (_scrollController.hasClients &&
        _scrollController.position.extentAfter < 700) {
      unawaited(widget.controller.loadMore());
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final state = widget.controller.state;
      final l = AppLocalizations.of(context);
      return Scaffold(
        body: RefreshIndicator.adaptive(
          onRefresh: widget.onRefresh ?? widget.controller.refresh,
          child: CustomScrollView(
            controller: _scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              NaviSliverHeader(title: Text(widget.title ?? l.navSongs)),
              SliverToBoxAdapter(child: _searchField(l)),
              SliverToBoxAdapter(child: _quickFilters(state.filter, l)),
              SliverToBoxAdapter(child: _resultHeader(state, l)),
              ..._resultSlivers(state, l),
            ],
          ),
        ),
      );
    },
  );

  Widget _searchField(AppLocalizations l) => Padding(
    padding: const EdgeInsets.fromLTRB(
      NaviSpacing.page,
      NaviSpacing.xs,
      NaviSpacing.page,
      NaviSpacing.sm,
    ),
    child: TextField(
      controller: _searchController,
      onChanged: widget.controller.setQuery,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: l.songsSearchHint,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                tooltip: l.clearFilters,
                onPressed: () {
                  _searchController.clear();
                  widget.controller.setQuery('');
                  setState(() {});
                },
                icon: const Icon(Icons.close_rounded),
              ),
      ),
    ),
  );

  Widget _resultHeader(SongsViewState state, AppLocalizations l) {
    final visibleFilterCount =
        state.filter.activeFilterCount -
        (widget.lockFavorites && state.filter.favoritesOnly ? 1 : 0);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        NaviSpacing.page,
        0,
        NaviSpacing.page,
        NaviSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: NaviMotion.micro,
              child: Text(
                '${l.songsCount(state.totalCount)} · '
                '${songSortLabel(l, state.filter.sort)}',
                key: ValueKey(state.totalCount),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          if (state.filter.isActive) ...[
            IconButton(
              tooltip: l.saveFilter,
              onPressed: _saveFilter,
              icon: const Icon(Icons.bookmark_add_outlined),
            ),
            const SizedBox(width: NaviSpacing.xxs),
          ],
          FilledButton.tonalIcon(
            style: NaviTheme.tonalButtonStyle,
            onPressed: () => _openFilters(state.filter),
            icon: const Icon(Icons.tune_rounded, size: 19),
            label: Text(
              visibleFilterCount == 0
                  ? l.filters
                  : '${l.filters} · $visibleFilterCount',
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickFilters(SongFilter filter, AppLocalizations l) => SizedBox(
    height: 46,
    child: ListView(
      padding: const EdgeInsets.symmetric(horizontal: NaviSpacing.page),
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      children: [
        for (final preset in widget.controller.savedFilters) ...[
          InputChip(
            avatar: const Icon(Icons.bookmark_rounded, size: 16),
            label: Text(preset.name),
            onPressed: () {
              _searchController.text = preset.filter.query;
              unawaited(widget.controller.applySavedFilter(preset));
            },
            onDeleted: () =>
                unawaited(widget.controller.deleteSavedFilter(preset.id)),
            deleteIcon: const Icon(Icons.close_rounded, size: 15),
          ),
          const SizedBox(width: NaviSpacing.xs),
        ],
        if (!widget.lockFavorites) ...[
          FilterChip(
            avatar: const Icon(Icons.favorite_rounded, size: 16),
            label: Text(l.filterFavorites),
            selected: filter.favoritesOnly,
            onSelected: (value) => unawaited(
              widget.controller.applyFilter(filter.withFavoritesOnly(value)),
            ),
          ),
          const SizedBox(width: NaviSpacing.xs),
        ],
        FilterChip(
          label: Text(l.qualityLossless),
          selected: filter.quality == SongQuality.lossless,
          onSelected: (value) => unawaited(
            widget.controller.applyFilter(
              filter.withQuality(
                value ? SongQuality.lossless : SongQuality.any,
              ),
            ),
          ),
        ),
        const SizedBox(width: NaviSpacing.xs),
        FilterChip(
          label: Text(l.qualityHiRes),
          selected: filter.quality == SongQuality.hiRes,
          onSelected: (value) => unawaited(
            widget.controller.applyFilter(
              filter.withQuality(value ? SongQuality.hiRes : SongQuality.any),
            ),
          ),
        ),
        const SizedBox(width: NaviSpacing.xs),
        FilterChip(
          avatar: const Icon(Icons.schedule_rounded, size: 16),
          label: Text(l.sortRecent),
          selected: filter.sort == SongSort.newest,
          onSelected: (value) => unawaited(
            widget.controller.applyFilter(
              _sortFilter(filter, value ? SongSort.newest : SongSort.title),
            ),
          ),
        ),
        const SizedBox(width: NaviSpacing.xs),
        FilterChip(
          label: Text(l.sortRecentlyPlayed),
          selected: filter.sort == SongSort.recentlyPlayed,
          onSelected: (value) => unawaited(
            widget.controller.applyFilter(
              _sortFilter(
                filter,
                value ? SongSort.recentlyPlayed : SongSort.title,
              ),
            ),
          ),
        ),
        const SizedBox(width: NaviSpacing.xs),
        FilterChip(
          label: Text(l.sortPlays),
          selected: filter.sort == SongSort.mostPlayed,
          onSelected: (value) => unawaited(
            widget.controller.applyFilter(
              _sortFilter(filter, value ? SongSort.mostPlayed : SongSort.title),
            ),
          ),
        ),
        const SizedBox(width: NaviSpacing.xs),
        FilterChip(
          label: Text(l.sortRandom),
          selected: filter.sort == SongSort.random,
          onSelected: (value) => unawaited(
            widget.controller.applyFilter(
              _sortFilter(filter, value ? SongSort.random : SongSort.title),
            ),
          ),
        ),
      ],
    ),
  );

  SongFilter _sortFilter(SongFilter filter, SongSort sort) => filter.withSort(
    sort,
    randomSeed: sort == SongSort.random
        ? DateTime.now().microsecondsSinceEpoch
        : null,
  );

  List<Widget> _resultSlivers(SongsViewState state, AppLocalizations l) {
    if (state.initialLoading) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: state.filter.sort == SongSort.random
              ? _RandomLoading(
                  label: l.shufflingSongs,
                  cancelLabel: l.cancel,
                  onCancel: widget.controller.cancelLoading,
                )
              : const Center(child: CircularProgressIndicator.adaptive()),
        ),
      ];
    }
    if (state.error != null && state.songs.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _MessageState(
            icon: Icons.cloud_off_rounded,
            title: l.couldNotLoadLibrary('${state.error}'),
            actionLabel: l.tryAgain,
            onAction: widget.controller.refresh,
          ),
        ),
      ];
    }
    if (state.songs.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _MessageState(
            icon: Icons.filter_alt_off_rounded,
            title: state.filter.isActive
                ? l.noFilteredSongs
                : l.nothingToShowYet,
            subtitle: state.filter.isActive ? l.noFilteredSongsHint : null,
            actionLabel: state.filter.isActive ? l.clearFilters : null,
            onAction: state.filter.isActive ? _clearFilters : null,
          ),
        ),
      ];
    }

    return [
      SliverList.builder(
        itemCount: state.songs.length,
        itemBuilder: (context, index) {
          final song = state.songs[index];
          final openMenu = widget.onSongMenu == null
              ? null
              : () => widget.onSongMenu!(song);
          return RepaintBoundary(
            child: NaviSongSwipeActions(
              dismissibleKey: ValueKey('songs-swipe-${song.id}'),
              quickAction: widget.quickSwipeActionBuilder?.call(context, song),
              onMore: openMenu,
              child: NaviSongRow(
                song: song,
                artwork: widget.artworkBuilder?.call(context, song),
                nowPlayingListenable: widget.nowPlaying,
                playingListenable: widget.playing,
                starred: song.starred,
                subtitle: [
                  primaryArtistName(song.artist),
                  song.album,
                ].where((value) => value.isNotEmpty).join(' · '),
                caption: _QualityLine(song: song, l: l),
                trailingText: formatDuration(song.duration),
                onTap: widget.onSongTap == null
                    ? null
                    : () => widget.onSongTap!(song),
                onMenu: openMenu,
              ),
            ),
          );
        },
      ),
      SliverToBoxAdapter(
        child: _LoadingTail(
          loading: state.loadingMore,
          error: state.error,
          errorLabel: l.loadingMoreFailed,
          retryLabel: l.tryAgain,
          onRetry: widget.controller.loadMore,
        ),
      ),
    ];
  }

  Future<void> _openFilters(SongFilter current) async {
    final result = await showSongFilterSheet(
      context,
      initial: current,
      lockFavorites: widget.lockFavorites,
    );
    if (result == null || !mounted) return;
    final effective = widget.lockFavorites
        ? result.withFavoritesOnly(true)
        : result;
    _searchController.text = effective.query;
    await widget.controller.applyFilter(effective);
  }

  void _clearFilters() {
    _searchController.clear();
    unawaited(
      widget.controller.applyFilter(
        SongFilter(favoritesOnly: widget.lockFavorites),
      ),
    );
  }

  Future<void> _saveFilter() async {
    final l = AppLocalizations.of(context);
    final text = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.saveFilter),
        content: TextField(
          controller: text,
          autofocus: true,
          decoration: InputDecoration(labelText: l.filterName),
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(dialogContext).pop,
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(text.text.trim()),
            child: Text(l.save),
          ),
        ],
      ),
    );
    text.dispose();
    if (name == null || name.isEmpty) return;
    await widget.controller.saveCurrentFilter(name);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l.filterSaved(name))));
  }
}

class _RandomLoading extends StatelessWidget {
  const _RandomLoading({
    required this.label,
    required this.cancelLabel,
    required this.onCancel,
  });

  final String label;
  final String cancelLabel;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      padding: const EdgeInsets.fromLTRB(
        NaviSpacing.md,
        NaviSpacing.sm,
        NaviSpacing.xs,
        NaviSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: NaviColors.surface,
        borderRadius: BorderRadius.circular(NaviRadii.card),
        border: Border.all(color: NaviColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const NaviInlineProgress(),
          const SizedBox(width: NaviSpacing.sm),
          Text(label),
          TextButton(onPressed: onCancel, child: Text(cancelLabel)),
        ],
      ),
    ),
  );
}

class _QualityLine extends StatelessWidget {
  const _QualityLine({required this.song, required this.l});

  final Song song;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final suffix = song.suffix.toUpperCase();
    final lossless = const {
      'FLAC',
      'ALAC',
      'WAV',
      'WAVE',
      'AIF',
      'AIFF',
      'APE',
    }.contains(suffix);
    final hiRes = lossless && (song.bitDepth > 16 || song.samplingRate > 48000);
    final quality = hiRes
        ? l.qualityHiRes
        : lossless
        ? l.qualityLossless
        : suffix;
    final detail = hiRes && song.bitDepth > 0 && song.samplingRate > 0
        ? '${song.bitDepth}-bit · ${(song.samplingRate / 1000).toStringAsFixed(song.samplingRate % 1000 == 0 ? 0 : 1)} kHz'
        : song.bitRate > 0
        ? '${song.bitRate} kbps'
        : '';
    return Text(
      [quality, detail].where((value) => value.isNotEmpty).join(' · '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: hiRes ? NaviColors.accent : NaviColors.textTertiary,
        fontSize: 10,
      ),
    );
  }
}

class _LoadingTail extends StatelessWidget {
  const _LoadingTail({
    required this.loading,
    required this.error,
    required this.errorLabel,
    required this.retryLabel,
    required this.onRetry,
  });

  final bool loading;
  final Object? error;
  final String errorLabel;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(NaviSpacing.lg),
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.all(NaviSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(child: Text(errorLabel)),
            TextButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ),
      );
    }
    return const SizedBox(height: NaviSpacing.lg);
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
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
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(NaviSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 38, color: NaviColors.textTertiary),
          const SizedBox(height: NaviSpacing.md),
          Text(title, textAlign: TextAlign.center),
          if (subtitle case final value?) ...[
            const SizedBox(height: NaviSpacing.xs),
            Text(
              value,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (actionLabel case final value?) ...[
            const SizedBox(height: NaviSpacing.md),
            FilledButton(onPressed: onAction, child: Text(value)),
          ],
        ],
      ),
    ),
  );
}

class _SongFilterSheet extends StatefulWidget {
  const _SongFilterSheet({required this.initial, this.lockFavorites = false});

  final SongFilter initial;
  final bool lockFavorites;

  @override
  State<_SongFilterSheet> createState() => _SongFilterSheetState();
}

class _SongFilterSheetState extends State<_SongFilterSheet> {
  late SongQuality quality = widget.initial.quality;
  late Set<String> formats = Set.of(widget.initial.formats);
  late bool favoritesOnly =
      widget.lockFavorites || widget.initial.favoritesOnly;
  late SongSort sort = widget.initial.sort;
  late final TextEditingController genres = TextEditingController(
    text: widget.initial.genres.join(', '),
  );
  late final TextEditingController minimumYear = _numberController(
    widget.initial.minimumYear,
  );
  late final TextEditingController maximumYear = _numberController(
    widget.initial.maximumYear,
  );
  late final TextEditingController minimumDuration = _numberController(
    widget.initial.minimumDuration?.inMinutes,
  );
  late final TextEditingController maximumDuration = _numberController(
    widget.initial.maximumDuration?.inMinutes,
  );
  late final TextEditingController minimumBitRate = _numberController(
    widget.initial.minimumBitRate,
  );
  late final TextEditingController maximumBitRate = _numberController(
    widget.initial.maximumBitRate,
  );

  @override
  void dispose() {
    for (final controller in [
      genres,
      minimumYear,
      maximumYear,
      minimumDuration,
      maximumDuration,
      minimumBitRate,
      maximumBitRate,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      snap: true,
      snapSizes: const [0.5, 0.9],
      builder: (context, scrollController) => NaviModalSurface(
        child: Column(
          children: [
            const NaviModalHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                NaviSpacing.xs,
                NaviSpacing.xs,
                NaviSpacing.md,
                NaviSpacing.xs,
              ),
              child: Row(
                children: [
                  IconButton(
                    tooltip: l.close,
                    onPressed: Navigator.of(context).pop,
                    icon: const Icon(Icons.close_rounded),
                  ),
                  Expanded(
                    child: Text(
                      l.filters,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  TextButton(onPressed: _reset, child: Text(l.resetFilters)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  NaviSpacing.page,
                  NaviSpacing.xs,
                  NaviSpacing.page,
                  NaviSpacing.xl,
                ),
                children: [
                  _label(l.filterQuality),
                  Wrap(
                    spacing: NaviSpacing.xs,
                    children: [
                      for (final value in SongQuality.values)
                        ChoiceChip(
                          label: Text(_qualityName(l, value)),
                          selected: quality == value,
                          onSelected: (_) => setState(() => quality = value),
                        ),
                    ],
                  ),
                  _label(l.filterFormat),
                  Wrap(
                    spacing: NaviSpacing.xs,
                    children: [
                      for (final value in const [
                        'mp3',
                        'm4a',
                        'flac',
                        'alac',
                        'wav',
                      ])
                        FilterChip(
                          label: Text(value.toUpperCase()),
                          selected: formats.contains(value),
                          onSelected: (selected) => setState(
                            () => selected
                                ? formats.add(value)
                                : formats.remove(value),
                          ),
                        ),
                    ],
                  ),
                  _label(l.filterGenre),
                  TextField(
                    controller: genres,
                    decoration: InputDecoration(hintText: l.filterGenreHint),
                  ),
                  const SizedBox(height: NaviSpacing.xs),
                  Wrap(
                    spacing: NaviSpacing.xs,
                    runSpacing: NaviSpacing.xxs,
                    children: [
                      for (final value in const [
                        'Pop',
                        'Rock',
                        'Hip-Hop',
                        'Electronic',
                        'R&B',
                        'Jazz',
                        'Metal',
                      ])
                        FilterChip(
                          label: Text(value),
                          selected: _genreValues.contains(value.toLowerCase()),
                          onSelected: (selected) =>
                              _toggleGenre(value, selected),
                        ),
                    ],
                  ),
                  _label(l.filterYear),
                  _range(l, minimumYear, maximumYear),
                  _label(l.filterDurationMinutes),
                  _range(l, minimumDuration, maximumDuration),
                  _label(l.filterBitRateKbps),
                  _range(l, minimumBitRate, maximumBitRate),
                  const SizedBox(height: NaviSpacing.md),
                  if (!widget.lockFavorites)
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l.filterFavorites),
                      value: favoritesOnly,
                      onChanged: (value) =>
                          setState(() => favoritesOnly = value),
                    ),
                  _label(l.sortBy),
                  Wrap(
                    spacing: NaviSpacing.xs,
                    runSpacing: NaviSpacing.xxs,
                    children: [
                      for (final value in SongSort.values)
                        ChoiceChip(
                          label: Text(songSortLabel(l, value)),
                          selected: sort == value,
                          onSelected: (_) => setState(() => sort = value),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                NaviSpacing.page,
                NaviSpacing.sm,
                NaviSpacing.page,
                NaviSpacing.page,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: Navigator.of(context).pop,
                      child: Text(l.cancel),
                    ),
                  ),
                  const SizedBox(width: NaviSpacing.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: _apply,
                      child: Text(l.applyFilters),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Set<String> get _genreValues => genres.text
      .split(',')
      .map((value) => value.trim().toLowerCase())
      .where((value) => value.isNotEmpty)
      .toSet();

  void _toggleGenre(String value, bool selected) {
    final values = _genreValues;
    selected
        ? values.add(value.toLowerCase())
        : values.remove(value.toLowerCase());
    genres.text = values.join(', ');
    setState(() {});
  }

  Widget _label(String value) => Padding(
    padding: const EdgeInsets.only(top: NaviSpacing.lg, bottom: NaviSpacing.xs),
    child: Text(value, style: Theme.of(context).textTheme.titleMedium),
  );

  Widget _range(
    AppLocalizations l,
    TextEditingController minimum,
    TextEditingController maximum,
  ) => Row(
    children: [
      Expanded(child: _numberField(minimum, l.filterMinimum)),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: NaviSpacing.sm),
        child: Text('–'),
      ),
      Expanded(child: _numberField(maximum, l.filterMaximum)),
    ],
  );

  Widget _numberField(TextEditingController controller, String label) =>
      TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
      );

  void _reset() => setState(() {
    quality = SongQuality.any;
    formats.clear();
    favoritesOnly = widget.lockFavorites;
    sort = widget.lockFavorites ? SongSort.newest : SongSort.title;
    for (final controller in [
      genres,
      minimumYear,
      maximumYear,
      minimumDuration,
      maximumDuration,
      minimumBitRate,
      maximumBitRate,
    ]) {
      controller.clear();
    }
  });

  void _apply() => Navigator.of(context).pop(
    SongFilter(
      query: widget.initial.query,
      genres: genres.text.split(',').toSet(),
      formats: formats,
      quality: quality,
      minimumYear: _integer(minimumYear),
      maximumYear: _integer(maximumYear),
      minimumDuration: _minutes(minimumDuration),
      maximumDuration: _minutes(maximumDuration),
      minimumBitRate: _integer(minimumBitRate),
      maximumBitRate: _integer(maximumBitRate),
      favoritesOnly: favoritesOnly,
      sort: sort,
      randomSeed: sort == SongSort.random
          ? widget.initial.sort == SongSort.random
                ? widget.initial.randomSeed
                : DateTime.now().microsecondsSinceEpoch
          : 0,
    ).normalized(),
  );
}

TextEditingController _numberController(int? value) =>
    TextEditingController(text: value == null ? '' : '$value');

int? _integer(TextEditingController controller) {
  final value = int.tryParse(controller.text.trim());
  return value != null && value >= 0 ? value : null;
}

Duration? _minutes(TextEditingController controller) {
  final value = _integer(controller);
  return value == null ? null : Duration(minutes: value);
}

String _qualityName(AppLocalizations l, SongQuality quality) =>
    switch (quality) {
      SongQuality.any => l.qualityAny,
      SongQuality.lossy => l.qualityLossy,
      SongQuality.lossless => l.qualityLossless,
      SongQuality.hiRes => l.qualityHiRes,
    };
