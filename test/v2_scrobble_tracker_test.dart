import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/domain/playback/scrobble_tracker.dart';

void main() {
  late _FakeScrobbleSink sink;
  late ScrobbleTracker tracker;

  setUp(() {
    sink = _FakeScrobbleSink();
    tracker = ScrobbleTracker(sink: sink);
  });

  tearDown(() => tracker.dispose());

  test('three-minute song submits at 50 percent, exactly once', () async {
    await tracker.start(
      playbackId: 'play-1',
      songId: 'song-1',
      duration: const Duration(minutes: 3),
    );

    await tracker.position(
      playbackId: 'play-1',
      position: const Duration(seconds: 89),
    );
    expect(sink.submitted, isEmpty);
    await tracker.position(
      playbackId: 'play-1',
      position: const Duration(seconds: 90),
    );
    await tracker.position(
      playbackId: 'play-1',
      position: const Duration(seconds: 170),
    );

    expect(sink.announced, ['song-1']);
    expect(sink.submitted, ['song-1']);
  });

  test('long song submits at four minutes before its halfway point', () async {
    await tracker.start(
      playbackId: 'play-long',
      songId: 'song-long',
      duration: const Duration(minutes: 10),
    );

    await tracker.position(
      playbackId: 'play-long',
      position: const Duration(minutes: 3, seconds: 59),
    );
    expect(sink.submitted, isEmpty);
    await tracker.position(
      playbackId: 'play-long',
      position: const Duration(minutes: 4),
    );

    expect(sink.submitted, ['song-long']);
  });

  test('concurrent position callbacks cannot double-submit', () async {
    await tracker.start(
      playbackId: 'play-1',
      songId: 'song-1',
      duration: const Duration(minutes: 2),
    );
    final blocker = Completer<void>();
    sink.blockNextSubmit = blocker;

    final updates = [
      tracker.position(
        playbackId: 'play-1',
        position: const Duration(seconds: 60),
      ),
      tracker.position(
        playbackId: 'play-1',
        position: const Duration(seconds: 70),
      ),
      tracker.completed(playbackId: 'play-1'),
    ];
    await Future<void>.delayed(Duration.zero);
    expect(sink.submitCalls, 1);
    blocker.complete();
    await Future.wait(updates);

    expect(sink.submitCalls, 1);
    expect(sink.submitted, ['song-1']);
  });

  test(
    'repeat with a new playback id may submit the same song again',
    () async {
      for (final playbackId in ['first', 'repeat']) {
        await tracker.start(
          playbackId: playbackId,
          songId: 'same-song',
          duration: const Duration(seconds: 100),
        );
        await tracker.position(
          playbackId: playbackId,
          position: const Duration(seconds: 50),
        );
      }

      expect(sink.announced, ['same-song', 'same-song']);
      expect(sink.submitted, ['same-song', 'same-song']);
    },
  );

  test('stale events from the previous track are ignored', () async {
    await tracker.start(
      playbackId: 'old-play',
      songId: 'old-song',
      duration: const Duration(minutes: 3),
    );
    await tracker.start(
      playbackId: 'new-play',
      songId: 'new-song',
      duration: const Duration(minutes: 3),
    );

    await tracker.completed(playbackId: 'old-play');
    await tracker.position(
      playbackId: 'new-play',
      position: const Duration(seconds: 90),
    );

    expect(sink.submitted, ['new-song']);
  });

  test('an ambiguous failed submission is not sent twice', () async {
    await tracker.start(
      playbackId: 'play-1',
      songId: 'song-1',
      duration: const Duration(seconds: 60),
    );
    sink.failNextSubmit = true;

    await expectLater(
      tracker.position(
        playbackId: 'play-1',
        position: const Duration(seconds: 30),
      ),
      throwsStateError,
    );
    expect(tracker.submitted, isTrue);

    await tracker.position(
      playbackId: 'play-1',
      position: const Duration(seconds: 31),
    );
    expect(tracker.submitted, isTrue);
    expect(sink.submitCalls, 1);
    expect(sink.submitted, isEmpty);
  });

  test('completion fills a missing background position event', () async {
    await tracker.start(
      playbackId: 'background-play',
      songId: 'song-background',
      duration: const Duration(minutes: 3),
    );

    await tracker.completed(playbackId: 'background-play');

    expect(sink.submitted, ['song-background']);
  });
}

class _FakeScrobbleSink implements ScrobbleSink {
  final List<String> announced = [];
  final List<String> submitted = [];
  int submitCalls = 0;
  bool failNextSubmit = false;
  Completer<void>? blockNextSubmit;

  @override
  Future<void> announceStart(String songId) async => announced.add(songId);

  @override
  Future<void> submitPlay(String songId) async {
    submitCalls++;
    final blocker = blockNextSubmit;
    blockNextSubmit = null;
    if (blocker != null) await blocker.future;
    if (failNextSubmit) {
      failNextSubmit = false;
      throw StateError('server unavailable');
    }
    submitted.add(songId);
  }
}
