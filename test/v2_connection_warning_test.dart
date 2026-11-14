import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/app/v2/v2_server_settings.dart';
import 'package:navimusic/design_system/navi_theme.dart';
import 'package:navimusic/features/settings/v2_connection_screen.dart';
import 'package:navimusic/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows a non-blocking warning for HTTP server URLs', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final settings = V2ServerSettings();
    addTearDown(settings.dispose);

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
        home: V2ConnectionScreen(settings: settings),
      ),
    );

    expect(find.textContaining('HTTP är okrypterat'), findsNothing);
    await tester.enterText(
      find.byType(TextField).first,
      'http://192.168.1.20:4533',
    );
    await tester.pump();

    expect(find.textContaining('HTTP är okrypterat'), findsOneWidget);
    expect(find.text('Anslut och spara'), findsOneWidget);
  });
}
