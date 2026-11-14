import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/domain/playback/auto_play_profile.dart';
import 'package:navimusic/domain/playback/logical_queue.dart';
import 'package:navimusic/domain/playback/playback_coordinator.dart';

void main() {
  late _FakeNativePlayback native;
  late _FakeAutoPlay autoPlay;
  late PlaybackCoordinator coordinator;

  setUp(() {
    native = _FakeNativePlayback();
    autoPlay = _FakeAutoPlay();
    coordinator = PlaybackCoordinator(
      nativePort: native,
      autoPlayCandidates: autoPlay,
    );
  });

  tearDown(() => coordinator.dispose());

  test('late completion cannot override a newer user selection', () async {
    await coordinator.replaceQueue(_entries(3), startEntryId: 'entry-0');
    final selection = coordinator.jumpTo('entry-2');
    final staleCompletion = coordinator.jumpTo(
      'entry-1',
      expectedCurrentEntryId: 'entry-0',
    );
    await selection;
    await staleCompletion;
    expect(coordinator.queue.current?.id, 'entry-2');
    expect(
      await coordinator.prepareNextEntry(expectedCurrentEntryId: 'entry-0'),
      isNull,
    );
    expect(autoPlay.calls, 0);
  });

  test(
    'jump keeps the complete queue and sends only a bounded native window',
    () async {
      final original = _entries(50);
      await coordinator.replaceQueue(original, startEntryId: 'entry-2');

      await coordinator.jumpTo('entry-35');

      expect(
        coordinator.queue.entries.map((entry) => entry.id),
        original.map((entry) => entry.id),
      );
      expect(coordinator.queue.current?.id, 'entry-35');
      expect(native.windows.last.entries, hasLength(20));
      expect(native.windows.last.entries.first.id, 'entry-30');
      expect(native.windows.last.currentIndex, 5);
    },
  );

  test(
    'native track change moves only the playhead, not the queue or window',
    () async {
      final original = _entries(12);
      await coordinator.replaceQueue(original, startEntryId: 'entry-0');
      final windowCount = native.windows.length;

      await coordinator.handleNativeCurrentEntry('entry-7');

      expect(coordinator.queue.current?.id, 'entry-7');
      expect(
        coordinator.queue.entries.map((entry) => entry.id),
        original.map((entry) => entry.id),
      );
      expect(native.windows, hasLength(windowCount));
    },
  );

  test(
    'native window advances near its end without changing logical entries',
    () async {
      final original = _entries(50);
      await coordinator.replaceQueue(original, startEntryId: 'entry-0');

      await coordinator.handleNativeCurrentEntry('entry-14');
      expect(native.windows, hasLength(1));
      await coordinator.handleNativeCurrentEntry('entry-15');

      expect(native.windows, hasLength(2));
      expect(native.reasons.last, QueueWindowUpdateReason.advance);
      expect(native.windows.last.entries.first.id, 'entry-10');
      expect(native.windows.last.entries.last.id, 'entry-35');
      expect(native.windows.last.currentIndex, 5);
      expect(
        coordinator.queue.entries.map((entry) => entry.id),
        original.map((entry) => entry.id),
      );
    },
  );

  test(
    'queue edits are serialized and keep the current occurrence stable',
    () async {
      await coordinator.replaceQueue(_entries(8), startEntryId: 'entry-4');
      final blocker = Completer<void>();
      native.blockNextReconcile = blocker;

      final first = coordinator.moveBefore('entry-0', 'entry-6');
      final second = coordinator.moveBefore('entry-7', 'entry-1');
      await Future<void>.delayed(Duration.zero);

      expect(native.reconcileCalls, 2); // replace + first edit entered
      // The list follows the finger before the platform answers: the first
      // move is already the published logical order while the native edit is
      // still blocked, and the playhead occurrence has not changed.
      expect(coordinator.queue.entries.first.id, 'entry-1');
      expect(coordinator.queue.entries[5].id, 'entry-0');
      expect(coordinator.queue.current?.id, 'entry-4');
      blocker.complete();
      await Future.wait([first, second]);

      expect(native.reconcileCalls, 3);
      expect(coordinator.queue.current?.id, 'entry-4');
      expect(coordinator.queue.entries.map((entry) => entry.id), [
        'entry-7',
        'entry-1',
        'entry-2',
        'entry-3',
        'entry-4',
        'entry-5',
        'entry-0',
        'entry-6',
      ]);
    },
  );

  test(
    'failed native reconcile leaves published logical state unchanged',
    () async {
      await coordinator.replaceQueue(_entries(6), startEntryId: 'entry-1');
      native.failNextReconcile = true;

      await expectLater(coordinator.jumpTo('entry-5'), throwsStateError);

      expect(coordinator.queue.current?.id, 'entry-1');
      expect(coordinator.queue.entries, hasLength(6));
    },
  );

  test(
    'AutoPlay appends five at exhaustion, then five more without rewriting',
    () async {
      await coordinator.replaceQueue(_entries(3), startEntryId: 'entry-2');
      autoPlay.responses.add([
        'song-1', // already queued
        for (var i = 3; i < 12; i++) 'song-$i',
      ]);
      autoPlay.responses.add([
        'song-4', // appended by the previous batch
        for (var i = 8; i < 18; i++) 'song-$i',
      ]);

      expect(await coordinator.handleQueueExhausted(), 5);
      final firstSnapshot = coordinator.queue.entries
          .map((e) => e.songId)
          .toList();
      expect(firstSnapshot, [
        'song-0',
        'song-1',
        'song-2',
        'song-3',
        'song-4',
        'song-5',
        'song-6',
        'song-7',
      ]);

      await coordinator.handleNativeCurrentEntry(
        coordinator.queue.entries.last.id,
      );
      expect(await coordinator.handleQueueExhausted(), 5);
      expect(
        coordinator.queue.entries
            .take(firstSnapshot.length)
            .map((e) => e.songId),
        firstSnapshot,
      );
      expect(
        coordinator.queue.entries
            .skip(firstSnapshot.length)
            .map((e) => e.songId),
        ['song-8', 'song-9', 'song-10', 'song-11', 'song-12'],
      );
      expect(autoPlay.excludedSets.last, containsAll(firstSnapshot));
    },
  );

  test(
    'next at the queue end loads a batch and returns its first entry',
    () async {
      await coordinator.replaceQueue(_entries(2), startEntryId: 'entry-1');
      autoPlay.responses.add(['autoplay-a', 'autoplay-b', 'autoplay-c']);

      final next = await coordinator.prepareNextEntry();

      expect(next?.songId, 'autoplay-a');
      expect(coordinator.queue.current?.songId, 'song-1');
      expect(coordinator.queue.entries.map((entry) => entry.songId), [
        'song-0',
        'song-1',
        'autoplay-a',
        'autoplay-b',
        'autoplay-c',
      ]);
      expect(native.reasons.last, QueueWindowUpdateReason.autoPlay);
      expect(await coordinator.handleQueueExhausted(), 0);
    },
  );

  test('disabled AutoPlay never requests or mutates candidates', () async {
    await coordinator.replaceQueue(_entries(2), startEntryId: 'entry-1');
    await coordinator.setAutoPlay(false);

    expect(await coordinator.handleQueueExhausted(), 0);
    expect(autoPlay.calls, 0);
    expect(coordinator.queue.entries, hasLength(2));
  });

  test(
    'similarity mix starts at the seed and queues initial candidates',
    () async {
      autoPlay.responses.add([
        for (var index = 1; index <= 24; index++) 'sonic-$index',
      ]);
      const seed = LogicalQueueEntry(id: 'sonic-seed', songId: 'seed-song');

      await coordinator.startAutoPlayMix(seed, initialCandidateCount: 20);

      expect(coordinator.queue.current, seed);
      expect(coordinator.queue.entries.first, seed);
      expect(coordinator.queue.entries, hasLength(21));
      expect(coordinator.queue.entries.skip(1).map((entry) => entry.songId), [
        for (var index = 1; index <= 20; index++) 'sonic-$index',
      ]);
      expect(native.playCalls, 1);
      expect(native.reasons.last, QueueWindowUpdateReason.autoPlay);
    },
  );

  test('live AutoPlay profile controls the initial mix', () async {
    final profiledNative = _FakeNativePlayback();
    final profiledAutoPlay = _FakeAutoPlay()
      ..responses.add([
        for (var index = 0; index < 30; index++) 'profile-$index',
      ]);
    final profiled = PlaybackCoordinator(
      nativePort: profiledNative,
      autoPlayCandidates: profiledAutoPlay,
      autoPlayProfile: () => const AutoPlayProfile(
        exploration: 0.7,
        maxSongsPerArtist: 4,
        initialCandidateCount: 10,
      ),
    );
    addTearDown(profiled.dispose);

    await profiled.startAutoPlayMix(
      const LogicalQueueEntry(id: 'seed', songId: 'song-seed'),
    );

    expect(profiledAutoPlay.limits.single, 10);
    expect(profiledAutoPlay.profiles.single.exploration, 0.7);
    expect(profiledAutoPlay.profiles.single.maxSongsPerArtist, 4);
    expect(profiled.queue.entries, hasLength(11));
  });

  test('a stale similarity response cannot modify a newer queue', () async {
    final pending = Completer<List<String>>();
    autoPlay.pendingResponse = pending;
    const oldSeed = LogicalQueueEntry(id: 'old-seed', songId: 'old-song');
    const newSeed = LogicalQueueEntry(id: 'new-seed', songId: 'new-song');

    final oldMix = coordinator.startAutoPlayMix(oldSeed);
    await Future<void>.delayed(Duration.zero);
    await coordinator.replaceQueue([newSeed], startEntryId: newSeed.id);
    pending.complete(['late-candidate']);
    await oldMix;

    expect(coordinator.queue.entries, [newSeed]);
    expect(coordinator.queue.current, newSeed);
  });

  test('a playback-lifetime play future never blocks pause', () async {
    final playbackLifetime = Completer<void>();
    native.playbackLifetime = playbackLifetime;

    await coordinator
        .replaceQueue(_entries(2), startEntryId: 'entry-0')
        .timeout(const Duration(seconds: 1));
    await coordinator.pause().timeout(const Duration(seconds: 1));

    expect(native.playCalls, 1);
    expect(native.pauseCalls, 1);
    expect(playbackLifetime.isCompleted, isFalse);
    playbackLifetime.complete();
  });

  test('an explicit station handoff can clear the queue atomically', () async {
    await coordinator.replaceQueue(_entries(4), startEntryId: 'entry-1');

    await coordinator.clear();

    expect(coordinator.queue.entries, isEmpty);
    expect(coordinator.queue.currentIndex, -1);
    expect(native.windows.last.entries, isEmpty);
    expect(native.reasons.last, QueueWindowUpdateReason.replace);
  });

  test('queueReady waits for the lookahead handed to the player', () async {
    final native = _FakeNativePlayback();
    addTearDown(() => native.playbackLifetime?.complete());
    final coordinator = PlaybackCoordinator(nativePort: native);
    final fill = Completer<void>();
    native.windowFill = fill;

    await coordinator.replaceQueue(_entries(3), startEntryId: 'entry-0');
    var ready = false;
    final waiting = coordinator.queueReady.then((_) => ready = true);
    await Future<void>.delayed(Duration.zero);
    expect(ready, isFalse, reason: 'the lookahead is still filling');

    fill.complete();
    await waiting;
    expect(ready, isTrue);
    await coordinator.dispose();
  });
}

List<LogicalQueueEntry> _entries(int count) => [
  for (var i = 0; i < count; i++)
    LogicalQueueEntry(id: 'entry-$i', songId: 'song-$i'),
];

class _FakeNativePlayback implements NativePlaybackPort {
  final List<NativeQueueWindow> windows = [];
  final List<QueueWindowUpdateReason> reasons = [];
  int reconcileCalls = 0;
  int playCalls = 0;
  int pauseCalls = 0;
  bool failNextReconcile = false;
  Completer<void>? blockNextReconcile;
  Completer<void>? playbackLifetime;

  @override
  Future<void> reconcileQueueWindow(
    NativeQueueWindow window, {
    required QueueWindowUpdateReason reason,
  }) async {
    reconcileCalls++;
    final blocker = blockNextReconcile;
    blockNextReconcile = null;
    if (blocker != null) await blocker.future;
    if (failNextReconcile) {
      failNextReconcile = false;
      throw StateError('native player rejected window');
    }
    windows.add(window);
    reasons.add(reason);
  }

  Completer<void>? windowFill;

  @override
  Future<void> get windowReady => windowFill?.future ?? Future<void>.value();

  @override
  Future<void> pause() async => pauseCalls++;

  @override
  Future<void> play() {
    playCalls++;
    return playbackLifetime?.future ?? Future.value();
  }
}

class _FakeAutoPlay implements AutoPlayCandidateProvider {
  final List<List<String>> responses = [];
  final List<Set<String>> excludedSets = [];
  final List<int> limits = [];
  final List<AutoPlayProfile> profiles = [];
  int calls = 0;
  Completer<List<String>>? pendingResponse;

  @override
  Future<List<String>> candidates({
    required String seedSongId,
    required Set<String> excludedSongIds,
    required int limit,
    required AutoPlayProfile profile,
  }) async {
    excludedSets.add(Set.of(excludedSongIds));
    limits.add(limit);
    profiles.add(profile);
    final pending = pendingResponse;
    pendingResponse = null;
    if (pending != null) {
      calls++;
      return pending.future;
    }
    return responses[calls++];
  }
}
