import '../../models/models.dart';

/// Places the last-used playlist first for fast repeated additions while
/// keeping every other playlist predictably alphabetical.
List<Playlist> prioritizeLastPlaylist(
  Iterable<Playlist> playlists,
  String? lastPlaylistId,
) {
  final ordered = List<Playlist>.of(playlists);
  ordered.sort((a, b) {
    if (a.id == lastPlaylistId && b.id != lastPlaylistId) return -1;
    if (b.id == lastPlaylistId && a.id != lastPlaylistId) return 1;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });
  return List.unmodifiable(ordered);
}
