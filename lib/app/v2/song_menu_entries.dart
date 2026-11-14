import 'package:flutter/material.dart';

import '../../design_system/widgets/navi_widgets.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';

/// What the composition root does when a song-menu entry is chosen. Plain
/// callbacks keep [songMenuEntries] a pure function a unit test can drive.
class SongMenuActions {
  const SongMenuActions({
    required this.toggleFavorite,
    required this.playNext,
    required this.addToQueue,
    required this.addToPlaylist,
    required this.addToLastPlaylist,
    required this.goToAlbum,
    required this.goToArtist,
    required this.createMix,
    required this.createSimilarPlaylist,
    required this.download,
    required this.removeDownload,
    required this.share,
    this.removeFromPlaylist,
  });

  final VoidCallback toggleFavorite;
  final VoidCallback playNext;
  final VoidCallback addToQueue;

  /// Opens the playlist picker.
  final VoidCallback addToPlaylist;

  /// Adds straight to the last-used playlist handed in.
  final ValueChanged<Playlist> addToLastPlaylist;
  final VoidCallback goToAlbum;
  final VoidCallback goToArtist;
  final VoidCallback? createMix;
  final VoidCallback? createSimilarPlaylist;
  final VoidCallback download;
  final VoidCallback removeDownload;
  final VoidCallback share;

  /// Only set when the menu was opened from inside a playlist.
  final VoidCallback? removeFromPlaylist;
}

/// The song menu superset in its fixed order: favorite · play next · add to
/// queue · add to playlist · add to the last-used playlist · go to album ·
/// go to artist · create mix · playlist of similar songs · download · share ·
/// remove from playlist. Entries without a target (no album or artist id,
/// no last playlist, not inside a playlist) are left out.
List<NaviSongMenuEntry> songMenuEntries({
  required AppLocalizations l,
  required Song song,
  required bool downloaded,
  required SongMenuActions actions,
  Playlist? lastPlaylist,
}) => [
  NaviSongMenuEntry(
    icon: song.starred ? Icons.favorite_rounded : Icons.favorite_border,
    label: song.starred ? l.removeFavorite : l.favorite,
    onTap: actions.toggleFavorite,
  ),
  NaviSongMenuEntry(
    icon: Icons.queue_play_next_rounded,
    label: l.playNext,
    onTap: actions.playNext,
  ),
  NaviSongMenuEntry(
    icon: Icons.playlist_play_rounded,
    label: l.addToQueue,
    onTap: actions.addToQueue,
  ),
  NaviSongMenuEntry(
    icon: Icons.playlist_add_rounded,
    label: l.addToPlaylist,
    onTap: actions.addToPlaylist,
  ),
  if (lastPlaylist != null)
    NaviSongMenuEntry(
      icon: Icons.playlist_add_check_rounded,
      label: l.addToNamedPlaylist(lastPlaylist.name),
      subtitle: l.lastUsedPlaylist,
      onTap: () => actions.addToLastPlaylist(lastPlaylist),
    ),
  if (song.albumId.isNotEmpty)
    NaviSongMenuEntry(
      icon: Icons.album_rounded,
      label: l.goToAlbum,
      onTap: actions.goToAlbum,
    ),
  if (song.artistId.isNotEmpty)
    NaviSongMenuEntry(
      icon: Icons.person_rounded,
      label: l.goToArtist,
      onTap: actions.goToArtist,
    ),
  if (actions.createMix case final createMix?)
    NaviSongMenuEntry(
      icon: Icons.sensors_rounded,
      label: l.createMixFromSong,
      subtitle: l.navidromeSimilarSongs,
      onTap: createMix,
    ),
  if (actions.createSimilarPlaylist case final createSimilarPlaylist?)
    NaviSongMenuEntry(
      icon: Icons.auto_awesome_rounded,
      label: l.createSimilarPlaylist,
      onTap: createSimilarPlaylist,
    ),
  NaviSongMenuEntry(
    icon: downloaded ? Icons.download_done_rounded : Icons.download_rounded,
    label: downloaded ? l.removeDownload : l.download,
    onTap: downloaded ? actions.removeDownload : actions.download,
  ),
  NaviSongMenuEntry(
    icon: Icons.ios_share_rounded,
    label: l.share,
    onTap: actions.share,
  ),
  if (actions.removeFromPlaylist case final removeFromPlaylist?)
    NaviSongMenuEntry(
      icon: Icons.playlist_remove_rounded,
      label: l.removeFromPlaylistAction,
      destructive: true,
      onTap: removeFromPlaylist,
    ),
];
