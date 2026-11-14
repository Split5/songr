import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/app/v2/v2_experience_preferences.dart';
import 'package:navimusic/app/v2/v2_playback_preferences.dart';
import 'package:navimusic/app/v2/v2_server_settings.dart';
import 'package:navimusic/design_system/navi_theme.dart';
import 'package:navimusic/domain/sync/library_sync_progress.dart';
import 'package:navimusic/features/settings/v2_settings_screen.dart';
import 'package:navimusic/features/settings/v2_support_screen.dart';
import 'package:navimusic/l10n/app_localizations.dart';
import 'package:navimusic/state/download_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final result in ['success', 'failure', 'exception']) {
    testWidgets('full library sync handles $result and prevents double taps', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final server = V2ServerSettings();
      final playback = V2PlaybackPreferences();
      final experience = V2ExperiencePreferences();
      final downloads = DownloadProvider();
      addTearDown(server.dispose);
      addTearDown(playback.dispose);
      addTearDown(experience.dispose);
      addTearDown(downloads.dispose);
      final pending = Completer<bool>();
      var calls = 0;
      final progress = ValueNotifier<LibrarySyncProgress?>(null);
      addTearDown(progress.dispose);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('sv'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: NaviTheme.dark(),
          home: V2SettingsScreen(
            server: server,
            playback: playback,
            experience: experience,
            downloads: downloads,
            librarySyncProgress: progress,
            onSyncLibrary: () {
              calls++;
              return pending.future;
            },
          ),
        ),
      );
      final tile = find.byKey(const ValueKey('sync-full-library'));
      expect(find.text('Läs in hela biblioteket'), findsOneWidget);
      await tester.tap(tile);
      await tester.pump();
      expect(find.text('Läser in biblioteket…'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(tester.widget<ListTile>(tile).onTap, isNull);
      await tester.tap(tile);
      expect(calls, 1);
      progress.value = const LibrarySyncProgress(
        LibrarySyncStage.songs,
        processed: 125000,
      );
      await tester.pump();
      expect(find.textContaining('låtar hämtade'), findsOneWidget);
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        isNull,
      );
      progress.value = const LibrarySyncProgress(
        LibrarySyncStage.playlists,
        processed: 3,
        total: 10,
      );
      await tester.pump();
      expect(find.text('3 av 10 spellistor hämtade'), findsOneWidget);
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        0.3,
      );
      progress.value = null;
      if (result == 'exception') {
        pending.completeError(StateError('offline'));
      } else {
        pending.complete(result == 'success');
      }
      await tester.pumpAndSettle();
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(tester.widget<ListTile>(tile).onTap, isNotNull);
      expect(
        find.text(
          result == 'success'
              ? 'Hela biblioteket har uppdaterats.'
              : 'Biblioteket kunde inte uppdateras helt. Kontrollera anslutningen och försök igen.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('full sync progress remains visible after reopening Settings', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final server = V2ServerSettings();
    final playback = V2PlaybackPreferences();
    final experience = V2ExperiencePreferences();
    final downloads = DownloadProvider();
    final progress = ValueNotifier<LibrarySyncProgress?>(null);
    addTearDown(server.dispose);
    addTearDown(playback.dispose);
    addTearDown(experience.dispose);
    addTearDown(downloads.dispose);
    addTearDown(progress.dispose);
    final pending = Completer<bool>();
    var calls = 0;
    final settings = V2SettingsScreen(
      server: server,
      playback: playback,
      experience: experience,
      downloads: downloads,
      librarySyncProgress: progress,
      onSyncLibrary: () {
        calls++;
        progress.value = const LibrarySyncProgress(
          LibrarySyncStage.songs,
          processed: 500,
        );
        return pending.future;
      },
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('sv'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: NaviTheme.dark(),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (_) => settings)),
              child: const Text('Open settings'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open settings'));
    await tester.pumpAndSettle();
    final tile = find.byKey(const ValueKey('sync-full-library'));
    await tester.tap(tile);
    await tester.pump();
    expect(find.text('500 låtar hämtade'), findsOneWidget);
    Navigator.of(tester.element(tile)).pop();
    await tester.pumpAndSettle();
    progress.value = const LibrarySyncProgress(
      LibrarySyncStage.albums,
      processed: 200,
    );
    await tester.tap(find.text('Open settings'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('200 album hämtade'), findsOneWidget);
    expect(tester.widget<ListTile>(tile).onTap, isNull);
    expect(calls, 1);
    progress.value = null;
    pending.complete(true);
    await tester.pumpAndSettle();
    expect(tester.widget<ListTile>(tile).onTap, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home and recommendation settings are reachable from Settings', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final server = V2ServerSettings();
    final playback = V2PlaybackPreferences();
    final experience = V2ExperiencePreferences();
    final downloads = DownloadProvider();
    addTearDown(server.dispose);
    addTearDown(playback.dispose);
    addTearDown(experience.dispose);
    addTearDown(downloads.dispose);
    await experience.load();

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('sv'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: NaviTheme.dark().copyWith(platform: TargetPlatform.iOS),
        home: V2SettingsScreen(
          server: server,
          playback: playback,
          experience: experience,
          downloads: downloads,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Anpassa Hem'));
    await tester.pumpAndSettle();
    final logoSwitch = find.byKey(const ValueKey('home-header-logo'));
    expect(tester.widget<SwitchListTile>(logoSwitch).value, isFalse);
    await tester.tap(logoSwitch);
    await tester.pumpAndSettle();
    expect(experience.homeHeaderStyle, HomeHeaderStyle.logo);
    expect(find.text('Innehåll per karusell'), findsOneWidget);
    expect(find.text('Låtar'), findsNWidgets(2));
    expect(find.text('Album'), findsNWidgets(2));
    expect(find.text('Hyllor och ordning'), findsOneWidget);
    expect(find.byIcon(Icons.drag_handle_rounded), findsNWidgets(5));

    await tester.tap(find.byKey(const ValueKey('home-content-recentlyAdded')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-content-option-albums')));
    await tester.pumpAndSettle();
    expect(
      experience.homeContentFor(HomeSectionKind.recentlyAdded),
      HomeContentFocus.albums,
    );
    expect(find.text('Låtar'), findsNWidgets(2));
    expect(find.text('Album'), findsNWidgets(2));

    Navigator.of(tester.element(find.text('Hyllor och ordning'))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('appearance-settings')));
    await tester.pumpAndSettle();
    expect(find.text('Övre baren'), findsOneWidget);
    expect(find.text('Genomskinlighet'), findsOneWidget);
    expect(find.text('Oskärpa'), findsOneWidget);
    final topSlider = tester.widget<Slider>(
      find.byKey(const ValueKey('top-bar-transparency-slider')),
    );
    final topBlurSlider = tester.widget<Slider>(
      find.byKey(const ValueKey('top-bar-blur-slider')),
    );
    expect(topSlider.value, closeTo(0.78, 0.001));
    expect(topBlurSlider.value, closeTo(10, 0.001));
    topSlider.onChanged!(0.74);
    topBlurSlider.onChanged!(0);
    await tester.pump();
    expect(experience.topBarTransparency, closeTo(0.74, 0.001));
    expect(experience.topBarBlurSigma, 0);

    Navigator.of(tester.element(find.text('Övre baren'))).pop();
    await tester.pumpAndSettle();
    expect(find.textContaining('AudioMuse'), findsNothing);
    expect(find.text('Rekommendationer'), findsNothing);
    expect(find.text('Algoritm'), findsOneWidget);
    expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
    await tester.tap(find.text('Algoritm'));
    await tester.pumpAndSettle();
    expect(find.text('Variation'), findsOneWidget);
    expect(find.text('Artistvariation'), findsOneWidget);
    expect(find.text('Startköns storlek'), findsOneWidget);
    expect(find.byType(Slider), findsNWidgets(3));
    // The direct AudioMuse connection screen is gone for good.
    expect(find.textContaining('AudioMuse'), findsNothing);
    expect(find.byIcon(Icons.cloud_off_rounded), findsNothing);
    expect(find.byIcon(Icons.cloud_done_rounded), findsNothing);

    Navigator.of(tester.element(find.text('Variation'))).pop();
    await tester.pumpAndSettle();
    expect(find.text('Installation'), findsOneWidget);
    final support = find.text('Rapportera fel eller förslag');
    await tester.scrollUntilVisible(
      support,
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(support, findsOneWidget);
    expect(find.text('Stöd utvecklaren'), findsNothing);
    expect(find.text('Integritetspolicy'), findsOneWidget);
    final refund = find.text('Begär återbetalning');
    expect(refund, findsNothing);
  });

  testWidgets('bug reporting opens an in-app report sheet', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('sv'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: NaviTheme.dark(),
        home: const Scaffold(body: V2BugReportTile()),
      ),
    );

    await tester.tap(find.text('Rapportera fel eller förslag'));
    await tester.pumpAndSettle();

    expect(find.text('Skicka felrapport'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('bug-report-description')),
      findsOneWidget,
    );
    expect(find.text('Bild'), findsOneWidget);
    expect(find.text('Video'), findsOneWidget);
  });
}
