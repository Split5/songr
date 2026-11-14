import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/data/local/app_database.dart';
import 'package:navimusic/data/local/drift_queue_session_repository.dart';
import 'package:navimusic/domain/playback/logical_queue.dart';

void main() {
  test(
    'queue occurrence order, playhead, autoplay and position survive',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = DriftQueueSessionRepository(database);
      await database.upsertSongs([
        LocalSongsCompanion.insert(
          id: 'same',
          title: 'Same',
          artist: 'Artist',
          album: 'Album',
        ),
        LocalSongsCompanion.insert(
          id: 'other',
          title: 'Other',
          artist: 'Artist',
          album: 'Album',
        ),
      ]);
      final queue = LogicalQueue.start(const [
        LogicalQueueEntry(id: 'one', songId: 'same'),
        LogicalQueueEntry(id: 'two', songId: 'same'),
        LogicalQueueEntry(id: 'three', songId: 'other'),
      ], 'two');

      await repository.save(
        queue: queue,
        autoPlayEnabled: false,
        position: const Duration(seconds: 42),
      );
      var restored = await repository.load();

      expect(restored, isNotNull);
      expect(restored!.entries.map((entry) => entry.id), [
        'one',
        'two',
        'three',
      ]);
      expect(restored.entries.map((entry) => entry.songId), [
        'same',
        'same',
        'other',
      ]);
      expect(restored.currentEntryId, 'two');
      expect(restored.autoPlayEnabled, isFalse);
      expect(restored.position, const Duration(seconds: 42));
      expect(restored.updatedAt, isNotNull);

      await repository.updatePosition(const Duration(seconds: 77));
      restored = await repository.load();
      expect(restored!.position, const Duration(seconds: 77));

      await repository.clear();
      expect(await repository.load(), isNull);
    },
  );

  test('stale queue entries are skipped and the playhead moves', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftQueueSessionRepository(database);
    await database.upsertSongs([
      LocalSongsCompanion.insert(
        id: 'first',
        title: 'First',
        artist: 'Artist',
        album: 'Album',
      ),
      LocalSongsCompanion.insert(
        id: 'last',
        title: 'Last',
        artist: 'Artist',
        album: 'Album',
      ),
    ]);
    await repository.save(
      queue: LogicalQueue.start(const [
        LogicalQueueEntry(id: 'a', songId: 'first'),
        LogicalQueueEntry(id: 'b', songId: 'removed'),
        LogicalQueueEntry(id: 'c', songId: 'last'),
      ], 'b'),
      autoPlayEnabled: true,
      position: Duration.zero,
    );

    final restored = await repository.load();

    expect(restored!.entries.map((entry) => entry.id), ['a', 'c']);
    expect(restored.currentEntryId, 'c');
  });
}
