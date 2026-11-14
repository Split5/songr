import 'dart:async';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:navimusic/domain/playback/just_audio_native_port.dart';
import 'package:navimusic/domain/playback/playback_coordinator.dart';
import 'package:navimusic/domain/playback/playback_media_resolver.dart';
import 'package:navimusic/domain/playback/scrobble_tracker.dart';
import 'package:navimusic/features/player/v2_playback_controller.dart';
import 'package:navimusic/models/models.dart';

/// Regression: the Favorites shuffle button ("Shuffle All" on
/// Låtar → Filter → Hjärta) used to keep the top row pinned as the first song
/// and shuffle only the rest, so every shuffle started on the same song.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('shuffle starts on a random member, not the top row', () async {
    final harness = _Harness(random: Random(7));
    addTearDown(harness.dispose);

    final songs = _songs(12);
    // What a uniform shuffle of the same list looks like with the same seed.
    final expected = List<Song>.of(songs)..shuffle(Random(7));

    await harness.controller.playSongs(songs, shuffle: true);

    expect(
      harness.controller.queue.entries.map((entry) => entry.songId).toList(),
      expected.map((song) => song.id).toList(),
    );
    expect(harness.controller.queue.current?.songId, expected.first.id);
    expect(
      harness.controller.queue.current?.songId,
      isNot(songs.first.id),
      reason: 'the first favourite must not be pinned to the front',
    );
  });

  test('shuffle keeps every favourite exactly once', () async {
    final harness = _Harness(random: Random(3));
    addTearDown(harness.dispose);

    final songs = _songs(9);
    await harness.controller.playSongs(songs, shuffle: true);

    expect(
      harness.controller.queue.entries.map((entry) => entry.songId),
      unorderedEquals(songs.map((song) => song.id)),
    );
    expect(harness.controller.queue.currentIndex, 0);
  });

  test('repeated shuffles do not all begin on the same song', () async {
    final firstSongs = <String>{};
    for (var run = 0; run < 12; run++) {
      final harness = _Harness(); // real Random.secure()
      final songs = _songs(8);
      await harness.controller.playSongs(songs, shuffle: true);
      firstSongs.add(harness.controller.queue.current!.songId);
      await harness.dispose();
    }
    expect(firstSongs.length, greaterThan(1));
  });

  test('playing a collection in order still starts on the tapped row', () async {
    final harness = _Harness(random: Random(7));
    addTearDown(harness.dispose);

    final songs = _songs(6);
    await harness.controller.playSongs(songs, startIndex: 4);

    expect(
      harness.controller.queue.entries.map((entry) => entry.songId).toList(),
      songs.map((song) => song.id).toList(),
    );
    expect(harness.controller.queue.current?.songId, songs[4].id);
  });
}

class _Harness {
  _Harness({Random? random}) {
    player = _RecordingPlayer();
    port = JustAudioNativePort(player: player, resolver: _Resolver());
    coordinator = PlaybackCoordinator(nativePort: port);
    controller = V2PlaybackController(
      nativePort: port,
      coordinator: coordinator,
      scrobbleTracker: ScrobbleTracker(sink: _Sink()),
      random: random,
    );
  }

  late final _RecordingPlayer player;
  late final JustAudioNativePort port;
  late final PlaybackCoordinator coordinator;
  late final V2PlaybackController controller;

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
