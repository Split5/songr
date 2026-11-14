import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/domain/playback/logical_queue.dart';

LogicalQueueEntry entry(int value, {String? song}) =>
    LogicalQueueEntry(id: 'entry-$value', songId: song ?? 'song-$value');

void main() {
  group('V2 LogicalQueue', () {
    test('jump changes only the playhead, never the queue', () {
      final original = [for (var i = 0; i < 40; i++) entry(i)];
      final queue = LogicalQueue.start(original, 'entry-3');
      final jumped = queue.jumpTo('entry-28');

      expect(jumped.entries.map((e) => e.id), original.map((e) => e.id));
      expect(jumped.current?.id, 'entry-28');
      expect(jumped.entries.length, 40);
    });

    test('moving any item keeps the same current occurrence selected', () {
      final queue = LogicalQueue.start([
        for (var i = 0; i < 8; i++) entry(i),
      ], 'entry-4');
      final movedBefore = queue.move('entry-1', 6);
      final movedCurrent = movedBefore.move('entry-4', 0);

      expect(movedBefore.current?.id, 'entry-4');
      expect(movedCurrent.current?.id, 'entry-4');
      expect(movedCurrent.entries.first.id, 'entry-4');
    });

    test('removing before current adjusts index without changing the song', () {
      final queue = LogicalQueue.start([
        for (var i = 0; i < 8; i++) entry(i),
      ], 'entry-5');
      final result = queue.remove('entry-2');

      expect(result.current?.id, 'entry-5');
      expect(result.currentIndex, 4);
    });

    test('removing current selects the next visible occurrence', () {
      final queue = LogicalQueue.start([
        for (var i = 0; i < 5; i++) entry(i),
      ], 'entry-2');
      final middle = queue.remove('entry-2');
      expect(middle.current?.id, 'entry-3');

      final atEnd = LogicalQueue.start([
        for (var i = 0; i < 5; i++) entry(i),
      ], 'entry-4').remove('entry-4');
      expect(atEnd.current?.id, 'entry-3');
    });

    test(
      'AutoPlay appends at most five new songs and preserves the prefix',
      () {
        final original = [for (var i = 0; i < 10; i++) entry(i)];
        final queue = LogicalQueue.start(original, 'entry-8');
        final result = queue.appendNewSongs([
          entry(90, song: 'song-2'), // already queued
          for (var i = 10; i < 20; i++) entry(i),
        ]);

        expect(
          result.entries.take(10).map((e) => e.id),
          original.map((e) => e.id),
        );
        expect(result.entries.skip(10).map((e) => e.songId), [
          'song-10',
          'song-11',
          'song-12',
          'song-13',
          'song-14',
        ]);
        expect(result.current?.id, 'entry-8');
      },
    );

    test('native window stays bounded without changing logical state', () {
      final queue = LogicalQueue.start([
        for (var i = 0; i < 100000; i++) entry(i),
      ], 'entry-50000');
      final window = queue.nativeWindow(before: 5, after: 20);

      expect(window.entries.length, 26);
      expect(window.entries.first.id, 'entry-49995');
      expect(window.entries.last.id, 'entry-50020');
      expect(window.currentIndex, 5);
      expect(queue.entries.length, 100000);
    });
  });

  test('insert next preserves the complete prefix and current occurrence', () {
    final queue = LogicalQueue.start([
      for (var i = 0; i < 4; i++) entry(i),
    ], 'entry-1');

    final next = queue.insertAfterCurrent(const [
      LogicalQueueEntry(id: 'manual', songId: 'manual-song'),
    ]);

    expect(next.entries.map((entry) => entry.id), [
      'entry-0',
      'entry-1',
      'manual',
      'entry-2',
      'entry-3',
    ]);
    expect(next.current?.id, 'entry-1');
  });

  test('explicit shuffle order keeps every occurrence and current item', () {
    final entries = [for (var i = 0; i < 5; i++) entry(i)];
    final queue = LogicalQueue.start(entries, 'entry-2');

    final shuffled = queue.reorderKeepingCurrent([
      entries[0],
      entries[2],
      entries[4],
      entries[1],
      entries[3],
    ]);

    expect(shuffled.current?.id, 'entry-2');
    expect(
      shuffled.entries.map((item) => item.id).toSet(),
      entries.map((item) => item.id).toSet(),
    );
  });

  test('live tuning replaces only upcoming entries', () {
    final queue = LogicalQueue.start([
      for (var i = 0; i < 6; i++) entry(i),
    ], 'entry-2');

    final tuned = queue.replaceAfterCurrent([entry(20), entry(21)]);

    expect(tuned.entries.map((item) => item.id), [
      'entry-0',
      'entry-1',
      'entry-2',
      'entry-20',
      'entry-21',
    ]);
    expect(tuned.current?.id, 'entry-2');
  });
}
