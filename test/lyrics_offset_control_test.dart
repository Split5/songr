import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/domain/lyrics/lrc_document.dart';
import 'package:navimusic/features/player/lyrics_playhead.dart';
import 'package:navimusic/features/player/v2_player_sheets.dart';
import 'package:navimusic/l10n/app_localizations.dart';

void main() {
  testWidgets('the sync buttons move the highlight a step at a time', (
    tester,
  ) async {
    final updates = StreamController<Duration>.broadcast(sync: true);
    addTearDown(updates.close);
    const position = Duration(milliseconds: 1400);

    await tester.pumpWidget(
      _app(
        _OffsetHarness(
          playhead: LyricsPlayhead(
            now: () => position,
            updates: updates.stream,
          ),
        ),
      ),
    );
    await tester.pump();

    // 1.40 s with no offset: still before the first line at 1.50 s.
    expect(_activeLine(tester), isNull);

    // "Visa texten tidigare" pulls the line in by 100 ms => 1.50 s.
    await tester.tap(find.byTooltip('Visa texten tidigare'));
    await tester.pump();
    expect(_activeLine(tester), 'First');
  });
}

/// Mirrors what the lyrics sheet does with the offset: keeps it and hands the
/// new value back to the view.
class _OffsetHarness extends StatefulWidget {
  const _OffsetHarness({required this.playhead});

  final LyricsPlayhead playhead;

  @override
  State<_OffsetHarness> createState() => _OffsetHarnessState();
}

class _OffsetHarnessState extends State<_OffsetHarness> {
  Duration offset = Duration.zero;

  @override
  Widget build(BuildContext context) => SyncedLyrics(
    document: LrcDocument.parse('[00:01.50]First\n[00:02.50]Second'),
    playhead: widget.playhead,
    onSeek: (_) async {},
    offset: offset,
    onOffsetChanged: (value) => setState(() => offset = value),
  );
}

String? _activeLine(WidgetTester tester) {
  for (final element
      in find
          .descendant(
            of: find.byType(SyncedLyrics),
            matching: find.byType(AnimatedOpacity),
          )
          .evaluate()) {
    final line = element.widget as AnimatedOpacity;
    if (line.opacity != 1) continue;
    final text = find.descendant(
      of: find.byWidget(line),
      matching: find.byType(Text),
    );
    return tester.widget<Text>(text).data;
  }
  return null;
}

Widget _app(Widget child) => MaterialApp(
  locale: const Locale('sv'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);
