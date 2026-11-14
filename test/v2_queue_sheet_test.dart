import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:navimusic/domain/playback/just_audio_native_port.dart';
import 'package:navimusic/domain/playback/playback_coordinator.dart';
import 'package:navimusic/domain/playback/playback_media_resolver.dart';
import 'package:navimusic/domain/playback/scrobble_tracker.dart';
import 'package:navimusic/features/player/v2_playback_controller.dart';
import 'package:navimusic/features/player/v2_queue_sheet.dart';
import 'package:navimusic/l10n/app_localizations.dart';
import 'package:navimusic/models/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AudioPlayer player;
  late _GateNative native;
  late V2PlaybackController controller;

  setUp(() async {
    player = AudioPlayer();
    native = _GateNative();
    controller = V2PlaybackController(
      nativePort: JustAudioNativePort(resolver: _Resolver(), player: player),
      coordinator: PlaybackCoordinator(nativePort: native),
      scrobbleTracker: ScrobbleTracker(sink: _Sink()),
    );
    await controller.playSongs([_song('a'), _song('b'), _song('c')]);
  });

  tearDown(() => controller.shutdown());

  testWidgets('a dragged row lifts on the sheet colour with its own title', (
    tester,
  ) async {
    await tester.pumpWidget(_app(controller));
    await tester.pump();
    await tester.pump();

    // Row 0 is the playing song and has no handle, so the first handle is b.
    final handle = find.byIcon(Icons.drag_handle_rounded).first;
    final gesture = await tester.startGesture(tester.getCenter(handle));
    await tester.pump(const Duration(milliseconds: 700));
    await gesture.moveBy(const Offset(0, -70));
    await tester.pump();

    final proxy = find.byKey(V2QueueSheet.dragProxyKey);
    expect(proxy, findsOneWidget);

    // Material's default decorator would paint this with canvasColor, which is
    // pure black here — the black band that flashed over the sheet.
    final lift = tester.widget<Material>(proxy);
    expect(lift.type, MaterialType.transparency);
    expect(find.text('…'), findsNothing);
    expect(find.text('Song b'), findsWidgets);

    await gesture.up();
    await tester.pumpAndSettle();
  });

  test('a reorder reaches the list before the native edit finishes', () async {
    final entries = controller.queue.entries;
    native.holdNext = true;

    final move = controller.moveBefore(entries[2].id, entries[0].id);
    await _settle();

    // The drag has landed; the platform still has not answered.
    expect(_songIds(controller), ['c', 'a', 'b']);
    expect(native.pending, isNotNull);

    native.release();
    await move;
    expect(_songIds(controller), ['c', 'a', 'b']);
  });

  test('a failed native edit puts the old order back', () async {
    final entries = controller.queue.entries;
    native.holdNext = true;

    final move = controller.moveBefore(entries[2].id, entries[0].id);
    final failed = expectLater(move, throwsStateError);
    await _settle();
    expect(_songIds(controller), ['c', 'a', 'b']);

    native.fail();
    await failed;
    expect(_songIds(controller), ['a', 'b', 'c']);
  });
}

/// Lets queued microtasks (the serialized command, the queue stream and the
/// controller's listener) all run.
Future<void> _settle() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

List<String> _songIds(V2PlaybackController controller) =>
    controller.queue.entries.map((entry) => entry.songId).toList();

Widget _app(V2PlaybackController controller) => MaterialApp(
  locale: const Locale('sv'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: V2QueueSheet(controller: controller)),
);

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

class _GateNative implements NativePlaybackPort {
  Completer<void>? pending;
  bool holdNext = false;

  @override
  Future<void> reconcileQueueWindow(
    NativeQueueWindow window, {
    required QueueWindowUpdateReason reason,
  }) async {
    if (!holdNext) return;
    holdNext = false;
    final gate = pending = Completer<void>();
    await gate.future;
  }

  void release() => pending?.complete();

  void fail() => pending?.completeError(StateError('native edit failed'));

  @override
  Future<void> get windowReady => Future<void>.value();

  @override
  Future<void> pause() async {}

  @override
  Future<void> play() async {}
}
