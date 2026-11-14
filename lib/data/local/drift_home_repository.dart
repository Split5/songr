import 'package:drift/drift.dart';

import '../../domain/home/home_repository.dart';
import '../../models/models.dart';
import 'app_database.dart';

typedef NewestAlbumsLoader = Future<List<Album>> Function({required int limit});

class DriftHomeRepository implements HomeRepository {
  DriftHomeRepository(
    this.database, {
    this.rotationStore,
    this.newestAlbumsLoader,
  });

  final AppDatabase database;
  final HomeRotationStore? rotationStore;

  /// Navidrome's own newest-albums list. The local mirror is built from songs
  /// that finished syncing, so an album the server already reports can be
  /// missing locally for a while. The Home shelf asks the server directly and
  /// falls back to the mirror only while it is unreachable.
  final NewestAlbumsLoader? newestAlbumsLoader;
  List<Song>? _cachedSongRotation;
  List<Album>? _cachedAlbumRotation;
  Future<({List<Song> songs, List<Album> albums})>? _rotationInFlight;

  @override
  Future<HomeSnapshot> load({bool refreshLibraryRotation = false}) async {
    final results = await Future.wait<Object?>([
      database.recentlyPlayedSnapshot(limit: 100),
      database.watchRecentlyAdded(limit: 100).first,
      database.replaySongs(limit: 120),
      _activityAlbums(orderByRecent: true, limit: 80),
      _newestAlbums(limit: 80),
      _activityAlbums(orderByRecent: false, limit: 100),
      _loadLibraryRotation(refresh: refreshLibraryRotation),
      database.recentlyPlayedPlaylists(),
      _newestAlbumsFromServer(),
    ]);

    final recentSongRows = results[0] as List<RecentLocalPlay>;
    final recentlyAddedRows = results[1] as List<LocalSong>;
    final replayRows = results[2] as List<LocalSong>;
    final rotation = results[6] as ({List<Song> songs, List<Album> albums});
    final localEffectiveCount = {
      for (final item in recentSongRows) item.song.id: item.effectivePlayCount,
    };
    final replayById = <String, LocalSong>{
      for (final song in replayRows) song.id: song,
      for (final item in recentSongRows)
        if (item.effectivePlayCount > 0) item.song.id: item.song,
    };
    final rankedReplay = replayById.values.toList()
      ..sort(
        (a, b) => (localEffectiveCount[b.id] ?? b.playCount).compareTo(
          localEffectiveCount[a.id] ?? a.playCount,
        ),
      );

    return HomeSnapshot(
      recentlyPlayedSongs: recentSongRows
          .map((item) => _mapSong(item.song))
          .toList(growable: false),
      recentlyAddedSongs: recentlyAddedRows
          .map(_mapSong)
          .toList(growable: false),
      mostPlayedSongs: rankedReplay.map(_mapSong).toList(growable: false),
      librarySongRotation: rotation.songs,
      recentlyPlayedAlbums: results[3] as List<Album>,
      recentlyAddedAlbums:
          results[8] as List<Album>? ?? results[4] as List<Album>,
      mostPlayedAlbums: results[5] as List<Album>,
      libraryRotation: rotation.albums,
      recentlyPlayedPlaylists: results[7] as List<Playlist>,
    );
  }

  /// Keep this discovery shelf stable while normal metadata syncs complete.
  /// A new random sample is generated only for an explicit Home refresh (or
  /// when an initially empty database has since received its first sync).
  Future<({List<Song> songs, List<Album> albums})> _loadLibraryRotation({
    required bool refresh,
  }) async {
    final active = _rotationInFlight;
    if (active != null) {
      final settled = await active;
      if (!refresh) return settled;
    }

    final operation = refresh
        ? _fetchLibraryRotation()
        : _restoreOrFetchLibraryRotation();
    _rotationInFlight = operation;
    try {
      return await operation;
    } finally {
      if (identical(_rotationInFlight, operation)) {
        _rotationInFlight = null;
      }
    }
  }

  Future<({List<Song> songs, List<Album> albums})>
  _restoreOrFetchLibraryRotation() async {
    final cachedSongs = _cachedSongRotation;
    final cachedAlbums = _cachedAlbumRotation;
    if (cachedSongs != null &&
        cachedAlbums != null &&
        (cachedSongs.isNotEmpty || cachedAlbums.isNotEmpty)) {
      return (songs: cachedSongs, albums: cachedAlbums);
    }

    final stored = await rotationStore?.read();
    if (stored != null && !stored.isEmpty) {
      final restored = await Future.wait<Object>([
        _songsByIds(stored.songIds),
        _albumsByIds(stored.albumIds),
      ]);
      final songs = List<Song>.unmodifiable(restored[0] as List<Song>);
      final albums = List<Album>.unmodifiable(restored[1] as List<Album>);
      if (songs.isNotEmpty || albums.isNotEmpty) {
        _cachedSongRotation = songs;
        _cachedAlbumRotation = albums;
        return (songs: songs, albums: albums);
      }
    }
    return _fetchLibraryRotation();
  }

  Future<({List<Song> songs, List<Album> albums})>
  _fetchLibraryRotation() async {
    final results = await Future.wait<Object?>([
      database.randomSongs(limit: 100),
      _catalogAlbums(orderBy: 'RANDOM()', limit: 80),
    ]);
    _cachedSongRotation = List.unmodifiable(
      (results[0] as List<LocalSong>).map(_mapSong),
    );
    _cachedAlbumRotation = List.unmodifiable(results[1] as List<Album>);
    if (_cachedSongRotation!.isNotEmpty || _cachedAlbumRotation!.isNotEmpty) {
      await rotationStore?.write(
        HomeRotationSelection(
          songIds: _cachedSongRotation!.map((song) => song.id).toList(),
          albumIds: _cachedAlbumRotation!.map((album) => album.id).toList(),
        ),
      );
    }
    return (songs: _cachedSongRotation!, albums: _cachedAlbumRotation!);
  }

  Future<List<Album>?> _newestAlbumsFromServer() async {
    final loader = newestAlbumsLoader;
    if (loader == null) return null;
    try {
      final albums = await loader(
        limit: 60,
      ).timeout(const Duration(seconds: 3));
      return albums.isEmpty ? null : List<Album>.unmodifiable(albums);
    } catch (_) {
      // Offline or a server error must not empty the shelf: the mirror still
      // holds the last known newest albums.
      return null;
    }
  }

  Future<List<Song>> _songsByIds(List<String> ids) async {
    if (ids.isEmpty) return const [];
    final rows = await (database.select(
      database.localSongs,
    )..where((row) => row.id.isIn(ids))).get();
    final byId = {for (final row in rows) row.id: _mapSong(row)};
    return [for (final id in ids) ?byId[id]];
  }

  Future<List<Album>> _albumsByIds(List<String> ids) async {
    if (ids.isEmpty) return const [];
    final placeholders = List.filled(ids.length, '?').join(', ');
    final rows = await database
        .customSelect(
          '''
      SELECT
        MIN(id) AS id,
        name,
        MIN(artist_id) AS artist_id,
        COALESCE(NULLIF(canonical_artist, ''), artist) AS canonical_artist,
        MAX(year) AS year,
        SUM(song_count) AS song_count,
        SUM(duration) AS duration,
        MAX(play_count) AS effective_play_count,
        MAX(cover_art) AS cover_art,
        MAX(CASE WHEN starred THEN 1 ELSE 0 END) AS starred,
        MAX(created_at) AS created_at
      FROM local_albums
      WHERE trim(name) != ''
      GROUP BY
        lower(name),
        lower(COALESCE(NULLIF(canonical_artist, ''), artist))
      HAVING MIN(id) IN ($placeholders)
      ''',
          variables: ids.map(Variable.withString).toList(growable: false),
          readsFrom: {database.localAlbums},
        )
        .get();
    final byId = {
      for (final row in rows) row.read<String>('id'): _mapAlbum(row),
    };
    return [for (final id in ids) ?byId[id]];
  }

  /// Album activity is derived from songs so a play made while offline is
  /// visible immediately, before Navidrome's next catalogue snapshot.
  Future<List<Album>> _activityAlbums({
    required bool orderByRecent,
    required int limit,
  }) async {
    final rows = await database
        .customSelect(
          '''
      SELECT
        COALESCE(MIN(a.id), MIN(s.album_id), MIN(s.id)) AS id,
        MAX(s.album) AS name,
        COALESCE(MIN(a.artist_id), MIN(s.artist_id), '') AS artist_id,
        COALESCE(
          NULLIF(MAX(a.canonical_artist), ''),
          NULLIF(MAX(s.canonical_artist), ''),
          MAX(s.artist)
        ) AS canonical_artist,
        MAX(COALESCE(a.year, s.year)) AS year,
        COUNT(DISTINCT s.id) AS song_count,
        SUM(s.duration) AS duration,
        SUM(s.play_count + COALESCE(activity.unacknowledged_play_count, 0))
          AS effective_play_count,
        COALESCE(MAX(a.cover_art), MAX(s.cover_art)) AS cover_art,
        MAX(CASE WHEN COALESCE(a.starred, 0) = 1 THEN 1 ELSE 0 END)
          AS starred,
        MAX(COALESCE(a.created_at, s.created_at)) AS created_at,
        MAX(
          CASE
            WHEN activity.last_played_at IS NULL THEN s.last_played_at
            WHEN s.last_played_at IS NULL THEN activity.last_played_at
            WHEN activity.last_played_at > s.last_played_at
              THEN activity.last_played_at
            ELSE s.last_played_at
          END
        ) AS effective_last_played_at
      FROM local_songs AS s
      LEFT JOIN local_song_activities AS activity ON activity.song_id = s.id
      LEFT JOIN local_albums AS a ON a.id = s.album_id
      WHERE trim(s.album) != ''
      GROUP BY
        lower(s.album),
        lower(COALESCE(NULLIF(s.canonical_artist, ''), s.artist))
      HAVING ${orderByRecent ? 'effective_last_played_at IS NOT NULL' : 'effective_play_count > 0'}
      ORDER BY ${orderByRecent ? 'effective_last_played_at DESC' : 'effective_play_count DESC, effective_last_played_at DESC'}
      LIMIT ?
      ''',
          variables: [Variable(limit.clamp(1, 200))],
          readsFrom: {
            database.localSongs,
            database.localSongActivities,
            database.localAlbums,
          },
        )
        .get();
    return rows.map(_mapAlbum).toList(growable: false);
  }

  /// Newest albums derived from the song library. Navidrome's album list can
  /// be out of step with the songs actually available locally (the two are
  /// synced from different endpoints), so the home shelf uses the same source
  /// of truth as the recently-added song shelf. Albums built this way always
  /// contain at least one local song and sort by the newest song's
  /// `created_at`, which matches Navidrome's "recently added" ordering.
  Future<List<Album>> _newestAlbums({required int limit}) async {
    final rows = await database
        .customSelect(
          '''
      SELECT
        COALESCE(MIN(a.id), MIN(s.album_id), MIN(s.id)) AS id,
        MAX(s.album) AS name,
        COALESCE(MIN(a.artist_id), MIN(s.artist_id), '') AS artist_id,
        COALESCE(
          NULLIF(MAX(a.canonical_artist), ''),
          NULLIF(MAX(s.canonical_artist), ''),
          MAX(s.artist)
        ) AS canonical_artist,
        MAX(COALESCE(a.year, s.year)) AS year,
        COUNT(DISTINCT s.id) AS song_count,
        SUM(s.duration) AS duration,
        MAX(COALESCE(a.play_count, s.play_count)) AS effective_play_count,
        COALESCE(MAX(a.cover_art), MAX(s.cover_art)) AS cover_art,
        MAX(CASE WHEN COALESCE(a.starred, 0) = 1 THEN 1 ELSE 0 END) AS starred,
        MAX(COALESCE(a.created_at, s.created_at)) AS created_at
      FROM local_songs AS s
      LEFT JOIN local_albums AS a ON a.id = s.album_id
      WHERE trim(s.album) != ''
      GROUP BY
        lower(s.album),
        lower(COALESCE(NULLIF(s.canonical_artist, ''), s.artist))
      ORDER BY created_at DESC, name COLLATE NOCASE
      LIMIT ?
      ''',
          variables: [Variable(limit.clamp(1, 200))],
          readsFrom: {database.localSongs, database.localAlbums},
        )
        .get();
    return rows.map(_mapAlbum).toList(growable: false);
  }

  Future<List<Album>> _catalogAlbums({
    required String orderBy,
    required int limit,
  }) async {
    final rows = await database
        .customSelect(
          '''
      SELECT
        MIN(id) AS id,
        name,
        MIN(artist_id) AS artist_id,
        COALESCE(NULLIF(canonical_artist, ''), artist) AS canonical_artist,
        MAX(year) AS year,
        SUM(song_count) AS song_count,
        SUM(duration) AS duration,
        MAX(play_count) AS effective_play_count,
        MAX(cover_art) AS cover_art,
        MAX(CASE WHEN starred THEN 1 ELSE 0 END) AS starred,
        MAX(created_at) AS created_at
      FROM local_albums
      WHERE trim(name) != ''
      GROUP BY
        lower(name),
        lower(COALESCE(NULLIF(canonical_artist, ''), artist))
      ORDER BY $orderBy
      LIMIT ?
      ''',
          variables: [Variable(limit.clamp(1, 200))],
          readsFrom: {database.localAlbums},
        )
        .get();
    return rows.map(_mapAlbum).toList(growable: false);
  }

  Album _mapAlbum(QueryRow row) => Album(
    id: row.read<String>('id'),
    name: row.read<String>('name'),
    artist: row.read<String>('canonical_artist'),
    artistId: row.readNullable<String>('artist_id') ?? '',
    coverArt: row.readNullable<String>('cover_art'),
    songCount: row.read<int>('song_count'),
    duration: row.read<int>('duration'),
    playCount: row.read<int>('effective_play_count'),
    year: row.read<int>('year'),
    created: row.readNullable<DateTime>('created_at'),
    starred: row.read<int>('starred') != 0,
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
