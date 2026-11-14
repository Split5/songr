import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../navi_design_tokens.dart';
import 'navi_glass.dart';
import 'navi_name_dialog.dart';

/// Playlist chooser for "Add to playlist". The first row always creates a
/// new playlist (asking for a name), then the caller's [playlists] follow in
/// the order given, with the last-used one marked.
Future<void> showNaviPlaylistPicker({
  required BuildContext context,
  required List<Playlist> playlists,
  required String? lastPlaylistId,
  required ValueChanged<Playlist> onPick,
  required ValueChanged<String> onCreate,
}) => showNaviModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (sheetContext) {
    // A draggable sheet lets a downward drag on the list dismiss it; a plain
    // shrink-wrapped ListView would swallow that drag instead.
    final height = MediaQuery.sizeOf(sheetContext).height;
    final estimated = (32 + (playlists.length + 1) * 56 + 16) / height;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: estimated.clamp(0.2, 0.7),
      minChildSize: 0.15,
      maxChildSize: 0.7,
      builder: (sheetContext, scrollController) => NaviModalSurface(
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.only(bottom: NaviSpacing.xs),
          children: [
            const NaviModalHandle(),
            ListTile(
              key: const ValueKey('navi-playlist-picker-new'),
              leading: const Icon(
                Icons.add_rounded,
                color: NaviColors.textPrimary,
              ),
              title: Text(
                AppLocalizations.of(sheetContext).newPlaylistEllipsis,
              ),
              onTap: () async {
                final l = AppLocalizations.of(sheetContext);
                final name = await showNaviNameDialog(
                  context: sheetContext,
                  title: l.newPlaylist,
                  label: l.playlistName,
                  confirmLabel: l.create,
                );
                if (name == null || !sheetContext.mounted) return;
                Navigator.of(sheetContext).pop();
                onCreate(name);
              },
            ),
            for (final playlist in playlists)
              ListTile(
                leading: Icon(
                  playlist.id == lastPlaylistId
                      ? Icons.history_rounded
                      : Icons.queue_music_rounded,
                ),
                title: Text(playlist.name),
                subtitle: playlist.id == lastPlaylistId
                    ? Text(AppLocalizations.of(sheetContext).lastUsedPlaylist)
                    : null,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onPick(playlist);
                },
              ),
          ],
        ),
      ),
    );
  },
);
