import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:navimusic/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App Review walkthrough on a physical iPhone', (tester) async {
    await app.main();
    await _waitFor(tester, find.byTooltip('Settings'));
    await _hold(tester, const Duration(seconds: 4));

    // Show and verify the configured review account.
    await tester.tap(find.byTooltip('Settings'));
    await _waitFor(tester, find.text('Server settings'));
    await _hold(tester, const Duration(seconds: 2));
    await tester.tap(find.text('Server settings'));
    await _waitFor(tester, find.text('Connect and save'));
    await _hold(tester, const Duration(seconds: 3));

    final fields = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    expect(fields, hasLength(3));
    expect(fields[0].controller?.text, 'https://musik.simonbystrom.se');
    expect(fields[1].controller?.text, 'demo');

    // Saving with the stored password performs a real Navidrome login check.
    await tester.ensureVisible(find.text('Connect and save'));
    await tester.tap(find.text('Connect and save'));
    await _waitFor(tester, find.text('Home'));
    await tester.pageBack();
    await _waitFor(tester, find.text('Home'));
    await _hold(tester, const Duration(seconds: 3));

    // Show live search against the demo library.
    await tester.tap(find.text('Search').last);
    await _waitFor(tester, find.byType(TextField));
    await tester.enterText(find.byType(TextField).first, 'Adele');
    await _hold(tester, const Duration(seconds: 4));
    tester.testTextInput.receiveAction(TextInputAction.done);
    await _hold(tester, const Duration(seconds: 2));

    // Show the album grid and start playback from a known demo album.
    await tester.tap(find.text('Library').last);
    await _waitFor(tester, find.text('Albums'));
    await _hold(tester, const Duration(seconds: 2));
    await tester.tap(find.text('Albums'));
    await _waitFor(tester, find.text('Back to Black'));
    await _hold(tester, const Duration(seconds: 3));
    await tester.tap(find.text('Back to Black'));
    await _waitFor(tester, find.text('Rehab'));
    await _hold(tester, const Duration(seconds: 2));
    await tester.tap(find.text('Rehab').first);
    await _waitFor(tester, find.text('Rehab').last);
    await _hold(tester, const Duration(seconds: 4));

    // Open the full player and leave enough time for playback to be visible.
    await tester.tap(find.text('Rehab').last);
    await _waitFor(tester, find.byTooltip('Queue'));
    await _hold(tester, const Duration(seconds: 5));
    await tester.tap(find.byTooltip('Queue'));
    await _hold(tester, const Duration(seconds: 4));
  });
}

Future<void> _waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
  throw TestFailure('Timed out waiting for $finder');
}

Future<void> _hold(WidgetTester tester, Duration duration) async {
  await tester.runAsync(() => Future<void>.delayed(duration));
  await tester.pump();
}
