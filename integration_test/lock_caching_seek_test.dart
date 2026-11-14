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

/// Verifies the library's own streaming-with-cache source on the real
/// just_audio plugin: a seek in a stream that is being cached must land where
/// it was asked for and must not change the entry that is playing.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late HttpServer server;
  late Directory cacheDir;
  late Uint8List audio;
  var rangeRequests = 0;

  setUpAll(() async {
    audio = _wav(seconds: 60, freq: 220);
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      final range = request.headers.value("range");
      final response = request.response;
      response.headers.set("Accept-Ranges", "bytes");
      response.headers.set("Content-Type", "audio/wav");
      if (range == null) {
        response.headers.contentLength = audio.length;
        response.add(audio);
        await response.close();
        return;
      }
      rangeRequests++;
      final match = RegExp(r"bytes=(\d+)-(\d*)").firstMatch(range);
      final start = int.parse(match!.group(1)!);
      final end = match.group(2)!.isEmpty
          ? audio.length - 1
          : int.parse(match.group(2)!);
      final slice = audio.sublist(start, end + 1);
      response.statusCode = 206;
      response.headers.set(
        "Content-Range",
        "bytes $start-$end/${audio.length}",
      );
      response.headers.contentLength = slice.length;
      response.add(slice);
      await response.close();
    });
  });

  tearDownAll(() async {
    await server.close(force: true);
  });

  setUp(() async {
    rangeRequests = 0;
    cacheDir = await Directory.systemTemp.createTemp("lock-cache");
  });

  tearDown(() async {
    if (cacheDir.existsSync()) await cacheDir.delete(recursive: true);
  });

  testWidgets("a seek in the cached proxy stream lands and keeps the entry", (
    tester,
  ) async {
    final player = AudioPlayer();
    final port = JustAudioNativePort(
      player: player,
      cacheDirectory: cacheDir,
      resolver: _StreamResolver("http://127.0.0.1:${server.port}/track"),
    );
    addTearDown(player.dispose);

    final entries = [
      for (var i = 0; i < 4; i++)
        LogicalQueueEntry(id: "s-$i", songId: "song-$i"),
    ];
    await port.reconcileQueueWindow(
      NativeQueueWindow(entries: entries, currentIndex: 0),
      reason: QueueWindowUpdateReason.replace,
    );
    unawaited(player.play());
    await _waitFor(() => player.position > const Duration(seconds: 1));

    await player.seek(const Duration(seconds: 40));
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final tag = player.sequenceState.currentSource?.tag;
    // ignore: avoid_print
    print(
      "LOCK seek position=${player.position} tag=$tag index=${player.currentIndex} "
      "playing=${player.playing} ranges=$rangeRequests",
    );
    expect(tag, "s-0", reason: "the seek must not move to another entry");
    expect(
      player.position,
      greaterThanOrEqualTo(const Duration(seconds: 39)),
      reason: "the playhead must land where the seek asked",
    );

    // Let the whole file cache, then seek again: the same source resolves to
    // the file and the seek stays exact.
    await Future<void>.delayed(const Duration(seconds: 3));
    await player.seek(const Duration(seconds: 20));
    await Future<void>.delayed(const Duration(milliseconds: 600));
    // ignore: avoid_print
    print(
      "LOCK cached seek position=${player.position} tag=$tag "
      "index=${player.currentIndex} files=${cacheDir.listSync().length}",
    );
    expect(player.sequenceState.currentSource?.tag, "s-0");
    expect(player.position, greaterThanOrEqualTo(const Duration(seconds: 19)));
  });
}

Future<void> _waitFor(bool Function() condition) async {
  final deadline = DateTime.now().add(const Duration(seconds: 20));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) fail("condition never became true");
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}

class _StreamResolver implements PlaybackMediaResolver {
  _StreamResolver(this.base);

  final String base;

  @override
  Future<ResolvedPlaybackMedia> resolve(String songId) async =>
      ResolvedPlaybackMedia(
        song: Song(
          id: songId,
          title: songId,
          artist: "Artist",
          album: "Album",
          albumId: "",
          artistId: "",
          duration: 60,
          suffix: "wav",
        ),
        uri: Uri.parse("$base?i=$songId"),
      );
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
