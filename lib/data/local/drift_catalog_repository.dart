import 'package:drift/drift.dart';

import '../../domain/library/catalog_repository.dart';
import '../../models/models.dart';
import 'app_database.dart';

class DriftCatalogRepository implements CatalogRepository {
  const DriftCatalogRepository(this.database);

  final AppDatabase database;

  @override
  Future<int> artistCount({String query = ''}) async {
    final normalized = query.trim().toLowerCase();
    final row = await database
        .customSelect(
          '''
      SELECT COUNT(*) AS result_count FROM (
        SELECT 1 FROM local_artists
        WHERE ? = '' OR lower(COALESCE(NULLIF(sort_name, ''), name)) LIKE ?
        GROUP BY lower(COALESCE(NULLIF(sort_name, ''), name))
      )
      ''',
          variables: [Variable(normalized), Variable('%$normalized%')],
          readsFrom: {database.localArtists},
        )
        .getSingle();
    return row.read<int>('result_count');
  }

  @override
  Future<List<ArtistSummary>> artistsPage({
    String query = '',
    int limit = 60,
    int offset = 0,
    ArtistSort sort = ArtistSort.name,
    int randomSeed = 0,
  }) async {
    final normalized = query.trim().toLowerCase();
    final orderBy = switch (sort) {
      ArtistSort.name => 'canonical_name COLLATE NOCASE',
      ArtistSort.albumCount =>
        'album_count DESC, canonical_name COLLATE NOCASE',
      ArtistSort.random =>
        '(((length(canonical_name) * 1103515245 + '
            'COALESCE(unicode(substr(canonical_name, 1, 1)), 0) * 12345 + '
            'COALESCE(unicode(substr(canonical_name, 2, 1)), 0) * 6789 + '
            '${randomSeed.abs()} * 48271) * 1664525 + 1013904223) '
            '% 2147483647), canonical_name COLLATE NOCASE',
    };
    final rows = await database
        .customSelect(
          '''
      SELECT
        MIN(id) AS id,
        COALESCE(NULLIF(sort_name, ''), name) AS canonical_name,
        MAX(cover_art) AS cover_art,
        MAX(album_count) AS album_count,
        MAX(CASE WHEN starred THEN 1 ELSE 0 END) AS starred
      FROM local_artists
      WHERE ? = '' OR lower(COALESCE(NULLIF(sort_name, ''), name)) LIKE ?
      GROUP BY lower(COALESCE(NULLIF(sort_name, ''), name))
      ORDER BY $orderBy
      LIMIT ? OFFSET ?
      ''',
          variables: [
            Variable(normalized),
            Variable('%$normalized%'),
            Variable(limit.clamp(1, 200)),
            Variable(offset < 0 ? 0 : offset),
          ],
          readsFrom: {database.localArtists},
        )
        .get();
    return rows
        .map(
          (row) => ArtistSummary(
            id: row.read<String>('id'),
            name: row.read<String>('canonical_name'),
            coverArt: row.readNullable<String>('cover_art'),
            albumCount: row.read<int>('album_count'),
            starred: row.read<int>('starred') != 0,
          ),
        )
        .toList(growable: false);
  }

  /// Canonical, explicitly starred artists. Collaboration variants remain
  /// collapsed exactly like the main artist browser.
  Future<List<ArtistSummary>> starredArtists({int limit = 500}) async {
    final rows = await database
        .customSelect(
          '''
      SELECT
        MIN(id) AS id,
        COALESCE(NULLIF(sort_name, ''), name) AS canonical_name,
        MAX(cover_art) AS cover_art,
        MAX(album_count) AS album_count,
        MAX(CASE WHEN starred THEN 1 ELSE 0 END) AS starred
      FROM local_artists
      GROUP BY lower(COALESCE(NULLIF(sort_name, ''), name))
      HAVING MAX(CASE WHEN starred THEN 1 ELSE 0 END) = 1
      ORDER BY canonical_name COLLATE NOCASE
      LIMIT ?
      ''',
          variables: [Variable(limit.clamp(1, 2000))],
          readsFrom: {database.localArtists},
        )
        .get();
    return rows
        .map(
          (row) => ArtistSummary(
            id: row.read<String>('id'),
            name: row.read<String>('canonical_name'),
            coverArt: row.readNullable<String>('cover_art'),
            albumCount: row.read<int>('album_count'),
            starred: true,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<int> albumCount({String query = ''}) async {
    final normalized = query.trim().toLowerCase();
    final row = await database
        .customSelect(
          '''
      SELECT COUNT(*) AS result_count FROM (
        SELECT 1 FROM local_albums
        WHERE ? = '' OR lower(name) LIKE ? OR lower(canonical_artist) LIKE ?
        GROUP BY lower(name), lower(canonical_artist)
      )
      ''',
          variables: [
            Variable(normalized),
            Variable('%$normalized%'),
            Variable('%$normalized%'),
          ],
          readsFrom: {database.localAlbums},
        )
        .getSingle();
    return row.read<int>('result_count');
  }

  @override
  Future<List<Album>> albumsPage({
    String query = '',
    int limit = 60,
    int offset = 0,
    bool newestFirst = false,
    AlbumSort sort = AlbumSort.title,
    int randomSeed = 0,
  }) async {
    final normalized = query.trim().toLowerCase();
    final effectiveSort = newestFirst && sort == AlbumSort.title
        ? AlbumSort.recentlyAdded
        : sort;
    final orderBy = switch (effectiveSort) {
      AlbumSort.title => 'name COLLATE NOCASE, canonical_artist COLLATE NOCASE',
      AlbumSort.artist =>
        'canonical_artist COLLATE NOCASE, name COLLATE NOCASE',
      AlbumSort.recentlyAdded => 'created_at DESC, name COLLATE NOCASE',
      AlbumSort.recentlyPlayed =>
        'COALESCE((SELECT MAX(COALESCE(activity.last_played_at, song.last_played_at)) '
            'FROM local_songs AS song '
            'LEFT JOIN local_song_activities AS activity '
            'ON activity.song_id = song.id '
            'WHERE song.album_id = local_albums.id), 0) DESC, '
            'name COLLATE NOCASE',
      AlbumSort.mostPlayed => 'play_count DESC, name COLLATE NOCASE',
      AlbumSort.random =>
        '(((length(name) * 1103515245 + '
            'COALESCE(unicode(substr(name, 1, 1)), 0) * 12345 + '
            'COALESCE(unicode(substr(canonical_artist, 1, 1)), 0) * 6789 + '
            '${randomSeed.abs()} * 48271) * 1664525 + 1013904223) '
            '% 2147483647), name COLLATE NOCASE',
    };
    final rows = await database
        .customSelect(
          '''
      SELECT
        MIN(id) AS id,
        name,
        MIN(artist_id) AS artist_id,
        canonical_artist,
        MAX(year) AS year,
        SUM(song_count) AS song_count,
        SUM(duration) AS duration,
        MAX(play_count) AS play_count,
        MAX(cover_art) AS cover_art,
        MAX(CASE WHEN starred THEN 1 ELSE 0 END) AS starred,
        MAX(created_at) AS created_at
      FROM local_albums
      WHERE ? = '' OR lower(name) LIKE ? OR lower(canonical_artist) LIKE ?
      GROUP BY lower(name), lower(canonical_artist)
      ORDER BY $orderBy
      LIMIT ? OFFSET ?
      ''',
          variables: [
            Variable(normalized),
            Variable('%$normalized%'),
            Variable('%$normalized%'),
            Variable(limit.clamp(1, 200)),
            Variable(offset < 0 ? 0 : offset),
          ],
          readsFrom: {database.localAlbums},
        )
        .get();
    return rows
        .map(
          (row) => Album(
            id: row.read<String>('id'),
            name: row.read<String>('name'),
            artist: row.read<String>('canonical_artist'),
            artistId: row.readNullable<String>('artist_id') ?? '',
            year: row.read<int>('year'),
            songCount: row.read<int>('song_count'),
            duration: row.read<int>('duration'),
            playCount: row.read<int>('play_count'),
            coverArt: row.readNullable<String>('cover_art'),
            starred: row.read<int>('starred') != 0,
            created: row.readNullable<DateTime>('created_at'),
          ),
        )
        .toList(growable: false);
  }

  /// Canonical, explicitly starred albums. A starred collaboration variant
  /// keeps the complete merged album represented in the Favorites browser.
  Future<List<Album>> starredAlbums({int limit = 500}) async {
    final rows = await database
        .customSelect(
          '''
      SELECT
        MIN(id) AS id,
        name,
        MIN(artist_id) AS artist_id,
        canonical_artist,
        MAX(year) AS year,
        SUM(song_count) AS song_count,
        SUM(duration) AS duration,
        MAX(play_count) AS play_count,
        MAX(cover_art) AS cover_art,
        MAX(CASE WHEN starred THEN 1 ELSE 0 END) AS starred,
        MAX(created_at) AS created_at
      FROM local_albums
      GROUP BY lower(name), lower(canonical_artist)
      HAVING MAX(CASE WHEN starred THEN 1 ELSE 0 END) = 1
      ORDER BY name COLLATE NOCASE, canonical_artist COLLATE NOCASE
      LIMIT ?
      ''',
          variables: [Variable(limit.clamp(1, 2000))],
          readsFrom: {database.localAlbums},
        )
        .get();
    return rows
        .map(
          (row) => Album(
            id: row.read<String>('id'),
            name: row.read<String>('name'),
            artist: row.read<String>('canonical_artist'),
            artistId: row.readNullable<String>('artist_id') ?? '',
            year: row.read<int>('year'),
            songCount: row.read<int>('song_count'),
            duration: row.read<int>('duration'),
            playCount: row.read<int>('play_count'),
            coverArt: row.readNullable<String>('cover_art'),
            starred: true,
            created: row.readNullable<DateTime>('created_at'),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<Playlist>> ownPlaylists() async {
    final rows =
        await (database.select(database.localPlaylists)
              ..where(
                (row) =>
                    row.isGenerated.equals(false) &
                    row.serverReadOnly.equals(false),
              )
              ..orderBy([
                (row) => OrderingTerm.asc(row.name.collate(Collate.noCase)),
              ]))
            .get();
    return rows
        .map(
          (row) => Playlist(
            id: row.id,
            name: row.name,
            songCount: row.songCount,
            duration: row.duration,
            coverArt: row.coverArt,
            owner: row.owner,
            readonly: row.serverReadOnly,
            isPublic: row.isPublic,
            changed: row.changedAt,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<String>> genres({int limit = 24}) async {
    final rows = await database
        .customSelect(
          '''
      SELECT genre, COUNT(*) AS song_count
      FROM local_songs
      WHERE genre IS NOT NULL AND trim(genre) != ''
      GROUP BY lower(trim(genre))
      ORDER BY song_count DESC, genre COLLATE NOCASE
      LIMIT ?
      ''',
          variables: [Variable(limit.clamp(1, 100))],
          readsFrom: {database.localSongs},
        )
        .get();
    return rows.map((row) => row.read<String>('genre')).toList(growable: false);
  }

  @override
  Future<List<Song>> songsForAlbum(Album album) async {
    final albumName = album.name.trim().toLowerCase();
    final artistName = album.artist.trim().toLowerCase();
    return (await (database.select(database.localSongs)
              ..where((row) {
                final byAlbumId = row.albumId.equals(album.id);
                final byNameAndArtist =
                    row.album.lower().equals(albumName) &
                    (row.canonicalArtist.lower().equals(artistName) |
                        row.artist.lower().equals(artistName));
                final byNameOnly = artistName.isEmpty
                    ? row.album.lower().equals(albumName)
                    : const Constant(false);
                return byAlbumId | byNameAndArtist | byNameOnly;
              })
              ..orderBy([
                (row) => OrderingTerm.asc(row.disc),
                (row) => OrderingTerm.asc(row.track),
                (row) => OrderingTerm.asc(row.title.collate(Collate.noCase)),
              ]))
            .get())
        .map(_mapSong)
        .toList(growable: false);
  }

  @override
  Future<List<Song>> songsForArtist(ArtistSummary artist) async =>
      (await (database.select(database.localSongs)
                ..where(
                  (row) => row.canonicalArtist.lower().equals(
                    artist.name.toLowerCase(),
                  ),
                )
                ..orderBy([
                  (row) => OrderingTerm.desc(row.year),
                  (row) => OrderingTerm.asc(row.album.collate(Collate.noCase)),
                  (row) => OrderingTerm.asc(row.disc),
                  (row) => OrderingTerm.asc(row.track),
                ]))
              .get())
          .map(_mapSong)
          .toList(growable: false);

  @override
  Future<List<Album>> albumsForArtist(ArtistSummary artist) async {
    final normalized = artist.name.trim().toLowerCase();
    final rows = await database
        .customSelect(
          '''
      SELECT
        MIN(id) AS id,
        name,
        MIN(artist_id) AS artist_id,
        canonical_artist,
        MAX(year) AS year,
        SUM(song_count) AS song_count,
        SUM(duration) AS duration,
        MAX(play_count) AS play_count,
        MAX(cover_art) AS cover_art,
        MAX(CASE WHEN starred THEN 1 ELSE 0 END) AS starred,
        MAX(created_at) AS created_at
      FROM local_albums
      WHERE lower(COALESCE(NULLIF(canonical_artist, ''), artist)) = ?
      GROUP BY lower(name), lower(COALESCE(NULLIF(canonical_artist, ''), artist))
      ORDER BY year DESC, name COLLATE NOCASE
      ''',
          variables: [Variable(normalized)],
          readsFrom: {database.localAlbums},
        )
        .get();
    return rows
        .map(
          (row) => Album(
            id: row.read<String>('id'),
            name: row.read<String>('name'),
            artist: row.read<String>('canonical_artist'),
            artistId: row.readNullable<String>('artist_id') ?? '',
            year: row.read<int>('year'),
            songCount: row.read<int>('song_count'),
            duration: row.read<int>('duration'),
            playCount: row.read<int>('play_count'),
            coverArt: row.readNullable<String>('cover_art'),
            starred: row.read<int>('starred') != 0,
            created: row.readNullable<DateTime>('created_at'),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<Song>> songsForPlaylist(String playlistId) async {
    final query =
        database.select(database.localPlaylistEntries).join([
            innerJoin(
              database.localSongs,
              database.localSongs.id.equalsExp(
                database.localPlaylistEntries.songId,
              ),
            ),
          ])
          ..where(database.localPlaylistEntries.playlistId.equals(playlistId))
          ..orderBy([OrderingTerm.asc(database.localPlaylistEntries.position)]);
    return (await query.get())
        .map((row) => _mapSong(row.readTable(database.localSongs)))
        .toList(growable: false);
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
