import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:navimusic/domain/playback/just_audio_native_port.dart';
import 'package:navimusic/domain/playback/playback_coordinator.dart';
import 'package:navimusic/domain/playback/playback_media_resolver.dart';
import 'package:navimusic/domain/playback/scrobble_tracker.dart';
import 'package:navimusic/features/player/v2_playback_controller.dart';
import 'package:navimusic/models/models.dart';

/// A tap must feel acknowledged immediately: the mini player shows the tapped
/// song and a progress ring runs on its play control until the player is ready.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the tapped song is shown before the player is ready', () async {
    final player = _BlockingPlayer();
    final port = JustAudioNativePort(player: player, resolver: _Resolver());
    final coordinator = PlaybackCoordinator(nativePort: port);
    final controller = V2PlaybackController(
      nativePort: port,
      coordinator: coordinator,
      scrobbleTracker: ScrobbleTracker(sink: _Sink()),
    );
    addTearDown(controller.shutdown);

    final songs = _songs(5);
    expect(controller.startingPlayback, isFalse);

    final playing = controller.playSongs(songs, startIndex: 2);
    await Future<void>.delayed(Duration.zero);

    expect(controller.startingPlayback, isTrue);
    expect(controller.currentSong?.id, songs[2].id);
    expect(controller.currentSongIdListenable.value, songs[2].id);

    player.ready.complete();
    await playing;

    expect(controller.startingPlayback, isFalse);
    expect(controller.currentSong?.id, songs[2].id);
  });

  test('a quick second tap takes over without the first song starting', () async {
    final player = _BlockingPlayer();
    final port = JustAudioNativePort(player: player, resolver: _Resolver());
    final coordinator = PlaybackCoordinator(nativePort: port);
    final controller = V2PlaybackController(
      nativePort: port,
      coordinator: coordinator,
      scrobbleTracker: ScrobbleTracker(sink: _Sink()),
    );
    addTearDown(controller.shutdown);

    final songs = _songs(6);
    final first = controller.playSongs(songs, startIndex: 0);
    await Future<void>.delayed(Duration.zero);
    expect(controller.currentSong?.id, songs[0].id);

    // Tapped again before the first stream opened.
    final second = controller.playSongs(songs, startIndex: 3);
    await Future<void>.delayed(Duration.zero);
    expect(controller.currentSong?.id, songs[3].id);

    // The first prepare finishes now; it must not publish, play, or take the
    // mini player back.
    player.ready.complete();
    await first;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(
      controller.currentSong?.id,
      songs[3].id,
      reason: 'the superseded tap must not flash back',
    );

    await second;
    expect(controller.startingPlayback, isFalse);
    expect(controller.queue.current?.songId, songs[3].id);
    expect(player.playedTags, hasLength(1));
    expect(player.playedTags.single, controller.queue.current?.id);
  });

  test('a failed start drops the feedback and rethrows', () async {
    final player = _BlockingPlayer(fail: true);
    final port = JustAudioNativePort(player: player, resolver: _Resolver());
    final coordinator = PlaybackCoordinator(nativePort: port);
    final controller = V2PlaybackController(
      nativePort: port,
      coordinator: coordinator,
      scrobbleTracker: ScrobbleTracker(sink: _Sink()),
    );
    addTearDown(controller.shutdown);

    final playing = controller.playSongs(_songs(4), startIndex: 0);
    await Future<void>.delayed(Duration.zero);
    expect(controller.startingPlayback, isTrue);

    player.ready.complete();
    await expectLater(playing, throwsA(isA<StateError>()));
    expect(controller.startingPlayback, isFalse);
  });

  test('a sonic mix shows its seed immediately', () async {
    final player = _BlockingPlayer();
    final port = JustAudioNativePort(player: player, resolver: _Resolver());
    final coordinator = PlaybackCoordinator(nativePort: port);
    final controller = V2PlaybackController(
      nativePort: port,
      coordinator: coordinator,
      scrobbleTracker: ScrobbleTracker(sink: _Sink()),
    );
    addTearDown(controller.shutdown);

    final seed = _songs(1).single;
    final playing = controller.playSonicMix(seed);
    await Future<void>.delayed(Duration.zero);

    expect(controller.startingPlayback, isTrue);
    expect(controller.currentSong?.id, seed.id);

    player.ready.complete();
    await playing;
    expect(controller.startingPlayback, isFalse);
  });
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

/// Starts slowly, like a remote stream opening over the network.
class _BlockingPlayer extends AudioPlayer {
  _BlockingPlayer({this.fail = false});

  final bool fail;
  final ready = Completer<void>();
  final List<String> playedTags = [];
  int _loads = 0;
  final states = StreamController<PlayerState>.broadcast();
  final sequences = StreamController<SequenceState>.broadcast();
  int plays = 0;
  final List<String> tags = [];
  int _index = 0;

  @override
  Stream<PlayerState> get playerStateStream => states.stream;

  @override
  Stream<SequenceState> get sequenceStateStream => sequences.stream;

  @override
  Future<void> play() async {
    plays++;
    if (_index >= 0 && _index < tags.length) playedTags.add(tags[_index]);
  }

  @override
  Future<void> dispose() async {
    await states.close();
    await sequences.close();
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
    // Only the first prepare is slow, like a remote stream opening; a later
    // tap replaces it immediately.
    if (_loads++ == 0) await ready.future;
    if (fail) throw StateError('stream rejected');
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
