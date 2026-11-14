import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/domain/playback/logical_queue.dart';
import 'package:navimusic/domain/playback/queue_edit_planner.dart';

void main() {
  test('reordering emits a native move, never replace/remove/insert', () {
    final edits = planNativeQueueEdits(
      [_entry('a'), _entry('b'), _entry('c'), _entry('d')],
      [_entry('a'), _entry('c'), _entry('b'), _entry('d')],
    );

    expect(edits, hasLength(1));
    expect(edits.single, isA<MoveNativeQueueEntry>());
    final move = edits.single as MoveNativeQueueEntry;
    expect((move.from, move.to), (2, 1));
  });

  test('shifting a bounded window removes old prefix and appends new tail', () {
    final edits = planNativeQueueEdits(
      [_entry('a'), _entry('b'), _entry('c')],
      [_entry('b'), _entry('c'), _entry('d'), _entry('e')],
    );

    expect(edits.whereType<RemoveNativeQueueEntry>(), hasLength(1));
    expect(edits.whereType<InsertNativeQueueEntry>(), hasLength(2));
    expect(edits.whereType<MoveNativeQueueEntry>(), isEmpty);
  });

  test('duplicate songs remain distinct queue occurrences', () {
    const first = LogicalQueueEntry(id: 'first', songId: 'same-song');
    const second = LogicalQueueEntry(id: 'second', songId: 'same-song');

    final edits = planNativeQueueEdits([first, second], [second, first]);

    expect(edits.single, isA<MoveNativeQueueEntry>());
  });

  test('identical windows produce no native work', () {
    final entries = [_entry('a'), _entry('b')];
    expect(planNativeQueueEdits(entries, entries), isEmpty);
  });
}

LogicalQueueEntry _entry(String id) => LogicalQueueEntry(id: id, songId: id);
