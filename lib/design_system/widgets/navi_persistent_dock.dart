import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../navi_design_tokens.dart';
import 'navi_glass.dart';

class NaviDockDestination {
  const NaviDockDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.accentColor,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;

  /// Kept for API compatibility. Navigation never consumes the playback hue:
  /// the selected item is distinguished by icon fill and brighter text.
  final Color? accentColor;
}

class NaviMiniPlayerData {
  const NaviMiniPlayerData({
    required this.title,
    required this.subtitle,
    required this.artwork,
    required this.progress,
    required this.isPlaying,
    this.starting = false,
    this.tintSource,
    required this.playLabel,
    required this.pauseLabel,
    required this.skipNextLabel,
    this.positionListenable,
    this.duration = Duration.zero,
  });

  final String title;
  final String subtitle;
  final Widget artwork;
  final double progress;
  final bool isPlaying;

  /// The tapped song is still being prepared; the play control shows a small
  /// progress ring instead of the play glyph so the tap feels acknowledged.
  final bool starting;

  /// Cover image the bar's colour is sampled from; null keeps the plain
  /// surface.
  final ImageProvider? tintSource;
  final String playLabel;
  final String pauseLabel;
  final String skipNextLabel;
  final ValueListenable<Duration>? positionListenable;
  final Duration duration;
}

/// One persistent dock shared by every feature navigator. It belongs to the
/// app frame: a flat surface separated from content by one rule.
class NaviPersistentDock extends StatelessWidget {
  const NaviPersistentDock({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.nowPlaying,
    this.onOpenPlayer,
    this.onTogglePlayback,
    this.onSkipPrevious,
    this.onSkipNext,
  }) : assert(destinations.length == 5);

  final List<NaviDockDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final NaviMiniPlayerData? nowPlaying;
  final VoidCallback? onOpenPlayer;
  final VoidCallback? onTogglePlayback;
  final VoidCallback? onSkipPrevious;
  final VoidCallback? onSkipNext;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('navi-persistent-dock'),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (nowPlaying != null)
            _CoverColor(
              provider: nowPlaying!.tintSource,
              builder: (context, tint) => ColoredBox(
                key: const ValueKey('navi-dock-player-surface'),
                color: NaviColors.surface,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: AnimatedSize(
                    duration: NaviMotion.standard,
                    curve: NaviMotion.curve,
                    child: _MiniPlayer(
                      key: ValueKey(nowPlaying!.title),
                      data: nowPlaying!,
                      tint: tint,
                      onOpen: onOpenPlayer,
                      onTogglePlayback: onTogglePlayback,
                      onSkipPrevious: onSkipPrevious,
                      onSkipNext: onSkipNext,
                    ),
                  ),
                ),
              ),
            ),
          DecoratedBox(
            key: const ValueKey('navi-dock-navigation-surface'),
            decoration: const BoxDecoration(color: NaviColors.surfaceRaised),
            child: Padding(
              key: const ValueKey('navi-dock-content-padding'),
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 18),
              child: Row(
                children: [
                  for (var index = 0; index < destinations.length; index++)
                    Expanded(
                      child: _DestinationButton(
                        destination: destinations[index],
                        selected: selectedIndex == index,
                        onTap: () => onDestinationSelected(index),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Samples the cover's average colour for the player bar's progress line.
///
/// A 2px line can carry the colour at full strength; a surface could not, and
/// the text has to stay readable.
class _CoverColor extends StatefulWidget {
  const _CoverColor({required this.provider, required this.builder});

  final ImageProvider? provider;
  final Widget Function(BuildContext context, Color? tint) builder;

  @override
  State<_CoverColor> createState() => _CoverColorState();
}

class _CoverColorState extends State<_CoverColor> {
  Color? _tint;
  ImageStream? _stream;
  ImageStreamListener? _listener;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(_CoverColor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.provider != widget.provider) _resolve();
  }

  @override
  void dispose() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }
    super.dispose();
  }

  void _resolve() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
      _stream = null;
      _listener = null;
    }
    final provider = widget.provider;
    if (provider == null) {
      if (_tint != null) setState(() => _tint = null);
      return;
    }
    final stream = provider.resolve(createLocalImageConfiguration(context));
    late final ImageStreamListener listener;
    listener = ImageStreamListener((info, _) async {
      stream.removeListener(listener);
      final tint = await _averageColor(info.image);
      if (mounted) setState(() => _tint = tint);
    }, onError: (_, _) => stream.removeListener(listener));
    stream.addListener(listener);
    _stream = stream;
    _listener = listener;
  }

  /// Samples the image down to one pixel, which is its average colour.
  Future<Color?> _averageColor(ui.Image image) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      const Rect.fromLTWH(0, 0, 1, 1),
      Paint()..filterQuality = FilterQuality.medium,
    );
    final tiny = await recorder.endRecording().toImage(1, 1);
    final data = await tiny.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (data == null) return null;
    return Color.fromARGB(
      data.getUint8(3),
      data.getUint8(0),
      data.getUint8(1),
      data.getUint8(2),
    );
  }

  /// Keeps the cover's hue but lifts a near-black cover enough to be seen on
  /// the dark bar.
  Color _barColor(Color tint) {
    final hsl = HSLColor.fromColor(tint);
    return hsl
        .withLightness(hsl.lightness < 0.55 ? 0.55 : hsl.lightness)
        .toColor();
  }

  @override
  Widget build(BuildContext context) {
    final tint = _tint;
    return widget.builder(context, tint == null ? null : _barColor(tint));
  }
}

class _MiniPlayer extends StatelessWidget {
  const _MiniPlayer({
    super.key,
    required this.data,
    this.tint,
    required this.onOpen,
    required this.onTogglePlayback,
    required this.onSkipPrevious,
    required this.onSkipNext,
  });

  final NaviMiniPlayerData data;
  final Color? tint;
  final VoidCallback? onOpen;
  final VoidCallback? onTogglePlayback;
  final VoidCallback? onSkipPrevious;
  final VoidCallback? onSkipNext;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: '${data.title}, ${data.subtitle}',
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 58,
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragEnd: (details) {
                    if (details.primaryVelocity case final velocity?
                        when velocity < -260) {
                      onOpen?.call();
                    }
                  },
                  onHorizontalDragEnd: (details) {
                    final velocity = details.primaryVelocity ?? 0;
                    if (velocity < -320) {
                      onSkipNext?.call();
                    } else if (velocity > 320) {
                      onSkipPrevious?.call();
                    }
                  },
                  child: NaviPressable(
                    borderRadius: BorderRadius.circular(NaviRadii.glass - 4),
                    pressedScale: 0.985,
                    onTap: onOpen,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox.square(
                            dimension: 48,
                            child: data.artwork,
                          ),
                        ),
                        const SizedBox(width: NaviSpacing.sm),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                data.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (data.starting)
                // Same 48pt slot as the button, so nothing shifts while the
                // song loads.
                SizedBox.square(
                  dimension: 48,
                  child: Center(
                    child: SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        semanticsLabel: data.playLabel,
                      ),
                    ),
                  ),
                )
              else
                IconButton(
                  onPressed: onTogglePlayback,
                  tooltip: data.isPlaying ? data.pauseLabel : data.playLabel,
                  icon: Icon(
                    data.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                  ),
                ),
              IconButton(
                onPressed: onSkipNext,
                tooltip: data.skipNextLabel,
                icon: const Icon(Icons.skip_next_rounded),
              ),
            ],
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: data.positionListenable == null
              ? _MiniProgress(value: data.progress, color: tint)
              : ValueListenableBuilder<Duration>(
                  valueListenable: data.positionListenable!,
                  builder: (context, position, _) {
                    final total = data.duration.inMilliseconds;
                    return _MiniProgress(
                      value: total <= 0 ? 0 : position.inMilliseconds / total,
                      color: tint,
                    );
                  },
                ),
        ),
        const SizedBox(height: 4),
      ],
    ),
  );
}

class _MiniProgress extends StatelessWidget {
  const _MiniProgress({required this.value, this.color});

  final double value;
  final Color? color;

  @override
  Widget build(BuildContext context) => LinearProgressIndicator(
    value: value.clamp(0, 1),
    minHeight: 2,
    color: color ?? NaviColors.textTertiary,
    backgroundColor: Colors.white.withValues(alpha: 0.08),
  );
}

class _DestinationButton extends StatelessWidget {
  const _DestinationButton({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final NaviDockDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? NaviColors.textPrimary : NaviColors.textTertiary;
    return Semantics(
      selected: selected,
      button: true,
      label: destination.label,
      child: NaviPressable(
        borderRadius: BorderRadius.circular(18),
        pressedScale: 0.985,
        onTap: onTap,
        child: AnimatedContainer(
          duration: NaviMotion.standard,
          curve: NaviMotion.curve,
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: NaviMotion.micro,
                child: Icon(
                  selected ? destination.selectedIcon : destination.icon,
                  key: ValueKey(selected),
                  size: 23,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.fade,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: color, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
