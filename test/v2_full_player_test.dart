import 'dart:async';

import 'package:flutter/gestures.dart' show kDoubleTapMinTime;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:navimusic/design_system/navi_theme.dart';
import 'package:navimusic/design_system/widgets/navi_widgets.dart';
import 'package:navimusic/domain/playback/auto_play_profile.dart';
import 'package:navimusic/domain/playback/just_audio_native_port.dart';
import 'package:navimusic/domain/playback/logical_queue.dart';
import 'package:navimusic/domain/playback/playback_coordinator.dart';
import 'package:navimusic/domain/playback/playback_media_resolver.dart';
import 'package:navimusic/domain/playback/scrobble_tracker.dart';
import 'package:navimusic/features/player/v2_full_player.dart';
import 'package:navimusic/features/player/v2_playback_controller.dart';
import 'package:navimusic/features/player/v2_queue_sheet.dart';
import 'package:navimusic/l10n/app_localizations.dart';
import 'package:navimusic/models/models.dart';

void main() {
  late _FakeController controller;
  late List<Song> toggled;
  late List<Song> menuOpened;

  setUp(() {
    controller = _FakeController(
      songs: [_song('a'), _song('b'), _song('c')],
      currentIndex: 1,
    );
    toggled = [];
    menuOpened = [];
  });

  tearDown(() => controller.shutdown());

  Future<void> pumpPlayer(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _app(
        V2FullPlayer(
          controller: controller,
          isFavorite: (song) => song.starred,
          onToggleFavorite: (song) async {
            toggled.add(song);
            controller.markSongStarred(song.id, !song.starred);
          },
          onSongMenu: (_, song) => menuOpened.add(song),
          lyricsLoader: (_) async => null,
          onTuneQueue: (_) async {},
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('the scrubber thumb stays under the finger while the song plays', (
    tester,
  ) async {
    await pumpPlayer(tester);
    final slider = find.byType(Slider);
    final gesture = await tester.startGesture(tester.getCenter(slider));
    await gesture.moveBy(const Offset(30, 0));
    await tester.pump();
    final dragged = tester.widget<Slider>(slider).value;

    // The player keeps reporting positions while the finger is down. The thumb
    // must not follow them back.
    controller.positionListenable.value = const Duration(seconds: 5);
    await tester.pump();
    controller.positionListenable.value = const Duration(seconds: 12);
    await tester.pump();
    expect(tester.widget<Slider>(slider).value, dragged);

    await gesture.moveBy(const Offset(20, 0));
    await tester.pump();
    final moved = tester.widget<Slider>(slider).value;
    expect(moved, greaterThan(dragged));

    await gesture.up();
    await tester.pump();
    // Released: the thumb keeps the released value until the playhead lands
    // there. Showing the old position while the seek is on its way is the
    // "thumb snaps back" bug.
    expect(tester.widget<Slider>(slider).value, closeTo(moved, 1));

    controller.positionListenable.value = Duration(milliseconds: moved.round());
    await tester.pump();
    expect(tester.widget<Slider>(slider).value, closeTo(moved, 1));
  });

  testWidgets('one labelled glass row carries the four secondary actions', (
    tester,
  ) async {
    await pumpPlayer(tester);

    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(NaviGlass), findsOneWidget);
    for (final key in [
      V2FullPlayer.lyricsActionKey,
      V2FullPlayer.queueActionKey,
      V2FullPlayer.sleepActionKey,
      V2FullPlayer.tuneActionKey,
    ]) {
      expect(
        find.descendant(of: find.byType(NaviGlass), matching: find.byKey(key)),
        findsOneWidget,
      );
    }
    for (final label in ['Text', 'Kö', 'Timer', 'Justera']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.byIcon(Icons.format_list_bulleted_rounded), findsOneWidget);
    expect(find.byIcon(Icons.bedtime_outlined), findsOneWidget);
    expect(find.byIcon(Icons.format_quote_rounded), findsOneWidget);
    expect(find.byIcon(Icons.sensors_rounded), findsOneWidget);
    expect(find.byIcon(Icons.queue_music_rounded), findsNothing);
    expect(find.byIcon(Icons.playlist_play_rounded), findsNothing);
    expect(find.byIcon(Icons.lyrics_outlined), findsNothing);
    expect(find.byIcon(Icons.album_outlined), findsNothing);
    expect(find.byIcon(Icons.auto_awesome_rounded), findsNothing);
  });

  testWidgets('the heart toggles the favourite and reflects the result', (
    tester,
  ) async {
    await pumpPlayer(tester);
    expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);

    await tester.tap(find.byKey(V2FullPlayer.favoriteKey));
    await tester.pump();

    expect(toggled.map((song) => song.id), ['b']);
    expect(controller.currentSong!.starred, isTrue);
    expect(
      find.descendant(
        of: find.byKey(V2FullPlayer.favoriteKey),
        matching: find.byIcon(Icons.favorite_rounded),
      ),
      findsOneWidget,
    );
  });

  testWidgets('double-tapping the artwork favourites the song', (tester) async {
    await pumpPlayer(tester);
    final artwork = find.byKey(V2FullPlayer.artworkKey);

    await tester.tap(artwork);
    await tester.pump(kDoubleTapMinTime);
    await tester.tap(artwork);
    await tester.pump();

    expect(toggled.map((song) => song.id), ['b']);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Tillagd i favoriter'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('the … button opens the shared song menu', (tester) async {
    await pumpPlayer(tester);

    await tester.tap(find.byKey(V2FullPlayer.menuKey));
    await tester.pump();

    expect(menuOpened.map((song) => song.id), ['b']);
  });

  testWidgets('the queue sheet lists song rows without a snapshots button', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: V2QueueSheet(
            controller: controller,
            onSongMenu: (_, song) => menuOpened.add(song),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.bookmarks_outlined), findsNothing);
    expect(find.byType(NaviSongRow), findsNWidgets(3));
    expect(find.text('Kö (3)'), findsOneWidget);

    await tester.longPress(find.text('Song c'));
    await tester.pump();
    expect(menuOpened.map((song) => song.id), ['c']);
  });

  testWidgets('a queue that is still loading rings, then opens itself', (
    tester,
  ) async {
    final pending = Completer<void>();
    controller.pendingQueue = pending;
    controller.queuePreparing.value = true;
    await pumpPlayer(tester);

    await tester.tap(find.byKey(V2FullPlayer.queueActionKey));
    await tester.pump();

    expect(
      find.descendant(
        of: find.byKey(V2FullPlayer.queueActionKey),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );
    expect(find.byType(V2QueueSheet), findsNothing);

    pending.complete();
    await tester.pumpAndSettle();

    expect(find.byType(V2QueueSheet), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('a ready queue opens on the first tap', (tester) async {
    await pumpPlayer(tester);

    await tester.tap(find.byKey(V2FullPlayer.queueActionKey));
    await tester.pumpAndSettle();

    expect(find.byType(V2QueueSheet), findsOneWidget);
  });

  test('markSongStarred patches the current song', () async {
    expect(controller.currentSong!.starred, isFalse);
    controller.markSongStarred('b', true);
    expect(controller.currentSong!.starred, isTrue);
    controller.markSongStarred('b', false);
    expect(controller.currentSong!.starred, isFalse);
  });
}

Widget _app(Widget home) => MaterialApp(
  locale: const Locale('sv'),
  theme: NaviTheme.dark(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

Song _song(String id) => Song(
  id: id,
  title: 'Song $id',
  artist: 'Artist',
  artistId: 'artist',
  album: 'Album',
  albumId: 'album',
  duration: 200,
);

class _FakeController extends V2PlaybackController {
  factory _FakeController({
    required List<Song> songs,
    required int currentIndex,
  }) => _FakeController._(
    _FakePort(
      resolver: _Resolver(),
      player: AudioPlayer(),
      media: ResolvedPlaybackMedia(
        song: songs[currentIndex],
        uri: Uri.parse('https://example.invalid/${songs[currentIndex].id}'),
      ),
    ),
    songs,
    currentIndex,
  );

  _FakeController._(_FakePort port, this.songs, int currentIndex)
    : _queue = LogicalQueue.start([
        for (final song in songs)
          LogicalQueueEntry(id: 'entry-${song.id}', songId: song.id),
      ], 'entry-${songs[currentIndex].id}'),
      super(
        nativePort: port,
        coordinator: PlaybackCoordinator(
          nativePort: _FakeNative(),
          autoPlayCandidates: _FakeAutoPlay(),
        ),
        scrobbleTracker: ScrobbleTracker(sink: _Sink()),
      );

  final List<Song> songs;
  final LogicalQueue _queue;

  /// When set, the queue stays "preparing" until the test completes it.
  Completer<void>? pendingQueue;

  @override
  Future<void> get queueReady => pendingQueue?.future ?? Future<void>.value();

  @override
  LogicalQueue get queue => _queue;

  @override
  Duration get duration => const Duration(seconds: 200);

  @override
  Future<Song?> songForEntry(LogicalQueueEntry entry) async =>
      songs.firstWhere((song) => song.id == entry.songId);

  @override
  Future<void> togglePlayback() async {}

  @override
  Future<void> next() async {}

  @override
  Future<void> previous() async {}

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> cycleRepeat() async {}

  @override
  Future<void> shuffleUpNext() async {}

  @override
  Future<void> jumpTo(String entryId) async {}

  @override
  Future<void> remove(String entryId) async {}

  @override
  Future<void> moveBefore(String entryId, String? beforeEntryId) async {}
}

/// Serves one fixed current media and applies [updateSong] to it, so the
/// controller's favourite patch can be observed without a loaded player.
class _FakePort extends JustAudioNativePort {
  _FakePort({
    required super.resolver,
    required super.player,
    required ResolvedPlaybackMedia media,
  }) : _media = media; // ignore: prefer_initializing_formals

  ResolvedPlaybackMedia _media;

  @override
  ResolvedPlaybackMedia? get currentMedia => _media;

  @override
  void updateSong(String id, Song Function(Song song) patch) {
    if (_media.song.id != id) return;
    _media = ResolvedPlaybackMedia(song: patch(_media.song), uri: _media.uri);
  }
}

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

class _FakeNative implements NativePlaybackPort {
  @override
  Future<void> reconcileQueueWindow(
    NativeQueueWindow window, {
    required QueueWindowUpdateReason reason,
  }) async {}

  @override
  Future<void> get windowReady => Future<void>.value();

  @override
  Future<void> pause() async {}

  @override
  Future<void> play() async {}
}

class _FakeAutoPlay implements AutoPlayCandidateProvider {
  @override
  Future<List<String>> candidates({
    required String seedSongId,
    required Set<String> excludedSongIds,
    required int limit,
    required AutoPlayProfile profile,
  }) async => const [];
}
