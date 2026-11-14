import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:navimusic/domain/playback/just_audio_native_port.dart';
import 'package:navimusic/domain/playback/auto_play_profile.dart';
import 'package:navimusic/domain/playback/logical_queue.dart';
import 'package:navimusic/domain/playback/playback_coordinator.dart';
import 'package:navimusic/domain/playback/playback_media_resolver.dart';
import 'package:navimusic/domain/playback/scrobble_tracker.dart';
import 'package:navimusic/features/player/v2_playback_controller.dart';
import 'package:navimusic/models/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'completion at the logical tail starts the first AutoPlay song',
    () async {
      final player = _Player();
      player.finishAppend.complete();
      final port = JustAudioNativePort(player: player, resolver: _Resolver());
      final coordinator = PlaybackCoordinator(
        nativePort: port,
        autoPlayCandidates: _AutoPlay(),
      );
      final controller = V2PlaybackController(
        nativePort: port,
        coordinator: coordinator,
        scrobbleTracker: ScrobbleTracker(sink: _Sink()),
      );
      addTearDown(() async {
        await controller.shutdown();
        await player.states.close();
      });
      await coordinator.replaceQueue(const [
        LogicalQueueEntry(id: 'first', songId: 'first'),
      ], startEntryId: 'first');
      final advanced = coordinator.queueChanges.firstWhere(
        (q) => q.current?.songId == 'autoplay',
      );
      player.states.add(PlayerState(true, ProcessingState.completed));
      await advanced.timeout(const Duration(seconds: 2));
      expect(port.currentMedia?.song.id, 'autoplay');
      expect(player.plays, 2);
    },
  );
  test(
    'completion waits for lookahead and starts the existing next song',
    () async {
      final player = _Player();
      final port = JustAudioNativePort(player: player, resolver: _Resolver());
      final coordinator = PlaybackCoordinator(nativePort: port);
      final controller = V2PlaybackController(
        nativePort: port,
        coordinator: coordinator,
        scrobbleTracker: ScrobbleTracker(sink: _Sink()),
      );
      addTearDown(() async {
        await controller.shutdown();
        await player.states.close();
      });
      await controller.playSongs([
        for (final id in ['first', 'second'])
          Song(
            id: id,
            title: id,
            artist: 'Artist',
            album: 'Album',
            albumId: '',
            artistId: '',
          ),
      ]);
      // The lookahead is held back until playback starts; release it so the
      // next song is in the native queue before the first one completes.
      await port.releaseLookahead();
      await player.appendStarted.future;
      final advanced = coordinator.queueChanges.firstWhere(
        (q) => q.current?.songId == 'second',
      );
      player.states.add(PlayerState(true, ProcessingState.completed));
      await Future<void>.delayed(Duration.zero);
      player.finishAppend.complete();
      await advanced.timeout(const Duration(seconds: 2));
      expect(port.currentMedia?.song.id, 'second');
      expect(player.plays, 2);
    },
  );
  test('jumping before the prepared history loads the selected song', () async {
    final player = _Player();
    final port = JustAudioNativePort(player: player, resolver: _Resolver());
    addTearDown(port.dispose);
    final entries = [
      for (var i = 0; i < 12; i++)
        LogicalQueueEntry(id: 'song-$i', songId: 'song-$i'),
    ];
    await port.reconcileQueueWindow(
      NativeQueueWindow(entries: entries, currentIndex: 5),
      reason: QueueWindowUpdateReason.replace,
    );
    await port.releaseLookahead();
    await player.appendStarted.future;
    player.finishAppend.complete();
    await port.windowReady;
    await port.reconcileQueueWindow(
      NativeQueueWindow(entries: entries, currentIndex: 0),
      reason: QueueWindowUpdateReason.jump,
    );
    expect(port.currentMedia?.song.id, 'song-0');
    await port.windowReady;
  });
  test(
    'a new selection cancels old lookahead after its current insert',
    () async {
      final player = _Player();
      final resolver = _Resolver();
      final port = JustAudioNativePort(player: player, resolver: resolver);
      addTearDown(port.dispose);
      final old = [
        for (var i = 0; i < 12; i++)
          LogicalQueueEntry(id: 'old-$i', songId: 'old-$i'),
      ];
      await port.reconcileQueueWindow(
        NativeQueueWindow(entries: old, currentIndex: 0),
        reason: QueueWindowUpdateReason.replace,
      );
      await port.releaseLookahead();
      await player.appendStarted.future;
      final replacement = port.reconcileQueueWindow(
        const NativeQueueWindow(
          entries: [LogicalQueueEntry(id: 'new', songId: 'new')],
          currentIndex: 0,
        ),
        reason: QueueWindowUpdateReason.replace,
      );
      player.finishAppend.complete();
      await replacement;
      expect(resolver.resolved, isNot(contains('old-11')));
      expect(port.entries.single.songId, 'new');
    },
  );
}

class _Player extends AudioPlayer {
  final states = StreamController<PlayerState>.broadcast();
  int plays = 0;
  @override
  Stream<PlayerState> get playerStateStream => states.stream;
  @override
  Future<void> play() async {
    plays++;
  }

  @override
  Future<void> seek(Duration? position, {int? index}) async {
    _index = index ?? _index;
  }

  final appendStarted = Completer<void>();
  final finishAppend = Completer<void>();
  int _index = 0;
  @override
  int? get currentIndex => _index;
  @override
  Future<Duration?> setAudioSources(
    List<AudioSource> sources, {
    bool preload = true,
    int? initialIndex,
    Duration? initialPosition,
    ShuffleOrder? shuffleOrder,
  }) async {
    _index = initialIndex ?? 0;
    return Duration.zero;
  }

  @override
  Future<void> insertAudioSource(int index, AudioSource source) async {
    if (!appendStarted.isCompleted) {
      appendStarted.complete();
      await finishAppend.future;
    }
  }
}

class _Sink implements ScrobbleSink {
  @override
  Future<void> announceStart(String songId) async {}
  @override
  Future<void> submitPlay(String songId) async {}
}

class _AutoPlay implements AutoPlayCandidateProvider {
  @override
  Future<List<String>> candidates({
    required String seedSongId,
    required Set<String> excludedSongIds,
    required int limit,
    required AutoPlayProfile profile,
  }) async => ['autoplay'];
}

class _Resolver implements PlaybackMediaResolver {
  final resolved = <String>[];
  @override
  Future<ResolvedPlaybackMedia> resolve(String id) async {
    resolved.add(id);
    return ResolvedPlaybackMedia(
      song: Song(
        id: id,
        title: id,
        artist: 'Artist',
        album: 'Album',
        albumId: '',
        artistId: '',
      ),
      uri: Uri.parse('https://music.example/$id'),
    );
  }
}
