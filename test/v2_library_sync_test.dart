import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/data/local/app_database.dart';
import 'package:navimusic/domain/sync/library_sync_service.dart';
import 'package:navimusic/domain/sync/library_sync_progress.dart';
import 'package:navimusic/models/models.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => database.close());

  test(
    'successful paged sync atomically replaces the previous snapshot',
    () async {
      await database.upsertSongs([_localSong('old')]);
      final gateway = _FakeSongGateway([
        [_song('a'), _song('b')],
        [_song('c'), _song('d')],
        [_song('e')],
      ]);
      final completedAt = DateTime.utc(2026, 8, 28, 10, 30);
      final service = LibrarySyncService(
        database: database,
        gateway: gateway,
        clock: () => completedAt,
      );

      final progress = <LibrarySyncProgress>[];
      final report = await service.syncSongs(
        pageSize: 2,
        onProgress: progress.add,
      );
      expect(progress.map((p) => p.stage).toSet(), {LibrarySyncStage.songs});
      expect(progress.map((p) => p.processed), [0, 2, 4, 5]);
      expect(progress.every((p) => p.fraction == null), isTrue);

      expect(gateway.offsets, [0, 2, 4]);
      expect(report.songCount, 5);
      expect(report.pageCount, 3);
      expect(report.completedAt, completedAt);
      expect(await database.songCount(), 5);
      expect((await database.songsPage(limit: 10)).map((song) => song.id), [
        'a',
        'b',
        'c',
        'd',
        'e',
      ]);
      expect(await database.stagedSongCount(), 0);

      final state = await database.select(database.syncStates).getSingle();
      expect(state.scope, LibrarySyncService.songsScope);
      expect(state.lastSuccessfulAt?.toUtc(), completedAt);
      expect(state.lastError, isNull);
    },
  );

  test('failed page leaves the last known-good snapshot untouched', () async {
    await database.upsertSongs([_localSong('old')]);
    final gateway = _FakeSongGateway([
      [_song('new-1'), _song('new-2')],
    ], failAtOffset: 2);
    final service = LibrarySyncService(database: database, gateway: gateway);

    await expectLater(
      service.syncSongs(pageSize: 2),
      throwsA(isA<StateError>()),
    );

    expect(await database.songCount(), 1);
    expect((await database.songsPage()).single.id, 'old');
    expect(await database.stagedSongCount(), 0);
    final state = await database.select(database.syncStates).getSingle();
    expect(state.lastSuccessfulAt, isNull);
    expect(state.lastError, contains('network interrupted'));
  });

  test('successful empty server snapshot clears the local catalogue', () async {
    await database.upsertSongs([_localSong('old')]);
    final service = LibrarySyncService(
      database: database,
      gateway: _FakeSongGateway(const [[]]),
    );

    final report = await service.syncSongs(pageSize: 2);

    expect(report.songCount, 0);
    expect(report.pageCount, 1);
    expect(await database.songCount(), 0);
  });

  test('page size is bounded to the verified Subsonic request size', () async {
    final service = LibrarySyncService(
      database: database,
      gateway: _FakeSongGateway(const [[]]),
    );

    await expectLater(service.syncSongs(pageSize: 0), throwsArgumentError);
    await expectLater(service.syncSongs(pageSize: 501), throwsArgumentError);
  });

  test(
    'sync stops when a server never advances past the page budget',
    () async {
      final service = LibrarySyncService(
        database: database,
        gateway: _FakeSongGateway([
          [_song('a'), _song('b')],
          [_song('c'), _song('d')],
          [_song('e'), _song('f')],
        ]),
      );

      await expectLater(
        service.syncSongs(pageSize: 2, maxPages: 2),
        throwsA(isA<StateError>()),
      );
    },
  );
}

class _FakeSongGateway implements NavidromeSongGateway {
  _FakeSongGateway(this.pages, {this.failAtOffset});

  final List<List<Song>> pages;
  final int? failAtOffset;
  final List<int> offsets = [];

  @override
  Future<List<Song>> fetchSongPage({
    required int offset,
    required int limit,
  }) async {
    offsets.add(offset);
    if (offset == failAtOffset) throw StateError('network interrupted');
    final index = offset ~/ limit;
    return index < pages.length ? pages[index] : const [];
  }
}

Song _song(String id) => Song(
  id: id,
  title: 'Song $id',
  artist: 'Artist ${id.toUpperCase()}',
  artistId: 'artist-$id',
  album: 'Album $id',
  albumId: 'album-$id',
  duration: 180,
  playCount: 2,
  year: 2026,
  bitRate: 1411,
  suffix: 'flac',
  created: DateTime.utc(2026, 8, 28),
);

LocalSongsCompanion _localSong(String id) => LocalSongsCompanion.insert(
  id: id,
  title: 'Song $id',
  artist: 'Artist $id',
  album: 'Album $id',
);
