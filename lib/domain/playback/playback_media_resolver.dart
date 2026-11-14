import '../../models/models.dart';

class ResolvedPlaybackMedia {
  const ResolvedPlaybackMedia({
    required this.song,
    required this.uri,
    this.scrobbleSongId,
    this.localArtworkPath,
    this.localLyricsPath,
  });

  final Song song;
  final Uri uri;

  /// Server song id to scrobble, or null for local media from another account.
  final String? scrobbleSongId;
  final String? localArtworkPath;
  final String? localLyricsPath;
}

abstract interface class PlaybackMediaResolver {
  Future<ResolvedPlaybackMedia> resolve(String songId);
}
