import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../design_system/navi_design_tokens.dart';
import '../../design_system/widgets/navi_widgets.dart';
import '../../domain/library/song_filter.dart';
import '../../l10n/app_localizations.dart';
import '../../state/download_provider.dart';
import '../library/songs/song_sort_labels.dart';
import 'downloads_controller.dart';

typedef DownloadArtworkBuilder =
    Widget Function(BuildContext context, DownloadedEntry entry);

class V2DownloadsScreen extends StatefulWidget {
  const V2DownloadsScreen({
    super.key,
    required this.controller,
    required this.onSongTap,
    required this.onPlayAll,
    this.onSongMenu,
    this.artworkBuilder,
    this.nowPlaying,
    this.playing,
  });

  final V2DownloadsController controller;
  final ValueChanged<DownloadedEntry> onSongTap;
  final ValueChanged<List<DownloadedEntry>> onPlayAll;
  final ValueChanged<DownloadedEntry>? onSongMenu;
  final DownloadArtworkBuilder? artworkBuilder;

  /// Id of the song at the playhead; rows mark themselves when it matches.
  final ValueListenable<String?>? nowPlaying;
  final ValueListenable<bool>? playing;

  @override
  State<V2DownloadsScreen> createState() => _V2DownloadsScreenState();
}

class _V2DownloadsScreenState extends State<V2DownloadsScreen> {
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
      final entries = widget.controller.entries;
      final visibleEntries = widget.controller.visibleEntries;
      return Scaffold(
        appBar: AppBar(
          title: Text(l.navDownloads),
          actions: [
            PopupMenuButton<SongSort>(
              tooltip: l.sortBy,
              initialValue: widget.controller.sort,
              onSelected: widget.controller.setSort,
              itemBuilder: (context) => [
                for (final sort in SongSort.values)
                  PopupMenuItem(
                    value: sort,
                    child: Text(songSortLabel(l, sort)),
                  ),
              ],
              icon: const Icon(Icons.sort_rounded),
            ),
            IconButton(
              tooltip: l.play,
              onPressed: entries.isEmpty
                  ? null
                  : () => widget.onPlayAll(entries),
              icon: const Icon(Icons.play_arrow_rounded),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                NaviSpacing.page,
                NaviSpacing.xs,
                NaviSpacing.page,
                NaviSpacing.sm,
              ),
              child: TextField(
                onChanged: widget.controller.setQuery,
                decoration: InputDecoration(
                  hintText: l.songsSearchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                ),
              ),
            ),
            Expanded(
              child: widget.controller.loading && entries.isEmpty
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : entries.isEmpty
                  ? NaviEmptyState(
                      icon: Icons.download_for_offline_outlined,
                      title: l.downloadsEmptyTitle,
                      hint: l.downloadsEmptyHint,
                    )
                  : visibleEntries.isEmpty
                  ? Center(child: Text(l.noResults))
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: NaviSpacing.xl),
                      itemCount: visibleEntries.length,
                      itemBuilder: (context, index) {
                        final entry = visibleEntries[index];
                        final song = entry.song!;
                        final openMenu = widget.onSongMenu == null
                            ? null
                            : () => widget.onSongMenu!(entry);
                        return NaviSongRow(
                          key: ValueKey('download-${entry.playbackKey}'),
                          song: song,
                          artwork: widget.artworkBuilder?.call(context, entry),
                          nowPlayingListenable: widget.nowPlaying,
                          playingListenable: widget.playing,
                          starred: song.starred,
                          trailingText: formatDuration(song.duration),
                          onTap: () => widget.onSongTap(entry),
                          onMenu: openMenu,
                          menuButtonKey: ValueKey(
                            'downloads-song-menu-${entry.playbackKey}',
                          ),
                          trailing: openMenu == null
                              ? IconButton(
                                  tooltip: l.downloadRemoveSong,
                                  onPressed: () => unawaited(
                                    widget.controller.remove(entry),
                                  ),
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                  ),
                                )
                              : null,
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    },
  );
}
