import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/domain/lyrics/lrc_document.dart';
import 'package:navimusic/features/player/lyrics_playhead.dart';
import 'package:navimusic/features/player/v2_player_sheets.dart';
import 'package:navimusic/l10n/app_localizations.dart';

void main() {
  late StreamController<Duration> updates;
  late Duration current;
  final seeks = <Duration>[];

  setUp(() {
    updates = StreamController<Duration>.broadcast(sync: true);
    current = const Duration(milliseconds: 1400);
    seeks.clear();
  });

  tearDown(() async {
    await updates.close();
  });

  final document = LrcDocument.parse('[00:01.50]First\n[00:02.50]Second');

  LyricsPlayhead playhead() =>
      LyricsPlayhead(now: () => current, updates: updates.stream);

  Future<void> pumpLyrics(
    WidgetTester tester, {
    LrcDocument? lines,
    Duration offset = Duration.zero,
    ValueChanged<Duration>? onOffsetChanged,
  }) => tester.pumpWidget(
    _app(
      SyncedLyrics(
        document: lines ?? document,
        playhead: playhead(),
        onSeek: (position) async => seeks.add(position),
        offset: offset,
        onOffsetChanged: onOffsetChanged,
      ),
    ),
  );

  List<double> highlighted(WidgetTester tester) => tester
      .widgetList<AnimatedOpacity>(
        find.descendant(
          of: find.byType(SyncedLyrics),
          matching: find.byType(AnimatedOpacity),
        ),
      )
      .map((line) => line.opacity)
      .toList(growable: false);

  testWidgets('the highlight follows the position the player reports', (
    tester,
  ) async {
    await pumpLyrics(tester);
    await tester.pump();
    expect(highlighted(tester), [0.38, 0.38]);

    current = const Duration(milliseconds: 1520);
    updates.add(current);
    await tester.pump();
    expect(highlighted(tester), [1, 0.38]);

    current = const Duration(milliseconds: 2600);
    updates.add(current);
    await tester.pump();
    expect(highlighted(tester), [0.38, 1]);
  });

  testWidgets('a stalled player does not run the lyrics ahead', (tester) async {
    // The regression: the view used to run its own clock, so a buffer stall
    // after a seek kept advancing the text while the audio stood still.
    await pumpLyrics(tester);
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    expect(highlighted(tester), [0.38, 0.38]);
  });

  testWidgets('a seek moves the highlight and the list to the new line', (
    tester,
  ) async {
    final lines = LrcDocument.parse(
      [
        for (var second = 0; second < 60; second++)
          '[00:${second.toString().padLeft(2, '0')}.00]Line $second',
      ].join('\n'),
    );
    current = const Duration(seconds: 10);

    await pumpLyrics(tester, lines: lines);
    await tester.pump();
    expect(find.text('Line 10'), findsOneWidget);

    current = const Duration(seconds: 45);
    updates.add(current);
    await tester.pump();
    await tester.pump();

    expect(find.text('Line 45'), findsOneWidget);
    final rect = tester.getRect(find.text('Line 45'));
    expect(rect.top, greaterThan(0));
    expect(rect.bottom, lessThan(600));
  });

  testWidgets('opens on the line that is playing', (tester) async {
    final lines = LrcDocument.parse(
      [
        for (var second = 0; second < 60; second++)
          '[00:${second.toString().padLeft(2, '0')}.00]Line $second',
      ].join('\n'),
    );
    current = const Duration(seconds: 40);

    await pumpLyrics(tester, lines: lines);
    await tester.pump();

    // The fortieth line is far below the first screenful; it can only be on
    // screen if the list opened at the playhead.
    expect(find.text('Line 40'), findsOneWidget);
    final rect = tester.getRect(find.text('Line 40'));
    expect(rect.top, greaterThan(0));
    expect(rect.bottom, lessThan(600));
    final list = tester.widget<ListView>(find.byType(ListView));
    expect(list.controller!.offset, greaterThan(0));
  });

  testWidgets('a positive offset delays the highlight', (tester) async {
    // 1.4 s + 100 ms delay is still before the first line at 1.5 s.
    await pumpLyrics(tester, offset: const Duration(milliseconds: 100));
    await tester.pump();
    expect(highlighted(tester), [0.38, 0.38]);

    // A negative offset pulls the first line in early.
    await tester.pumpWidget(_app(const SizedBox.shrink()));
    await pumpLyrics(tester, offset: const Duration(milliseconds: -100));
    await tester.pump();
    expect(highlighted(tester), [1, 0.38]);
  });

  testWidgets('the sync control nudges the offset one step at a time', (
    tester,
  ) async {
    final changes = <Duration>[];
    await pumpLyrics(tester, onOffsetChanged: changes.add);
    await tester.pump();

    expect(find.text('Synk'), findsOneWidget);
    expect(find.text('+0 ms'), findsOneWidget);

    await tester.tap(find.byTooltip('Visa texten senare'));
    expect(changes, [const Duration(milliseconds: 100)]);
  });
}

Widget _app(Widget child) => MaterialApp(
  locale: const Locale('sv'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);
