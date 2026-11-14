import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/l10n/app_localizations.dart';

void main() {
  testWidgets('uses Swedish and English from the system locale', (
    tester,
  ) async {
    addTearDown(() => tester.platformDispatcher.clearLocalesTestValue());

    for (final (locale, expected) in [
      (const Locale('sv', 'SE'), 'Söngr'),
      (const Locale('en', 'US'), 'Soengr'),
    ]) {
      tester.platformDispatcher.localesTestValue = [locale];
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Text(AppLocalizations.of(context).appTitle),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(expected), findsOneWidget);
    }
  });
}
