import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/data/local/app_database.dart';
import 'package:navimusic/data/local/drift_catalog_repository.dart';
import 'package:navimusic/domain/library/catalog_repository.dart';

void main() {
  late AppDatabase database;
  late DriftCatalogRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftCatalogRepository(database);
  });
  tearDown(() => database.close());

  test(
    'artist and album collaboration variants collapse in every view',
    () async {
      await database.batch((batch) {
        batch.insertAll(database.localArtists, [
          LocalArtistsCompanion.insert(
            id: 'artist-solo',
            name: 'Alex Warren',
            sortName: const Value('Alex Warren'),
            albumCount: const Value(1),
          ),
          LocalArtistsCompanion.insert(
            id: 'artist-duet',
            name: 'Alex Warren, ROSÉ',
            sortName: const Value('Alex Warren'),
            albumCount: const Value(1),
          ),
        ]);
        batch.insertAll(database.localAlbums, [
          _album('album-solo', 'Alex Warren'),
          _album('album-duet', 'Alex Warren, ROSÉ'),
        ]);
        batch.insertAll(database.localSongs, [
          _song('song-solo', 'Alex Warren', track: 1),
          _song('song-duet', 'Alex Warren, ROSÉ', track: 2),
        ]);
      });

      expect(await repository.artistCount(), 1);
      final artist = (await repository.artistsPage()).single;
      expect(artist.name, 'Alex Warren');
      expect(await repository.albumCount(), 1);
      final album = (await repository.albumsPage()).single;
      expect(album.artist, 'Alex Warren');
      expect(album.songCount, 2);
      expect((await repository.songsForArtist(artist)).map((song) => song.id), [
        'song-solo',
        'song-duet',
      ]);
      expect((await repository.songsForAlbum(album)).map((song) => song.id), [
        'song-solo',
        'song-duet',
      ]);
    },
  );

  test(
    'only user-owned playlists are returned and order is preserved',
    () async {
      await database.upsertSongs([
        _song('first', 'Artist', track: 1),
        _song('second', 'Artist', track: 2),
      ]);
      await database.batch((batch) {
        batch.insertAll(database.localPlaylists, [
          LocalPlaylistsCompanion.insert(id: 'mine', name: 'My list'),
          LocalPlaylistsCompanion.insert(
            id: 'generated',
            name: 'Cluster',
            isGenerated: const Value(true),
          ),
        ]);
        batch.insertAll(database.localPlaylistEntries, [
          LocalPlaylistEntriesCompanion.insert(
            playlistId: 'mine',
            songId: 'second',
            position: 0,
          ),
          LocalPlaylistEntriesCompanion.insert(
            playlistId: 'mine',
            songId: 'first',
            position: 1,
          ),
        ]);
      });

      expect((await repository.ownPlaylists()).map((item) => item.id), [
        'mine',
      ]);
      expect(
        (await repository.songsForPlaylist('mine')).map((song) => song.id),
        ['second', 'first'],
      );
    },
  );

  test(
    'soundtrack membership follows album id across different track artists',
    () async {
      await database.batch((batch) {
        batch.insert(
          database.localAlbums,
          LocalAlbumsCompanion.insert(
            id: 'encanto',
            name: 'Encanto',
            artist: 'Lin-Manuel Miranda',
            canonicalArtist: const Value('Lin-Manuel Miranda'),
            songCount: const Value(2),
          ),
        );
        batch.insertAll(database.localSongs, [
          LocalSongsCompanion.insert(
            id: 'family-madrigal',
            title: 'The Family Madrigal',
            albumId: const Value('encanto'),
            album: 'Encanto',
            artist: 'Stephanie Beatriz',
            canonicalArtist: const Value('Stephanie Beatriz'),
            track: const Value(1),
          ),
          LocalSongsCompanion.insert(
            id: 'surface-pressure',
            title: 'Surface Pressure',
            albumId: const Value('encanto'),
            album: 'Encanto',
            artist: 'Jessica Darrow',
            canonicalArtist: const Value('Jessica Darrow'),
            track: const Value(2),
          ),
        ]);
      });

      final album = (await repository.albumsPage(query: 'Encanto')).single;
      expect((await repository.songsForAlbum(album)).map((song) => song.id), [
        'family-madrigal',
        'surface-pressure',
      ]);
    },
  );

  test(
    'starred album and artist browsers preserve canonical grouping',
    () async {
      await database.batch((batch) {
        batch.insertAll(database.localArtists, [
          LocalArtistsCompanion.insert(
            id: 'artist-solo',
            name: 'Alex Warren',
            sortName: const Value('Alex Warren'),
            starred: const Value(true),
          ),
          LocalArtistsCompanion.insert(
            id: 'artist-duet',
            name: 'Alex Warren, ROSÉ',
            sortName: const Value('Alex Warren'),
          ),
        ]);
        batch.insertAll(database.localAlbums, [
          _album('album-solo', 'Alex Warren', starred: true),
          _album('album-duet', 'Alex Warren, ROSÉ'),
        ]);
      });

      final artist = (await repository.starredArtists()).single;
      final album = (await repository.starredAlbums()).single;
      expect(artist.name, 'Alex Warren');
      expect(artist.starred, isTrue);
      expect(album.artist, 'Alex Warren');
      expect(album.songCount, 2);
      expect(album.starred, isTrue);
    },
  );

  test('catalogue search and paging stay in SQLite', () async {
    await database.batch((batch) {
      batch.insertAll(database.localArtists, [
        for (var i = 0; i < 75; i++)
          LocalArtistsCompanion.insert(
            id: 'artist-$i',
            name: 'Artist ${i.toString().padLeft(2, '0')}',
          ),
      ]);
    });

    expect(await repository.artistCount(), 75);
    expect(await repository.artistsPage(limit: 20, offset: 60), hasLength(15));
    expect(await repository.artistCount(query: 'Artist 7'), 5);
  });

  test(
    'album sorting supports recent, played and stable random order',
    () async {
      await database.batch((batch) {
        batch.insertAll(database.localAlbums, [
          _sortAlbum(
            'album-a',
            'Alpha',
            created: DateTime.utc(2024),
            playCount: 2,
          ),
          _sortAlbum(
            'album-b',
            'Beta',
            created: DateTime.utc(2026),
            playCount: 1,
          ),
          _sortAlbum(
            'album-c',
            'Gamma',
            created: DateTime.utc(2025),
            playCount: 20,
          ),
        ]);
        batch.insertAll(database.localSongs, [
          _albumSong('song-a', 'album-a', DateTime.utc(2026, 10, 25)),
          _albumSong('song-b', 'album-b', DateTime.utc(2026, 10, 24)),
          _albumSong('song-c', 'album-c', DateTime.utc(2026, 10, 23)),
        ]);
      });

      Future<List<String>> ids(AlbumSort sort, {int seed = 0}) async =>
          (await repository.albumsPage(
            sort: sort,
            randomSeed: seed,
          )).map((album) => album.id).toList();

      expect(await ids(AlbumSort.recentlyAdded), [
        'album-b',
        'album-c',
        'album-a',
      ]);
      expect((await ids(AlbumSort.mostPlayed)).first, 'album-c');
      expect((await ids(AlbumSort.recentlyPlayed)).first, 'album-a');
      expect(
        await ids(AlbumSort.random, seed: 42),
        await ids(AlbumSort.random, seed: 42),
      );
    },
  );

  test('artist sorting supports album count and stable random order', () async {
    await database.batch((batch) {
      batch.insertAll(database.localArtists, [
        LocalArtistsCompanion.insert(
          id: 'artist-a',
          name: 'Alpha',
          albumCount: const Value(1),
        ),
        LocalArtistsCompanion.insert(
          id: 'artist-b',
          name: 'Beta',
          albumCount: const Value(5),
        ),
        LocalArtistsCompanion.insert(
          id: 'artist-c',
          name: 'Gamma',
          albumCount: const Value(3),
        ),
      ]);
    });

    Future<List<String>> ids(ArtistSort sort, {int seed = 0}) async =>
        (await repository.artistsPage(
          sort: sort,
          randomSeed: seed,
        )).map((artist) => artist.id).toList();

    expect(await ids(ArtistSort.albumCount), [
      'artist-b',
      'artist-c',
      'artist-a',
    ]);
    expect(
      await ids(ArtistSort.random, seed: 42),
      await ids(ArtistSort.random, seed: 42),
    );
  });
}

LocalAlbumsCompanion _sortAlbum(
  String id,
  String name, {
  required DateTime created,
  required int playCount,
}) => LocalAlbumsCompanion.insert(
  id: id,
  name: name,
  artist: 'Artist',
  canonicalArtist: const Value('Artist'),
  songCount: const Value(1),
  playCount: Value(playCount),
  createdAt: Value(created),
);

LocalSongsCompanion _albumSong(
  String id,
  String albumId,
  DateTime lastPlayedAt,
) => LocalSongsCompanion.insert(
  id: id,
  title: id,
  albumId: Value(albumId),
  album: albumId,
  artist: 'Artist',
  canonicalArtist: const Value('Artist'),
  lastPlayedAt: Value(lastPlayedAt),
);

LocalAlbumsCompanion _album(String id, String artist, {bool starred = false}) =>
    LocalAlbumsCompanion.insert(
      id: id,
      name: "You'll Be Alright, Kid",
      artist: artist,
      artistId: Value('artist-$id'),
      canonicalArtist: const Value('Alex Warren'),
      songCount: const Value(1),
      duration: const Value(180),
      starred: Value(starred),
    );

LocalSongsCompanion _song(String id, String artist, {required int track}) =>
    LocalSongsCompanion.insert(
      id: id,
      title: 'Song $id',
      artist: artist,
      artistId: Value('artist-$id'),
      canonicalArtist: Value(
        artist.startsWith('Alex Warren') ? 'Alex Warren' : artist,
      ),
      album: "You'll Be Alright, Kid",
      albumId: Value('album-$id'),
      track: Value(track),
    );
