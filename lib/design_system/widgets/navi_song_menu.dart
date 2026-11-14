import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../navi_design_tokens.dart';
import 'navi_artwork.dart';
import 'navi_glass.dart';

/// One row in the shared song action sheet.
class NaviSongMenuEntry {
  const NaviSongMenuEntry({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.destructive = false,
    this.key,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool destructive;
  final Key? key;
}

/// The one song action sheet: an Apple-style header (artwork, title, artist)
/// followed by [entries] in the order given. Each entry closes the sheet
/// before running so the caller can open follow-up sheets or dialogs.
Future<void> showNaviSongMenu({
  required BuildContext context,
  required Song song,
  required List<NaviSongMenuEntry> entries,
  Widget? artwork,
}) => showNaviModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  enableDrag: false,
  builder: (sheetContext) {
    final height = MediaQuery.sizeOf(sheetContext).height;
    final estimated = (32 + 96 + entries.length * 56 + 16) / height;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: estimated.clamp(0.2, 0.82),
      minChildSize: 0.15,
      maxChildSize: 0.82,
      snap: true,
      snapSizes: [estimated.clamp(0.2, 0.82)],
      shouldCloseOnMinExtent: true,
      builder: (sheetContext, scrollController) => NaviModalSurface(
        child: ListView(
          controller: scrollController,
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: NaviSpacing.xs),
          children: [
            const NaviModalHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                NaviSpacing.page,
                NaviSpacing.xs,
                NaviSpacing.page,
                NaviSpacing.sm,
              ),
              child: Row(
                children: [
                  NaviArtwork(
                    coverArt: song.coverArt,
                    fallback: Icons.music_note_rounded,
                    size: 56,
                    child: artwork,
                  ),
                  const SizedBox(width: NaviSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(sheetContext).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          [
                            primaryArtistName(song.artist),
                            song.album,
                          ].where((value) => value.isNotEmpty).join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(sheetContext).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            for (final entry in entries)
              ListTile(
                key: entry.key,
                leading: Icon(
                  entry.icon,
                  color: entry.destructive ? NaviColors.destructive : null,
                ),
                title: Text(
                  entry.label,
                  style: entry.destructive
                      ? const TextStyle(color: NaviColors.destructive)
                      : null,
                ),
                subtitle: entry.subtitle == null ? null : Text(entry.subtitle!),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  entry.onTap();
                },
              ),
          ],
        ),
      ),
    );
  },
);
