import 'package:flutter/material.dart';

import '../../design_system/navi_design_tokens.dart';
import '../../domain/sync/library_sync_progress.dart';
import '../../l10n/app_localizations.dart';

class LibrarySyncProgressView extends StatelessWidget {
  const LibrarySyncProgressView({super.key, this.progress});

  final LibrarySyncProgress? progress;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final progress = this.progress;
    final numbers = MaterialLocalizations.of(context);
    final count = numbers.formatDecimal(progress?.processed ?? 0);
    final status = switch (progress?.stage) {
      LibrarySyncStage.songs => l.librarySyncSongsProgress(count),
      LibrarySyncStage.artists => l.librarySyncArtistsProgress(count),
      LibrarySyncStage.albums => l.librarySyncAlbumsProgress(count),
      LibrarySyncStage.playlists =>
        progress?.total == null
            ? l.librarySyncPlaylistsLoading
            : l.librarySyncPlaylistsProgress(
                count,
                numbers.formatDecimal(progress!.total!),
              ),
      LibrarySyncStage.finishing => l.librarySyncFinishing,
      _ => l.librarySyncWaiting,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(status),
        const SizedBox(height: NaviSpacing.sm),
        LinearProgressIndicator(
          value: progress?.fraction,
          semanticsLabel: status,
        ),
      ],
    );
  }
}
