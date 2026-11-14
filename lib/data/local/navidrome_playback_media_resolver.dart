import 'dart:io';

import '../../api/subsonic_api.dart';
import '../../domain/playback/playback_media_resolver.dart';
import '../../models/models.dart';
import 'app_database.dart';

typedef LocalMediaPathResolver = String? Function(String songId);
typedef LocalSidecarPathResolver = String? Function(String songId);
typedef DataSaverBitRateResolver = int? Function(Song song);
typedef DownloadedMediaResolver =
    ResolvedPlaybackMedia? Function(String playbackKey);

class NavidromePlaybackMediaResolver implements PlaybackMediaResolver {
  const NavidromePlaybackMediaResolver({
    required this.database,
    required this.api,
    this.localPathFor,
    this.localArtworkPathFor,
    this.localLyricsPathFor,
    this.maximumBitRateFor,
    this.downloadedMediaResolver,
  });

  final AppDatabase database;
  final SubsonicApi api;
  final LocalMediaPathResolver? localPathFor;
  final LocalSidecarPathResolver? localArtworkPathFor;
  final LocalSidecarPathResolver? localLyricsPathFor;
  final DataSaverBitRateResolver? maximumBitRateFor;
  final DownloadedMediaResolver? downloadedMediaResolver;

  @override
  Future<ResolvedPlaybackMedia> resolve(String songId) async {
    if (songId.startsWith('download:')) {
      final downloaded = downloadedMediaResolver?.call(songId);
      if (downloaded == null) {
        throw StateError('Downloaded media is no longer available');
      }
      return downloaded;
    }
    final row = await (database.select(
      database.localSongs,
    )..where((song) => song.id.equals(songId))).getSingleOrNull();
    if (row == null) {
      throw StateError('Song $songId is not in the local library');
    }
    final song = _mapSong(row);
    final localPath = localPathFor?.call(songId);
    final uri = localPath != null && File(localPath).existsSync()
        ? Uri.file(localPath)
        : api.streamUri(songId, maxBitRate: maximumBitRateFor?.call(song));
    return ResolvedPlaybackMedia(
      song: song,
      uri: uri,
      scrobbleSongId: song.id,
      localArtworkPath: localArtworkPathFor?.call(songId),
      localLyricsPath: localLyricsPathFor?.call(songId),
    );
  }

  Song _mapSong(LocalSong song) => Song(
    id: song.id,
    title: song.title,
    artist: song.artist,
    artistId: song.artistId ?? '',
    album: song.album,
    albumId: song.albumId ?? '',
    coverArt: song.coverArt,
    duration: song.duration,
    playCount: song.playCount,
    year: song.year,
    bitRate: song.bitRate ?? 0,
    bitDepth: song.bitDepth ?? 0,
    samplingRate: song.samplingRate ?? 0,
    fileSize: song.fileSize ?? 0,
    track: song.track,
    disc: song.disc,
    suffix: song.suffix ?? '',
    contentType: song.contentType,
    created: song.createdAt,
    lastPlayed: song.lastPlayedAt,
    genre: song.genre,
    starred: song.starred,
    starredAt: song.starredAt,
  );
}
