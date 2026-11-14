import "package:flutter_test/flutter_test.dart";
import "package:navimusic/domain/playback/just_audio_native_port.dart";
import "package:navimusic/domain/playback/playback_media_resolver.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    "waitForCached returns at once for an entry that is not a stream",
    () async {
      final port = JustAudioNativePort(resolver: _Resolver());
      expect(await port.waitForCached("missing"), isFalse);
    },
  );

  test("waitForCached gives up after the timeout instead of hanging", () async {
    final port = JustAudioNativePort(resolver: _Resolver());
    port.debugSetCacheProgress("entry", 0.4);
    final clock = Stopwatch()..start();
    final cached = await port.waitForCached(
      "entry",
      timeout: const Duration(milliseconds: 300),
    );
    expect(cached, isFalse);
    expect(clock.elapsed, lessThan(const Duration(seconds: 2)));
  });

  test("waitForCached completes when the download finishes", () async {
    final port = JustAudioNativePort(resolver: _Resolver());
    port.debugSetCacheProgress("entry", 0.4);
    final future = port.waitForCached(
      "entry",
      timeout: const Duration(seconds: 5),
    );
    await Future<void>.delayed(const Duration(milliseconds: 150));
    port.debugSetCacheProgress("entry", 1);
    expect(await future, isTrue);
  });
}

class _Resolver implements PlaybackMediaResolver {
  @override
  Future<ResolvedPlaybackMedia> resolve(String songId) =>
      throw UnimplementedError();
}
