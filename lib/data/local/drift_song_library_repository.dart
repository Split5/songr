import '../../domain/diagnostics/app_metrics.dart';
import '../../domain/library/song_filter.dart';
import '../../domain/library/song_library_repository.dart';
import '../../models/models.dart';
import 'app_database.dart';

class DriftSongLibraryRepository implements SongLibraryRepository {
  const DriftSongLibraryRepository(this.database);

  final AppDatabase database;

  @override
  Future<int> count(SongFilter filter) async {
    final stopwatch = Stopwatch()..start();
    try {
      final count = await database.filteredSongCount(filter);
      AppMetrics.duration('song_query_count', stopwatch.elapsed);
      return count;
    } catch (_) {
      AppMetrics.duration(
        'song_query_count',
        stopwatch.elapsed,
        success: false,
      );
      rethrow;
    }
  }

  @override
  Future<List<Song>> page({
    required SongFilter filter,
    required int limit,
    required int offset,
  }) async {
    final metric = filter.sort == SongSort.random
        ? 'song_query_random'
        : filter.query.isNotEmpty
        ? 'song_query_search'
        : 'song_query_page';
    final stopwatch = Stopwatch()..start();
    try {
      final songs = await database.filteredSongsPage(
        filter: filter,
        limit: limit,
        offset: offset,
      );
      AppMetrics.duration(metric, stopwatch.elapsed);
      return songs.map(_mapSong).toList(growable: false);
    } catch (_) {
      AppMetrics.duration(metric, stopwatch.elapsed, success: false);
      rethrow;
    }
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
