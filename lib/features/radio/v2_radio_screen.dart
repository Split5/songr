import 'dart:async';

import 'package:flutter/material.dart';

import '../../design_system/navi_design_tokens.dart';
import '../../design_system/navi_theme.dart';
import '../../design_system/widgets/navi_glass.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../library/v2_library_screens.dart';
import 'radio_controller.dart';

class V2RadioScreen extends StatefulWidget {
  const V2RadioScreen({
    super.key,
    required this.controller,
    required this.onStationTap,
    required this.onSongsReady,
    this.artworkBuilder,
    this.onRefresh,
  });
  /// Pull must reach the server; the runtime decides how cheap that is.
  final Future<void> Function()? onRefresh;

  final RadioController controller;
  final Future<void> Function(InternetRadioStation) onStationTap;
  final ValueChanged<List<Song>> onSongsReady;
  final CatalogArtworkBuilder? artworkBuilder;

  @override
  State<V2RadioScreen> createState() => _V2RadioScreenState();
}

class _V2RadioScreenState extends State<V2RadioScreen> {
  String? _starting;

  @override
  void initState() {
    super.initState();
    unawaited(widget.controller.initialize());
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final state = widget.controller.state;
      final l = AppLocalizations.of(context);
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
                NaviSliverHeader(title: Text(l.navRadio)),
                if (state.loading && !state.hasContent)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(NaviSpacing.page),
                      child: _RadioSkeleton(),
                    ),
                  )
                else if (!state.hasContent)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _RadioEmpty(
                      message: l.radioEmptyHint,
                      onRetry: widget.controller.refresh,
                    ),
                  )
                else ...[
                  if (state.stations.isNotEmpty) ...[
                    _header(l.radioStations),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 96,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: NaviSpacing.page,
                          ),
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: state.stations.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: NaviSpacing.sm),
                          itemBuilder: (context, index) {
                            final station = state.stations[index];
                            return _StationCard(
                              station: station,
                              onTap: () => unawaited(_playStation(station)),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                  if (state.genres.isNotEmpty) ...[
                    _header(l.genreRadio),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        NaviSpacing.page,
                        NaviSpacing.xs,
                        NaviSpacing.page,
                        NaviSpacing.lg,
                      ),
                      sliver: SliverGrid.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: NaviSpacing.sm,
                              crossAxisSpacing: NaviSpacing.sm,
                              childAspectRatio: 2.15,
                            ),
                        itemCount: state.genres.length,
                        itemBuilder: (context, index) {
                          final genre = state.genres[index];
                          return _RadioCard(
                            title: genre,
                            busy: _starting == 'genre:$genre',
                            onTap: () => _start(
                              'genre:$genre',
                              () => widget.controller.genreRadio(genre),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  if (state.artists.isNotEmpty) ...[
                    _header(l.artistRadio),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 148,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: NaviSpacing.page,
                          ),
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: state.artists.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: NaviSpacing.sm),
                          itemBuilder: (context, index) {
                            final artist = state.artists[index];
                            return _ArtistRadioCard(
                              artist: artist,
                              artworkBuilder: widget.artworkBuilder,
                              busy: _starting == 'artist:${artist.id}',
                              onTap: () => _start(
                                'artist:${artist.id}',
                                () => widget.controller.artistRadio(artist),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
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

  Future<void> _playStation(InternetRadioStation station) async {
    try {
      await widget.onStationTap(station);
    } on FormatException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).invalidRadioStream),
        ),
      );
    }
  }

  SliverToBoxAdapter _header(String title) => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(
        NaviSpacing.page,
        NaviSpacing.md,
        NaviSpacing.page,
        NaviSpacing.xs,
      ),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    ),
  );

  Future<void> _start(String key, Future<List<Song>> Function() load) async {
    if (_starting != null) return;
    setState(() => _starting = key);
    try {
      final songs = await load();
      if (songs.isNotEmpty) widget.onSongsReady(songs);
    } finally {
      if (mounted) setState(() => _starting = null);
    }
  }
}

class _RadioCard extends StatelessWidget {
  const _RadioCard({
    required this.title,
    required this.busy,
    required this.onTap,
  });

  final String title;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => NaviPressable(
    clip: true,
    onTap: onTap,
    child: Ink(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(NaviRadii.card),
        color: NaviColors.surface,
        border: Border.all(color: NaviColors.border),
      ),
      padding: const EdgeInsets.all(NaviSpacing.md),
      child: Stack(
        children: [
          Positioned.fill(child: NaviAbstractArtwork(seed: title)),
          Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: busy
                ? const SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator.adaptive(),
                  )
                : const Icon(Icons.play_circle_fill_rounded, size: 22),
          ),
        ],
      ),
    ),
  );
}

class _StationCard extends StatelessWidget {
  const _StationCard({required this.station, required this.onTap});

  final InternetRadioStation station;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      child: NaviPressable(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(NaviRadii.card),
            color: NaviColors.surface,
            border: Border.all(color: NaviColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(NaviSpacing.md),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(color: NaviColors.surfaceRaised),
                    child: NaviAbstractArtwork(seed: station.id),
                  ),
                ),
                const SizedBox(width: NaviSpacing.sm),
                Expanded(
                  child: Text(
                    station.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const Icon(Icons.play_circle_fill_rounded, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ArtistRadioCard extends StatelessWidget {
  const _ArtistRadioCard({
    required this.artist,
    required this.busy,
    required this.onTap,
    this.artworkBuilder,
  });

  final ArtistSummary artist;
  final bool busy;
  final VoidCallback onTap;
  final CatalogArtworkBuilder? artworkBuilder;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 104,
    child: NaviPressable(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(NaviRadii.artwork),
                child: SizedBox.square(
                  dimension: 104,
                  child:
                      artworkBuilder?.call(
                        context,
                        artist.coverArt,
                        Icons.person_rounded,
                      ) ??
                      const ColoredBox(
                        color: NaviColors.surfaceRaised,
                        child: Icon(Icons.person_rounded, size: 28),
                      ),
                ),
              ),
              Positioned(
                right: NaviSpacing.xs,
                bottom: NaviSpacing.xs,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: NaviColors.textPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: busy
                      ? const Padding(
                          padding: EdgeInsets.all(7),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: NaviColors.canvas,
                          ),
                        )
                      : const Icon(
                          Icons.play_arrow_rounded,
                          color: NaviColors.canvas,
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: NaviSpacing.xs),
          Text(artist.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    ),
  );
}

class _RadioSkeleton extends StatelessWidget {
  const _RadioSkeleton();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        height: 96,
        decoration: BoxDecoration(
          color: NaviColors.surfaceRaised,
          borderRadius: BorderRadius.circular(NaviRadii.card),
        ),
      ),
      const SizedBox(height: NaviSpacing.md),
      Row(
        children: [
          for (var index = 0; index < 2; index++)
            Expanded(
              child: Container(
                height: 82,
                margin: EdgeInsets.only(right: index == 0 ? NaviSpacing.sm : 0),
                decoration: BoxDecoration(
                  color: NaviColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(NaviRadii.card),
                ),
              ),
            ),
        ],
      ),
    ],
  );
}

class _RadioEmpty extends StatelessWidget {
  const _RadioEmpty({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(NaviSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.radio_rounded, size: 48),
          const SizedBox(height: NaviSpacing.md),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: NaviSpacing.md),
          FilledButton.tonal(
            style: NaviTheme.tonalButtonStyle,
            onPressed: onRetry,
            child: Text(AppLocalizations.of(context).tryAgain),
          ),
        ],
      ),
    ),
  );
}
