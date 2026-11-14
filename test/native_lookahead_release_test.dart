import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:navimusic/domain/playback/just_audio_native_port.dart';
import 'package:navimusic/domain/playback/logical_queue.dart';
import 'package:navimusic/domain/playback/playback_coordinator.dart';
import 'package:navimusic/domain/playback/playback_media_resolver.dart';
import 'package:navimusic/domain/playback/scrobble_tracker.dart';
import 'package:navimusic/features/player/v2_playback_controller.dart';
import 'package:navimusic/models/models.dart';

/// A freshly started queue used to open its whole lookahead immediately, which
/// put up to twenty stream requests on the network while the tapped song was
/// still starting. The window is now held back and released in two waves once
/// playback is audible.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a cold start prepares only the tapped song', () async {
    final player = _RecordingPlayer();
    final port = JustAudioNativePort(player: player, resolver: _Resolver());
    addTearDown(port.dispose);

    await port.reconcileQueueWindow(
      NativeQueueWindow(entries: _entries(25), currentIndex: 0),
      reason: QueueWindowUpdateReason.replace,
    );

    expect(port.entries, hasLength(1));
    expect(port.hasDeferredLookahead, isTrue);
    expect(player.inserts, 0, reason: 'nothing may be opened yet');
    // Starting playback must not wait for the lookahead.
    await port.windowReady.timeout(const Duration(milliseconds: 200));
  });

  test('the first wave stays small and the rest follows later', () async {
    final player = _RecordingPlayer();
    final port = JustAudioNativePort(player: player, resolver: _Resolver());
    addTearDown(port.dispose);

    await port.reconcileQueueWindow(
      NativeQueueWindow(entries: _entries(25), currentIndex: 0),
      reason: QueueWindowUpdateReason.replace,
    );

    await port.releaseLookahead(limit: 4);
    await port.windowReady;
    expect(port.entries, hasLength(5));
    expect(port.hasDeferredLookahead, isTrue);

    await port.releaseLookahead();
    await port.windowReady;
    // This window holds all 25 entries; a coordinator window is 5 + 20 + 1.
    expect(port.entries, hasLength(25));
    expect(port.hasDeferredLookahead, isFalse);
  });

  test('a replacement window cancels a pending release', () async {
    final player = _RecordingPlayer();
    final port = JustAudioNativePort(player: player, resolver: _Resolver());
    addTearDown(port.dispose);

    await port.reconcileQueueWindow(
      NativeQueueWindow(entries: _entries(12), currentIndex: 0),
      reason: QueueWindowUpdateReason.replace,
    );
    expect(port.hasDeferredLookahead, isTrue);

    await port.reconcileQueueWindow(
      const NativeQueueWindow(
        entries: [LogicalQueueEntry(id: 'only', songId: 'only')],
        currentIndex: 0,
      ),
      reason: QueueWindowUpdateReason.replace,
    );
    expect(port.hasDeferredLookahead, isFalse);
    expect(port.entries.single.songId, 'only');
  });

  test('the controller releases after one second, then after five', () async {
    final player = _RecordingPlayer();
    final port = JustAudioNativePort(player: player, resolver: _Resolver());
    final coordinator = PlaybackCoordinator(nativePort: port);
    final controller = V2PlaybackController(
      nativePort: port,
      coordinator: coordinator,
      scrobbleTracker: ScrobbleTracker(sink: _Sink()),
    );
    addTearDown(controller.shutdown);

    await controller.playSongs(_songs(30), startIndex: 0);
    await Future<void>.delayed(Duration.zero);
    expect(port.entries, hasLength(1));

    player.positions.add(const Duration(milliseconds: 500));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(port.entries, hasLength(1), reason: 'still starting');

    player.positions.add(const Duration(milliseconds: 1200));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await port.windowReady;
    expect(port.entries, hasLength(5), reason: 'tapped song plus four');

    player.positions.add(const Duration(milliseconds: 5200));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await port.windowReady;
    expect(port.entries, hasLength(21), reason: 'the rest of the window');
    expect(port.hasDeferredLookahead, isFalse);
  });
}

List<LogicalQueueEntry> _entries(int count) => [
  for (var i = 0; i < count; i++)
    LogicalQueueEntry(id: 'entry-$i', songId: 'song-$i'),
];

List<Song> _songs(int count) => [
  for (var index = 0; index < count; index++)
    Song(
      id: 'song-$index',
      title: 'song-$index',
      artist: 'Artist',
      album: 'Album',
      albumId: '',
      artistId: '',
    ),
];

class _RecordingPlayer extends AudioPlayer {
  final states = StreamController<PlayerState>.broadcast();
  final sequences = StreamController<SequenceState>.broadcast();
  final positions = StreamController<Duration>.broadcast();
  int plays = 0;
  int loads = 0;
  int inserts = 0;
  final List<String> tags = [];
  int _index = 0;

  @override
  Stream<PlayerState> get playerStateStream => states.stream;

  @override
  Stream<SequenceState> get sequenceStateStream => sequences.stream;

  @override
  Stream<Duration> get positionStream => positions.stream;

  @override
  Future<void> play() async {
    plays++;
  }

  @override
  Future<void> dispose() async {
    await states.close();
    await sequences.close();
    await positions.close();
  }

  @override
  Future<void> seek(Duration? position, {int? index}) async {
    _index = index ?? _index;
  }

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
    loads++;
    tags
      ..clear()
      ..addAll(
        sources.map((source) => (source as IndexedAudioSource).tag as String),
      );
    _index = initialIndex ?? 0;
    return Duration.zero;
  }

  @override
  Future<void> insertAudioSource(int index, AudioSource source) async {
    inserts++;
    tags.insert(index, (source as IndexedAudioSource).tag as String);
    if (index <= _index) _index++;
  }

  @override
  Future<void> removeAudioSourceAt(int index) async {
    tags.removeAt(index);
    if (index < _index) _index--;
  }

  @override
  Future<void> moveAudioSource(int from, int to) async {
    final tag = tags.removeAt(from);
    tags.insert(to, tag);
  }

  @override
  Future<void> stop() async {}

  @override
  Future<void> clearAudioSources() async {
    tags.clear();
    _index = 0;
  }
}

class _Sink implements ScrobbleSink {
  @override
  Future<void> announceStart(String songId) async {}

  @override
  Future<void> submitPlay(String songId) async {}
}

class _Resolver implements PlaybackMediaResolver {
  @override
  Future<ResolvedPlaybackMedia> resolve(String id) async =>
      ResolvedPlaybackMedia(
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
