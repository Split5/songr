import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/app/v2/v2_experience_preferences.dart';
import 'package:navimusic/app/v2/v2_shell.dart';
import 'package:navimusic/data/local/app_database.dart';
import 'package:navimusic/data/local/drift_home_repository.dart';
import 'package:navimusic/design_system/navi_theme.dart';
import 'package:navimusic/domain/home/home_repository.dart';
import 'package:navimusic/domain/home/quick_picks_service.dart';
import 'package:navimusic/features/home/home_controller.dart';
import 'package:navimusic/features/home/v2_home_screen.dart';
import 'package:navimusic/l10n/app_localizations.dart';
import 'package:navimusic/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => database.close());

  testWidgets(
    'Home keeps picks and position across navigation until a manual pull',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final repository = _CountingRepository(
        HomeSnapshot(recentlyAddedSongs: [_song('seed')]),
      );
      var builds = 0;
      var requests = 0;
      var server = Completer<void>();
      final controller = HomeController(
        repository: repository,
        quickPicksLoader: (_, _) async {
          final generation = builds++;
          return [
            for (var i = 0; i < 8; i++)
              QuickPick(
                song: _song('pick-$generation-$i'),
                reason: QuickPickReason.fresh,
              ),
          ];
        },
      );
      final preferences = V2ExperiencePreferences();
      await preferences.load();
      addTearDown(controller.dispose);
      addTearDown(preferences.dispose);
      await tester.pumpWidget(
        _app(
          V2HomeScreen(
            controller: controller,
            preferences: preferences,
            onRefresh: () async {
              requests++;
              await server.future;
              await controller.refresh(
                rotateLibrary: true,
                rotateQuickPicks: false,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      final navigator = Navigator.of(tester.element(find.byType(V2HomeScreen)));
      final shelf = find.byWidgetPredicate(
        (widget) =>
            widget is ListView && '${widget.key}'.contains('home-quick-picks-'),
      );
      for (var cycle = 1; cycle <= 2; cycle++) {
        server = Completer<void>();
        try {
          final selectedBefore = controller.state.quickPicks.first.song.id;
          final keyBefore = tester.widget<ListView>(shelf).key;
          final scrolling = tester.state<ScrollableState>(
            find.descendant(of: shelf, matching: find.byType(Scrollable)),
          );
          scrolling.position.jumpTo(140);
          await tester.pumpAndSettle();
          unawaited(
            navigator.push(
              MaterialPageRoute<void>(
                builder: (_) => const Scaffold(body: Text('Album detail')),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(requests, cycle - 1);
          navigator.pop();
          await tester.pumpAndSettle();
          expect(requests, cycle - 1);
          expect(builds, cycle);
          expect(controller.state.quickPicks.first.song.id, selectedBefore);
          expect(tester.widget<ListView>(shelf).key, keyBefore);
          expect(scrolling.position.pixels, 140);
          await tester.fling(
            find.byType(CustomScrollView),
            const Offset(0, 420),
            1000,
          );
          for (var frame = 0; frame < 15; frame++) {
            await tester.pump(const Duration(milliseconds: 100));
          }
          expect(requests, cycle);
          expect(builds, cycle + 1);
          final selected = controller.state.quickPicks.first.song.id;
          final key = tester.widget<ListView>(shelf).key;
          server.complete();
          await tester.pumpAndSettle();
          expect(builds, cycle + 1);
          expect(controller.state.quickPicks.first.song.id, selected);
          expect(tester.widget<ListView>(shelf).key, key);
        } finally {
          if (!server.isCompleted) {
            server.complete();
            await tester.pumpAndSettle();
          }
        }
      }
    },
  );

  testWidgets('detail route return preserves Home without refreshing', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final repository = _CountingRepository(
      HomeSnapshot(recentlyAddedSongs: [_song('one')]),
    );
    final controller = HomeController(repository: repository);
    final preferences = V2ExperiencePreferences();
    await preferences.load();
    addTearDown(controller.dispose);
    addTearDown(preferences.dispose);
    var reloads = 0;
    await tester.pumpWidget(
      _app(
        V2TabActivity(
          isActive: true,
          activation: 0,
          child: V2HomeScreen(
            controller: controller,
            preferences: preferences,
            onRefresh: () async {
              reloads++;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final navigator = Navigator.of(tester.element(find.byType(V2HomeScreen)));
    unawaited(
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('Album detail')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(repository.calls, 1);
    expect(reloads, 0);
    navigator.pop();
    await tester.pumpAndSettle();
    expect(repository.calls, 1);
    expect(reloads, 0);
  });

  testWidgets('a Home popup does not sync or reshuffle the shelves', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final repository = _CountingRepository(
      HomeSnapshot(recentlyAddedSongs: [_song('one')]),
    );
    final controller = HomeController(repository: repository);
    final preferences = V2ExperiencePreferences();
    addTearDown(controller.dispose);
    addTearDown(preferences.dispose);
    var reloads = 0;
    await tester.pumpWidget(
      _app(
        V2HomeScreen(
          controller: controller,
          preferences: preferences,
          onRefresh: () async {
            reloads++;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(V2HomeScreen));
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        builder: (_) => const Text('Song menu'),
      ),
    );
    await tester.pumpAndSettle();
    expect(repository.calls, 1);
    Navigator.of(tester.element(find.text('Song menu'))).pop();
    await tester.pumpAndSettle();
    expect(reloads, 0);
    expect(repository.calls, 1);
  });

  testWidgets('Home leaves app resume syncing to the app for every tab', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final controller = HomeController(
      repository: _CountingRepository(
        HomeSnapshot(recentlyAddedSongs: [_song('one')]),
      ),
    );
    final preferences = V2ExperiencePreferences();
    await preferences.load();
    addTearDown(controller.dispose);
    addTearDown(preferences.dispose);
    var reloads = 0;
    for (final active in [true, false]) {
      await tester.pumpWidget(
        _app(
          V2TabActivity(
            isActive: active,
            activation: 0,
            child: V2HomeScreen(
              controller: controller,
              preferences: preferences,
              onRefresh: () async {
                reloads++;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(reloads, 0);
    }
  });

  test('recently added albums mirror Navidrome newest order', () async {
    await database
        .into(database.localSongs)
        .insert(
          LocalSongsCompanion.insert(
            id: 'song-local',
            title: 'Local song',
            albumId: const Value('local-1'),
            album: 'Album local-1',
            artist: 'Local artist',
            createdAt: Value(DateTime(2026, 1, 1)),
          ),
        );
    final repository = DriftHomeRepository(
      database,
      newestAlbumsLoader: ({required limit}) async {
        expect(limit, greaterThan(0));
        return [
          _album('srv-b', created: DateTime(2026, 10, 30)),
          _album('srv-a', created: DateTime(2026, 10, 20)),
        ];
      },
    );

    final snapshot = await repository.load();

    expect(snapshot.recentlyAddedAlbums.map((album) => album.id), [
      'srv-b',
      'srv-a',
    ]);
  });

  test(
    'a stalled newest-album request falls back to the local shelf',
    () async {
      await database.batch((batch) {
        batch.insert(
          database.localAlbums,
          LocalAlbumsCompanion.insert(
            id: 'local',
            name: 'Local album',
            artist: 'Local artist',
          ),
        );
        batch.insert(
          database.localSongs,
          LocalSongsCompanion.insert(
            id: 'local-song',
            title: 'Local song',
            artist: 'Local artist',
            album: 'Local album',
            albumId: const Value('local'),
          ),
        );
      });
      final stalled = Completer<List<Album>>();
      final repository = DriftHomeRepository(
        database,
        newestAlbumsLoader: ({required limit}) => stalled.future,
      );
      try {
        final snapshot = await repository.load().timeout(
          const Duration(seconds: 5),
        );
        expect(snapshot.recentlyAddedAlbums.single.id, 'local');
      } finally {
        stalled.complete(const []);
      }
    },
  );

  test('an unreachable server keeps the local mirror on the shelf', () async {
    await database
        .into(database.localSongs)
        .insert(
          LocalSongsCompanion.insert(
            id: 'song-local',
            title: 'Local song',
            albumId: const Value('local-1'),
            album: 'Album local-1',
            artist: 'Local artist',
            createdAt: Value(DateTime(2026, 1, 1)),
          ),
        );
    final repository = DriftHomeRepository(
      database,
      newestAlbumsLoader: ({required limit}) async =>
          throw StateError('offline'),
    );

    final snapshot = await repository.load();

    expect(snapshot.recentlyAddedAlbums, hasLength(1));
    expect(snapshot.recentlyAddedAlbums.single.id, 'local-1');
  });

  test('every completed reload bumps the carousel revision', () async {
    final controller = HomeController(
      repository: _CountingRepository(
        HomeSnapshot(recentlyAddedAlbums: [_album('a', created: null)]),
      ),
    );

    expect(controller.state.revision, 0);
    await controller.refresh();
    expect(controller.state.revision, 1);
    await controller.refresh(rotateLibrary: true, rotateQuickPicks: false);
    expect(controller.state.revision, 2);
    controller.dispose();
  });

  test('concurrent refreshes share one load', () async {
    final repository = _CountingRepository(
      HomeSnapshot(recentlyAddedAlbums: [_album('a', created: null)]),
    );
    final controller = HomeController(repository: repository);

    await Future.wait([
      controller.refresh(),
      controller.refresh(),
      controller.refresh(rotateLibrary: true),
    ]);

    expect(repository.calls, 1);
    controller.dispose();
  });

  testWidgets('tab changes preserve Home without refreshing', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repository = _CountingRepository(
      HomeSnapshot(recentlyAddedSongs: [_song('one')]),
    );
    final controller = HomeController(repository: repository);
    addTearDown(controller.dispose);
    final preferences = V2ExperiencePreferences();
    await preferences.load();
    addTearDown(preferences.dispose);
    var reloads = 0;

    Widget build({required bool active}) => _app(
      V2TabActivity(
        isActive: active,
        activation: active ? 1 : 0,
        child: V2HomeScreen(
          controller: controller,
          preferences: preferences,
          onRefresh: () async {
            reloads++;
            await controller.refresh(
              rotateLibrary: true,
              rotateQuickPicks: false,
            );
          },
        ),
      ),
    );

    await tester.pumpWidget(build(active: true));
    await tester.pumpAndSettle();
    expect(reloads, 0, reason: 'the first load is the initial load');

    await tester.pumpWidget(build(active: false));
    await tester.pumpAndSettle();
    expect(repository.calls, 1);

    await tester.pumpWidget(build(active: true));
    await tester.pumpAndSettle();
    expect(reloads, 0);
  });

  testWidgets('a refresh rewinds the carousels to the first card', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final controller = HomeController(
      repository: _CountingRepository(
        HomeSnapshot(
          recentlyAddedAlbums: [
            for (var i = 0; i < 8; i++)
              _album('album-$i', created: null, artist: 'Artist $i'),
          ],
        ),
      ),
    );
    addTearDown(controller.dispose);
    final preferences = V2ExperiencePreferences();
    await preferences.load();
    addTearDown(preferences.dispose);

    await tester.pumpWidget(
      _app(V2HomeScreen(controller: controller, preferences: preferences)),
    );
    await tester.pumpAndSettle();

    final first = find.byKey(
      const PageStorageKey('home-albums-Nyligen tillagda album-1'),
    );
    expect(first, findsOneWidget);
    final before = tester.state<ScrollableState>(
      find.descendant(of: first, matching: find.byType(Scrollable)),
    );
    before.position.jumpTo(320);
    await tester.pumpAndSettle();
    expect(before.position.pixels, greaterThan(0));

    unawaited(controller.refresh());
    await tester.pumpAndSettle();

    final second = find.byKey(
      const PageStorageKey('home-albums-Nyligen tillagda album-2'),
    );
    expect(second, findsOneWidget);
    final after = tester.state<ScrollableState>(
      find.descendant(of: second, matching: find.byType(Scrollable)),
    );
    expect(after.position.pixels, 0);
  });
}

Album _album(
  String id, {
  required DateTime? created,
  String artist = 'Artist',
}) => Album(
  id: id,
  name: 'Album $id',
  artist: artist,
  artistId: 'artist-$id',
  songCount: 10,
  year: 2026,
  created: created,
);

Widget _app(Widget home) => MaterialApp(
  navigatorObservers: [RouteObserver<PageRoute<dynamic>>()],
  locale: const Locale('sv'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  theme: NaviTheme.dark(),
  home: home,
);

Song _song(String id, {String artist = 'Artist'}) => Song(
  id: id,
  title: 'Song $id',
  artist: artist,
  artistId: 'artist-$id',
  album: 'Album',
  albumId: 'album',
  year: 2026,
);

class _CountingRepository implements HomeRepository {
  _CountingRepository(this.snapshot);

  final HomeSnapshot snapshot;
  int calls = 0;

  @override
  Future<HomeSnapshot> load({bool refreshLibraryRotation = false}) async {
    calls++;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return snapshot;
  }
}
