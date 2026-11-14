import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/app/v2/v2_splash_fallback.dart';
import 'package:navimusic/design_system/navi_design_tokens.dart';
import 'package:navimusic/design_system/navi_theme.dart';

void main() {
  Widget app() =>
      MaterialApp(theme: NaviTheme.dark(), home: const V2SplashFallback());

  testWidgets('shows the small splash mark and progress immediately', (
    tester,
  ) async {
    await tester.pumpWidget(app());

    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as AssetImage).assetName, V2SplashFallback.markAsset);
    expect(
      image.width,
      tester.view.physicalSize.width / tester.view.devicePixelRatio * 0.3,
    );

    final box = tester.widget<ColoredBox>(
      find.descendant(
        of: find.byType(V2SplashFallback),
        matching: find.byType(ColoredBox),
      ),
    );
    expect(box.color, NaviColors.canvas);

    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });
}
