import 'dart:math' as math;

/// Stable logical queue entry. [id] identifies this occurrence in the queue;
/// [songId] identifies the library song. The same song may intentionally occur
/// more than once in a manually assembled queue.
class LogicalQueueEntry {
  final String id;
  final String songId;

  const LogicalQueueEntry({required this.id, required this.songId});
}

/// Immutable, platform-independent queue state.
///
/// This is deliberately separate from just_audio's native playlist. The native
/// player receives only a bounded window around [currentIndex]; UI operations
/// mutate this model first and can therefore never accidentally truncate the
/// queue merely because the native source window is rebuilt.
class LogicalQueue {
  final List<LogicalQueueEntry> entries;
  final int currentIndex;

  const LogicalQueue._(this.entries, this.currentIndex);

  const LogicalQueue.empty() : this._(const [], -1);

  factory LogicalQueue.start(
    List<LogicalQueueEntry> entries,
    String startEntryId,
  ) {
    final immutable = List<LogicalQueueEntry>.unmodifiable(entries);
    final index = immutable.indexWhere((entry) => entry.id == startEntryId);
    if (index < 0) {
      throw ArgumentError.value(
        startEntryId,
        'startEntryId',
        'is not present in the queue',
      );
    }
    return LogicalQueue._(immutable, index);
  }

  LogicalQueueEntry? get current =>
      currentIndex < 0 || currentIndex >= entries.length
      ? null
      : entries[currentIndex];

  LogicalQueue jumpTo(String entryId) {
    final index = entries.indexWhere((entry) => entry.id == entryId);
    if (index < 0) return this;
    return LogicalQueue._(entries, index);
  }

  /// Moves one stable queue entry while keeping the same entry selected.
  LogicalQueue move(String entryId, int newIndex) {
    final oldIndex = entries.indexWhere((entry) => entry.id == entryId);
    if (oldIndex < 0 || entries.length < 2) return this;
    final target = newIndex.clamp(0, entries.length - 1);
    if (target == oldIndex) return this;

    final selectedId = current?.id;
    final next = List<LogicalQueueEntry>.of(entries);
    final moved = next.removeAt(oldIndex);
    next.insert(target, moved);
    return LogicalQueue._(
      List.unmodifiable(next),
      selectedId == null
          ? -1
          : next.indexWhere((entry) => entry.id == selectedId),
    );
  }

  /// Removes one occurrence. Removing the current item selects the item that
  /// slides into its position, or the new last item when the old last is
  /// removed.
  LogicalQueue remove(String entryId) {
    final index = entries.indexWhere((entry) => entry.id == entryId);
    if (index < 0) return this;
    final selectedId = current?.id;
    final next = List<LogicalQueueEntry>.of(entries)..removeAt(index);
    if (next.isEmpty) return const LogicalQueue.empty();

    final selectedStillExists = selectedId != entryId && selectedId != null;
    final nextCurrent = selectedStillExists
        ? next.indexWhere((entry) => entry.id == selectedId)
        : math.min(index, next.length - 1);
    return LogicalQueue._(List.unmodifiable(next), nextCurrent);
  }

  LogicalQueue append(List<LogicalQueueEntry> additions) {
    if (additions.isEmpty) return this;
    final next = List<LogicalQueueEntry>.of(entries)..addAll(additions);
    return LogicalQueue._(
      List.unmodifiable(next),
      currentIndex < 0 ? 0 : currentIndex,
    );
  }

  LogicalQueue insertAfterCurrent(List<LogicalQueueEntry> additions) {
    if (additions.isEmpty) return this;
    if (entries.isEmpty || currentIndex < 0) {
      return LogicalQueue.start(additions, additions.first.id);
    }
    final next = List<LogicalQueueEntry>.of(entries)
      ..insertAll(currentIndex + 1, additions);
    return LogicalQueue._(List.unmodifiable(next), currentIndex);
  }

  /// Keeps the played prefix and selected occurrence intact while replacing
  /// everything after it. This is the safe primitive for live radio tuning:
  /// the current audio source never moves or restarts.
  LogicalQueue replaceAfterCurrent(List<LogicalQueueEntry> additions) {
    final selected = current;
    if (selected == null) {
      return additions.isEmpty
          ? const LogicalQueue.empty()
          : LogicalQueue.start(additions, additions.first.id);
    }
    final next = <LogicalQueueEntry>[
      ...entries.take(currentIndex + 1),
      ...additions,
    ];
    final ids = next.map((entry) => entry.id).toSet();
    if (ids.length != next.length) return this;
    return LogicalQueue.start(next, selected.id);
  }

  LogicalQueue reorderKeepingCurrent(List<LogicalQueueEntry> reordered) {
    if (reordered.length != entries.length) return this;
    final expected = entries.map((entry) => entry.id).toSet();
    final actual = reordered.map((entry) => entry.id).toSet();
    if (actual.length != reordered.length || !expected.containsAll(actual)) {
      return this;
    }
    final currentId = current?.id;
    if (currentId == null) return this;
    return LogicalQueue.start(reordered, currentId);
  }

  /// AutoPlay uses this variant: preserve the existing prefix and reject both
  /// songs already in the queue and duplicates within the candidate batch.
  LogicalQueue appendNewSongs(
    List<LogicalQueueEntry> candidates, {
    int maxCount = 5,
  }) {
    if (maxCount <= 0 || candidates.isEmpty) return this;
    final seenSongs = entries.map((entry) => entry.songId).toSet();
    final seenEntries = entries.map((entry) => entry.id).toSet();
    final accepted = <LogicalQueueEntry>[];
    for (final candidate in candidates) {
      if (seenSongs.add(candidate.songId) && seenEntries.add(candidate.id)) {
        accepted.add(candidate);
        if (accepted.length == maxCount) break;
      }
    }
    return append(accepted);
  }

  /// Returns the bounded native source window and the selected index within
  /// that window. Rebuilding this window does not mutate the logical queue.
  ({List<LogicalQueueEntry> entries, int currentIndex}) nativeWindow({
    int before = 5,
    int after = 20,
  }) {
    if (entries.isEmpty || currentIndex < 0) {
      return (entries: const [], currentIndex: -1);
    }
    final start = math.max(0, currentIndex - math.max(0, before)).toInt();
    final end = math
        .min(entries.length, currentIndex + math.max(0, after) + 1)
        .toInt();
    return (
      entries: List.unmodifiable(entries.sublist(start, end)),
      currentIndex: currentIndex - start,
    );
  }
}
