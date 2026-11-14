import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/data/local/app_database.dart';
import 'package:navimusic/domain/sync/delta_sync_service.dart';
import 'package:navimusic/models/models.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => database.close());

  test('first run mirrors the newest albums and their tracks', () async {
    final gateway = _Gateway(
      albums: [_album('a1', DateTime.utc(2026, 10, 31))],
      songs: {
        'a1': [_song('s1'), _song('s2')],
      },
    );
    final service = DeltaSyncService(
      database: database,
      gateway: gateway,
      clock: () => DateTime.utc(2026, 11, 1),
    );

    final report = await service.syncRecent();

    expect(report.albumCount, 1);
    expect(report.songCount, 2);
    expect(await database.select(database.localSongs).get(), hasLength(2));
    expect(await database.select(database.localAlbums).get(), hasLength(1));
    expect(
      (await database.lastSuccessAt(DeltaSyncService.scope))!.toUtc(),
      DateTime.utc(2026, 11, 1),
    );
  });

  test('second run only fetches albums newer than the watermark', () async {
    var now = DateTime.utc(2026, 11, 1);
    final gateway = _Gateway(
      albums: [_album('old', DateTime.utc(2026, 10, 20))],
      songs: {
        'old': [_song('s-old')],
      },
    );
    final service = DeltaSyncService(
      database: database,
      gateway: gateway,
      clock: () => now,
    );
    await service.syncRecent();

    gateway.albums = [
      _album('new', DateTime.utc(2026, 11, 1)),
      _album('old', DateTime.utc(2026, 10, 20)),
    ];
    gateway.songs['new'] = [_song('s-new')];
    now = DateTime.utc(2026, 11, 1, 0, 5);

    final report = await service.syncRecent();

    expect(gateway.requestedAlbums, ['old', 'new']);
    expect(report.albumCount, 1);
    expect(report.songCount, 1);
    expect(
      (await database.select(database.localSongs).get()).map((s) => s.id),
      containsAll(<String>['s-old', 's-new']),
    );
  });

  test('a run costs one album request regardless of library size', () async {
    final gateway = _Gateway(
      albums: [_album('a1', DateTime.utc(2026, 10, 31))],
      songs: {
        'a1': [_song('s1')],
      },
    );
    final service = DeltaSyncService(
      database: database,
      gateway: gateway,
      clock: () => DateTime.utc(2026, 11, 1),
    );

    await service.syncRecent();
    await service.syncRecent();

    expect(gateway.albumListCalls, 2);
  });

  test('a failed run keeps the previous mirror and records the error', () async {
    final gateway = _Gateway(
      albums: [_album('a1', DateTime.utc(2026, 10, 31))],
      songs: {
        'a1': [_song('s1')],
      },
    );
    final service = DeltaSyncService(
      database: database,
      gateway: gateway,
      clock: () => DateTime.utc(2026, 11, 1),
    );
    await service.syncRecent();

    gateway.failSongs = true;
    gateway.albums = [_album('a2', DateTime.utc(2026, 11, 1))];

    await expectLater(service.syncRecent(), throwsA(isA<StateError>()));
    expect(await database.select(database.localSongs).get(), hasLength(1));
  });

  test('rejects an album limit outside the paging contract', () async {
    final service = DeltaSyncService(
      database: database,
      gateway: _Gateway(albums: const [], songs: const {}),
    );

    expect(() => service.syncRecent(albumLimit: 0), throwsArgumentError);
    expect(() => service.syncRecent(albumLimit: 501), throwsArgumentError);
  });
}

class _Gateway implements NavidromeDeltaGateway {
  _Gateway({required this.albums, required this.songs});

  List<Album> albums;
  Map<String, List<Song>> songs;
  bool failSongs = false;
  int albumListCalls = 0;
  final List<String> requestedAlbums = [];

  @override
  Future<List<Album>> fetchNewestAlbums({required int limit}) async {
    albumListCalls++;
    return albums.take(limit).toList();
  }

  @override
  Future<List<Song>> fetchAlbumSongs(String albumId) async {
    requestedAlbums.add(albumId);
    if (failSongs) throw StateError('network interrupted');
    return songs[albumId] ?? const [];
  }
}

Album _album(String id, DateTime created) => Album(
  id: id,
  name: 'Album $id',
  artist: 'Stromae',
  artistId: 'artist-1',
  coverArt: 'cover-$id',
  songCount: 1,
  created: created,
);

Song _song(String id) => Song(
  id: id,
  title: 'Song $id',
  artist: 'Stromae',
  artistId: 'artist-1',
  album: 'Album a1',
  albumId: 'a1',
  duration: 200,
  created: DateTime.utc(2026, 10, 31),
  suffix: 'flac',
  bitRate: 900,
);
