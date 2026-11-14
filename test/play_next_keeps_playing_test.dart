import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:navimusic/domain/playback/just_audio_native_port.dart';
import 'package:navimusic/domain/playback/playback_coordinator.dart';
import 'package:navimusic/domain/playback/playback_media_resolver.dart';
import 'package:navimusic/domain/playback/scrobble_tracker.dart';
import 'package:navimusic/features/player/v2_playback_controller.dart';
import 'package:navimusic/models/models.dart';

/// Regression: "Play next" on a song that is already in the queue used to make
/// the playing song start over. The native window had been opened from the
/// middle of the queue, so the queue edit fell through to a full rebuild
/// (`setAudioSources`), which re-opened the stream that was playing.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('play next of a queued song keeps the playing stream open', () async {
    final harness = _Harness();
    addTearDown(harness.dispose);

    final songs = _songs(30);
    await harness.controller.playSongs(songs, startIndex: 10);
    await harness.port.windowReady;

    final playingEntry = harness.currentEntryId;
    final loadsBefore = harness.player.loads;
    final positionBefore = harness.player.playhead;

    await harness.controller.playNext(songs[2]);
    await harness.port.windowReady;

    expect(harness.player.loads, loadsBefore, reason: 'no source reload');
    expect(harness.currentEntryId, playingEntry);
    expect(harness.player.playhead, positionBefore, reason: 'no restart');
    expect(harness.player.plays, 1, reason: 'playback keeps running');
  });

  test('a long queue keeps the stream open when play next pushes the window', () async {
    final harness = _Harness();
    addTearDown(harness.dispose);

    // More entries than the 5 + 20 bounded window: inserting next to the
    // current song pushes the window's tail out, which used to force a rebuild.
    final songs = _songs(200);
    await harness.controller.playSongs(songs, startIndex: 100);
    await harness.port.windowReady;
    final loadsBefore = harness.player.loads;

    await harness.controller.playNext(songs[150]);
    await harness.port.windowReady;

    expect(harness.player.loads, loadsBefore, reason: 'no source reload');
    expect(harness.controller.queue.current?.songId, songs[100].id);
  });

  test('play next still puts the song directly after the current one', () async {
    final harness = _Harness();
    addTearDown(harness.dispose);

    final songs = _songs(30);
    await harness.controller.playSongs(songs, startIndex: 10);
    await harness.port.windowReady;

    await harness.controller.playNext(songs[2]);
    await harness.port.windowReady;

    final queue = harness.controller.queue;
    expect(
      queue.entries[queue.currentIndex + 1].songId,
      songs[2].id,
      reason: 'the request lands immediately after the playing song',
    );
    final native = harness.port.entries;
    final nativeCurrent = native.indexWhere(
      (entry) => entry.id == harness.currentEntryId,
    );
    expect(nativeCurrent, isNonNegative);
    expect(native[nativeCurrent + 1].songId, songs[2].id);
  });

  test('appending to a queue opened mid-list keeps the stream open', () async {
    final harness = _Harness();
    addTearDown(harness.dispose);

    final songs = _songs(30);
    await harness.controller.playSongs(songs, startIndex: 12);
    await harness.port.windowReady;
    final loadsBefore = harness.player.loads;

    await harness.controller.appendSongs([songs[29]]);
    await harness.port.windowReady;

    expect(harness.player.loads, loadsBefore);
    expect(
      harness.controller.queue.entries.last.songId,
      songs[29].id,
    );
  });

  test('shuffling Up Next keeps the playing stream open', () async {
    final harness = _Harness();
    addTearDown(harness.dispose);

    final songs = _songs(30);
    await harness.controller.playSongs(songs, startIndex: 9);
    await harness.port.windowReady;
    final playingEntry = harness.currentEntryId;
    final loadsBefore = harness.player.loads;

    await harness.controller.shuffleUpNext();
    await harness.port.windowReady;

    expect(harness.player.loads, loadsBefore);
    expect(harness.currentEntryId, playingEntry);
    expect(harness.controller.queue.current?.id, playingEntry);
  });

  test('removing an upcoming queue entry keeps the stream open', () async {
    final harness = _Harness();
    addTearDown(harness.dispose);

    final songs = _songs(30);
    await harness.controller.playSongs(songs, startIndex: 8);
    await harness.port.windowReady;
    final unloading = harness.controller.queue.entries[10];
    final loadsBefore = harness.player.loads;

    await harness.controller.remove(unloading.id);
    await harness.port.windowReady;

    expect(harness.player.loads, loadsBefore);
    expect(harness.currentEntryId, harness.controller.queue.current?.id);
  });
}

class _Harness {
  _Harness() {
    player = _RecordingPlayer();
    port = JustAudioNativePort(player: player, resolver: _Resolver());
    coordinator = PlaybackCoordinator(nativePort: port);
    controller = V2PlaybackController(
      nativePort: port,
      coordinator: coordinator,
      scrobbleTracker: ScrobbleTracker(sink: _Sink()),
    );
  }

  late final _RecordingPlayer player;
  late final JustAudioNativePort port;
  late final PlaybackCoordinator coordinator;
  late final V2PlaybackController controller;

  String? get currentEntryId {
    final index = player.currentIndex;
    if (index == null || index < 0 || index >= player.tags.length) return null;
    return player.tags[index];
  }

  Future<void> dispose() async {
    await controller.shutdown();
  }
}

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
  int plays = 0;
  int loads = 0;
  final List<String> tags = [];
  int _index = 0;
  Duration playhead = Duration.zero;

  @override
  Stream<PlayerState> get playerStateStream => states.stream;

  @override
  Stream<SequenceState> get sequenceStateStream => sequences.stream;

  @override
  Future<void> play() async {
    plays++;
  }

  @override
  Future<void> dispose() async {
    await states.close();
    await sequences.close();
  }

  @override
  Future<void> seek(Duration? position, {int? index}) async {
    _index = index ?? _index;
    playhead = position ?? playhead;
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
    playhead = initialPosition ?? Duration.zero;
    return Duration.zero;
  }

  @override
  Future<void> insertAudioSource(int index, AudioSource source) async {
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
