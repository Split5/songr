import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/data/local/app_database.dart';
import 'package:navimusic/data/local/drift_song_library_repository.dart';
import 'package:navimusic/design_system/navi_theme.dart';
import 'package:navimusic/domain/library/song_filter.dart';
import 'package:navimusic/domain/library/song_library_repository.dart';
import 'package:navimusic/features/library/songs/songs_controller.dart';
import 'package:navimusic/features/library/songs/v2_songs_screen.dart';
import 'package:navimusic/l10n/app_localizations.dart';
import 'package:navimusic/models/models.dart';

void main() {
  late AppDatabase database;
  late SongsController controller;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    controller.dispose();
    await database.close();
  });

  testWidgets(
    'renders exact SQLite count, localized labels and quality badge',
    (tester) async {
      await database.upsertSongs([
        _song(
          id: 'hires',
          title: 'A Hi-Res Song',
          suffix: 'flac',
          bitRate: 3010,
          bitDepth: 24,
          samplingRate: 96000,
        ),
        for (var i = 1; i < 75; i++)
          _song(
            id: '$i',
            title: 'Song ${i.toString().padLeft(3, '0')}',
            suffix: 'mp3',
            bitRate: 320,
          ),
      ]);
      controller = _controller(database, pageSize: 20);

      await tester.pumpWidget(_app(controller));
      await tester.pumpAndSettle();

      expect(find.text('Låtar'), findsWidgets);
      expect(find.textContaining('75 låtar'), findsOneWidget);
      expect(find.text('A Hi-Res Song'), findsOneWidget);
      expect(find.text('Hi-Res · 24-bit · 96 kHz'), findsOneWidget);
      expect(find.text('Song 074'), findsNothing);
    },
  );

  testWidgets('filter sheet always has close, cancel, reset and apply exits', (
    tester,
  ) async {
    await database.upsertSongs([_song(id: '1', title: 'One')]);
    controller = _controller(database);
    await tester.pumpWidget(_app(controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Filter'));
    await tester.pumpAndSettle();

    expect(find.text('Kvalitet'), findsOneWidget);
    expect(find.text('Återställ'), findsOneWidget);
    expect(find.text('Avbryt'), findsOneWidget);
    expect(find.text('Tillämpa'), findsOneWidget);
    expect(find.byTooltip('Stäng'), findsOneWidget);

    await tester.tap(find.byTooltip('Stäng'));
    await tester.pumpAndSettle();
    expect(find.text('Kvalitet'), findsNothing);
    expect(find.textContaining('1 låt'), findsOneWidget);
  });

  testWidgets('applying Hi-Res filter updates both count and visible rows', (
    tester,
  ) async {
    await database.upsertSongs([
      _song(id: 'mp3', title: 'Compressed song', suffix: 'mp3', bitRate: 320),
      _song(
        id: 'hires',
        title: 'Studio master',
        suffix: 'flac',
        bitRate: 3010,
        bitDepth: 24,
        samplingRate: 96000,
      ),
    ]);
    controller = _controller(database);
    await tester.pumpWidget(_app(controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Filter'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Hi-Res'));
    await tester.tap(find.text('Tillämpa'));
    await tester.pumpAndSettle();

    expect(find.textContaining('1 låt'), findsOneWidget);
    expect(find.text('Studio master'), findsOneWidget);
    expect(find.text('Compressed song'), findsNothing);
  });

  testWidgets('quick quality chips filter without opening the sheet', (
    tester,
  ) async {
    await database.upsertSongs([
      _song(id: 'mp3', title: 'Compressed song', suffix: 'mp3', bitRate: 320),
      _song(
        id: 'hires',
        title: 'Studio master',
        suffix: 'flac',
        bitRate: 3010,
        bitDepth: 24,
        samplingRate: 96000,
      ),
    ]);
    controller = _controller(database);
    await tester.pumpWidget(_app(controller));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilterChip, 'Hi-Res'));
    await tester.pumpAndSettle();

    expect(find.textContaining('1 låt'), findsOneWidget);
    expect(find.text('Studio master'), findsOneWidget);
    expect(find.text('Compressed song'), findsNothing);
  });

  testWidgets('song tap is forwarded without long-press feedback machinery', (
    tester,
  ) async {
    await database.upsertSongs([_song(id: 'tap', title: 'Tap me')]);
    controller = _controller(database);
    Song? tapped;
    await tester.pumpWidget(
      _app(
        controller,
        screen: V2SongsScreen(
          controller: controller,
          onSongTap: (song) => tapped = song,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tap me'));
    expect(tapped?.id, 'tap');
  });

  testWidgets('screen follows the app locale', (tester) async {
    await database.upsertSongs([_song(id: '1', title: 'One')]);
    controller = _controller(database);

    await tester.pumpWidget(_app(controller, locale: const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Songs'), findsWidgets);
    expect(find.textContaining('1 song'), findsOneWidget);
    expect(find.text('Filters'), findsOneWidget);
  });

  testWidgets('favorites root stays restricted when filters reset', (
    tester,
  ) async {
    await database.upsertSongs([
      _song(id: 'favorite', title: 'Favorite song', starred: true),
      _song(id: 'other', title: 'Other song'),
    ]);
    controller = SongsController(
      repository: DriftSongLibraryRepository(database),
      searchDebounce: Duration.zero,
      initialFilter: const SongFilter(favoritesOnly: true),
    );
    await tester.pumpWidget(
      _app(
        controller,
        screen: V2SongsScreen(
          controller: controller,
          title: 'Favoriter',
          lockFavorites: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Favorite song'), findsOneWidget);
    expect(find.text('Other song'), findsNothing);
    expect(find.widgetWithText(FilterChip, 'Favoriter'), findsNothing);

    await tester.tap(find.text('Filter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Återställ'));
    await tester.tap(find.text('Tillämpa'));
    await tester.pumpAndSettle();
    expect(find.text('Favorite song'), findsOneWidget);
    expect(find.text('Other song'), findsNothing);
  });

  testWidgets('random sort shows a cancellable compact loading state', (
    tester,
  ) async {
    final repository = _PendingSongRepository();
    controller = SongsController(repository: repository);
    await tester.pumpWidget(_app(controller));
    repository.pages[0].complete([_modelSong('visible', 'Visible song')]);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Filter'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 6 && find.text('Slumpat').evaluate().isEmpty; i++) {
      await tester.drag(find.byType(ListView).last, const Offset(0, -300));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Slumpat'));
    await tester.tap(find.text('Tillämpa'));
    await tester.pump();

    expect(find.text('Blandar låtar…'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Avbryt'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Avbryt'));
    await tester.pump();
    expect(find.text('Visible song'), findsOneWidget);

    repository.pages[1].complete([
      _modelSong('discarded', 'Discarded shuffle'),
    ]);
    await tester.pumpAndSettle();
    expect(find.text('Visible song'), findsOneWidget);
    expect(find.text('Discarded shuffle'), findsNothing);
  });
}

class _PendingSongRepository implements SongLibraryRepository {
  final List<Completer<List<Song>>> pages = [];

  @override
  Future<int> count(SongFilter filter) async => 1;

  @override
  Future<List<Song>> page({
    required SongFilter filter,
    required int limit,
    required int offset,
  }) {
    final page = Completer<List<Song>>();
    pages.add(page);
    return page.future;
  }
}

SongsController _controller(AppDatabase database, {int pageSize = 60}) =>
    SongsController(
      repository: DriftSongLibraryRepository(database),
      pageSize: pageSize,
      searchDebounce: Duration.zero,
    );

Widget _app(
  SongsController controller, {
  Locale locale = const Locale('sv'),
  Widget? screen,
}) => MaterialApp(
  locale: locale,
  theme: NaviTheme.dark(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: screen ?? V2SongsScreen(controller: controller),
);

LocalSongsCompanion _song({
  required String id,
  required String title,
  String suffix = 'mp3',
  int bitRate = 320,
  int? bitDepth,
  int? samplingRate,
  bool starred = false,
}) => LocalSongsCompanion.insert(
  id: id,
  title: title,
  artist: 'Artist',
  album: 'Album',
  duration: const Value(180),
  suffix: Value(suffix),
  bitRate: Value(bitRate),
  bitDepth: Value(bitDepth),
  samplingRate: Value(samplingRate),
  starred: Value(starred),
);

Song _modelSong(String id, String title) => Song(
  id: id,
  title: title,
  artist: 'Artist',
  artistId: 'artist',
  album: 'Album',
  albumId: 'album',
);
