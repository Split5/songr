import 'package:drift/drift.dart';

import '../../domain/playback/logical_queue.dart';
import '../../domain/playback/queue_session_repository.dart';
import 'app_database.dart';

class DriftQueueSessionRepository implements QueueSessionRepository {
  const DriftQueueSessionRepository(this.database);

  static const sessionId = 'active';
  final AppDatabase database;

  @override
  Future<PersistedQueueSession?> load() async {
    final session = await (database.select(
      database.localQueueSessions,
    )..where((row) => row.id.equals(sessionId))).getSingleOrNull();
    if (session?.currentEntryId == null) return null;
    final allRows =
        await (database.select(database.localQueueEntries)
              ..where((row) => row.sessionId.equals(sessionId))
              ..orderBy([(row) => OrderingTerm.asc(row.position)]))
            .get();
    if (allRows.isEmpty) return null;
    final joined =
        await (database.select(database.localQueueEntries).join([
                innerJoin(
                  database.localSongs,
                  database.localSongs.id.equalsExp(
                    database.localQueueEntries.songId,
                  ),
                ),
              ])
              ..where(database.localQueueEntries.sessionId.equals(sessionId))
              ..orderBy([
                OrderingTerm.asc(database.localQueueEntries.position),
              ]))
            .get();
    final rows = joined
        .map((row) => row.readTable(database.localQueueEntries))
        .toList(growable: false);
    if (rows.isEmpty) return null;
    var currentEntryId = session!.currentEntryId!;
    if (!rows.any((row) => row.entryId == currentEntryId)) {
      final oldIndex = allRows.indexWhere(
        (row) => row.entryId == currentEntryId,
      );
      final oldPosition = oldIndex < 0 ? 0 : allRows[oldIndex].position;
      String? replacement;
      for (final row in rows) {
        if (row.position >= oldPosition) {
          replacement = row.entryId;
          break;
        }
      }
      currentEntryId = replacement ?? rows.last.entryId;
    }
    return PersistedQueueSession(
      entries: rows
          .map((row) => LogicalQueueEntry(id: row.entryId, songId: row.songId))
          .toList(growable: false),
      currentEntryId: currentEntryId,
      autoPlayEnabled: session.autoPlayEnabled,
      position: Duration(milliseconds: session.positionMilliseconds),
      updatedAt: session.updatedAt,
    );
  }

  @override
  Future<void> save({
    required LogicalQueue queue,
    required bool autoPlayEnabled,
    required Duration position,
  }) => database.transaction(() async {
    if (queue.entries.isEmpty || queue.current == null) {
      await (database.delete(
        database.localQueueEntries,
      )..where((row) => row.sessionId.equals(sessionId))).go();
      await (database.delete(
        database.localQueueSessions,
      )..where((row) => row.id.equals(sessionId))).go();
      return;
    }
    await database
        .into(database.localQueueSessions)
        .insertOnConflictUpdate(
          LocalQueueSessionsCompanion.insert(
            id: sessionId,
            currentEntryId: Value(queue.current!.id),
            autoPlayEnabled: Value(autoPlayEnabled),
            positionMilliseconds: Value(
              position.isNegative ? 0 : position.inMilliseconds,
            ),
            updatedAt: DateTime.now(),
          ),
        );
    await (database.delete(
      database.localQueueEntries,
    )..where((row) => row.sessionId.equals(sessionId))).go();
    await database.batch(
      (batch) => batch.insertAll(database.localQueueEntries, [
        for (var index = 0; index < queue.entries.length; index++)
          LocalQueueEntriesCompanion.insert(
            sessionId: sessionId,
            entryId: queue.entries[index].id,
            songId: queue.entries[index].songId,
            position: index,
          ),
      ]),
    );
  });

  @override
  Future<void> updatePosition(Duration position) =>
      (database.update(
        database.localQueueSessions,
      )..where((row) => row.id.equals(sessionId))).write(
        LocalQueueSessionsCompanion(
          positionMilliseconds: Value(
            position.isNegative ? 0 : position.inMilliseconds,
          ),
          updatedAt: Value(DateTime.now()),
        ),
      );

  @override
  Future<void> clear() => database.transaction(() async {
    await (database.delete(
      database.localQueueEntries,
    )..where((row) => row.sessionId.equals(sessionId))).go();
    await (database.delete(
      database.localQueueSessions,
    )..where((row) => row.id.equals(sessionId))).go();
  });
}
