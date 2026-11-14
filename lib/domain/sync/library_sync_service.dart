import 'package:drift/drift.dart';

import '../../api/subsonic_api.dart';
import '../../data/local/app_database.dart';
import '../../models/models.dart';
import 'library_sync_progress.dart';

/// Small boundary around the one Navidrome operation required by a full song
/// sync. Keeping it separate makes network failure and pagination testable
/// without a real server.
abstract interface class NavidromeSongGateway {
  Future<List<Song>> fetchSongPage({required int offset, required int limit});
}

class SubsonicSongGateway implements NavidromeSongGateway {
  const SubsonicSongGateway(this.api);

  final SubsonicApi api;

  @override
  Future<List<Song>> fetchSongPage({
    required int offset,
    required int limit,
  }) async {
    final result = await api.search3(
      '',
      artistCount: 0,
      albumCount: 0,
      songCount: limit,
      songOffset: offset,
    );
    return result.songs;
  }
}

class SongSyncReport {
  const SongSyncReport({
    required this.songCount,
    required this.pageCount,
    required this.completedAt,
  });

  final int songCount;
  final int pageCount;
  final DateTime completedAt;
}

/// Synchronizes the complete Navidrome song catalogue into the local database.
///
/// Pages are written to an invisible staging table. The last known-good local
/// snapshot is replaced in one SQLite transaction only after the final page
/// arrives. An interrupted sync therefore cannot blank or partially update the
/// offline library.
class LibrarySyncService {
  LibrarySyncService({
    required this.database,
    required this.gateway,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  static const songsScope = 'songs';

  final AppDatabase database;
  final NavidromeSongGateway gateway;
  final DateTime Function() _clock;

  Future<SongSyncReport> syncSongs({
    int pageSize = 500,
    int maxPages = 1000,
    LibrarySyncProgressCallback? onProgress,
  }) async {
    if (pageSize < 1 || pageSize > 500) {
      throw ArgumentError.value(pageSize, 'pageSize', 'must be 1 to 500');
    }
    if (maxPages < 1) {
      throw ArgumentError.value(maxPages, 'maxPages', 'must be positive');
    }

    await database.beginSongStaging();
    var offset = 0;
    var pageCount = 0;
    var processed = 0;

    try {
      onProgress?.call(const LibrarySyncProgress(LibrarySyncStage.songs));
      while (true) {
        final songs = await gateway.fetchSongPage(
          offset: offset,
          limit: pageSize,
        );
        pageCount++;
        await database.stageSongs(songs.map(_toStagedSong));
        processed += songs.length;
        onProgress?.call(
          LibrarySyncProgress(LibrarySyncStage.songs, processed: processed),
        );

        if (songs.length < pageSize) break;
        if (pageCount >= maxPages) {
          throw StateError('Song sync exceeded $maxPages pages');
        }
        offset += pageSize;
      }

      final songCount = await database.stagedSongCount();
      await database.commitStagedSongs();
      final completedAt = _clock();
      await database.recordSyncSuccess(songsScope, completedAt);
      return SongSyncReport(
        songCount: songCount,
        pageCount: pageCount,
        completedAt: completedAt,
      );
    } catch (error) {
      await database.discardStagedSongs();
      await database.recordSyncFailure(songsScope, error);
      rethrow;
    }
  }

  StagedSongsCompanion _toStagedSong(Song song) => StagedSongsCompanion.insert(
    id: song.id,
    title: song.title,
    albumId: Value(_nonEmptyOrNull(song.albumId)),
    album: song.album,
    artistId: Value(_nonEmptyOrNull(song.artistId)),
    artist: song.artist,
    canonicalArtist: Value(primaryArtistName(song.artist)),
    track: Value(song.track),
    disc: Value(song.disc),
    year: Value(song.year),
    genre: Value(_nonEmptyOrNull(song.genre)),
    duration: Value(song.duration),
    bitRate: Value(song.bitRate > 0 ? song.bitRate : null),
    bitDepth: Value(song.bitDepth > 0 ? song.bitDepth : null),
    samplingRate: Value(song.samplingRate > 0 ? song.samplingRate : null),
    suffix: Value(_nonEmptyOrNull(song.suffix)),
    contentType: Value(_nonEmptyOrNull(song.contentType)),
    fileSize: Value(song.fileSize > 0 ? song.fileSize : null),
    coverArt: Value(_nonEmptyOrNull(song.coverArt)),
    playCount: Value(song.playCount),
    starred: Value(song.starred),
    starredAt: Value(song.starredAt),
    createdAt: Value(song.created),
    lastPlayedAt: Value(song.lastPlayed),
    updatedAt: Value(_clock()),
  );

  String? _nonEmptyOrNull(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
