import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../design_system/navi_design_tokens.dart';
import '../../design_system/widgets/navi_widgets.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../library/v2_library_screens.dart';
import 'new_music_controller.dart';

class V2NewMusicScreen extends StatefulWidget {
  const V2NewMusicScreen({
    super.key,
    required this.controller,
    required this.onAlbumTap,
    required this.onSongTap,
    this.onSongMenu,
    this.artworkBuilder,
    this.nowPlaying,
    this.playing,
    this.onRefresh,
  });
  /// Pull must reach the server; the runtime decides how cheap that is.
  final Future<void> Function()? onRefresh;

  final NewMusicController controller;
  final ValueChanged<Album> onAlbumTap;
  final ValueChanged<Song> onSongTap;
  final ValueChanged<Song>? onSongMenu;
  final CatalogArtworkBuilder? artworkBuilder;

  /// Id of the song at the playhead; rows mark themselves when it matches.
  final ValueListenable<String?>? nowPlaying;
  final ValueListenable<bool>? playing;

  @override
  State<V2NewMusicScreen> createState() => _V2NewMusicScreenState();
}

class _V2NewMusicScreenState extends State<V2NewMusicScreen> {
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
          primary: NaviColors.atmosphereWine,
          secondary: NaviColors.atmospherePlum,
          child: RefreshIndicator.adaptive(
            onRefresh: widget.onRefresh ?? widget.controller.refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                NaviSliverHeader(title: Text(l.navNew)),
                if (state.loading && state.albums.isEmpty)
                  ..._loadingSlivers()
                else if (state.error != null && state.albums.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Text(l.couldNotLoadLibrary('${state.error}')),
                    ),
                  )
                else ...[
                  _header(l.sectionRecentlyAdded),
                  if (state.albums.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(NaviSpacing.page),
                        child: Text(l.nothingToShowYet),
                      ),
                    )
                  else
                    SliverList.builder(
                      itemCount: state.albums.length,
                      itemBuilder: (context, index) {
                        final album = state.albums[index];
                        final previous = index == 0
                            ? null
                            : state.albums[index - 1];
                        final showDate = !_sameDay(
                          album.created,
                          previous?.created,
                        );
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showDate)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  NaviSpacing.page,
                                  NaviSpacing.md,
                                  NaviSpacing.page,
                                  NaviSpacing.xs,
                                ),
                                child: Text(
                                  _dateLabel(context, album.created),
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                              ),
                            _NewAlbumRow(
                              album: album,
                              artworkBuilder: widget.artworkBuilder,
                              onTap: () => widget.onAlbumTap(album),
                            ),
                          ],
                        );
                      },
                    ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: NaviSpacing.xl),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );

  SliverToBoxAdapter _header(String title) => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(
        NaviSpacing.page,
        NaviSpacing.md,
        NaviSpacing.page,
        NaviSpacing.sm,
      ),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    ),
  );

  bool _sameDay(DateTime? a, DateTime? b) =>
      a != null &&
      b != null &&
      a.year == b.year &&
      a.month == b.month &&
      a.day == b.day;

  String _dateLabel(BuildContext context, DateTime? date) => date == null
      ? AppLocalizations.of(context).sectionRecentlyAdded
      : MaterialLocalizations.of(context).formatMediumDate(date.toLocal());

  List<Widget> _loadingSlivers() => const [
    SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(NaviSpacing.page),
        child: _NewSkeleton(height: 210),
      ),
    ),
    SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: NaviSpacing.page),
        child: _NewSkeleton(width: 138, height: 22),
      ),
    ),
  ];
}

class _NewAlbumRow extends StatelessWidget {
  const _NewAlbumRow({
    required this.album,
    required this.onTap,
    this.artworkBuilder,
  });

  final Album album;
  final VoidCallback onTap;
  final CatalogArtworkBuilder? artworkBuilder;

  @override
  Widget build(BuildContext context) => NaviPressable(
    onTap: onTap,
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 68),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          NaviSpacing.page,
          NaviSpacing.xs,
          NaviSpacing.xs,
          NaviSpacing.xs,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(NaviRadii.row),
              child: SizedBox.square(
                dimension: 56,
                child:
                    artworkBuilder?.call(
                      context,
                      album.coverArt,
                      Icons.album_rounded,
                    ) ??
                    const ColoredBox(
                      color: NaviColors.surfaceRaised,
                      child: Icon(Icons.album_rounded, size: 24),
                    ),
              ),
            ),
            const SizedBox(width: NaviSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      album.artist,
                      AppLocalizations.of(context).songsCount(album.songCount),
                    ].where((value) => value.isNotEmpty).join(' · '),
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
              color: NaviColors.textTertiary,
            ),
          ],
        ),
      ),
    ),
  );
}

class _NewSkeleton extends StatelessWidget {
  const _NewSkeleton({this.width = double.infinity, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: NaviColors.surfaceRaised.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(NaviRadii.glass),
    ),
  );
}
