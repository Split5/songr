import '../../models/models.dart';

class RecentlyPlayedSong {
  const RecentlyPlayedSong({
    required this.song,
    required this.playedAt,
    required this.effectivePlayCount,
  });

  final Song song;
  final DateTime playedAt;
  final int effectivePlayCount;
}

/// Narrow write contract consumed by the playback layer.
abstract interface class PlaybackHistoryRecorder {
  Future<void> beginPlayback({
    required String playbackId,
    required String songId,
    required DateTime startedAt,
    required Duration duration,
  });

  Future<bool> markPlayed({required String playbackId, required DateTime at});

  Future<void> completePlayback({
    required String playbackId,
    required DateTime at,
  });

  Future<void> endPlayback({
    required String playbackId,
    required DateTime at,
    bool skipped = false,
  });
}

abstract interface class PlaybackHistoryRepository
    implements PlaybackHistoryRecorder {
  Stream<List<RecentlyPlayedSong>> watchRecentlyPlayed({int limit = 40});
}
