import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/app/v2/v2_experience_preferences.dart';
import 'package:navimusic/data/local/app_database.dart';
import 'package:navimusic/data/local/drift_catalog_repository.dart';
import 'package:navimusic/data/local/drift_song_library_repository.dart';
import 'package:navimusic/design_system/navi_design_tokens.dart';
import 'package:navimusic/design_system/navi_theme.dart';
import 'package:navimusic/domain/library/song_filter.dart';
import 'package:navimusic/features/favorites/favorites_controller.dart';
import 'package:navimusic/features/favorites/v2_favorites_screen.dart';
import 'package:navimusic/l10n/app_localizations.dart';
import 'package:navimusic/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase database;
  late FavoritesController controller;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await database.batch((batch) {
      batch.insertAll(database.localSongs, [
        _song('favorite', 'Favorite song', starred: true),
        _song('other', 'Other song'),
      ]);
      batch.insert(
        database.localAlbums,
        LocalAlbumsCompanion.insert(
          id: 'favorite-album',
          name: 'Favorite album',
          artist: 'Favorite artist',
          canonicalArtist: const Value('Favorite artist'),
          year: const Value(2010),
          playCount: const Value(2),
          createdAt: Value(DateTime(2020)),
          starred: const Value(true),
        ),
      );
      batch.insert(
        database.localAlbums,
        LocalAlbumsCompanion.insert(
          id: 'newer-album',
          name: 'Newer album',
          artist: 'Other artist',
          canonicalArtist: const Value('Other artist'),
          year: const Value(2024),
          playCount: const Value(12),
          createdAt: Value(DateTime(2024)),
          starred: const Value(true),
        ),
      );
      batch.insert(
        database.localArtists,
        LocalArtistsCompanion.insert(
          id: 'favorite-artist',
          name: 'Favorite artist',
          sortName: const Value('Favorite artist'),
          albumCount: const Value(1),
          starred: const Value(true),
        ),
      );
      batch.insert(
        database.localArtists,
        LocalArtistsCompanion.insert(
          id: 'other-artist',
          name: 'Other artist',
          sortName: const Value('Other artist'),
          albumCount: const Value(5),
          starred: const Value(true),
        ),
      );
    });
    controller = FavoritesController(
      songLibrary: DriftSongLibraryRepository(database),
      catalog: DriftCatalogRepository(database),
    );
  });

  tearDown(() async {
    controller.dispose();
    await database.close();
  });

  testWidgets('favorites keep songs albums and artists explicitly separated', (
    tester,
  ) async {
    await tester.pumpWidget(_app(controller));
    await tester.pumpAndSettle();

    expect(find.text('Favorite song'), findsOneWidget);
    expect(find.text('Other song'), findsNothing);

    await tester.tap(find.text('Album'));
    await tester.pumpAndSettle();
    expect(find.text('Favorite album'), findsOneWidget);
    expect(find.textContaining('Favorite artist'), findsOneWidget);

    await tester.tap(find.text('Artister'));
    await tester.pumpAndSettle();
    expect(find.text('Favorite artist'), findsOneWidget);
    expect(find.text('Favorite album'), findsNothing);
  });

  testWidgets('favorites can seed a similarity mix', (tester) async {
    List<String>? mixedIds;
    await tester.pumpWidget(
      _app(
        controller,
        onPlayMix: (songs) async {
          mixedIds = songs.map((song) => song.id).toList();
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Favoritmix'));
    await tester.pumpAndSettle();

    expect(mixedIds, ['favorite']);
  });

  testWidgets('favorite songs expose full filtering and can be reset', (
    tester,
  ) async {
    await tester.pumpWidget(_app(controller));
    await tester.pumpAndSettle();
    expect(controller.songs.state.filter.sort, SongSort.newest);
    expect(find.textContaining('· Senast tillagda'), findsOneWidget);

    await tester.tap(find.byTooltip('Filter'));
    await tester.pumpAndSettle();
    expect(find.text('Kvalitet'), findsOneWidget);

    await tester.tap(find.text('Hi-Res'));
    await tester.tap(find.text('Tillämpa'));
    await tester.pumpAndSettle();

    expect(find.text('Favorite song'), findsNothing);
    expect(find.text('Rensa filter'), findsOneWidget);

    await tester.tap(find.text('Rensa filter'));
    await tester.pumpAndSettle();
    expect(find.text('Favorite song'), findsOneWidget);
    expect(controller.songs.state.filter.sort, SongSort.newest);
  });

  testWidgets('favorite playback actions use tonal surfaces, not white', (
    tester,
  ) async {
    await tester.pumpWidget(_app(controller));
    await tester.pumpAndSettle();

    final play = tester.widget<IconButton>(
      find
          .ancestor(
            of: find.byTooltip('Spela'),
            matching: find.byType(IconButton),
          )
          .first,
    );
    expect(play.style?.backgroundColor?.resolve({}), NaviColors.surfaceRaised);

    final mix = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Favoritmix'),
        matching: find.byType(FilledButton),
      ),
    );
    expect(mix.style?.backgroundColor?.resolve({}), NaviColors.surfaceRaised);
  });

  testWidgets('favorite filters and sorting survive a new app session', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final firstPreferences = V2ExperiencePreferences();
    await firstPreferences.load();
    final first = FavoritesController(
      songLibrary: DriftSongLibraryRepository(database),
      catalog: DriftCatalogRepository(database),
      preferences: firstPreferences,
    );
    await first.initialize();
    await first.select(FavoriteSection.albums);
    await first.setAlbumSort(FavoriteAlbumSort.yearNewest);
    await first.setArtistSort(FavoriteArtistSort.albumCount);
    await first.applySongFilter(
      const SongFilter(
        query: 'favorite',
        quality: SongQuality.hiRes,
        favoritesOnly: true,
        sort: SongSort.artist,
      ),
    );
    first.dispose();
    firstPreferences.dispose();

    final restoredPreferences = V2ExperiencePreferences();
    await restoredPreferences.load();
    final restored = FavoritesController(
      songLibrary: DriftSongLibraryRepository(database),
      catalog: DriftCatalogRepository(database),
      preferences: restoredPreferences,
    );
    addTearDown(restored.dispose);
    addTearDown(restoredPreferences.dispose);
    await restored.initialize();

    expect(restored.section, FavoriteSection.albums);
    expect(restored.albumSort, FavoriteAlbumSort.yearNewest);
    expect(restored.artistSort, FavoriteArtistSort.albumCount);
    expect(restored.songs.state.filter.query, 'favorite');
    expect(restored.songs.state.filter.quality, SongQuality.hiRes);
    expect(restored.songs.state.filter.sort, SongSort.artist);
    expect(restored.songs.state.filter.favoritesOnly, isTrue);

    await tester.pumpWidget(_app(restored));
    await tester.pumpAndSettle();
    final search = tester.widget<TextField>(find.byType(TextField));
    expect(search.controller?.text, 'favorite');
  });

  test('album and artist favorites support contextual sorting', () async {
    await controller.initialize();

    await controller.setAlbumSort(FavoriteAlbumSort.yearNewest);
    expect(controller.visibleAlbums.map((album) => album.name), [
      'Newer album',
      'Favorite album',
    ]);

    await controller.setArtistSort(FavoriteArtistSort.albumCount);
    expect(controller.visibleArtists.map((artist) => artist.name), [
      'Other artist',
      'Favorite artist',
    ]);
  });
}

Widget _app(
  FavoritesController controller, {
  Future<void> Function(List<Song>)? onPlayMix,
}) => MaterialApp(
  locale: const Locale('sv'),
  theme: NaviTheme.dark(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: V2FavoritesScreen(
    controller: controller,
    onSongTap: (_) {},
    onSongMenu: (_) {},
    onAlbumTap: (_) {},
    onArtistTap: (_) {},
    onPlaySongs: (_, {required shuffle}) {},
    onPlayMix: onPlayMix ?? (_) async {},
  ),
);

LocalSongsCompanion _song(String id, String title, {bool starred = false}) =>
    LocalSongsCompanion.insert(
      id: id,
      title: title,
      artist: 'Favorite artist',
      artistId: const Value('favorite-artist'),
      album: 'Favorite album',
      albumId: const Value('favorite-album'),
      duration: const Value(180),
      starred: Value(starred),
    );
