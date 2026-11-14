import 'package:drift/drift.dart';

import '../../domain/lyrics/lyrics_service.dart';
import 'app_database.dart';

class DriftLyricsCache implements LyricsCache {
  const DriftLyricsCache(this.database);

  final AppDatabase database;

  @override
  Future<CachedLyrics?> read(String songId) async {
    final row = await (database.select(
      database.localLyrics,
    )..where((item) => item.songId.equals(songId))).getSingleOrNull();
    if (row == null) return null;
    return CachedLyrics(lrc: row.lrc, fetchedAt: row.fetchedAt);
  }

  @override
  Future<void> write(String songId, String? lrc) => database
      .into(database.localLyrics)
      .insertOnConflictUpdate(
        LocalLyricsCompanion.insert(
          songId: songId,
          lrc: Value(lrc),
          fetchedAt: DateTime.now(),
        ),
      );
}
