import 'logical_queue.dart';

sealed class NativeQueueEdit {
  const NativeQueueEdit();
}

class RemoveNativeQueueEntry extends NativeQueueEdit {
  const RemoveNativeQueueEntry(this.index);
  final int index;
}

class MoveNativeQueueEntry extends NativeQueueEdit {
  const MoveNativeQueueEntry(this.from, this.to);
  final int from;
  final int to;
}

class InsertNativeQueueEntry extends NativeQueueEdit {
  const InsertNativeQueueEntry(this.index, this.entry);
  final int index;
  final LogicalQueueEntry entry;
}

/// Produces an incremental edit script identified by queue occurrence id.
/// Applying this script never replaces the native playlist wholesale.
List<NativeQueueEdit> planNativeQueueEdits(
  List<LogicalQueueEntry> current,
  List<LogicalQueueEntry> desired,
) {
  final edits = <NativeQueueEdit>[];
  final working = List<LogicalQueueEntry>.of(current);
  final desiredIds = desired.map((entry) => entry.id).toSet();
  for (var index = working.length - 1; index >= 0; index--) {
    if (!desiredIds.contains(working[index].id)) {
      edits.add(RemoveNativeQueueEntry(index));
      working.removeAt(index);
    }
  }
  for (var target = 0; target < desired.length; target++) {
    final wanted = desired[target];
    if (target < working.length && working[target].id == wanted.id) continue;
    final existing = working.indexWhere(
      (entry) => entry.id == wanted.id,
      target + 1,
    );
    if (existing >= 0) {
      edits.add(MoveNativeQueueEntry(existing, target));
      final moved = working.removeAt(existing);
      working.insert(target, moved);
    } else {
      edits.add(InsertNativeQueueEntry(target, wanted));
      working.insert(target, wanted);
    }
  }
  while (working.length > desired.length) {
    edits.add(RemoveNativeQueueEntry(working.length - 1));
    working.removeLast();
  }
  return List.unmodifiable(edits);
}
