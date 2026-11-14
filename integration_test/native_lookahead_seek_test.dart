import "dart:async";
import "dart:io";
import "dart:typed_data";

import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";
import "package:just_audio/just_audio.dart";
import "package:navimusic/domain/playback/just_audio_native_port.dart";
import "package:navimusic/domain/playback/logical_queue.dart";
import "package:navimusic/domain/playback/playback_coordinator.dart";
import "package:navimusic/domain/playback/playback_media_resolver.dart";
import "package:navimusic/models/models.dart";

/// Reproduces the reported "wrong song" flow on the real just_audio plugin:
/// a cold start with the lookahead held back, then a seek, then the lookahead
/// fill while the seek is in flight. It asserts that the entry being played
/// never changes under those operations.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late Map<String, Uri> files;

  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp("songr-lookahead-seek");
    files = {};
    for (var i = 0; i < 12; i++) {
      final file = File("${dir.path}/track-$i.wav");
      await file.writeAsBytes(_wav(seconds: 20, freq: 180 + i * 23));
      files["song-${i % 6}"] = file.uri;
    }
  });

  tearDownAll(() async {
    if (dir.existsSync()) await dir.delete(recursive: true);
  });

  String diag(AudioPlayer player, JustAudioNativePort port, String step) {
    final tag = player.sequenceState.currentSource?.tag;
    final index = player.currentIndex;
    // ignore: avoid_print
    print(
      "DIAG $step tag=$tag index=$index media=${port.currentMedia?.song.id} "
      "entries=${port.entries.length} playing=${player.playing}",
    );
    return tag as String? ?? "";
  }

  testWidgets("the played entry survives a seek during the lookahead fill", (
    tester,
  ) async {
    final player = AudioPlayer();
    final port = JustAudioNativePort(
      player: player,
      resolver: _FileResolver(files),
    );
    addTearDown(player.dispose);

    final entries = [
      for (var i = 0; i < 12; i++)
        LogicalQueueEntry(id: "entry-$i", songId: "song-${i % 6}"),
    ];
    await port.reconcileQueueWindow(
      NativeQueueWindow(entries: entries, currentIndex: 1),
      reason: QueueWindowUpdateReason.replace,
    );
    unawaited(player.play());
    await _waitFor(() => player.position > const Duration(seconds: 1));

    final playingEntry = diag(player, port, "after start");
    expect(port.currentMedia?.song.id, "song-1");

    // First wave, exactly like the controller releases it one second in.
    await port.releaseLookahead(limit: 4);
    await port.windowReady;
    expect(diag(player, port, "after first wave"), playingEntry);

    // The scrubber seek, then the rest of the lookahead lands while the seek
    // is still settling.
    unawaited(port.releaseLookahead());
    await player.seek(const Duration(milliseconds: 1500));
    await port.windowReady;
    await Future<void>.delayed(const Duration(milliseconds: 400));
    expect(diag(player, port, "after seek + full fill"), playingEntry);
    expect(port.currentMedia?.song.id, "song-1");
  });

  testWidgets("a queue edit during the fill keeps the played entry", (
    tester,
  ) async {
    final player = AudioPlayer();
    final port = JustAudioNativePort(
      player: player,
      resolver: _FileResolver(files),
    );
    addTearDown(player.dispose);

    final entries = [
      for (var i = 0; i < 10; i++)
        LogicalQueueEntry(id: "e-$i", songId: "song-${i % 6}"),
    ];
    await port.reconcileQueueWindow(
      NativeQueueWindow(entries: entries, currentIndex: 2),
      reason: QueueWindowUpdateReason.replace,
    );
    unawaited(player.play());
    await _waitFor(() => player.position > const Duration(seconds: 1));
    final playingEntry = diag(player, port, "edit before");

    // Insert a song just before the playing one, like "Play next".
    final edited = [
      entries[0],
      entries[1],
      LogicalQueueEntry(id: "e-new", songId: "song-4"),
      ...entries.sublist(2),
    ];
    await port.reconcileQueueWindow(
      NativeQueueWindow(entries: edited, currentIndex: 3),
      reason: QueueWindowUpdateReason.edit,
    );
    await Future<void>.delayed(const Duration(milliseconds: 300));
    expect(diag(player, port, "edit after"), playingEntry);
    expect(port.currentMedia?.song.id, "song-2");
  });
}

Future<void> _waitFor(bool Function() condition) async {
  final deadline = DateTime.now().add(const Duration(seconds: 20));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail("condition never became true");
    }
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}

Uint8List _wav({required int seconds, required int freq}) {
  const sampleRate = 8000;
  final samples = sampleRate * seconds;
  final data = ByteData(44 + samples * 2);
  void ascii(int offset, String value) {
    for (var i = 0; i < value.length; i++) {
      data.setUint8(offset + i, value.codeUnitAt(i));
    }
  }

  ascii(0, "RIFF");
  data.setUint32(4, 36 + samples * 2, Endian.little);
  ascii(8, "WAVEfmt ");
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little);
  data.setUint16(22, 1, Endian.little);
  data.setUint32(24, sampleRate, Endian.little);
  data.setUint32(28, sampleRate * 2, Endian.little);
  data.setUint16(32, 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  ascii(36, "data");
  data.setUint32(40, samples * 2, Endian.little);
  final period = sampleRate ~/ freq;
  for (var i = 0; i < samples; i++) {
    data.setInt16(
      44 + i * 2,
      i % period < period ~/ 2 ? 8000 : -8000,
      Endian.little,
    );
  }
  return data.buffer.asUint8List();
}

class _FileResolver implements PlaybackMediaResolver {
  _FileResolver(this.files);

  final Map<String, Uri> files;

  @override
  Future<ResolvedPlaybackMedia> resolve(String songId) async {
    final uri = files[songId];
    if (uri == null) throw StateError("no audio for $songId");
    return ResolvedPlaybackMedia(
      song: Song(
        id: songId,
        title: songId,
        artist: "Artist",
        album: "Album",
        albumId: "",
        artistId: "",
        duration: 20,
      ),
      uri: uri,
    );
  }
}
