import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/data/local/app_database.dart';
import 'package:navimusic/domain/library/song_filter.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => database.close());

  test('100,000-song library stays paged and ordered', () async {
    const total = 100000;
    await database.batch((batch) {
      batch.insertAll(database.localSongs, [
        for (var i = 0; i < total; i++)
          LocalSongsCompanion.insert(
            id: 'song-$i',
            title: 'Song ${i.toString().padLeft(6, '0')}',
            artist: 'Artist ${i % 1000}',
            album: 'Album ${i % 5000}',
          ),
      ]);
    });

    expect(await database.songCount(), total);
    final page = await database.songsPage(limit: 100, offset: 50000);
    expect(page, hasLength(100));
    expect(page.first.title, 'Song 050000');
    expect(page.last.title, 'Song 050099');

    final searchWatch = Stopwatch()..start();
    final search = await database.filteredSongsPage(
      filter: const SongFilter(query: '099999'),
      limit: 60,
    );
    expect(search.single.id, 'song-99999');
    expect(searchWatch.elapsed, lessThan(const Duration(seconds: 5)));
  }, timeout: const Timeout(Duration(seconds: 30)));

  test('upsert is transactional and search remains database-backed', () async {
    await database.upsertSongs([
      LocalSongsCompanion.insert(
        id: '1',
        title: 'Northern Lights',
        artist: 'Aurora',
        album: 'Runaway',
      ),
      LocalSongsCompanion.insert(
        id: '2',
        title: 'Midnight City',
        artist: 'M83',
        album: 'Hurry Up',
      ),
    ]);
    await database.upsertSongs([
      LocalSongsCompanion.insert(
        id: '1',
        title: 'Northern Lights (Live)',
        artist: 'Aurora',
        album: 'Runaway',
      ),
    ]);

    expect(await database.songCount(), 2);
    final result = await database.songsPage(query: 'aurora');
    expect(result.map((song) => song.id), ['1']);
    expect(result.single.title, 'Northern Lights (Live)');
  });

  test('offline favorite mutations keep only the latest state', () async {
    await database.setSongStarred('song', starred: false);
    await database.queueFavoriteMutation(songId: 'song', starred: true);
    await database.queueFavoriteMutation(songId: 'song', starred: false);

    final pending = await database.pendingFavoriteMutations();

    expect(pending, hasLength(1));
    expect(pending.single.songId, 'song');
    expect(pending.single.starred, isFalse);
    await database.deletePendingMutation(pending.single.id);
    expect(await database.pendingFavoriteMutations(), isEmpty);
  });

  test('account cache clear removes server-scoped local data', () async {
    await database.batch((batch) {
      batch.insert(
        database.localSongs,
        LocalSongsCompanion.insert(
          id: 'old-song',
          title: 'Old song',
          artist: 'Old artist',
          album: 'Old album',
        ),
      );
      batch.insert(
        database.localPlaylists,
        LocalPlaylistsCompanion.insert(id: 'old-list', name: 'Old list'),
      );
      batch.insert(
        database.localFavorites,
        LocalFavoritesCompanion.insert(
          entityType: 'song',
          entityId: 'old-song',
        ),
      );
    });

    await database.clearAccountCache();

    expect(await database.songCount(), 0);
    expect(await database.recentlyPlayedPlaylists(), isEmpty);
    expect(await database.select(database.localFavorites).get(), isEmpty);
  });

  test('sync failures are sanitized before they reach SQLite', () async {
    await database.recordSyncFailure(
      'songs',
      StateError(
        'ClientException: closed, '
        'uri=https://music.example.test/rest/search3?t=secret-token&s=salt',
      ),
    );

    final state = await database.select(database.syncStates).getSingle();
    expect(state.lastError, isNot(contains('secret-token')));
    expect(state.lastError, isNot(contains('music.example.test')));
    expect(state.lastError, contains('[url]'));
  });

  test('schema v8 upgrades to the current schema with data intact', () async {
    final previousWarningSetting =
        driftRuntimeOptions.dontWarnAboutMultipleDatabases;
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    addTearDown(
      () => driftRuntimeOptions.dontWarnAboutMultipleDatabases =
          previousWarningSetting,
    );
    final directory = await Directory.systemTemp.createTemp('navimusic-db-');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/migration.sqlite');
    final fresh = AppDatabase.forTesting(NativeDatabase(file));
    await fresh.upsertSongs([
      LocalSongsCompanion.insert(
        id: 'kept',
        title: 'Kept',
        artist: 'Artist',
        album: 'Album',
      ),
    ]);
    await fresh.close();

    final migrated = AppDatabase.forTesting(
      NativeDatabase(
        file,
        setup: (raw) {
          raw.execute('DROP TABLE saved_queue_snapshot_entries');
          raw.execute('DROP TABLE saved_queue_snapshots');
          raw.execute('DROP INDEX IF EXISTS songs_starred_at_idx');
          raw.execute('ALTER TABLE local_songs DROP COLUMN starred_at');
          raw.execute('ALTER TABLE staged_songs DROP COLUMN starred_at');
          raw.userVersion = 8;
        },
      ),
    );
    addTearDown(migrated.close);

    expect(await migrated.songCount(), 1);
    await migrated
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name = 'saved_queue_snapshots'",
        )
        .getSingle();
  });

  test('schema v9 backfills song favorite timestamps', () async {
    final previousWarningSetting =
        driftRuntimeOptions.dontWarnAboutMultipleDatabases;
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    addTearDown(
      () => driftRuntimeOptions.dontWarnAboutMultipleDatabases =
          previousWarningSetting,
    );
    final directory = await Directory.systemTemp.createTemp('navimusic-db-');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/migration-v9.sqlite');
    final fresh = AppDatabase.forTesting(NativeDatabase(file));
    await fresh.upsertSongs([
      LocalSongsCompanion.insert(
        id: 'favorite',
        title: 'Favorite',
        artist: 'Artist',
        album: 'Album',
        starred: const Value(true),
      ),
    ]);
    await fresh.setSongStarred(
      'favorite',
      starred: true,
      starredAt: DateTime.utc(2026, 10, 24),
    );
    await fresh.close();

    final migrated = AppDatabase.forTesting(
      NativeDatabase(
        file,
        setup: (raw) {
          raw.execute('DROP INDEX IF EXISTS songs_starred_at_idx');
          raw.execute('ALTER TABLE local_songs DROP COLUMN starred_at');
          raw.execute('ALTER TABLE staged_songs DROP COLUMN starred_at');
          raw.userVersion = 9;
        },
      ),
    );
    addTearDown(migrated.close);

    final song = await (migrated.select(
      migrated.localSongs,
    )..where((row) => row.id.equals('favorite'))).getSingle();
    expect(song.starredAt?.toUtc(), DateTime.utc(2026, 10, 24));
  });
}
