import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design_system/navi_design_tokens.dart';
import '../../design_system/widgets/navi_artwork.dart';
import '../../design_system/widgets/navi_glass.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import 'v2_playback_controller.dart';
import 'v2_player_sheets.dart';
import 'v2_queue_sheet.dart';

export 'v2_player_sheets.dart'
    show LyricsLoader, QueueTuneAction, QueueTuneCallback;

typedef PlayerArtworkBuilder = Widget Function(BuildContext context, Song song);
typedef SongMenuCallback = void Function(BuildContext context, Song song);

/// Now Playing: grabber, lifted artwork, title row with heart and menu,
/// scrubber, transport and one labelled glass row (lyrics, queue, sleep
/// timer, tune). Every secondary action lives in that row exactly once.
class V2FullPlayer extends StatelessWidget {
  const V2FullPlayer({
    super.key,
    required this.controller,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onSongMenu,
    this.artworkBuilder,
    this.lyricsLoader,
    this.lyricsOffset,
    this.onLyricsOffsetChanged,
    this.onAlbumTap,
    this.onArtistTap,
    this.onTuneQueue,
  });

  final V2PlaybackController controller;
  final bool Function(Song song) isFavorite;
  final Future<void> Function(Song song) onToggleFavorite;
  final SongMenuCallback onSongMenu;
  final PlayerArtworkBuilder? artworkBuilder;
  final LyricsLoader? lyricsLoader;

  /// Reads the manual lyric offset (positive moves the lyrics later) when the
  /// lyrics sheet opens, so a value changed in the sheet is never stale.
  final Duration Function()? lyricsOffset;
  final ValueChanged<Duration>? onLyricsOffsetChanged;
  final ValueChanged<Song>? onAlbumTap;
  final ValueChanged<Song>? onArtistTap;
  final QueueTuneCallback? onTuneQueue;

  static const playPauseKey = ValueKey('player-play-pause');
  static const favoriteKey = ValueKey('player-favorite');
  static const menuKey = ValueKey('player-menu');
  static const artworkKey = ValueKey('player-artwork');
  static const lyricsActionKey = ValueKey('player-action-lyrics');
  static const queueActionKey = ValueKey('player-action-queue');
  static const sleepActionKey = ValueKey('player-action-sleep');
  static const tuneActionKey = ValueKey('player-action-tune');

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final song = controller.currentSong;
      final station = controller.currentStation;
      final l = AppLocalizations.of(context);
      if (song == null && station == null) {
        return Scaffold(
          backgroundColor: NaviColors.canvas,
          body: SafeArea(
            child: Column(
              children: [
                _Grabber(onTap: () => Navigator.of(context).maybePop()),
                Expanded(child: Center(child: Text(l.noSongPlaying))),
              ],
            ),
          ),
        );
      }
      return Scaffold(
        backgroundColor: NaviColors.canvas,
        body: NaviArtworkAtmosphere(
          primary: NaviColors.atmosphereWine,
          secondary: NaviColors.atmospherePlum,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onVerticalDragEnd: (details) {
              if ((details.primaryVelocity ?? 0) > 520) {
                Navigator.of(context).maybePop();
              }
            },
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final artworkSize = math.min(
                    constraints.maxWidth - 2 * NaviSpacing.page,
                    constraints.maxHeight * 0.42,
                  );
                  return Column(
                    children: [
                      _Grabber(onTap: () => Navigator.of(context).maybePop()),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: NaviSpacing.page,
                        ),
                        child: Column(
                          children: [
                            _artwork(context, song, station, artworkSize),
                            const SizedBox(height: NaviSpacing.xl),
                            _titleRow(context, l, song, station),
                            const SizedBox(height: NaviSpacing.md),
                            if (song != null)
                              _Scrubber(controller: controller, song: song)
                            else
                              const SizedBox(height: NaviSpacing.xl),
                            const SizedBox(height: NaviSpacing.md),
                            _transport(context, l, song),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (song != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            NaviSpacing.page,
                            0,
                            NaviSpacing.page,
                            NaviSpacing.md,
                          ),
                          child: _actionRow(context, l, song),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
    },
  );

  Widget _artwork(
    BuildContext context,
    Song? song,
    InternetRadioStation? station,
    double size,
  ) {
    if (song == null) return _StationArtwork(station: station!, size: size);
    return ValueListenableBuilder<bool>(
      valueListenable: controller.playingListenable,
      builder: (context, playing, child) => NaviLift(
        elevated: playing,
        restingScale: 1,
        borderRadius: BorderRadius.circular(NaviRadii.artwork),
        child: child!,
      ),
      child: AnimatedSwitcher(
        duration: NaviMotion.reduceMotion(context)
            ? Duration.zero
            : NaviMotion.page,
        switchInCurve: NaviMotion.curve,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: _FlipArtwork(
          key: ValueKey('artwork-${song.id}'),
          song: song,
          size: size,
          front: artworkBuilder?.call(context, song),
          onPrevious: () => unawaited(controller.previous()),
          onNext: () => unawaited(controller.next()),
          onFavorite: () => _toggleFavorite(context, song, announce: true),
        ),
      ),
    );
  }

  Widget _titleRow(
    BuildContext context,
    AppLocalizations l,
    Song? song,
    InternetRadioStation? station,
  ) {
    final theme = Theme.of(context);
    final starred = song != null && isFavorite(song);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NaviPressable(
                pressedScale: 0.985,
                onTap: song == null || onAlbumTap == null
                    ? null
                    : () => onAlbumTap!(song),
                child: AnimatedSwitcher(
                  duration: NaviMotion.standard,
                  child: Text(
                    song?.title ?? station!.name,
                    key: ValueKey('title-${song?.id ?? station!.id}'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              NaviPressable(
                pressedScale: 0.985,
                onTap: song == null || onArtistTap == null
                    ? null
                    : () => onArtistTap!(song),
                child: Text(
                  song == null ? l.navRadio : primaryArtistName(song.artist),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: NaviColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (song != null) ...[
          const SizedBox(width: NaviSpacing.xs),
          Semantics(
            toggled: starred,
            child: IconButton(
              key: favoriteKey,
              tooltip: starred ? l.removeFavorite : l.favorite,
              onPressed: () => _toggleFavorite(context, song),
              icon: Icon(
                starred
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: starred
                    ? NaviColors.textPrimary
                    : NaviColors.textSecondary,
              ),
            ),
          ),
          IconButton(
            key: menuKey,
            tooltip: l.showMore,
            onPressed: () => onSongMenu(context, song),
            icon: const Icon(Icons.more_horiz_rounded),
          ),
        ],
      ],
    );
  }

  Widget _transport(BuildContext context, AppLocalizations l, Song? song) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            tooltip: l.shuffle,
            onPressed: song == null
                ? null
                : () => unawaited(controller.shuffleUpNext()),
            icon: const Icon(Icons.shuffle_rounded),
          ),
          IconButton(
            tooltip: l.previousTrack,
            onPressed: song == null
                ? null
                : () => unawaited(controller.previous()),
            iconSize: 40,
            icon: const Icon(Icons.skip_previous_rounded),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: controller.playingListenable,
            builder: (context, playing, _) => Tooltip(
              message: playing ? l.pause : l.play,
              child: Semantics(
                button: true,
                label: playing ? l.pause : l.play,
                child: NaviPressable(
                  key: playPauseKey,
                  lift: true,
                  pressedScale: 0.94,
                  borderRadius: BorderRadius.circular(34),
                  onTap: () => unawaited(controller.togglePlayback()),
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: const BoxDecoration(
                      color: NaviColors.textPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 38,
                      color: NaviColors.canvas,
                    ),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: l.nextTrack,
            onPressed: song == null ? null : () => unawaited(controller.next()),
            iconSize: 40,
            icon: const Icon(Icons.skip_next_rounded),
          ),
          IconButton(
            tooltip: l.repeat,
            onPressed: song == null
                ? null
                : () => unawaited(controller.cycleRepeat()),
            icon: Icon(
              controller.repeatMode == V2RepeatMode.one
                  ? Icons.repeat_one_rounded
                  : Icons.repeat_rounded,
              color: controller.repeatMode == V2RepeatMode.off
                  ? NaviColors.textTertiary
                  : NaviColors.textPrimary,
            ),
          ),
        ],
      );

  Widget _actionRow(BuildContext context, AppLocalizations l, Song song) =>
      NaviGlass(
        padding: const EdgeInsets.symmetric(
          horizontal: NaviSpacing.xs,
          vertical: NaviSpacing.xxs,
        ),
        radius: NaviRadii.card,
        child: Row(
          children: [
            Expanded(
              child: _GlassAction(
                key: lyricsActionKey,
                icon: Icons.format_quote_rounded,
                label: l.playerLyricsShort,
                tooltip: l.lyrics,
                onTap: lyricsLoader == null
                    ? null
                    : () => showPlayerLyricsSheet(
                        context,
                        song: song,
                        loader: lyricsLoader!,
                        controller: controller,
                        offset: lyricsOffset?.call() ?? Duration.zero,
                        onOffsetChanged: onLyricsOffsetChanged,
                      ),
              ),
            ),
            Expanded(
              child: _QueueAction(
                key: queueActionKey,
                controller: controller,
                artworkBuilder: artworkBuilder,
                onSongMenu: onSongMenu,
                icon: Icons.format_list_bulleted_rounded,
                label: l.playerQueueShort,
                tooltip: l.queue,
              ),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: controller.sleepTimer,
                builder: (context, _) {
                  final remaining = controller.sleepTimer.remaining;
                  final active = remaining != null && remaining > Duration.zero;
                  return _GlassAction(
                    key: sleepActionKey,
                    icon: Icons.bedtime_outlined,
                    label: active
                        ? formatSleepTimerTime(remaining)
                        : l.playerSleepShort,
                    tooltip: active
                        ? l.sleepTimerRemaining(formatSleepTimerTime(remaining))
                        : l.sleepTimer,
                    active: active,
                    onTap: () => showPlayerSleepTimerSheet(context, controller),
                  );
                },
              ),
            ),
            Expanded(
              child: _GlassAction(
                key: tuneActionKey,
                icon: Icons.sensors_rounded,
                label: l.playerTuneShort,
                tooltip: l.tuneQueue,
                onTap: onTuneQueue == null
                    ? null
                    : () => showPlayerTuneSheet(context, onTuneQueue!),
              ),
            ),
          ],
        ),
      );

  Future<void> _toggleFavorite(
    BuildContext context,
    Song song, {
    bool announce = false,
  }) async {
    final wasStarred = isFavorite(song);
    try {
      await onToggleFavorite(song);
    } catch (_) {
      return;
    }
    if (!announce || !context.mounted) return;
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(wasStarred ? l.unlikedSong : l.likedSong)),
    );
  }
}

/// Up Next, but never a half-built list. A tap while the queue is still being
/// prepared turns the action into a progress ring and opens the sheet the
/// moment the list is complete; a tap on a ready queue opens it immediately.
class _QueueAction extends StatefulWidget {
  const _QueueAction({
    super.key,
    required this.controller,
    required this.icon,
    required this.label,
    required this.tooltip,
    this.artworkBuilder,
    this.onSongMenu,
  });

  final V2PlaybackController controller;
  final IconData icon;
  final String label;
  final String tooltip;
  final PlayerArtworkBuilder? artworkBuilder;
  final SongMenuCallback? onSongMenu;

  @override
  State<_QueueAction> createState() => _QueueActionState();
}

class _QueueActionState extends State<_QueueAction> {
  bool _waiting = false;

  Future<void> _open() async {
    if (_waiting) return;
    if (!widget.controller.queuePreparing.value) {
      _showQueue();
      return;
    }
    setState(() => _waiting = true);
    try {
      // The cap only exists so a stalled network cannot leave a ring turning
      // forever; the queue is normally complete well inside it.
      await widget.controller.queueReady.timeout(
        const Duration(seconds: 4),
        onTimeout: () {},
      );
    } catch (_) {
      // An incomplete queue still has the songs that are already known; the
      // sheet shows the real list rather than an error.
    }
    if (!mounted) return;
    setState(() => _waiting = false);
    _showQueue();
  }

  void _showQueue() => showNaviModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => V2QueueSheet(
      controller: widget.controller,
      artworkBuilder: widget.artworkBuilder,
      onSongMenu: widget.onSongMenu,
    ),
  );

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: widget.controller.queuePreparing,
    builder: (context, preparing, _) => _GlassAction(
      icon: widget.icon,
      label: widget.label,
      tooltip: widget.tooltip,
      loading: _waiting && preparing,
      onTap: () => unawaited(_open()),
    ),
  );
}

/// The small centred grabber standing in for an app bar; tapping it closes
/// the player, the same as a downward swipe.
class _Grabber extends StatelessWidget {
  const _Grabber({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: AppLocalizations.of(context).close,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: NaviSpacing.xxs),
        child: NaviModalHandle(),
      ),
    ),
  );
}

/// Slider plus elapsed / remaining; the only part of the page that repaints
/// on position ticks.
///
/// While the thumb is held the slider follows the finger instead of the player,
/// and the seek is sent once on release. Sending one on every drag update made
/// a streamed FLAC seek over and over — each one re-reading the file — which
/// both stuttered the UI and landed on the wrong time.
class _Scrubber extends StatefulWidget {
  const _Scrubber({required this.controller, required this.song});

  final V2PlaybackController controller;
  final Song song;

  @override
  State<_Scrubber> createState() => _ScrubberState();
}

class _ScrubberState extends State<_Scrubber> {
  double? _dragMilliseconds;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final song = widget.song;
    final theme = Theme.of(context);
    final timeStyle = theme.textTheme.labelSmall?.copyWith(
      color: NaviColors.textSecondary,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final player = controller.nativePort.player;
    // Read straight from the audio player so the scrubber never depends on
    // controller rebuild timing; fall back to the catalogue length while the
    // native duration is still unknown so seeking works from the first frame.
    return StreamBuilder<Duration?>(
      stream: player.durationStream,
      initialData: controller.duration,
      builder: (context, durationSnapshot) {
        final native = durationSnapshot.data ?? controller.duration;
        final total = native > Duration.zero
            ? native
            : Duration(seconds: song.duration);
        final max = math.max(1, total.inMilliseconds).toDouble();
        // The controller's playhead, not the raw player stream: while a seek
        // swaps the playing source to the local file the player briefly reports
        // 0:00, and the scrubber must not jump back for it.
        return ValueListenableBuilder<Duration>(
          valueListenable: controller.positionListenable,
          builder: (context, played, _) {
            final position = _dragMilliseconds == null
                ? played
                : Duration(milliseconds: _dragMilliseconds!.round());
            final remaining = total - position;
            return Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    activeTrackColor: NaviColors.textPrimary,
                    inactiveTrackColor: NaviColors.textTertiary,
                    thumbColor: NaviColors.textPrimary,
                    overlayColor: NaviColors.glassBorder,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14,
                    ),
                  ),
                  child: Slider(
                    value: position.inMilliseconds.toDouble().clamp(0, max),
                    max: max,
                    onChangeStart: (value) =>
                        setState(() => _dragMilliseconds = value),
                    onChanged: (value) =>
                        setState(() => _dragMilliseconds = value),
                    onChangeEnd: (value) {
                      setState(() => _dragMilliseconds = null);
                      unawaited(
                        controller.seek(Duration(milliseconds: value.round())),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: NaviSpacing.xs,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatPlayerTime(position), style: timeStyle),
                      Text(
                        formatPlayerTime(
                          remaining.isNegative ? Duration.zero : remaining,
                          remaining: true,
                        ),
                        style: timeStyle,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _GlassAction extends StatelessWidget {
  const _GlassAction({
    super.key,
    required this.icon,
    required this.label,
    required this.tooltip,
    this.active = false,
    this.loading = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String tooltip;
  final bool active;

  /// Replaces the glyph with a progress ring. Used by the queue action while
  /// the list is still being prepared.
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final color = enabled ? NaviColors.textPrimary : NaviColors.textTertiary;
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: tooltip,
        child: NaviPressable(
          borderRadius: BorderRadius.circular(NaviRadii.row),
          pressedScale: 0.96,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: NaviSpacing.xs),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (loading)
                  SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  )
                else
                  Icon(icon, size: 22, color: color),
                const SizedBox(height: NaviSpacing.xxs),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: active
                        ? NaviColors.textPrimary
                        : NaviColors.textSecondary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Artwork with the gestures Now Playing owns: horizontal swipe for
/// previous/next, double-tap to favourite (transient heart), long-press to
/// flip to the info card (a crossfade under Reduce Motion).
class _FlipArtwork extends StatefulWidget {
  const _FlipArtwork({
    super.key,
    required this.song,
    required this.size,
    this.front,
    this.onPrevious,
    this.onNext,
    this.onFavorite,
  });

  final Song song;
  final double size;
  final Widget? front;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onFavorite;

  @override
  State<_FlipArtwork> createState() => _FlipArtworkState();
}

class _FlipArtworkState extends State<_FlipArtwork>
    with TickerProviderStateMixin {
  static const _heartDuration = Duration(milliseconds: 600);
  static const _heartFadeDuration = Duration(milliseconds: 300);

  late final AnimationController _flip = AnimationController(
    vsync: this,
    duration: NaviMotion.artworkFlip,
  );
  late final AnimationController _heart = AnimationController(
    vsync: this,
    duration: _heartDuration,
  );

  @override
  void didUpdateWidget(covariant _FlipArtwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.song.id != widget.song.id) _flip.value = 0;
  }

  @override
  void dispose() {
    _flip.dispose();
    _heart.dispose();
    super.dispose();
  }

  void _toggle() => _flip.value < 0.5 ? _flip.forward() : _flip.reverse();

  void _favorite() {
    final onFavorite = widget.onFavorite;
    if (onFavorite == null) return;
    onFavorite();
    unawaited(HapticFeedback.lightImpact());
    _heart.duration = NaviMotion.reduceMotion(context)
        ? _heartFadeDuration
        : _heartDuration;
    _heart.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = NaviMotion.reduceMotion(context);
    _flip.duration = reduceMotion
        ? NaviMotion.standard
        : NaviMotion.artworkFlip;
    final front = ClipRRect(
      borderRadius: BorderRadius.circular(NaviRadii.artwork),
      child: SizedBox.square(
        dimension: widget.size,
        child: widget.front ?? const _ArtworkFallback(),
      ),
    );
    final back = _SongInfo(song: widget.song, size: widget.size);
    return Semantics(
      label: AppLocalizations.of(context).holdArtworkForInfo,
      child: GestureDetector(
        key: V2FullPlayer.artworkKey,
        onLongPress: _toggle,
        onDoubleTap: widget.onFavorite == null ? null : _favorite,
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity < -320) {
            widget.onNext?.call();
          } else if (velocity > 320) {
            widget.onPrevious?.call();
          }
        },
        onTap: () {
          if (_flip.value > 0.5) _toggle();
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _flip,
              builder: (context, _) {
                if (reduceMotion) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(opacity: 1 - _flip.value, child: front),
                      if (_flip.value > 0)
                        Opacity(opacity: _flip.value, child: back),
                    ],
                  );
                }
                final angle = _flip.value * math.pi;
                final showBack = angle > math.pi / 2;
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0012)
                    ..rotateY(angle),
                  child: showBack
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(math.pi),
                          child: back,
                        )
                      : front,
                );
              },
            ),
            IgnorePointer(
              child: AnimatedBuilder(
                animation: _heart,
                builder: (context, _) {
                  final t = _heart.value;
                  if (t == 0 || _heart.status == AnimationStatus.dismissed) {
                    return const SizedBox.shrink();
                  }
                  final opacity = t < 0.2
                      ? t / 0.2
                      : t > 0.65
                      ? (1 - t) / 0.35
                      : 1.0;
                  final scale = reduceMotion
                      ? 1.0
                      : 1 +
                            0.15 *
                                NaviMotion.curve.transform(
                                  math.min(1, t / 0.5),
                                );
                  return Opacity(
                    opacity: opacity.clamp(0, 1),
                    child: Transform.scale(
                      scale: scale,
                      child: Icon(
                        Icons.favorite_rounded,
                        size: widget.size * 0.3,
                        color: NaviColors.textPrimary,
                        shadows: const [
                          Shadow(color: Color(0x73000000), blurRadius: 28),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SongInfo extends StatelessWidget {
  const _SongInfo({required this.song, required this.size});

  final Song song;
  final double size;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final quality = [
      if (song.bitDepth > 0) '${song.bitDepth}-bit',
      if (song.samplingRate > 0)
        '${(song.samplingRate / 1000).toStringAsFixed(1)} kHz',
    ].join(' · ');
    final rows = <(String, String)>[
      (l.sortArtist, primaryArtistName(song.artist)),
      (l.sortAlbum, song.album),
      if (song.genre?.trim().isNotEmpty == true) (l.filterGenre, song.genre!),
      if (song.year > 0) (l.filterYear, '${song.year}'),
      if (song.suffix.isNotEmpty) (l.filterFormat, song.suffix.toUpperCase()),
      if (song.bitRate > 0) (l.filterBitRateKbps, '${song.bitRate} kbps'),
      if (quality.isNotEmpty) (l.filterQuality, quality),
    ];
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(NaviSpacing.lg),
      decoration: BoxDecoration(
        color: NaviColors.glassOpaque,
        borderRadius: BorderRadius.circular(NaviRadii.artwork),
        border: Border.all(color: NaviColors.glassBorder),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(song.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: NaviSpacing.md),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: NaviSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 92,
                      child: Text(
                        row.$1,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Expanded(child: Text(row.$2)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StationArtwork extends StatelessWidget {
  const _StationArtwork({required this.station, required this.size});

  final InternetRadioStation station;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: NaviColors.glass,
      borderRadius: BorderRadius.circular(NaviRadii.artwork),
      border: Border.all(color: NaviColors.glassBorder),
    ),
    child: const Icon(Icons.radio_rounded, size: 112),
  );
}

class _ArtworkFallback extends StatelessWidget {
  const _ArtworkFallback();

  @override
  Widget build(BuildContext context) =>
      const NaviArtwork(fallback: Icons.music_note_rounded, radius: 0);
}
