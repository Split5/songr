import 'dart:async';

import 'package:drift/drift.dart';

import '../../api/subsonic_api.dart';
import '../../data/local/app_database.dart';
import '../../models/models.dart';
import 'library_sync_progress.dart';

abstract interface class NavidromeCatalogGateway {
  Future<List<ArtistSummary>> fetchArtistPage({
    required int offset,
    required int limit,
  });

  Future<List<Album>> fetchAlbumPage({required int offset, required int limit});

  Future<List<Playlist>> fetchPlaylists();
  Future<List<Song>> fetchPlaylistSongs(String playlistId);
}

class SubsonicCatalogGateway implements NavidromeCatalogGateway {
  const SubsonicCatalogGateway(this.api);

  final SubsonicApi api;

  @override
  Future<List<ArtistSummary>> fetchArtistPage({
    required int offset,
    required int limit,
  }) async => (await api.search3(
    '',
    artistCount: limit,
    artistOffset: offset,
    albumCount: 0,
    songCount: 0,
  )).artists;

  @override
  Future<List<Album>> fetchAlbumPage({
    required int offset,
    required int limit,
  }) async => (await api.search3(
    '',
    artistCount: 0,
    albumCount: limit,
    albumOffset: offset,
    songCount: 0,
  )).albums;

  @override
  Future<List<Playlist>> fetchPlaylists() => api.getPlaylists();

  @override
  Future<List<Song>> fetchPlaylistSongs(String playlistId) =>
      api.getPlaylist(playlistId);
}

class CatalogSyncReport {
  const CatalogSyncReport({
    required this.artistCount,
    required this.albumCount,
    required this.playlistCount,
    required this.playlistEntryCount,
    required this.completedAt,
  });

  final int artistCount;
  final int albumCount;
  final int playlistCount;
  final int playlistEntryCount;
  final DateTime completedAt;
}

/// Atomically refreshes every non-song catalogue scope. A failed scope keeps
/// its previous local snapshot and does not affect the already synced scopes.
class CatalogSyncService {
  CatalogSyncService({
    required this.database,
    required this.gateway,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  static const artistsScope = 'artists';
  static const albumsScope = 'albums';
  static const playlistsScope = 'playlists';

  final AppDatabase database;
  final NavidromeCatalogGateway gateway;
  final DateTime Function() _clock;
  Future<void> _playlistSyncTail = Future.value();

  Future<CatalogSyncReport> syncAll({
    int pageSize = 500,
    int maxPages = 1000,
    LibrarySyncProgressCallback? onProgress,
  }) async {
    _validatePageSize(pageSize);
    final artistCount = await _syncArtists(
      pageSize,
      maxPages: maxPages,
      onProgress: onProgress,
    );
    final albumCount = await _syncAlbums(
      pageSize,
      maxPages: maxPages,
      onProgress: onProgress,
    );
    final playlistResult = await _serializePlaylistSync(
      () => _syncPlaylists(onProgress: onProgress),
    );
    return CatalogSyncReport(
      artistCount: artistCount,
      albumCount: albumCount,
      playlistCount: playlistResult.$1,
      playlistEntryCount: playlistResult.$2,
      completedAt: _clock(),
    );
  }

  Future<(int, int)> syncPlaylists() => _serializePlaylistSync(_syncPlaylists);

  Future<int> _syncArtists(
    int pageSize, {
    required int maxPages,
    LibrarySyncProgressCallback? onProgress,
  }) async {
    if (maxPages < 1) {
      throw ArgumentError.value(maxPages, 'maxPages', 'must be positive');
    }
    await database.beginArtistStaging();
    var offset = 0;
    var pageCount = 0;
    var processed = 0;
    try {
      onProgress?.call(const LibrarySyncProgress(LibrarySyncStage.artists));
      while (true) {
        final page = await gateway.fetchArtistPage(
          offset: offset,
          limit: pageSize,
        );
        pageCount++;
        await database.stageArtists(page.map(_artistCompanion));
        processed += page.length;
        onProgress?.call(
          LibrarySyncProgress(LibrarySyncStage.artists, processed: processed),
        );
        if (page.length < pageSize) break;
        if (pageCount >= maxPages) {
          throw StateError('Artist sync exceeded $maxPages pages');
        }
        offset += pageSize;
      }
      final count = await database.stagedArtistCount();
      await database.commitStagedArtists();
      await database.recordSyncSuccess(artistsScope, _clock());
      return count;
    } catch (error) {
      await database.discardStagedArtists();
      await database.recordSyncFailure(artistsScope, error);
      rethrow;
    }
  }

  Future<int> _syncAlbums(
    int pageSize, {
    required int maxPages,
    LibrarySyncProgressCallback? onProgress,
  }) async {
    if (maxPages < 1) {
      throw ArgumentError.value(maxPages, 'maxPages', 'must be positive');
    }
    await database.beginAlbumStaging();
    var offset = 0;
    var pageCount = 0;
    var processed = 0;
    try {
      onProgress?.call(const LibrarySyncProgress(LibrarySyncStage.albums));
      while (true) {
        final page = await gateway.fetchAlbumPage(
          offset: offset,
          limit: pageSize,
        );
        pageCount++;
        await database.stageAlbums(page.map(_albumCompanion));
        processed += page.length;
        onProgress?.call(
          LibrarySyncProgress(LibrarySyncStage.albums, processed: processed),
        );
        if (page.length < pageSize) break;
        if (pageCount >= maxPages) {
          throw StateError('Album sync exceeded $maxPages pages');
        }
        offset += pageSize;
      }
      final count = await database.stagedAlbumCount();
      await database.commitStagedAlbums();
      await database.recordSyncSuccess(albumsScope, _clock());
      return count;
    } catch (error) {
      await database.discardStagedAlbums();
      await database.recordSyncFailure(albumsScope, error);
      rethrow;
    }
  }

  Future<(int, int)> _syncPlaylists({
    LibrarySyncProgressCallback? onProgress,
  }) async {
    await database.beginPlaylistStaging();
    var entryCount = 0;
    try {
      onProgress?.call(const LibrarySyncProgress(LibrarySyncStage.playlists));
      final playlists = await gateway.fetchPlaylists();
      final owned = playlists
          .where((playlist) => !_isGenerated(playlist))
          .toList();
      var processed = 0;
      onProgress?.call(
        LibrarySyncProgress(LibrarySyncStage.playlists, total: owned.length),
      );
      await database.stagePlaylists(owned.map(_playlistCompanion));
      // Deliberately sequential: a server can return hundreds of generated
      // playlists, and unbounded getPlaylist calls previously froze the app.
      for (final playlist in owned) {
        final songs = await gateway.fetchPlaylistSongs(playlist.id);
        entryCount += songs.length;
        await database.stagePlaylistEntries([
          for (var index = 0; index < songs.length; index++)
            StagedPlaylistEntriesCompanion.insert(
              playlistId: playlist.id,
              songId: songs[index].id,
              position: index,
            ),
        ]);
        processed++;
        onProgress?.call(
          LibrarySyncProgress(
            LibrarySyncStage.playlists,
            processed: processed,
            total: owned.length,
          ),
        );
      }
      await database.commitStagedPlaylists();
      await database.recordSyncSuccess(playlistsScope, _clock());
      return (owned.length, entryCount);
    } catch (error) {
      await database.discardStagedPlaylists();
      await database.recordSyncFailure(playlistsScope, error);
      rethrow;
    }
  }

  StagedArtistsCompanion _artistCompanion(ArtistSummary artist) =>
      StagedArtistsCompanion.insert(
        id: artist.id,
        name: artist.name,
        sortName: Value(primaryArtistName(artist.name)),
        coverArt: Value(_nonEmpty(artist.coverArt)),
        albumCount: Value(artist.albumCount),
        starred: Value(artist.starred),
        updatedAt: Value(_clock()),
      );

  StagedAlbumsCompanion _albumCompanion(Album album) =>
      StagedAlbumsCompanion.insert(
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
        updatedAt: Value(_clock()),
      );

  StagedPlaylistsCompanion _playlistCompanion(Playlist playlist) {
    return StagedPlaylistsCompanion.insert(
      id: playlist.id,
      name: playlist.name,
      coverArt: Value(_nonEmpty(playlist.coverArt)),
      songCount: Value(playlist.songCount),
      duration: Value(playlist.duration),
      serverReadOnly: Value(playlist.readonly),
      owner: Value(playlist.owner),
      isPublic: Value(playlist.isPublic),
      isGenerated: const Value(false),
      changedAt: Value(playlist.changed),
    );
  }

  bool _isGenerated(Playlist playlist) =>
      playlist.readonly ||
      playlist.name.trim().toLowerCase().endsWith('_automatic');

  Future<T> _serializePlaylistSync<T>(Future<T> Function() operation) {
    final result = Completer<T>();
    _playlistSyncTail = _playlistSyncTail.then((_) async {
      try {
        result.complete(await operation());
      } catch (error, stackTrace) {
        result.completeError(error, stackTrace);
      }
    });
    return result.future;
  }

  void _validatePageSize(int pageSize) {
    if (pageSize < 1 || pageSize > 500) {
      throw ArgumentError.value(pageSize, 'pageSize', 'must be 1 to 500');
    }
  }

  String? _nonEmpty(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
