import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/design_system/navi_design_tokens.dart';
import 'package:navimusic/design_system/navi_theme.dart';
import 'package:navimusic/design_system/widgets/navi_glass.dart';

void main() {
  testWidgets('modal glass has its own opaque surface and strong barrier', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: NaviTheme.dark(),
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () => showNaviModalBottomSheet<void>(
                context: context,
                builder: (_) => const NaviModalSurface(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      NaviModalHandle(),
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('Readable modal text'),
                      ),
                    ],
                  ),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('navi-modal-surface')), findsOneWidget);
    expect(find.byKey(const ValueKey('navi-modal-handle')), findsOneWidget);
    expect(find.text('Readable modal text'), findsOneWidget);

    final surface = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('navi-modal-surface')),
    );
    final decoration = surface.decoration as BoxDecoration;
    final gradient = decoration.gradient;
    // The keyed outer box owns the shadow. The inner gradient is verified via
    // the public color tokens so neither modal endpoint can regress to a
    // nearly transparent card.
    expect(decoration.boxShadow, isNotEmpty);
    expect(gradient, isNull);
    expect(NaviColors.modalGlassTop.a, greaterThan(0.9));
    expect(NaviColors.modalGlassBottom.a, greaterThan(0.95));

    final barriers = tester.widgetList<ModalBarrier>(find.byType(ModalBarrier));
    expect(
      barriers.any((barrier) => barrier.color == NaviColors.modalBarrier),
      isTrue,
    );
  });
}
