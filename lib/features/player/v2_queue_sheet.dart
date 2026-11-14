import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../design_system/navi_design_tokens.dart';
import '../../design_system/widgets/navi_widgets.dart';
import '../../domain/playback/logical_queue.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import 'v2_playback_controller.dart';

/// Up Next: reorderable [NaviSongRow]s, the Autoplay switch and, on long
/// press, the same song sheet every other list uses.
class V2QueueSheet extends StatefulWidget {
  const V2QueueSheet({
    super.key,
    required this.controller,
    this.artworkBuilder,
    this.onSongMenu,
  });

  final V2PlaybackController controller;
  final SongArtworkBuilder? artworkBuilder;
  final void Function(BuildContext context, Song song)? onSongMenu;

  /// Every row is laid out at exactly this height so the sheet can open on
  /// the playing song without measuring.
  static const rowHeight = 64.0;

  /// Marks the lifted row so a test can prove it no longer paints the opaque
  /// black card Material's default decorator used.
  static const dragProxyKey = ValueKey('queue-drag-proxy');

  /// The default decorator wraps the dragged row in a [Material] painted with
  /// the theme's `canvasColor` — pure black here — so picking a row up flashed
  /// a black band over the `#111` sheet. Lifting it on the sheet's own colour,
  /// with a soft shadow instead, keeps the row looking unchanged while it
  /// moves.
  static Widget _dragProxy(
    Widget child,
    int index,
    Animation<double> animation,
  ) => Material(
    key: dragProxyKey,
    type: MaterialType.transparency,
    child: DecoratedBox(
      decoration: const BoxDecoration(
        color: NaviColors.surface,
        boxShadow: [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    ),
  );

  @override
  State<V2QueueSheet> createState() => _V2QueueSheetState();
}

class _V2QueueSheetState extends State<V2QueueSheet> {
  final ScrollController _scroll = ScrollController();

  /// Resolved rows keyed by queue entry. Dragging re-parents the row into an
  /// overlay, so it must be able to paint without waiting on anything: a
  /// `FutureBuilder` there restarted in its waiting state and flashed the
  /// placeholder title while the finger was already moving.
  final Map<String, Song> _resolved = {};
  final Set<String> _loading = {};
  bool _positioned = false;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Song? _songFor(LogicalQueueEntry entry) {
    final resolved = _resolved[entry.id];
    if (resolved != null) return resolved;
    if (_loading.add(entry.id)) {
      unawaited(
        widget.controller.songForEntry(entry).then((song) {
          if (!mounted || song == null) return;
          setState(() => _resolved[entry.id] = song);
        }),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final queue = widget.controller.queue;
      _positionOnCurrent(queue);
      final l = AppLocalizations.of(context);
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.78,
        minChildSize: 0.48,
        maxChildSize: 0.96,
        builder: (context, sheetScroll) => NaviModalSurface(
          child: Column(
            children: [
              const NaviModalHandle(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  NaviSpacing.page,
                  NaviSpacing.md,
                  NaviSpacing.page,
                  NaviSpacing.xs,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${l.queue} (${queue.entries.length})',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: l.close,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              SwitchListTile.adaptive(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: NaviSpacing.page,
                ),
                title: Text(l.autoplay),
                subtitle: Text(l.autoplaySubtitle),
                value: widget.controller.autoPlayEnabled,
                onChanged: (value) =>
                    unawaited(widget.controller.setAutoPlay(value)),
              ),
              const Divider(height: 1),
              Expanded(
                child: queue.entries.isEmpty
                    ? Center(child: Text(l.queueEmpty))
                    : ReorderableListView.builder(
                        scrollController: _scroll,
                        buildDefaultDragHandles: false,
                        itemCount: queue.entries.length,
                        itemExtent: V2QueueSheet.rowHeight,
                        onReorderItem: (oldIndex, newIndex) =>
                            _reorder(queue, oldIndex, newIndex),
                        proxyDecorator: V2QueueSheet._dragProxy,
                        itemBuilder: (context, index) {
                          final entry = queue.entries[index];
                          return _QueueRow(
                            key: ValueKey(entry.id),
                            entry: entry,
                            song: _songFor(entry),
                            current: index == queue.currentIndex,
                            playing: widget.controller.playingListenable,
                            artworkBuilder: widget.artworkBuilder,
                            dragIndex: index,
                            onTap: () =>
                                unawaited(widget.controller.jumpTo(entry.id)),
                            onRemove: () =>
                                unawaited(widget.controller.remove(entry.id)),
                            onMenu: widget.onSongMenu,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      );
    },
  );

  void _positionOnCurrent(LogicalQueue queue) {
    if (_positioned || queue.currentIndex <= 0) return;
    _positioned = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.jumpTo(
        (queue.currentIndex * V2QueueSheet.rowHeight).clamp(
          0,
          _scroll.position.maxScrollExtent,
        ),
      );
    });
  }

  void _reorder(LogicalQueue queue, int oldIndex, int newIndex) {
    final entries = List<LogicalQueueEntry>.of(queue.entries);
    final moved = entries.removeAt(oldIndex);
    entries.insert(newIndex.clamp(0, entries.length), moved);
    final movedIndex = entries.indexWhere((entry) => entry.id == moved.id);
    final beforeId = movedIndex + 1 < entries.length
        ? entries[movedIndex + 1].id
        : null;
    unawaited(widget.controller.moveBefore(moved.id, beforeId));
  }
}

class _QueueRow extends StatelessWidget {
  const _QueueRow({
    super.key,
    required this.entry,
    required this.song,
    required this.current,
    required this.playing,
    required this.dragIndex,
    required this.onTap,
    required this.onRemove,
    this.onMenu,
    this.artworkBuilder,
  });

  final LogicalQueueEntry entry;

  /// Null while the row is still resolving; the placeholder paints in its
  /// place and is replaced in the same frame the song arrives.
  final Song? song;

  /// The same song can sit in the queue twice, so the playhead is matched by
  /// queue position rather than song id.
  final bool current;
  final ValueListenable<bool> playing;
  final int dragIndex;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final void Function(BuildContext context, Song song)? onMenu;
  final SongArtworkBuilder? artworkBuilder;

  @override
  Widget build(BuildContext context) {
    final resolved = song;
    final value =
        resolved ??
        Song(
          id: entry.songId,
          title: '…',
          artist: '',
          artistId: '',
          album: '',
          albumId: '',
        );
    final onMenu = this.onMenu;
    return ValueListenableBuilder<bool>(
      valueListenable: playing,
      builder: (context, isPlaying, _) => NaviSongRow(
        song: value,
        dense: true,
        artwork: resolved == null ? null : artworkBuilder?.call(context, value),
        nowPlaying: current,
        playing: current && isPlaying,
        starred: value.starred,
        onTap: onTap,
        onMenu: onMenu == null || resolved == null
            ? null
            : () => onMenu(context, resolved),
        showMenuButton: false,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: AppLocalizations.of(context).removeFromQueue,
              visualDensity: VisualDensity.compact,
              onPressed: current ? null : onRemove,
              icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
            ),
            if (!current)
              // Delayed (press-and-hold) start wins the gesture arena over
              // the row's tap/long-press and the list's scroll, so the
              // handle reliably reorders on touch screens.
              ReorderableDelayedDragStartListener(
                index: dragIndex,
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: NaviSpacing.sm,
                    vertical: NaviSpacing.md,
                  ),
                  child: Icon(Icons.drag_handle_rounded),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
