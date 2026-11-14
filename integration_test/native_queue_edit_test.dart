import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:navimusic/domain/playback/just_audio_native_port.dart';
import 'package:navimusic/domain/playback/logical_queue.dart';
import 'package:navimusic/domain/playback/playback_coordinator.dart';
import 'package:navimusic/domain/playback/scrobble_tracker.dart';
import 'package:navimusic/features/player/v2_playback_controller.dart';
import 'package:navimusic/domain/playback/playback_media_resolver.dart';
import 'package:navimusic/models/models.dart';

/// Runs against the real just_audio plugin so the platform behaviour of a
/// queue edit is measured, not simulated. Two things are asserted:
///   * a queue edit never re-opens the stream that is playing (no cold start),
///   * "Play next" on a song that is already in the queue leaves the playhead
///     where it is instead of restarting the song.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late Map<String, Uri> files;

  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('songr-native-queue');
    files = {};
    for (var i = 0; i < 30; i++) {
      final file = File('${dir.path}/track-$i.wav');
      await file.writeAsBytes(_wav(seconds: 30, freq: 180 + i * 23));
      files['song-$i'] = file.uri;
    }
  });

  tearDownAll(() async {
    if (dir.existsSync()) await dir.delete(recursive: true);
  });

  testWidgets('play next on a queued song keeps the playhead running', (
    tester,
  ) async {
    final player = AudioPlayer();
    final port = JustAudioNativePort(
      player: player,
      resolver: _FileResolver(files),
    );
    addTearDown(player.dispose);

    // Six songs, two minutes long, playing song 1 with song 2 already queued.
    final entries = [
      for (var i = 0; i < 6; i++)
        LogicalQueueEntry(id: 'entry-$i', songId: 'song-${i % 3}'),
    ];
    await port.reconcileQueueWindow(
      NativeQueueWindow(entries: entries, currentIndex: 1),
      reason: QueueWindowUpdateReason.replace,
    );
    expect(port.currentMedia?.song.id, 'song-1');

    unawaited(player.play());
    await _waitFor(() => player.position > const Duration(seconds: 3));
    final before = player.position;
    // ignore: avoid_print
    print('NATIVE before edit: position=$before index=${player.currentIndex}');

    final edited = [
      entries[0],
      entries[1],
      LogicalQueueEntry(id: 'next-xyz', songId: 'song-2'),
      for (final entry in entries.skip(2)) entry,
    ];
    await port.reconcileQueueWindow(
      NativeQueueWindow(entries: edited, currentIndex: 1),
      reason: QueueWindowUpdateReason.edit,
    );

    // Sample the playhead for a second so a restart is visible.
    var lowest = player.position;
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (player.position < lowest) lowest = player.position;
    }
    // ignore: avoid_print
    print(
      'NATIVE after edit: position=${player.position} lowest=$lowest '
      'index=${player.currentIndex} media=${port.currentMedia?.song.id}',
    );

    expect(port.currentMedia?.song.id, 'song-1');
    expect(
      lowest,
      greaterThanOrEqualTo(before - const Duration(milliseconds: 300)),
      reason: 'the playing song must not restart from the beginning',
    );
    expect(player.position, greaterThan(before));
  });

  testWidgets('inserting into a window opened mid-queue keeps playing', (
    tester,
  ) async {
    final player = AudioPlayer();
    final port = JustAudioNativePort(
      player: player,
      resolver: _FileResolver(files),
    );
    addTearDown(player.dispose);

    final queue = [
      for (var i = 0; i < 30; i++)
        LogicalQueueEntry(id: 'mid-$i', songId: 'song-${i % 3}'),
    ];
    ({List<LogicalQueueEntry> entries, int currentIndex}) windowFor(
      List<LogicalQueueEntry> source,
      int current,
    ) {
      final start = math.max(0, current - 5);
      final end = math.min(source.length, current + 21);
      return (
        entries: source.sublist(start, end),
        currentIndex: current - start,
      );
    }

    final first = windowFor(queue, 12);
    await port.reconcileQueueWindow(
      NativeQueueWindow(entries: first.entries, currentIndex: first.currentIndex),
      reason: QueueWindowUpdateReason.replace,
    );
    await port.windowReady;
    unawaited(player.play());
    await _waitFor(() => player.position > const Duration(seconds: 2));
    final before = player.position;

    final editedQueue = [...queue]
      ..insert(13, LogicalQueueEntry(id: 'mid-new', songId: 'song-0'));
    final second = windowFor(editedQueue, 12);
    await port.reconcileQueueWindow(
      NativeQueueWindow(
        entries: second.entries,
        currentIndex: second.currentIndex,
      ),
      reason: QueueWindowUpdateReason.edit,
    );

    var lowest = player.position;
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (player.position < lowest) lowest = player.position;
    }
    // ignore: avoid_print
    print(
      'NATIVE mid-window after edit: position=${player.position} '
      'lowest=$lowest index=${player.currentIndex} '
      'media=${port.currentMedia?.song.id}',
    );

    expect(port.currentMedia?.song.id, 'song-0');
    expect(
      lowest,
      greaterThanOrEqualTo(before - const Duration(milliseconds: 300)),
      reason: 'editing a mid-queue window must not reload the playing source',
    );
    expect(player.position, greaterThan(before));
  });
  testWidgets('the app controller keeps the playhead on play next', (
    tester,
  ) async {
    final player = AudioPlayer();
    final port = JustAudioNativePort(
      player: player,
      resolver: _FileResolver(files),
    );
    final coordinator = PlaybackCoordinator(nativePort: port);
    final controller = V2PlaybackController(
      nativePort: port,
      coordinator: coordinator,
      scrobbleTracker: ScrobbleTracker(sink: _Sink()),
    );
    addTearDown(controller.shutdown);

    final songs = [
      for (var i = 0; i < 30; i++)
        Song(
          id: 'song-$i',
          title: 'song-$i',
          artist: 'Artist',
          album: 'Album',
          albumId: '',
          artistId: '',
          duration: 30,
        ),
    ];

    // Exactly the reported flow: start a song in the middle of the list, then
    // Play next a song further down, which is already part of the queue.
    await controller.playSongs(songs, startIndex: 12);
    await controller.queueReady;
    await _waitFor(() => controller.position > const Duration(seconds: 2));
    final before = controller.position;
    final playing = controller.currentSong?.id;
    // ignore: avoid_print
    print('CONTROLLER before: position=$before playing=$playing');

    await controller.playNext(songs[25]);

    var lowest = controller.position;
    for (var i = 0; i < 15; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (controller.position < lowest) lowest = controller.position;
    }
    // ignore: avoid_print
    print(
      'CONTROLLER after: position=${controller.position} lowest=$lowest '
      'playing=${controller.currentSong?.id}',
    );

    expect(controller.currentSong?.id, playing);
    expect(
      lowest,
      greaterThanOrEqualTo(before - const Duration(milliseconds: 300)),
      reason: 'Play next must not restart the song that is playing',
    );
    expect(controller.position, greaterThan(before));
  });
  testWidgets('a long queue opened mid-list keeps playing on play next', (
    tester,
  ) async {
    final player = AudioPlayer();
    final port = JustAudioNativePort(
      player: player,
      resolver: _FileResolver(files),
    );
    final coordinator = PlaybackCoordinator(nativePort: port);
    final controller = V2PlaybackController(
      nativePort: port,
      coordinator: coordinator,
      scrobbleTracker: ScrobbleTracker(sink: _Sink()),
    );
    addTearDown(controller.shutdown);

    // A favourites list long enough that the native window is bounded on both
    // sides, which is the real-world case.
    final songs = [
      for (var i = 0; i < 200; i++)
        Song(
          id: 'song-$i',
          title: 'song-$i',
          artist: 'Artist',
          album: 'Album',
          albumId: '',
          artistId: '',
          duration: 30,
        ),
    ];
    await controller.playSongs(songs, startIndex: 100);
    await controller.queueReady;
    await _waitFor(() => controller.position > const Duration(seconds: 2));
    final before = controller.position;
    final playing = controller.currentSong?.id;
    // ignore: avoid_print
    print('LONG before: position=$before playing=$playing');

    await controller.playNext(songs[150]);

    var lowest = controller.position;
    for (var i = 0; i < 15; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (controller.position < lowest) lowest = controller.position;
    }
    // ignore: avoid_print
    print(
      'LONG after: position=${controller.position} lowest=$lowest '
      'playing=${controller.currentSong?.id}',
    );

    expect(controller.currentSong?.id, playing);
    expect(
      lowest,
      greaterThanOrEqualTo(before - const Duration(milliseconds: 300)),
      reason: 'Play next must not restart the song that is playing',
    );
  });
}

Future<void> _waitFor(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('condition not met');
    }
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}

class _FileResolver implements PlaybackMediaResolver {
  _FileResolver(this.files);

  final Map<String, Uri> files;

  @override
  Future<ResolvedPlaybackMedia> resolve(String songId) async {
    final index = int.tryParse(songId.split('-').last);
    if (index == null) throw StateError('bad song id $songId');
    final uri = files['song-${index % 30}'];
    if (uri == null) throw StateError('no audio for $songId');
    return ResolvedPlaybackMedia(
      song: Song(
        id: songId,
        title: songId,
        artist: 'Artist',
        album: 'Album',
        albumId: '',
        artistId: '',
        duration: 30,
      ),
      uri: uri,
    );
  }
}

Uint8List _wav({
  required int seconds,
  required double freq,
  int sampleRate = 8000,
}) {
  final samples = seconds * sampleRate;
  final data = ByteData(44 + samples * 2);
  void text(int offset, String value) {
    for (var i = 0; i < value.length; i++) {
      data.setUint8(offset + i, value.codeUnitAt(i));
    }
  }

  text(0, 'RIFF');
  data.setUint32(4, 36 + samples * 2, Endian.little);
  text(8, 'WAVE');
  text(12, 'fmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little);
  data.setUint16(22, 1, Endian.little);
  data.setUint32(24, sampleRate, Endian.little);
  data.setUint32(28, sampleRate * 2, Endian.little);
  data.setUint16(32, 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  text(36, 'data');
  data.setUint32(40, samples * 2, Endian.little);
  for (var i = 0; i < samples; i++) {
    final value = (math.sin(2 * math.pi * freq * i / sampleRate) * 8000).round();
    data.setInt16(44 + i * 2, value, Endian.little);
  }
  return data.buffer.asUint8List();
}

class _Sink implements ScrobbleSink {
  @override
  Future<void> announceStart(String songId) async {}

  @override
  Future<void> submitPlay(String songId) async {}
}
