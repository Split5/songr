import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/app/v2/v2_experience_preferences.dart';
import 'package:navimusic/data/local/app_database.dart';
import 'package:navimusic/data/local/drift_home_repository.dart';
import 'package:navimusic/data/local/drift_playback_history_repository.dart';
import 'package:navimusic/design_system/navi_theme.dart';
import 'package:navimusic/design_system/widgets/navi_glass.dart';
import 'package:navimusic/domain/home/home_repository.dart';
import 'package:navimusic/domain/home/quick_picks_service.dart';
import 'package:navimusic/features/home/home_controller.dart';
import 'package:navimusic/features/home/v2_home_screen.dart';
import 'package:navimusic/l10n/app_localizations.dart';
import 'package:navimusic/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'metadata fills the first picks and saves new data for the next rotation',
    () async {
      final repository = _QueuedHomeRepository([
        Completer<HomeSnapshot>()
          ..complete(HomeSnapshot(recentlyAddedSongs: [_song('old')])),
        Completer<HomeSnapshot>()
          ..complete(HomeSnapshot(recentlyAddedSongs: [_song('new')])),
      ]);
      var builds = 0;
      final controller = HomeController(
        repository: repository,
        quickPicksLoader: (snapshot, _) async {
          builds++;
          return [
            QuickPick(
              song: snapshot.recentlyAddedSongs.single,
              reason: QuickPickReason.fresh,
            ),
          ];
        },
      );
      addTearDown(controller.dispose);
      await controller.refresh(rotateQuickPicks: false);
      expect(controller.state.quickPicks.single.song.id, 'old');
      await controller.refresh(rotateQuickPicks: false);
      expect(controller.state.recentlyAddedSongs.single.id, 'new');
      expect(controller.state.quickPicks.single.song.id, 'old');
      expect(builds, 1);
      await controller.refreshQuickPicks();
      expect(controller.state.quickPicks.single.song.id, 'new');
      expect(builds, 2);
    },
  );

  for (final snapshotFirst in [true, false]) {
    test(
      'snapshot and quick refresh share one selection (snapshot first: $snapshotFirst)',
      () async {
        final started = Completer<void>();
        final pending = Completer<List<QuickPick>>();
        var builds = 0;
        final controller = HomeController(
          repository: _FakeHomeRepository(
            HomeSnapshot(recentlyPlayedSongs: [_song('seed')]),
          ),
          quickPicksLoader: (_, _) {
            if (++builds == 1) {
              return Future.value([
                QuickPick(
                  song: _song('initial'),
                  reason: QuickPickReason.fresh,
                ),
              ]);
            }
            if (!started.isCompleted) started.complete();
            return pending.future;
          },
        );
        addTearDown(controller.dispose);
        await controller.initialize();
        final first = snapshotFirst
            ? controller.refresh()
            : controller.refreshQuickPicks();
        await started.future;
        final second = snapshotFirst
            ? controller.refreshQuickPicks()
            : controller.refresh();
        await Future<void>.delayed(Duration.zero);
        try {
          expect(builds, 2);
        } finally {
          pending.complete([
            QuickPick(song: _song('next'), reason: QuickPickReason.fresh),
          ]);
          await Future.wait([first, second]);
        }
      },
    );
  }

  test(
    'overlapping Quick Picks refreshes share their pending selection',
    () async {
      final pending = Completer<List<QuickPick>>();
      var builds = 0;
      final controller = HomeController(
        repository: _FakeHomeRepository(
          HomeSnapshot(recentlyPlayedSongs: [_song('seed')]),
        ),
        quickPicksLoader: (_, _) {
          builds++;
          return builds == 1
              ? Future.value([
                  QuickPick(
                    song: _song('initial'),
                    reason: QuickPickReason.fresh,
                  ),
                ])
              : pending.future;
        },
      );
      addTearDown(controller.dispose);
      await controller.initialize();
      final first = controller.refreshQuickPicks();
      final second = controller.refreshQuickPicks();
      try {
        expect(builds, 2);
      } finally {
        pending.complete([
          QuickPick(song: _song('next'), reason: QuickPickReason.fresh),
        ]);
        await Future.wait([first, second]);
      }
    },
  );

  testWidgets('Home refresh supports large accessibility text', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = HomeController(
      repository: _FakeHomeRepository(const HomeSnapshot()),
    );
    final preferences = V2ExperiencePreferences();
    await preferences.load();
    addTearDown(controller.dispose);
    addTearDown(preferences.dispose);
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(3)),
            child: V2HomeScreen(
              controller: controller,
              preferences: preferences,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), null);
  });

  test(
    'Quick Picks can renew while the newest-album snapshot is blocked',
    () async {
      final first = Completer<HomeSnapshot>()
        ..complete(HomeSnapshot(recentlyPlayedSongs: [_song('seed')]));
      final blocked = Completer<HomeSnapshot>();
      var picks = 0;
      final controller = HomeController(
        repository: _QueuedHomeRepository([first, blocked]),
        quickPicksLoader: (_, _) async => [
          QuickPick(
            song: _song('pick-${picks++}'),
            reason: QuickPickReason.fresh,
          ),
        ],
      );
      addTearDown(controller.dispose);
      await controller.refresh();
      final before = controller.state.quickPicks.single.song.id;
      final loading = controller.refresh();
      await controller.refreshQuickPicks();
      expect(blocked.isCompleted, isFalse);
      expect(controller.state.quickPicks.single.song.id, isNot(before));
      blocked.complete(const HomeSnapshot());
      await loading;
    },
  );

  testWidgets(
    'pull renews visible Quick Picks while server refresh is pending',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final server = Completer<void>();
      var refreshes = 0;
      var picks = 0;
      final controller = HomeController(
        repository: _FakeHomeRepository(
          HomeSnapshot(
            recentlyPlayedSongs: [_song('seed')],
            recentlyAddedSongs: [_song('new')],
            mostPlayedSongs: [_song('popular')],
            librarySongRotation: [_song('library')],
          ),
        ),
        quickPicksLoader: (_, _) async => [
          QuickPick(
            song: _song('pick-${picks++}'),
            reason: QuickPickReason.fresh,
          ),
        ],
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
            onRefresh: () {
              refreshes++;
              return server.future;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      final before = controller.state.quickPicks.single.song.id;
      await tester.fling(
        find.byType(CustomScrollView),
        const Offset(0, 420),
        1000,
      );
      for (var frame = 0; frame < 15; frame++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      try {
        expect(refreshes, 1);
        expect(controller.state.quickPicks.single.song.id, isNot(before));
        expect(server.isCompleted, isFalse);
        expect(find.text('Hämtar nya album…'), findsOneWidget);
        expect(
          find.text(controller.state.quickPicks.single.song.title),
          findsWidgets,
        );
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -650));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Hämtar nya album…').hitTestable(), findsNothing);
        expect(server.isCompleted, isFalse);
        expect(refreshes, 1);
      } finally {
        server.complete();
        await tester.pumpAndSettle();
      }
    },
  );

  test(
    'every Home reload advances Quick Picks without rotating the library',
    () async {
      final rotations = <int>[];
      final repository = _RecordingHomeRepository();
      final controller = HomeController(
        repository: repository,
        quickPicksLoader: (_, rotation) async {
          rotations.add(rotation);
          return const [];
        },
      );
      addTearDown(controller.dispose);
      await controller.refresh();
      await controller.refresh();
      expect(rotations.last, rotations.first + 1);
      expect(repository.rotationRequests, [false, false]);
    },
  );

  test('controller enforces artist variety before allowing repeats', () async {
    final candidates = [
      for (var i = 0; i < 8; i++) _album('a$i', artist: 'Artist A'),
      for (var i = 0; i < 4; i++) _album('b$i', artist: 'Artist B'),
      for (var i = 0; i < 4; i++) _album('c$i', artist: 'Artist C'),
      for (var i = 0; i < 4; i++) _album('d$i', artist: 'Artist D'),
    ];
    final controller = HomeController(
      repository: _FakeHomeRepository(
        HomeSnapshot(mostPlayedAlbums: candidates),
      ),
    );

    await controller.refresh();

    final albums = controller.state.mostPlayedAlbums;
    expect(albums.take(4).map((album) => album.artist).toSet(), hasLength(4));
    final counts = <String, int>{};
    for (final album in albums) {
      counts.update(album.artist, (value) => value + 1, ifAbsent: () => 1);
    }
    expect(counts.values.every((count) => count <= 2), isTrue);
    controller.dispose();
  });

  test('song shelves enforce artist variety before repeats', () async {
    final candidates = [
      for (var i = 0; i < 8; i++) _song('a$i', artist: 'Artist A'),
      for (var i = 0; i < 4; i++) _song('b$i', artist: 'Artist B'),
      for (var i = 0; i < 4; i++) _song('c$i', artist: 'Artist C'),
      for (var i = 0; i < 4; i++) _song('d$i', artist: 'Artist D'),
    ];
    final controller = HomeController(
      repository: _FakeHomeRepository(
        HomeSnapshot(mostPlayedSongs: candidates),
      ),
    );

    await controller.refresh();

    final songs = controller.state.mostPlayedSongs;
    expect(songs.take(4).map((song) => song.artist).toSet(), hasLength(4));
    final counts = <String, int>{};
    for (final song in songs) {
      counts.update(song.artist, (value) => value + 1, ifAbsent: () => 1);
    }
    expect(counts.values.every((count) => count <= 2), isTrue);
    controller.dispose();
  });

  test('a refresh requested while one runs joins that run', () async {
    final pending = Completer<HomeSnapshot>();
    final repository = _QueuedHomeRepository([pending]);
    final controller = HomeController(repository: repository);

    // App resume, a tab switch and pull-to-refresh can all fire at once. They
    // describe the same load, so they share one repository call instead of
    // stacking three identical ones.
    final firstRefresh = controller.refresh();
    final secondRefresh = controller.refresh();
    final rotationRefresh = controller.refresh(rotateLibrary: true);

    expect(secondRefresh, same(firstRefresh));
    expect(rotationRefresh, same(firstRefresh));

    pending.complete(HomeSnapshot(libraryRotation: [_album('new')]));
    await firstRefresh;

    expect(repository.index, 1);
    expect(controller.state.libraryRotation.single.id, 'new');
    controller.dispose();
  });

  test('Home requests a new library rotation only when explicit', () async {
    final repository = _RecordingHomeRepository();
    final controller = HomeController(repository: repository);

    await controller.refresh();
    await controller.refresh();
    await controller.refresh(rotateLibrary: true);

    expect(repository.rotationRequests, [false, false, true]);
    controller.dispose();
  });

  test('home playlists include generated and unplayed lists', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await database.batch((batch) {
      batch.insertAll(database.localPlaylists, [
        LocalPlaylistsCompanion.insert(id: 'old', name: 'Older playlist'),
        LocalPlaylistsCompanion.insert(id: 'new', name: 'Newer playlist'),
        LocalPlaylistsCompanion.insert(
          id: 'generated',
          name: 'Automatic mix',
          isGenerated: const Value(true),
        ),
      ]);
      batch.insertAll(database.localPlaylistEntries, [
        LocalPlaylistEntriesCompanion.insert(
          playlistId: 'old',
          songId: 'old-song',
          position: 0,
        ),
        LocalPlaylistEntriesCompanion.insert(
          playlistId: 'new',
          songId: 'new-song',
          position: 0,
        ),
        LocalPlaylistEntriesCompanion.insert(
          playlistId: 'generated',
          songId: 'new-song',
          position: 0,
        ),
      ]);
    });
    await database.upsertSongs([
      _localSong(
        'old-song',
        albumId: 'old-album',
        artist: 'Artist',
        lastPlayedAt: DateTime.utc(2026, 10, 20),
      ),
      _localSong(
        'new-song',
        albumId: 'new-album',
        artist: 'Artist',
        lastPlayedAt: DateTime.utc(2026, 10, 25),
      ),
    ]);

    await database
        .into(database.localPlaylists)
        .insert(
          LocalPlaylistsCompanion.insert(id: 'unplayed', name: 'Unplayed'),
        );

    final playlists = await database.recentlyPlayedPlaylists();

    expect(
      playlists.map((playlist) => playlist.id),
      containsAll({'new', 'old', 'generated', 'unplayed'}),
    );
    expect(
      playlists.indexWhere((playlist) => playlist.id == 'new'),
      lessThan(playlists.indexWhere((playlist) => playlist.id == 'old')),
    );
    expect(
      playlists.indexWhere((playlist) => playlist.id == 'unplayed'),
      playlists.length - 1,
    );
  });

  test('Drift home source builds four honest album shelves', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await database.batch((batch) {
      batch.insertAll(database.localAlbums, [
        _localAlbum(
          'server',
          artist: 'Server Artist',
          playCount: 8,
          createdAt: DateTime.utc(2026, 8, 25),
        ),
        _localAlbum(
          'local',
          artist: 'Local Artist',
          playCount: 2,
          createdAt: DateTime.utc(2026, 8, 28),
        ),
        _localAlbum(
          'newest',
          artist: 'Fresh Artist',
          createdAt: DateTime.utc(2026, 8, 29),
        ),
        _localAlbum(
          'top',
          artist: 'Top Artist',
          playCount: 15,
          createdAt: DateTime.utc(2026, 8, 26),
        ),
      ]);
    });
    await database.upsertSongs([
      _localSong(
        'server-song',
        albumId: 'server',
        artist: 'Server Artist',
        playCount: 8,
        createdAt: DateTime.utc(2026, 8, 25),
        lastPlayedAt: DateTime.utc(2026, 8, 28, 8),
      ),
      _localSong(
        'local-song',
        albumId: 'local',
        artist: 'Local Artist',
        playCount: 2,
        createdAt: DateTime.utc(2026, 8, 28),
      ),
      _localSong(
        'newest-song',
        albumId: 'newest',
        artist: 'Fresh Artist',
        createdAt: DateTime.utc(2026, 8, 29),
      ),
      _localSong(
        'top-song',
        albumId: 'top',
        artist: 'Top Artist',
        playCount: 15,
        createdAt: DateTime.utc(2026, 8, 26),
      ),
    ]);
    final history = DriftPlaybackHistoryRepository(database);
    await history.beginPlayback(
      playbackId: 'play-local',
      songId: 'local-song',
      startedAt: DateTime.utc(2026, 8, 28, 10),
      duration: const Duration(minutes: 3),
    );
    await history.markPlayed(
      playbackId: 'play-local',
      at: DateTime.utc(2026, 8, 28, 10, 2),
    );

    final repository = DriftHomeRepository(database);
    final concurrentLoads = await Future.wait([
      repository.load(),
      repository.load(),
    ]);
    final snapshot = concurrentLoads.first;
    expect(
      identical(
        snapshot.librarySongRotation,
        concurrentLoads.last.librarySongRotation,
      ),
      isTrue,
    );
    expect(
      identical(snapshot.libraryRotation, concurrentLoads.last.libraryRotation),
      isTrue,
    );

    expect(snapshot.recentlyPlayedAlbums.map((album) => album.id), [
      'local',
      'server',
    ]);
    expect(snapshot.recentlyAddedAlbums.first.id, 'newest');
    expect(snapshot.mostPlayedAlbums.first.id, 'top');
    expect(snapshot.recentlyPlayedSongs.map((song) => song.id), [
      'local-song',
      'server-song',
    ]);
    expect(snapshot.recentlyAddedSongs.first.id, 'newest-song');
    expect(snapshot.mostPlayedSongs.first.id, 'top-song');
    expect(snapshot.librarySongRotation, hasLength(4));
    expect(snapshot.libraryRotation.map((album) => album.id).toSet(), {
      'server',
      'local',
      'newest',
      'top',
    });

    final automaticRefresh = await repository.load();
    expect(
      identical(
        snapshot.librarySongRotation,
        automaticRefresh.librarySongRotation,
      ),
      isTrue,
    );
    expect(
      identical(snapshot.libraryRotation, automaticRefresh.libraryRotation),
      isTrue,
    );

    final manualRefresh = await repository.load(refreshLibraryRotation: true);
    expect(
      identical(
        snapshot.librarySongRotation,
        manualRefresh.librarySongRotation,
      ),
      isFalse,
    );
    expect(
      identical(snapshot.libraryRotation, manualRefresh.libraryRotation),
      isFalse,
    );
  });

  test(
    'library rotation survives a new repository until explicitly changed',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final store = _MemoryRotationStore();
      await database
          .into(database.localAlbums)
          .insert(
            _localAlbum(
              'initial',
              artist: 'Initial Artist',
              createdAt: DateTime.utc(2026, 8, 29),
            ),
          );
      await database.upsertSongs([
        _localSong(
          'initial-song',
          albumId: 'initial',
          artist: 'Initial Artist',
          createdAt: DateTime.utc(2026, 8, 29),
        ),
      ]);

      final first = await DriftHomeRepository(
        database,
        rotationStore: store,
      ).load();
      await database
          .into(database.localAlbums)
          .insert(
            _localAlbum(
              'later',
              artist: 'Later Artist',
              createdAt: DateTime.utc(2026, 8, 30),
            ),
          );
      await database.upsertSongs([
        _localSong(
          'later-song',
          albumId: 'later',
          artist: 'Later Artist',
          createdAt: DateTime.utc(2026, 8, 30),
        ),
      ]);

      final restarted = DriftHomeRepository(database, rotationStore: store);
      final restored = await restarted.load();
      expect(
        restored.librarySongRotation.map((song) => song.id),
        first.librarySongRotation.map((song) => song.id),
      );
      expect(
        restored.libraryRotation.map((album) => album.id),
        first.libraryRotation.map((album) => album.id),
      );
      expect(
        restored.librarySongRotation.map((song) => song.id),
        isNot(contains('later-song')),
      );

      final rotated = await restarted.load(refreshLibraryRotation: true);
      expect(
        rotated.librarySongRotation.map((song) => song.id),
        contains('later-song'),
      );
      expect(
        rotated.libraryRotation.map((album) => album.id),
        contains('later'),
      );
    },
  );

  test('newer server history wins over older offline history', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await database.batch((batch) {
      batch.insertAll(database.localAlbums, [
        _localAlbum(
          'both',
          artist: 'Both Artist',
          createdAt: DateTime.utc(2026, 8, 25),
        ),
        _localAlbum(
          'middle',
          artist: 'Middle Artist',
          createdAt: DateTime.utc(2026, 8, 25),
        ),
      ]);
    });
    await database.upsertSongs([
      _localSong(
        'both-song',
        albumId: 'both',
        artist: 'Both Artist',
        lastPlayedAt: DateTime.utc(2026, 8, 29),
      ),
      _localSong(
        'middle-song',
        albumId: 'middle',
        artist: 'Middle Artist',
        lastPlayedAt: DateTime.utc(2026, 8, 28, 12),
      ),
    ]);
    final history = DriftPlaybackHistoryRepository(database);
    await history.beginPlayback(
      playbackId: 'older-local-play',
      songId: 'both-song',
      startedAt: DateTime.utc(2026, 8, 28),
      duration: const Duration(minutes: 3),
    );
    await history.markPlayed(
      playbackId: 'older-local-play',
      at: DateTime.utc(2026, 8, 28, 0, 2),
    );

    final snapshot = await DriftHomeRepository(database).load();

    expect(snapshot.recentlyPlayedAlbums.map((album) => album.id), [
      'both',
      'middle',
    ]);
  });

  test(
    'Home and recommendation preferences persist with safe defaults',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = V2ExperiencePreferences();
      await preferences.load();

      expect(
        preferences.homeContentFor(HomeSectionKind.recentlyPlayed),
        HomeContentFocus.songs,
      );
      expect(
        preferences.homeContentFor(HomeSectionKind.fromLibrary),
        HomeContentFocus.albums,
      );
      expect(preferences.homeHeaderStyle, HomeHeaderStyle.wordmark);
      expect(preferences.enabledHomeSections, HomeSectionKind.values.toSet());
      await preferences.setHomeSectionContent(
        HomeSectionKind.recentlyAdded,
        HomeContentFocus.albums,
      );
      await preferences.setHomeSectionContent(
        HomeSectionKind.fromLibrary,
        HomeContentFocus.songs,
      );
      await preferences.reorderHomeSection(
        preferences.homeSectionOrder.indexOf(HomeSectionKind.fromLibrary),
        0,
      );
      await preferences.setHomeSectionEnabled(
        HomeSectionKind.mostPlayed,
        false,
      );
      await preferences.setRecommendationExploration(0.7);
      await preferences.setRecommendationMaxSongsPerArtist(4);
      await preferences.setRecommendationInitialCandidateCount(30);
      await preferences.setLastPlaylistId('playlist-42');
      await preferences.setHomeHeaderStyle(HomeHeaderStyle.logo);
      await preferences.setTopBarTransparency(1);
      await preferences.setTopBarBlurSigma(0);
      preferences.dispose();

      final restored = V2ExperiencePreferences();
      await restored.load();
      expect(
        restored.homeContentFor(HomeSectionKind.recentlyPlayed),
        HomeContentFocus.songs,
      );
      expect(
        restored.homeContentFor(HomeSectionKind.recentlyAdded),
        HomeContentFocus.albums,
      );
      expect(
        restored.homeContentFor(HomeSectionKind.fromLibrary),
        HomeContentFocus.songs,
      );
      expect(restored.homeSectionOrder.first, HomeSectionKind.fromLibrary);
      expect(
        restored.enabledHomeSections.contains(HomeSectionKind.mostPlayed),
        isFalse,
      );
      expect(restored.recommendationExploration, 0.7);
      expect(restored.recommendationMaxSongsPerArtist, 4);
      expect(restored.recommendationInitialCandidateCount, 30);
      expect(restored.lastPlaylistId, 'playlist-42');
      expect(restored.homeHeaderStyle, HomeHeaderStyle.logo);
      expect(restored.topBarTransparency, 1);
      expect(restored.topBarBlurSigma, 0);
      restored.dispose();
    },
  );

  test('legacy global Home focus migrates to every carousel', () async {
    SharedPreferences.setMockInitialValues({
      'v2_home_content_focus': HomeContentFocus.albums.name,
    });
    final preferences = V2ExperiencePreferences();
    await preferences.load();

    expect(HomeSectionKind.values.map(preferences.homeContentFor).toSet(), {
      HomeContentFocus.albums,
    });
    preferences.dispose();
  });

  testWidgets('home supports a separate content type for every shelf', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final songs = [
      _song('one', artist: 'First Artist'),
      _song('two', artist: 'Second Artist'),
    ];
    final albums = [
      _album('one', artist: 'First Artist'),
      _album('two', artist: 'Second Artist'),
    ];
    final playlists = [
      for (var index = 0; index < 14; index++)
        Playlist(
          id: 'playlist-$index',
          name: 'Spellista ${index + 1}',
          songCount: 24 - index,
        ),
    ];
    final controller = HomeController(
      repository: _FakeHomeRepository(
        HomeSnapshot(
          recentlyPlayedSongs: songs,
          recentlyAddedSongs: songs,
          mostPlayedSongs: songs,
          librarySongRotation: songs,
          recentlyPlayedAlbums: albums,
          recentlyAddedAlbums: albums,
          mostPlayedAlbums: albums,
          libraryRotation: albums,
          recentlyPlayedPlaylists: playlists,
        ),
      ),
    );
    addTearDown(controller.dispose);
    final preferences = V2ExperiencePreferences();
    addTearDown(preferences.dispose);
    Song? tappedSong;
    Album? tapped;
    Playlist? tappedPlaylist;

    await tester.pumpWidget(
      _app(
        V2HomeScreen(
          controller: controller,
          preferences: preferences,
          onSongTap: (song) => tappedSong = song,
          onAlbumTap: (album) => tapped = album,
          onPlaylistTap: (playlist) => tappedPlaylist = playlist,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Söngr'), findsWidgets);
    expect(find.byKey(const ValueKey('home-brand-mark')), findsNothing);
    expect(find.text('Senast spelade spellistor'), findsNothing);
    for (var index = 1; index <= 6; index++) {
      expect(find.text('Spellista $index'), findsOneWidget);
    }
    expect(find.text('Spellista 7'), findsNothing);
    expect(
      tester.getTopLeft(find.text('Spellista 1')).dy,
      closeTo(tester.getTopLeft(find.text('Spellista 2')).dy, 1),
    );
    await tester.tap(find.text('Spellista 1'));
    expect(tappedPlaylist?.id, 'playlist-0');
    await tester.drag(
      find.byKey(const ValueKey('home-playlist-pager')),
      const Offset(-600, 0),
    );
    await tester.pumpAndSettle();
    expect(find.text('Spellista 7'), findsOneWidget);
    expect(find.text('Spellista 8'), findsOneWidget);
    await tester.drag(
      find.byKey(const ValueKey('home-playlist-pager')),
      const Offset(-600, 0),
    );
    await tester.pumpAndSettle();
    expect(find.text('Spellista 13'), findsOneWidget);
    expect(find.text('Spellista 14'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Senast spelade låtar'),
      300,
      scrollable: find
          .descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('Senast spelade låtar'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Nyligen tillagda album'),
      300,
      scrollable: find
          .descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('Nyligen tillagda album'), findsOneWidget);
    expect(find.text('My Listening'), findsNothing);
    expect(find.text('Populärt i Pop'), findsNothing);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 120));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Song one').first);
    expect(tappedSong?.id, 'one');

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('Mest spelade låtar'), findsOneWidget);
    expect(find.text('Ur ditt bibliotek'), findsOneWidget);
    // Two shelves now show albums (recently added and from library), so the
    // same record appears on both and the key is found more than once.
    expect(find.byKey(const ValueKey('home-album-count-one')), findsWidgets);
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey('home-album-count-one')).first)
          .dy,
      greaterThan(tester.getTopLeft(find.text('Album one').first).dy),
    );
    expect(find.text('10 låtar · 2026'), findsWidgets);
    expect(find.byKey(const ValueKey('home-album-count-icon')), findsWidgets);
    // The record now sits on two album shelves; tap the one in the shelf that
    // is currently on screen.
    await tester.ensureVisible(find.text('Album one').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Album one').last);
    expect(tapped?.id, 'one');

    await preferences.setHomeSectionContent(
      HomeSectionKind.recentlyPlayed,
      HomeContentFocus.albums,
    );
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 900));
    await tester.pumpAndSettle();
    expect(find.text('Senast spelade album'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Nyligen tillagda album'),
      300,
      scrollable: find
          .descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('Nyligen tillagda album'), findsOneWidget);
    expect(find.text('Nyligen tillagda låtar'), findsNothing);
  });

  testWidgets(
    'initial home load uses a compact skeleton instead of a spinner',
    (tester) async {
      final pending = Completer<HomeSnapshot>();
      final controller = HomeController(
        repository: _QueuedHomeRepository([pending]),
      );
      addTearDown(controller.dispose);
      final preferences = V2ExperiencePreferences();
      addTearDown(preferences.dispose);

      await tester.pumpWidget(
        _app(V2HomeScreen(controller: controller, preferences: preferences)),
      );
      await tester.pump();

      expect(find.byType(NaviSliverHeader), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      pending.complete(const HomeSnapshot());
      await tester.pumpAndSettle();
    },
  );

  testWidgets('pull to refresh rotates Quick Picks and library selection', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final rotations = <int>[];
    final controller = HomeController(
      repository: _FakeHomeRepository(
        HomeSnapshot(
          recentlyPlayedSongs: [_song('one')],
          librarySongRotation: [_song('two')],
        ),
      ),
      quickPicksLoader: (_, rotation) async {
        rotations.add(rotation);
        return const [];
      },
    );
    addTearDown(controller.dispose);
    final preferences = V2ExperiencePreferences();
    addTearDown(preferences.dispose);
    await preferences.load();

    await tester.pumpWidget(
      _app(V2HomeScreen(controller: controller, preferences: preferences)),
    );
    await tester.pumpAndSettle();
    expect(rotations, hasLength(1));
    final firstRotation = rotations.single;

    await tester.fling(
      find.byType(CustomScrollView),
      const Offset(0, 420),
      1000,
    );
    await tester.pumpAndSettle();

    expect(rotations, [firstRotation, firstRotation + 1]);
  });

  testWidgets('Show more opens after a resisted horizontal drag', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final controller = HomeController(
      repository: _FakeHomeRepository(
        HomeSnapshot(recentlyPlayedSongs: [_song('one')]),
      ),
    );
    addTearDown(controller.dispose);
    final preferences = V2ExperiencePreferences();
    addTearDown(preferences.dispose);
    await preferences.load();
    HomeSectionKind? openedSection;
    HomeContentFocus? openedFocus;

    await tester.pumpWidget(
      _app(
        V2HomeScreen(
          controller: controller,
          preferences: preferences,
          onShowMore: (section, focus) async {
            openedSection = section;
            openedFocus = focus;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Visa mer'),
      250,
      scrollable: find
          .descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.drag(find.text('Visa mer'), const Offset(-150, 0));
    await tester.pumpAndSettle();

    expect(openedSection, HomeSectionKind.recentlyPlayed);
    expect(openedFocus, HomeContentFocus.songs);
  });

  testWidgets('home does not duplicate the app foreground sync', (
    tester,
  ) async {
    final repository = _RecordingHomeRepository();
    final controller = HomeController(repository: repository);
    addTearDown(controller.dispose);
    final preferences = V2ExperiencePreferences();
    addTearDown(preferences.dispose);

    await tester.pumpWidget(
      _app(V2HomeScreen(controller: controller, preferences: preferences)),
    );
    await tester.pumpAndSettle();
    expect(repository.rotationRequests, hasLength(1));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(repository.rotationRequests, hasLength(1));
  });

  testWidgets('home can show the logo instead of its wordmark', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = V2ExperiencePreferences();
    await preferences.load();
    await preferences.setHomeHeaderStyle(HomeHeaderStyle.logo);
    final controller = HomeController(
      repository: _FakeHomeRepository(const HomeSnapshot()),
    );
    addTearDown(controller.dispose);
    addTearDown(preferences.dispose);

    await tester.pumpWidget(
      _app(V2HomeScreen(controller: controller, preferences: preferences)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('home-brand-mark')), findsOneWidget);
    final logo = tester.widget<SvgPicture>(
      find.byKey(const ValueKey('home-brand-mark')),
    );
    expect(logo.width, 38);
    expect(logo.height, 38);
    expect(find.text('Söngr'), findsNothing);
  });
}

class _FakeHomeRepository implements HomeRepository {
  const _FakeHomeRepository(this.snapshot);

  final HomeSnapshot snapshot;

  @override
  Future<HomeSnapshot> load({bool refreshLibraryRotation = false}) async =>
      snapshot;
}

class _QueuedHomeRepository implements HomeRepository {
  _QueuedHomeRepository(this.requests);

  final List<Completer<HomeSnapshot>> requests;
  var index = 0;

  @override
  Future<HomeSnapshot> load({bool refreshLibraryRotation = false}) =>
      requests[index++].future;
}

class _RecordingHomeRepository implements HomeRepository {
  final List<bool> rotationRequests = [];

  @override
  Future<HomeSnapshot> load({bool refreshLibraryRotation = false}) async {
    rotationRequests.add(refreshLibraryRotation);
    return const HomeSnapshot();
  }
}

class _MemoryRotationStore implements HomeRotationStore {
  HomeRotationSelection? selection;

  @override
  Future<HomeRotationSelection?> read() async => selection;

  @override
  Future<void> write(HomeRotationSelection value) async {
    selection = value;
  }
}

Widget _app(Widget home) => MaterialApp(
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

Album _album(String id, {String artist = 'Artist'}) => Album(
  id: id,
  name: 'Album $id',
  artist: artist,
  artistId: 'artist-$id',
  songCount: 10,
  year: 2026,
);

Song _song(String id, {String artist = 'Artist'}) => Song(
  id: id,
  title: 'Song $id',
  artist: artist,
  artistId: 'artist-$id',
  album: 'Album $id',
  albumId: 'album-$id',
  year: 2026,
);

LocalAlbumsCompanion _localAlbum(
  String id, {
  required String artist,
  int playCount = 0,
  DateTime? createdAt,
}) => LocalAlbumsCompanion.insert(
  id: id,
  name: 'Album $id',
  artist: artist,
  artistId: Value('artist-$id'),
  canonicalArtist: Value(artist),
  songCount: const Value(1),
  duration: const Value(180),
  playCount: Value(playCount),
  createdAt: Value(createdAt),
);

LocalSongsCompanion _localSong(
  String id, {
  required String albumId,
  required String artist,
  int playCount = 0,
  DateTime? createdAt,
  DateTime? lastPlayedAt,
}) => LocalSongsCompanion.insert(
  id: id,
  title: 'Song $id',
  albumId: Value(albumId),
  album: 'Album $albumId',
  artist: artist,
  artistId: Value('artist-$albumId'),
  canonicalArtist: Value(artist),
  duration: const Value(180),
  playCount: Value(playCount),
  createdAt: Value(createdAt),
  lastPlayedAt: Value(lastPlayedAt),
);
