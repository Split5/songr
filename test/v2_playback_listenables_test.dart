import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:navimusic/domain/playback/auto_play_profile.dart';
import 'package:navimusic/domain/playback/just_audio_native_port.dart';
import 'package:navimusic/domain/playback/playback_coordinator.dart';
import 'package:navimusic/domain/playback/playback_media_resolver.dart';
import 'package:navimusic/domain/playback/scrobble_tracker.dart';
import 'package:navimusic/features/player/v2_playback_controller.dart';
import 'package:navimusic/models/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AudioPlayer player;
  late PlaybackCoordinator coordinator;
  late V2PlaybackController controller;

  setUp(() {
    // An idle just_audio player never touches the platform until a source
    // is loaded, which is enough to observe the player state stream.
    player = AudioPlayer();
    coordinator = PlaybackCoordinator(
      nativePort: _FakeNative(),
      autoPlayCandidates: _FakeAutoPlay(),
    );
    controller = V2PlaybackController(
      nativePort: JustAudioNativePort(resolver: _Resolver(), player: player),
      coordinator: coordinator,
      scrobbleTracker: ScrobbleTracker(sink: _Sink()),
    );
  });

  tearDown(() => controller.shutdown());

  test('currentSongIdListenable follows the queue playhead', () async {
    final seen = <String?>[];
    controller.currentSongIdListenable.addListener(
      () => seen.add(controller.currentSongIdListenable.value),
    );
    expect(controller.currentSongIdListenable.value, isNull);

    await controller.playSongs([_song('a'), _song('b'), _song('c')]);
    await _untilValue(controller.currentSongIdListenable, 'a');
    expect(controller.isCurrent('a'), isTrue);
    expect(controller.isCurrent('b'), isFalse);

    final next = controller.queue.entries[1].id;
    await coordinator.handleNativeCurrentEntry(next);
    await _untilValue(controller.currentSongIdListenable, 'b');
    expect(seen, ['a', 'b']);
  });

  test('currentSong follows the selected queue item', () async {
    await controller.playSongs([
      _song('a'),
      _song('b'),
      _song('c'),
    ], startIndex: 2);

    await _untilValue(controller.currentSongIdListenable, 'c');
    expect(controller.currentSong?.id, 'c');
  });

  test('playingListenable mirrors the player state', () async {
    final seen = <bool>[];
    controller.playingListenable.addListener(
      () => seen.add(controller.playingListenable.value),
    );
    expect(controller.playingListenable.value, isFalse);

    // ignore: unawaited_futures
    player.play();
    await _untilValue(controller.playingListenable, true);
    expect(controller.playing, isTrue);

    await player.pause();
    await _untilValue(controller.playingListenable, false);
    expect(seen, [true, false]);
  });

  test(
    'next at the queue end waits for AutoPlay and selects its first song',
    () async {
      final autoPlay = _FakeAutoPlay()
        ..responses.add(['autoplay-a', 'autoplay-b']);
      final localCoordinator = PlaybackCoordinator(
        nativePort: _FakeNative(),
        autoPlayCandidates: autoPlay,
      );
      final localController = V2PlaybackController(
        nativePort: JustAudioNativePort(resolver: _Resolver(), player: player),
        coordinator: localCoordinator,
        scrobbleTracker: ScrobbleTracker(sink: _Sink()),
      );
      addTearDown(localController.shutdown);

      await localController.playSongs([_song('a'), _song('b')]);
      await localController.jumpTo(localController.queue.entries.last.id);
      await localController.next();

      expect(localController.queue.entries, hasLength(4));
      expect(localController.queue.current?.songId, 'autoplay-a');
      expect(autoPlay.calls, 1);
    },
  );
}

/// Completes as soon as [listenable] reports [expected] (immediately when it
/// already does), so the tests never wait on wall-clock delays for the
/// player state stream. Fails after a bounded timeout instead of hanging.
Future<void> _untilValue<T>(ValueListenable<T> listenable, T expected) {
  if (listenable.value == expected) return Future.value();
  final reached = Completer<void>();
  void check() {
    if (listenable.value != expected || reached.isCompleted) return;
    listenable.removeListener(check);
    reached.complete();
  }

  listenable.addListener(check);
  return reached.future.timeout(
    const Duration(seconds: 5),
    onTimeout: () {
      listenable.removeListener(check);
      fail('$listenable never reached $expected');
    },
  );
}

Song _song(String id) => Song(
  id: id,
  title: 'Song $id',
  artist: 'Artist',
  artistId: 'artist',
  album: 'Album',
  albumId: 'album',
);

class _Resolver implements PlaybackMediaResolver {
  @override
  Future<ResolvedPlaybackMedia> resolve(String songId) =>
      throw UnimplementedError('no media is loaded in this test');
}

class _Sink implements ScrobbleSink {
  @override
  Future<void> announceStart(String songId) async {}

  @override
  Future<void> submitPlay(String songId) async {}
}

class _FakeNative implements NativePlaybackPort {
  @override
  Future<void> reconcileQueueWindow(
    NativeQueueWindow window, {
    required QueueWindowUpdateReason reason,
  }) async {}

  @override
  Future<void> get windowReady => Future<void>.value();

  @override
  Future<void> pause() async {}

  @override
  Future<void> play() async {}
}

class _FakeAutoPlay implements AutoPlayCandidateProvider {
  final List<List<String>> responses = [];
  int calls = 0;

  @override
  Future<List<String>> candidates({
    required String seedSongId,
    required Set<String> excludedSongIds,
    required int limit,
    required AutoPlayProfile profile,
  }) async => calls < responses.length ? responses[calls++] : const [];
}
