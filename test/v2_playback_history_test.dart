import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/data/local/app_database.dart';
import 'package:navimusic/data/local/drift_playback_history_repository.dart';
import 'package:navimusic/domain/playback/scrobble_tracker.dart';

void main() {
  late AppDatabase database;
  late DriftPlaybackHistoryRepository history;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    history = DriftPlaybackHistoryRepository(database);
  });

  tearDown(() => database.close());

  test('a playback occurrence is counted exactly once', () async {
    await database.upsertSongs([_song('song-1', playCount: 10)]);
    final startedAt = DateTime.utc(2026, 8, 28, 10);
    final playedAt = startedAt.add(const Duration(minutes: 2));

    await history.beginPlayback(
      playbackId: 'play-1',
      songId: 'song-1',
      startedAt: startedAt,
      duration: const Duration(minutes: 4),
    );
    expect(
      await history.markPlayed(playbackId: 'play-1', at: playedAt),
      isTrue,
    );
    expect(
      await history.markPlayed(playbackId: 'play-1', at: playedAt),
      isFalse,
    );

    final activity = await database
        .select(database.localSongActivities)
        .getSingle();
    expect(activity.localPlayCount, 1);
    expect(activity.unacknowledgedPlayCount, 1);
    expect(activity.serverPlayCountSeen, 10);
    final recent = await history.watchRecentlyPlayed().first;
    expect(recent.single.song.id, 'song-1');
    expect(recent.single.playedAt.toUtc(), playedAt);
    expect(recent.single.effectivePlayCount, 11);
  });

  test(
    'a server refresh acknowledges the local delta without deleting history',
    () async {
      await database.upsertSongs([_song('song-1', playCount: 10)]);
      await history.beginPlayback(
        playbackId: 'play-1',
        songId: 'song-1',
        startedAt: DateTime.utc(2026, 8, 28, 10),
        duration: const Duration(minutes: 3),
      );
      await history.markPlayed(
        playbackId: 'play-1',
        at: DateTime.utc(2026, 8, 28, 10, 2),
      );

      await database.beginSongStaging();
      await database.stageSongs([_stagedSong('song-1', playCount: 11)]);
      await database.commitStagedSongs();

      final activity = await database
          .select(database.localSongActivities)
          .getSingle();
      expect(activity.localPlayCount, 1);
      expect(activity.unacknowledgedPlayCount, 0);
      expect(activity.serverPlayCountSeen, 11);
      expect(
        await database.select(database.localPlayEvents).get(),
        hasLength(1),
      );
      expect(
        (await history.watchRecentlyPlayed().first).single.effectivePlayCount,
        11,
      );
    },
  );

  test('recent history is ordered by the latest completed play', () async {
    await database.upsertSongs([_song('older'), _song('newer')]);
    for (final record in [
      ('older', DateTime.utc(2026, 8, 28, 8)),
      ('newer', DateTime.utc(2026, 8, 28, 9)),
    ]) {
      await history.beginPlayback(
        playbackId: 'play-${record.$1}',
        songId: record.$1,
        startedAt: record.$2,
        duration: const Duration(minutes: 3),
      );
      await history.markPlayed(
        playbackId: 'play-${record.$1}',
        at: record.$2.add(const Duration(minutes: 2)),
      );
    }

    final recent = await history.watchRecentlyPlayed().first;
    expect(recent.map((item) => item.song.id), ['newer', 'older']);
  });

  test('ScrobbleTracker persists start, threshold and completion', () async {
    await database.upsertSongs([_song('song-1')]);
    final times = <DateTime>[
      DateTime.utc(2026, 8, 28, 10),
      DateTime.utc(2026, 8, 28, 10, 1),
      DateTime.utc(2026, 8, 28, 10, 3),
    ];
    var timeIndex = 0;
    final sink = _Sink();
    final tracker = ScrobbleTracker(
      sink: sink,
      history: history,
      clock: () => times[timeIndex++],
    );

    await tracker.start(
      playbackId: 'play-1',
      songId: 'song-1',
      duration: const Duration(minutes: 2),
    );
    await tracker.position(
      playbackId: 'play-1',
      position: const Duration(minutes: 1),
    );
    await tracker.completed(playbackId: 'play-1');
    await tracker.dispose();

    final event = await database.select(database.localPlayEvents).getSingle();
    expect(event.scrobbledAt?.toUtc(), times[1]);
    expect(event.completedAt?.toUtc(), times[2]);
    expect(sink.submitted, ['song-1']);
  });

  test('ending a skipped playback is idempotent', () async {
    await database.upsertSongs([_song('song-1')]);
    final startedAt = DateTime.utc(2026, 8, 28, 10);
    await history.beginPlayback(
      playbackId: 'play-1',
      songId: 'song-1',
      startedAt: startedAt,
      duration: const Duration(minutes: 3),
    );
    await history.endPlayback(
      playbackId: 'play-1',
      at: startedAt.add(const Duration(seconds: 10)),
      skipped: true,
    );
    await history.endPlayback(
      playbackId: 'play-1',
      at: startedAt.add(const Duration(seconds: 11)),
      skipped: true,
    );

    final activity = await database
        .select(database.localSongActivities)
        .getSingle();
    expect(activity.skipCount, 1);
    final event = await database.select(database.localPlayEvents).getSingle();
    expect(event.skipped, isTrue);
  });
}

class _Sink implements ScrobbleSink {
  final List<String> submitted = [];

  @override
  Future<void> announceStart(String songId) async {}

  @override
  Future<void> submitPlay(String songId) async => submitted.add(songId);
}

LocalSongsCompanion _song(String id, {int playCount = 0}) =>
    LocalSongsCompanion.insert(
      id: id,
      title: 'Song $id',
      artist: 'Artist $id',
      album: 'Album $id',
      playCount: Value(playCount),
    );

StagedSongsCompanion _stagedSong(String id, {int playCount = 0}) =>
    StagedSongsCompanion.insert(
      id: id,
      title: 'Song $id',
      artist: 'Artist $id',
      album: 'Album $id',
      playCount: Value(playCount),
    );
