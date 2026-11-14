import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/data/local/app_database.dart';
import 'package:navimusic/data/local/drift_catalog_repository.dart';
import 'package:navimusic/data/local/drift_radio_repository.dart';
import 'package:navimusic/data/local/drift_song_library_repository.dart';
import 'package:navimusic/design_system/navi_theme.dart';
import 'package:navimusic/domain/radio/radio_repository.dart';
import 'package:navimusic/features/radio/radio_controller.dart';
import 'package:navimusic/features/radio/v2_radio_screen.dart';
import 'package:navimusic/l10n/app_localizations.dart';
import 'package:navimusic/models/models.dart';

void main() {
  test('station snapshots replace atomically and remain offline', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await database.replaceInternetRadioStations([
      LocalInternetRadioStationsCompanion.insert(
        id: 'old',
        name: 'Old station',
        streamUrl: 'https://example.test/old',
        updatedAt: DateTime(2026),
      ),
    ]);
    await database.replaceInternetRadioStations([
      LocalInternetRadioStationsCompanion.insert(
        id: 'new',
        name: 'New station',
        streamUrl: 'https://example.test/new',
        updatedAt: DateTime(2026, 2),
      ),
    ]);

    final rows = await database
        .select(database.localInternetRadioStations)
        .get();
    expect(rows.map((row) => row.id), ['new']);
  });

  testWidgets('Radio renders all local seed types and starts genre radio', (
    tester,
  ) async {
    final controller = RadioController(repository: _Radio());
    addTearDown(controller.dispose);
    List<Song>? played;
    await tester.pumpWidget(
      _app(
        V2RadioScreen(
          controller: controller,
          onStationTap: (_) async {},
          onSongsReady: (songs) => played = songs,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Stationer'), findsOneWidget);
    expect(find.text('P3'), findsOneWidget);
    expect(find.text('Genreradio'), findsOneWidget);
    expect(find.text('Pop'), findsOneWidget);
    await tester.tap(find.text('Pop'));
    await tester.pumpAndSettle();
    expect(played?.single.id, 'pop-song');
  });

  testWidgets(
    'an unsupported station URL explains why playback did not start',
    (tester) async {
      final controller = RadioController(repository: _Radio());
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _app(
          V2RadioScreen(
            controller: controller,
            onStationTap: (_) async =>
                throw const FormatException('unsupported URL'),
            onSongsReady: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('P3'));
      await tester.pumpAndSettle();

      expect(
        find.text('Radiostationens streamadress stöds inte.'),
        findsOneWidget,
      );
    },
  );

  test(
    'artist radio falls back to a real song cover and play history',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      await database
          .into(database.localArtists)
          .insert(LocalArtistsCompanion.insert(id: 'artist', name: 'Artist'));
      await database.upsertSongs([
        LocalSongsCompanion.insert(
          id: 'song',
          title: 'Song',
          artist: 'Artist',
          canonicalArtist: const Value('Artist'),
          album: 'Album',
          coverArt: const Value('song-cover'),
          playCount: const Value(12),
        ),
      ]);
      final catalog = DriftCatalogRepository(database);
      final repository = DriftRadioRepository(
        database: database,
        catalog: catalog,
        songs: DriftSongLibraryRepository(database),
      );

      final artist = (await repository.artists()).single;
      expect(artist.name, 'Artist');
      expect(artist.coverArt, 'song-cover');
    },
  );
}

class _Radio implements RadioRepository {
  @override
  Future<List<ArtistSummary>> artists({int limit = 12}) async => [
    ArtistSummary(id: 'artist', name: 'Artist'),
  ];

  @override
  Future<List<String>> genres({int limit = 12}) async => ['Pop'];

  @override
  Future<List<Song>> songsForArtist(ArtistSummary artist) async => [
    _song('artist-song'),
  ];

  @override
  Future<List<Song>> songsForGenre(String genre, {int limit = 80}) async => [
    _song('pop-song'),
  ];

  @override
  Future<List<InternetRadioStation>> stations() async => const [
    InternetRadioStation(
      id: 'p3',
      name: 'P3',
      streamUrl: 'https://example.test/p3',
    ),
  ];
}

Song _song(String id) => Song(
  id: id,
  title: 'Song',
  artist: 'Artist',
  artistId: 'artist',
  album: 'Album',
  albumId: 'album',
);

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
