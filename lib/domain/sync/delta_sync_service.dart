import 'package:drift/drift.dart';

import '../../api/subsonic_api.dart';
import '../../data/local/app_database.dart';
import '../../models/models.dart';

/// Boundary around the two cheap Navidrome calls an incremental refresh needs.
abstract interface class NavidromeDeltaGateway {
  Future<List<Album>> fetchNewestAlbums({required int limit});
  Future<List<Song>> fetchAlbumSongs(String albumId);
}

class SubsonicDeltaGateway implements NavidromeDeltaGateway {
  const SubsonicDeltaGateway(this.api);

  final SubsonicApi api;

  @override
  Future<List<Album>> fetchNewestAlbums({required int limit}) =>
      api.getAlbumList2(size: limit);

  @override
  Future<List<Song>> fetchAlbumSongs(String albumId) =>
      api.getAlbumSongs(albumId);
}

class DeltaSyncReport {
  const DeltaSyncReport({
    required this.albumCount,
    required this.songCount,
    required this.completedAt,
  });

  final int albumCount;
  final int songCount;
  final DateTime completedAt;
}

/// Incremental refresh of the local mirror.
///
/// A full catalogue sync pages the entire library. On a 30 000 track
/// collection that is dozens of requests, so doing it on every pull-to-refresh
/// would be both slow and rude to the server. This service asks Navidrome only
/// for the newest albums, then fetches tracks for the albums that appeared
/// since the previous successful run.
///
/// Reading stays local: filtering, sorting and search continue to query the
/// Drift mirror, so library size does not change how a query performs. Delta
/// runs cannot detect deletions; [LibrarySyncService] still owns the full
/// reconciliation that removes tracks deleted on the server.
class DeltaSyncService {
  DeltaSyncService({
    required this.database,
    required this.gateway,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  static const scope = 'songs.delta';

  final AppDatabase database;
  final NavidromeDeltaGateway gateway;
  final DateTime Function() _clock;

  Future<DeltaSyncReport> syncRecent({int albumLimit = 50}) async {
    if (albumLimit < 1 || albumLimit > 500) {
      throw ArgumentError.value(albumLimit, 'albumLimit', 'must be 1 to 500');
    }
    try {
      final watermark = await database.lastSuccessAt(scope);
      final albums = await gateway.fetchNewestAlbums(limit: albumLimit);
      final changed = albums
          .where((album) {
            final created = album.created;
            return watermark == null ||
                created == null ||
                !created.isBefore(watermark);
          })
          .toList(growable: false);

      final now = _clock();
      var songCount = 0;
      if (changed.isNotEmpty) {
        await database.upsertAlbums(
          changed.map((album) => _albumCompanion(album, now)),
        );
        for (final album in changed) {
          final songs = await gateway.fetchAlbumSongs(album.id);
          if (songs.isEmpty) continue;
          await database.upsertSongs(
            songs.map((song) => _songCompanion(song, now)),
          );
          songCount += songs.length;
        }
      }
      await database.recordSyncSuccess(scope, now);
      return DeltaSyncReport(
        albumCount: changed.length,
        songCount: songCount,
        completedAt: now,
      );
    } catch (error) {
      await database.recordSyncFailure(scope, error);
      rethrow;
    }
  }

  LocalAlbumsCompanion _albumCompanion(Album album, DateTime now) =>
      LocalAlbumsCompanion.insert(
        id: album.id,
        name: album.name,
        artistId: Value(_nonEmpty(album.artistId)),
        artist: album.artist,
        canonicalArtist: Value(primaryArtistName(album.artist)),
        year: Value(album.year),
        songCount: Value(album.songCount),
        duration: Value(album.duration),
        playCount: Value(album.playCount),
        coverArt: Value(_nonEmpty(album.coverArt)),
        starred: Value(album.starred),
        createdAt: Value(album.created),
        updatedAt: Value(now),
      );

  LocalSongsCompanion _songCompanion(Song song, DateTime now) =>
      LocalSongsCompanion.insert(
        id: song.id,
        title: song.title,
        albumId: Value(_nonEmpty(song.albumId)),
        album: song.album,
        artistId: Value(_nonEmpty(song.artistId)),
        artist: song.artist,
        canonicalArtist: Value(primaryArtistName(song.artist)),
        track: Value(song.track),
        disc: Value(song.disc),
        year: Value(song.year),
        genre: Value(_nonEmpty(song.genre)),
        duration: Value(song.duration),
        bitRate: Value(song.bitRate > 0 ? song.bitRate : null),
        bitDepth: Value(song.bitDepth > 0 ? song.bitDepth : null),
        samplingRate: Value(song.samplingRate > 0 ? song.samplingRate : null),
        suffix: Value(_nonEmpty(song.suffix)),
        contentType: Value(_nonEmpty(song.contentType)),
        fileSize: Value(song.fileSize > 0 ? song.fileSize : null),
        coverArt: Value(_nonEmpty(song.coverArt)),
        playCount: Value(song.playCount),
        starred: Value(song.starred),
        starredAt: Value(song.starredAt),
        createdAt: Value(song.created),
        lastPlayedAt: Value(song.lastPlayed),
        updatedAt: Value(now),
      );

  String? _nonEmpty(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
