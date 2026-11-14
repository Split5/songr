import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/design_system/navi_theme.dart';
import 'package:navimusic/design_system/widgets/navi_widgets.dart';

void main() {
  group('NaviArtwork fallback glyph', () {
    Future<double?> glyphSizeIn(WidgetTester tester, Widget host) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NaviTheme.dark(),
          home: Scaffold(body: Center(child: host)),
        ),
      );
      return tester.widget<Icon>(find.byIcon(Icons.music_note_rounded)).size;
    }

    testWidgets('fills the player artwork with a 72 pt glyph', (tester) async {
      final size = await glyphSizeIn(
        tester,
        const SizedBox.square(
          dimension: 310,
          child: NaviArtwork(fallback: Icons.music_note_rounded, radius: 0),
        ),
      );
      expect(size, 72);
    });

    testWidgets('scales with a 144 pt card', (tester) async {
      final size = await glyphSizeIn(
        tester,
        const SizedBox.square(
          dimension: 144,
          child: NaviArtwork(fallback: Icons.music_note_rounded, radius: 0),
        ),
      );
      expect(size, closeTo(60.5, 0.1));
    });

    testWidgets('uses the explicit size when given', (tester) async {
      final size = await glyphSizeIn(
        tester,
        const NaviArtwork(fallback: Icons.music_note_rounded, size: 52),
      );
      expect(size, closeTo(21.8, 0.1));
      expect(tester.getSize(find.byType(NaviArtwork)), const Size.square(52));
    });

    testWidgets('keeps the theme glyph when the parent is unbounded', (
      tester,
    ) async {
      final size = await glyphSizeIn(
        tester,
        const UnconstrainedBox(
          child: NaviArtwork(fallback: Icons.music_note_rounded),
        ),
      );
      expect(size, isNull);
    });
  });
}
