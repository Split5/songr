import 'dart:async';

import 'package:flutter/material.dart';

import '../../design_system/navi_design_tokens.dart';
import '../../design_system/widgets/navi_glass.dart';
import '../../domain/lyrics/lrc_document.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import 'lyrics_playhead.dart';
import 'v2_playback_controller.dart';

typedef LyricsLoader = Future<String?> Function(Song song);

/// The two queue adjustments the Navidrome similarity plugin can serve
/// through `getSimilarSongs2`. Mood-style tuning (more energy, calmer) needed
/// a direct AudioMuse text search and was removed together with that API.
enum QueueTuneAction { moreLikeThis, lessLikeThis }

typedef QueueTuneCallback = Future<void> Function(QueueTuneAction action);

/// `m:ss` for elapsed time and `-m:ss` for the remaining time.
String formatPlayerTime(Duration value, {bool remaining = false}) {
  final minutes = value.inMinutes;
  final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
  return remaining ? '-$minutes:$seconds' : '$minutes:$seconds';
}

/// `mm:ss`, or `h:mm:ss` once a timer runs longer than an hour.
String formatSleepTimerTime(Duration value) {
  final hours = value.inHours;
  final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
  return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
}

/// The plugin-only tune sheet: 'More like this' / 'Less like this'.
Future<void> showPlayerTuneSheet(
  BuildContext context,
  QueueTuneCallback onTuneQueue,
) async {
  final l = AppLocalizations.of(context);
  final action = await showNaviModalBottomSheet<QueueTuneAction>(
    context: context,
    builder: (sheetContext) => NaviModalSurface(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const NaviModalHandle(),
          ListTile(
            leading: const Icon(Icons.sensors_rounded),
            title: Text(l.tuneQueue),
          ),
          const Divider(height: 1),
          for (final action in QueueTuneAction.values)
            ListTile(
              leading: Icon(switch (action) {
                QueueTuneAction.moreLikeThis =>
                  Icons.add_circle_outline_rounded,
                QueueTuneAction.lessLikeThis =>
                  Icons.remove_circle_outline_rounded,
              }),
              title: Text(switch (action) {
                QueueTuneAction.moreLikeThis => l.moreLikeThis,
                QueueTuneAction.lessLikeThis => l.lessLikeThis,
              }),
              onTap: () => Navigator.of(sheetContext).pop(action),
            ),
          const SizedBox(height: NaviSpacing.xs),
        ],
      ),
    ),
  );
  if (action == null || !context.mounted) return;
  try {
    await onTuneQueue(action);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.queueTuned)));
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.similarSuggestionsError)));
    }
  }
}

/// 15/30/45/60 minutes, 'End of current song' and cancel. The sheet closes
/// on selection because the remaining time is shown in the player's glass
/// row the moment the timer starts.
Future<void> showPlayerSleepTimerSheet(
  BuildContext context,
  V2PlaybackController controller,
) async {
  final l = AppLocalizations.of(context);
  const choices = [15, 30, 45, 60];
  await showNaviModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => NaviModalSurface(
      child: AnimatedBuilder(
        animation: controller.sleepTimer,
        builder: (context, _) {
          final remaining = controller.sleepTimer.remaining;
          final untilEnd = controller.duration - controller.position;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const NaviModalHandle(),
              ListTile(
                leading: const Icon(Icons.bedtime_outlined),
                title: Text(l.sleepTimer),
                subtitle: remaining == null
                    ? Text(l.sleepTimerDescription)
                    : Text(
                        l.sleepTimerRemaining(formatSleepTimerTime(remaining)),
                      ),
              ),
              const Divider(height: 1),
              for (final minutes in choices)
                ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: Text(l.sleepTimerMinutes(minutes)),
                  onTap: () {
                    controller.sleepTimer.start(Duration(minutes: minutes));
                    Navigator.of(sheetContext).pop();
                  },
                ),
              ListTile(
                key: const ValueKey('sleep-end-of-song'),
                leading: const Icon(Icons.music_off_outlined),
                title: Text(l.sleepTimerEndOfSong),
                enabled: untilEnd > Duration.zero,
                onTap: untilEnd <= Duration.zero
                    ? null
                    : () {
                        controller.sleepTimer.start(
                          controller.duration - controller.position,
                        );
                        Navigator.of(sheetContext).pop();
                      },
              ),
              if (controller.sleepTimer.active)
                ListTile(
                  leading: const Icon(Icons.timer_off_outlined),
                  title: Text(l.cancelSleepTimer),
                  onTap: () {
                    controller.sleepTimer.cancel();
                    Navigator.of(sheetContext).pop();
                  },
                ),
              const SizedBox(height: NaviSpacing.xs),
            ],
          );
        },
      ),
    ),
  );
}

Future<void> showPlayerLyricsSheet(
  BuildContext context, {
  required Song song,
  required LyricsLoader loader,
  required V2PlaybackController controller,
  Duration offset = Duration.zero,
  ValueChanged<Duration>? onOffsetChanged,
}) async {
  final future = loader(song);
  final playhead = controller.createLyricsPlayhead();
  await showNaviModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.88,
      child: NaviModalSurface(
        child: _LyricsSheet(
          future: future,
          playhead: playhead,
          onSeek: controller.seek,
          initialOffset: offset,
          onOffsetChanged: onOffsetChanged,
        ),
      ),
    ),
  );
}

class _LyricsSheet extends StatefulWidget {
  const _LyricsSheet({
    required this.future,
    required this.playhead,
    required this.onSeek,
    required this.initialOffset,
    this.onOffsetChanged,
  });

  final Future<String?> future;
  final LyricsPlayhead playhead;
  final Future<void> Function(Duration position) onSeek;
  final Duration initialOffset;
  final ValueChanged<Duration>? onOffsetChanged;

  @override
  State<_LyricsSheet> createState() => _LyricsSheetState();
}

class _LyricsSheetState extends State<_LyricsSheet> {
  late Duration _offset = widget.initialOffset;

  void _changeOffset(Duration value) {
    widget.onOffsetChanged?.call(value);
    setState(() => _offset = value);
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const NaviModalHandle(),
      Padding(
        padding: const EdgeInsets.fromLTRB(
          NaviSpacing.page,
          0,
          NaviSpacing.xs,
          NaviSpacing.xs,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context).lyrics,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            IconButton(
              tooltip: AppLocalizations.of(context).close,
              onPressed: Navigator.of(context).pop,
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
      ),
      const Divider(height: 1),
      Expanded(
        child: FutureBuilder<String?>(
          future: widget.future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
            final lrc = snapshot.data;
            if (lrc == null || lrc.trim().isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(NaviSpacing.page),
                  child: Text(AppLocalizations.of(context).noLyrics),
                ),
              );
            }
            return _LyricsView(
              lrc: lrc,
              playhead: widget.playhead,
              onSeek: widget.onSeek,
              offset: _offset,
              onOffsetChanged: widget.onOffsetChanged == null
                  ? null
                  : _changeOffset,
            );
          },
        ),
      ),
    ],
  );
}

class _LyricsView extends StatelessWidget {
  const _LyricsView({
    required this.lrc,
    required this.playhead,
    required this.onSeek,
    required this.offset,
    this.onOffsetChanged,
  });

  final String lrc;
  final LyricsPlayhead playhead;
  final Future<void> Function(Duration position) onSeek;

  /// Positive values show the lyrics later, negative values earlier.
  final Duration offset;
  final ValueChanged<Duration>? onOffsetChanged;

  @override
  Widget build(BuildContext context) {
    final document = LrcDocument.parse(lrc);
    if (document.lines.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context).noLyrics));
    }
    if (document.isSynced) {
      return SyncedLyrics(
        document: document,
        playhead: playhead,
        onSeek: onSeek,
        offset: offset,
        onOffsetChanged: onOffsetChanged,
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(NaviSpacing.page),
      child: SelectableText(
        document.lines.map((line) => line.text).join('\n'),
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(height: 1.55),
      ),
    );
  }
}

/// Synced lines change only in opacity as the playhead moves; the type size
/// stays put so the text never breathes.
///
/// Follows the player's own playhead rather than a clock of its own: just_audio
/// already interpolates between platform reports, freezes the value while
/// buffering and moves it when the listener seeks. Sampling that value about
/// thirty times a second keeps the highlight on the sung line, and keeps it
/// there after a seek or a stall instead of letting it drift.
class SyncedLyrics extends StatefulWidget {
  const SyncedLyrics({
    super.key,
    required this.document,
    required this.playhead,
    required this.onSeek,
    this.offset = Duration.zero,
    this.onOffsetChanged,
  });

  /// A route with its own latency (Bluetooth, AirPlay, a receiver) can be
  /// several hundred milliseconds behind the player, which no client can
  /// measure. The manual nudge covers exactly that gap.
  static const maxOffset = Duration(seconds: 2);
  static const offsetStep = Duration(milliseconds: 100);

  final LrcDocument document;
  final LyricsPlayhead playhead;
  final Future<void> Function(Duration position) onSeek;
  final Duration offset;

  /// Null hides the sync control, which is the case when the app has nowhere
  /// to remember the value.
  final ValueChanged<Duration>? onOffsetChanged;

  @override
  State<SyncedLyrics> createState() => _SyncedLyricsState();
}

class _SyncedLyricsState extends State<SyncedLyrics> {
  late final List<GlobalKey> _keys = [
    for (var i = 0; i < widget.document.lines.length; i++) GlobalKey(),
  ];
  StreamSubscription<Duration>? _updates;
  ScrollController? _scroll;

  /// The last playhead the player reported.
  Duration _position = Duration.zero;

  /// A jump this large is a seek or a new track, not normal playback; the
  /// list should be there at once rather than glide to it.
  static const _seekThreshold = Duration(seconds: 2);

  /// Top and bottom breathing room; the list is scrolled past it so the
  /// playing line can sit in the middle.
  static const _verticalPadding = 160.0;

  int _active = -1;

  @override
  void initState() {
    super.initState();
    _position = widget.playhead.now();
    // initState builds anyway, so seed the highlight directly instead of
    // asking for another frame.
    _active = widget.document.activeLine(_playhead);
    _updates = widget.playhead.updates.listen(_positionChanged);
    _scrollTo(_active, snap: true);
  }

  @override
  void didUpdateWidget(covariant SyncedLyrics oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.document.lines.length != widget.document.lines.length) {
      _keys
        ..clear()
        ..addAll([
          for (var i = 0; i < widget.document.lines.length; i++) GlobalKey(),
        ]);
      _active = widget.document.activeLine(_playhead);
      _scrollTo(_active, snap: true);
    } else if (oldWidget.offset != widget.offset) {
      // The build that follows uses the new offset; the list only has to
      // follow the line the nudge selected.
      final next = widget.document.activeLine(_playhead);
      if (next != _active) {
        _active = next;
        _scrollTo(next);
      }
    }
  }

  @override
  void dispose() {
    unawaited(_updates?.cancel());
    _scroll?.dispose();
    super.dispose();
  }

  void _positionChanged(Duration position) {
    final jumped = (position - _position).abs() > _seekThreshold;
    _position = position;
    _refresh(snap: jumped);
  }

  /// A positive offset delays the lyrics: the lines start [offset] later
  /// than the file says, which is the convention a subtitle or lyric offset
  /// uses. Adding it to the position instead made the +/- buttons act
  /// backwards.
  Duration get _playhead => _position - widget.offset;

  void _refresh({bool snap = false}) {
    if (!mounted) return;
    final next = widget.document.activeLine(_playhead);
    if (next == _active) return;
    setState(() => _active = next);
    _scrollTo(next, snap: snap);
  }

  void _scrollTo(int index, {bool snap = false, int attempt = 0}) {
    if (index < 0 || index >= _keys.length) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final lineContext = _keys[index].currentContext;
      if (lineContext != null) {
        Scrollable.ensureVisible(
          lineContext,
          alignment: 0.42,
          duration: snap || NaviMotion.reduceMotion(context)
              ? Duration.zero
              : NaviMotion.micro,
          curve: NaviMotion.curve,
        );
        return;
      }
      // The row has never been built because it sits far down a lazy list.
      // Move to where it should be, then try again now that it is built.
      final controller = _scroll;
      if (controller == null || !controller.hasClients || attempt >= 3) return;
      final offset = _offsetForLine(
        context,
        index,
        controller.position.viewportDimension,
        _lineStyle(context),
      );
      controller.jumpTo(offset.clamp(0.0, controller.position.maxScrollExtent));
      _scrollTo(index, snap: snap, attempt: attempt + 1);
    });
  }

  TextStyle? _lineStyle(BuildContext context) => Theme.of(context)
      .textTheme
      .headlineSmall
      ?.copyWith(height: 1.35, fontWeight: FontWeight.w700);

  /// Scroll offset that puts line [index] where the list puts the playing
  /// line, measured before the first frame.
  ///
  /// A `ListView` builds lazily, so opening the sheet on the current line
  /// cannot rely on the row existing — without this the lyrics always started
  /// at the top of the song and had to be scrolled.
  double _offsetForLine(
    BuildContext context,
    int index,
    double viewport,
    TextStyle? style,
  ) {
    if (index <= 0 || style == null) return 0;
    final width = MediaQuery.sizeOf(context).width - 2 * NaviSpacing.page;
    var before = 0.0;
    for (var i = 0; i < index; i++) {
      before += _lineHeight(
        context,
        widget.document.lines[i].text,
        style,
        width,
      );
    }
    final target = _verticalPadding + before - viewport * 0.42;
    return target < 0 ? 0 : target;
  }

  double _lineHeight(
    BuildContext context,
    String text,
    TextStyle style,
    double width,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text.isEmpty ? '♪' : text, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: width);
    return painter.height + 2 * NaviSpacing.sm;
  }

  void _nudge(Duration delta) {
    final next = widget.offset + delta;
    widget.onOffsetChanged?.call(
      Duration(
        milliseconds: next.inMilliseconds.clamp(
          -SyncedLyrics.maxOffset.inMilliseconds,
          SyncedLyrics.maxOffset.inMilliseconds,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = _lineStyle(context);
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final controller = _scroll ??= ScrollController(
                initialScrollOffset: _offsetForLine(
                  context,
                  _active,
                  constraints.maxHeight,
                  style,
                ),
              );
              return ListView.builder(
                controller: controller,
                padding: const EdgeInsets.symmetric(
                  horizontal: NaviSpacing.page,
                  vertical: _verticalPadding,
                ),
                itemCount: widget.document.lines.length,
                itemBuilder: (context, index) {
                  final line = widget.document.lines[index];
                  return AnimatedOpacity(
                    key: _keys[index],
                    opacity: index == _active ? 1 : 0.38,
                    duration: NaviMotion.reduceMotion(context)
                        ? Duration.zero
                        : NaviMotion.micro,
                    curve: NaviMotion.curve,
                    // Tapping a line is off until a seek works for a part of
                    // the stream that is not cached yet: the player stayed in
                    // buffering at the target.
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: NaviSpacing.sm,
                      ),
                      child: Text(
                        line.text.isEmpty ? '♪' : line.text,
                        style: style,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        if (widget.onOffsetChanged != null) _syncBar(context),
      ],
    );
  }

  Widget _syncBar(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelMedium?.copyWith(
      color: NaviColors.textSecondary,
    );
    final milliseconds = widget.offset.inMilliseconds;
    final canEarlier = milliseconds > -SyncedLyrics.maxOffset.inMilliseconds;
    final canLater = milliseconds < SyncedLyrics.maxOffset.inMilliseconds;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          NaviSpacing.page,
          0,
          NaviSpacing.xs,
          NaviSpacing.xxs,
        ),
        child: Row(
          children: [
            Text(
              l.lyricsSync,
              style: theme.textTheme.labelMedium?.copyWith(
                color: NaviColors.textTertiary,
              ),
            ),
            const SizedBox(width: NaviSpacing.sm),
            Text(
              '${milliseconds < 0 ? '−' : '+'}${milliseconds.abs()} ms',
              style: labelStyle,
            ),
            const Spacer(),
            IconButton(
              tooltip: l.lyricsSyncEarlier,
              visualDensity: VisualDensity.compact,
              onPressed: canEarlier
                  ? () => _nudge(const Duration(milliseconds: -100))
                  : null,
              icon: const Icon(Icons.remove_rounded, size: 20),
            ),
            IconButton(
              tooltip: l.lyricsSyncLater,
              visualDensity: VisualDensity.compact,
              onPressed: canLater
                  ? () => _nudge(const Duration(milliseconds: 100))
                  : null,
              icon: const Icon(Icons.add_rounded, size: 20),
            ),
            IconButton(
              tooltip: l.lyricsSyncReset,
              visualDensity: VisualDensity.compact,
              onPressed: milliseconds == 0
                  ? null
                  : () => widget.onOffsetChanged!.call(Duration.zero),
              icon: const Icon(Icons.restart_alt_rounded, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
