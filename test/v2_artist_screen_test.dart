import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/data/local/app_database.dart';
import 'package:navimusic/data/local/drift_catalog_repository.dart';
import 'package:navimusic/design_system/navi_theme.dart';
import 'package:navimusic/features/library/v2_artist_screen.dart';
import 'package:navimusic/l10n/app_localizations.dart';
import 'package:navimusic/models/models.dart';

void main() {
  testWidgets(
    'artist refresh waits for server work and then reloads local songs',
    (tester) async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      LocalSongsCompanion song(String title) => LocalSongsCompanion.insert(
        id: 'song',
        title: title,
        artist: 'Artist',
        album: 'Album',
        canonicalArtist: const Value('Artist'),
        playCount: const Value(10),
      );
      await database.upsertSongs([song('Before refresh')]);
      var refreshes = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: NaviTheme.dark(),
          locale: const Locale('sv'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: V2ArtistScreen(
            artist: ArtistSummary(id: 'artist', name: 'Artist'),
            catalog: DriftCatalogRepository(database),
            onAlbumTap: (_) {},
            onSongTap: (_) {},
            onPlay: (_) {},
            onShuffle: (_) {},
            onRefresh: () async {
              refreshes++;
              await database.upsertSongs([song('After refresh')]);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Before refresh'), findsWidgets);
      final indicator = tester.widget<RefreshIndicator>(
        find.byType(RefreshIndicator),
      );
      await indicator.onRefresh();
      await tester.pumpAndSettle();
      expect(refreshes, 1);
      expect(find.text('After refresh'), findsWidgets);
      expect(find.text('Before refresh'), findsNothing);
    },
  );
}
