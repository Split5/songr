import '../../domain/playback/playback_history_repository.dart';
import '../../models/models.dart';
import 'app_database.dart';

class DriftPlaybackHistoryRepository implements PlaybackHistoryRepository {
  const DriftPlaybackHistoryRepository(this.database);

  final AppDatabase database;

  @override
  Future<void> beginPlayback({
    required String playbackId,
    required String songId,
    required DateTime startedAt,
    required Duration duration,
  }) => database.beginPlayback(
    playbackId: playbackId,
    songId: songId,
    startedAt: startedAt,
    duration: duration,
  );

  @override
  Future<bool> markPlayed({required String playbackId, required DateTime at}) =>
      database.markPlaybackScrobbled(playbackId: playbackId, at: at);

  @override
  Future<void> completePlayback({
    required String playbackId,
    required DateTime at,
  }) => database.completePlayback(playbackId: playbackId, at: at);

  @override
  Future<void> endPlayback({
    required String playbackId,
    required DateTime at,
    bool skipped = false,
  }) => database.endPlayback(playbackId: playbackId, at: at, skipped: skipped);

  @override
  Stream<List<RecentlyPlayedSong>> watchRecentlyPlayed({int limit = 40}) =>
      database
          .watchRecentlyPlayed(limit: limit)
          .map(
            (rows) => rows
                .map(
                  (row) => RecentlyPlayedSong(
                    song: _mapSong(row.song),
                    playedAt: row.playedAt,
                    effectivePlayCount: row.effectivePlayCount,
                  ),
                )
                .toList(growable: false),
          );

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
