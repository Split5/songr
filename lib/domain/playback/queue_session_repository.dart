import 'logical_queue.dart';

class PersistedQueueSession {
  const PersistedQueueSession({
    required this.entries,
    required this.currentEntryId,
    required this.autoPlayEnabled,
    required this.position,
    required this.updatedAt,
  });

  final List<LogicalQueueEntry> entries;
  final String currentEntryId;
  final bool autoPlayEnabled;
  final Duration position;
  final DateTime updatedAt;
}

abstract interface class QueueSessionRepository {
  Future<PersistedQueueSession?> load();
  Future<void> save({
    required LogicalQueue queue,
    required bool autoPlayEnabled,
    required Duration position,
  });
  Future<void> updatePosition(Duration position);
  Future<void> clear();
}
