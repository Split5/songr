import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/design_system/navi_design_tokens.dart';
import 'package:navimusic/design_system/navi_theme.dart';
import 'package:navimusic/design_system/widgets/navi_chrome_style.dart';
import 'package:navimusic/design_system/widgets/navi_glass.dart';
import 'package:navimusic/design_system/widgets/navi_persistent_dock.dart';

void main() {
  test('V2 theme keeps a stable dark canvas and artwork-safe contrast', () {
    final theme = NaviTheme.dark();

    expect(theme.scaffoldBackgroundColor, NaviColors.canvas);
    expect(theme.colorScheme.primary, NaviColors.textPrimary);
    expect(theme.colorScheme.onPrimary, NaviColors.canvas);
    expect(theme.colorScheme.secondary, NaviColors.accent);
    expect(theme.colorScheme.surface, NaviColors.canvas);
    expect(theme.colorScheme.surfaceTint, Colors.transparent);
    expect(theme.textTheme.bodyMedium?.color, NaviColors.textSecondary);
    expect(theme.splashFactory, NoSplash.splashFactory);
  });

  test('primary pills are white on black and snack bars float', () {
    final theme = NaviTheme.dark();
    final filled = theme.filledButtonTheme.style!;

    expect(filled.backgroundColor?.resolve({}), NaviColors.textPrimary);
    expect(filled.foregroundColor?.resolve({}), NaviColors.canvas);
    expect(
      NaviTheme.tonalButtonStyle.backgroundColor?.resolve({}),
      NaviColors.surfaceRaised,
    );
    expect(theme.snackBarTheme.behavior, SnackBarBehavior.floating);
    expect(theme.snackBarTheme.backgroundColor, NaviColors.surfaceRaised);
    expect(theme.dividerColor, NaviColors.separator);
  });

  testWidgets('primary and tonal pills resolve to different surfaces', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: NaviTheme.dark(),
        home: Scaffold(
          body: Column(
            children: [
              FilledButton(onPressed: () {}, child: const Text('Play')),
              FilledButton.tonal(
                style: NaviTheme.tonalButtonStyle,
                onPressed: () {},
                child: const Text('Shuffle'),
              ),
            ],
          ),
        ),
      ),
    );

    Material surfaceOf(String label) => tester.widget<Material>(
      find
          .ancestor(of: find.text(label), matching: find.byType(Material))
          .first,
    );

    final primary = surfaceOf('Play');
    final tonal = surfaceOf('Shuffle');
    expect(primary.color, NaviColors.textPrimary);
    expect(primary.textStyle?.color, NaviColors.canvas);
    expect(tonal.color, NaviColors.surfaceRaised);
    expect(tonal.textStyle?.color, NaviColors.textPrimary);
    expect(tonal.color, isNot(primary.color));
  });

  test('small text styles keep Material weight and colour', () {
    final theme = NaviTheme.dark();
    final fallback = ThemeData(
      brightness: Brightness.dark,
      colorScheme: theme.colorScheme,
    ).textTheme;

    for (final pair in [
      (theme.textTheme.headlineSmall, fallback.headlineSmall),
      (theme.textTheme.titleSmall, fallback.titleSmall),
      (theme.textTheme.bodySmall, fallback.bodySmall),
      (theme.textTheme.labelSmall, fallback.labelSmall),
    ]) {
      expect(pair.$1?.fontWeight, pair.$2?.fontWeight);
      expect(pair.$1?.fontSize, pair.$2?.fontSize);
      expect(pair.$1?.color, pair.$2?.color);
      expect(pair.$1?.letterSpacing, lessThanOrEqualTo(0));
    }
  });

  test('palette is neutral: only accents carry saturation', () {
    double chroma(Color color) {
      final channels = [color.r, color.g, color.b];
      channels.sort();
      return channels.last - channels.first;
    }

    for (final neutral in [
      NaviColors.canvas,
      NaviColors.surface,
      NaviColors.surfaceRaised,
      NaviColors.glassOpaque,
      NaviColors.atmosphereWine,
      NaviColors.atmospherePlum,
      NaviColors.modalGlassTop,
      NaviColors.modalGlassBottom,
    ]) {
      expect(chroma(neutral), lessThan(0.03), reason: '$neutral is tinted');
    }
    expect(NaviColors.accent, const Color(0xFFE9A23B));
    expect(NaviColors.textPrimary, const Color(0xFFFFFFFF));
  });

  test('motion is calm and exposes an ambient duration', () {
    expect(NaviMotion.micro, const Duration(milliseconds: 120));
    expect(NaviMotion.standard, const Duration(milliseconds: 180));
    expect(NaviMotion.page, const Duration(milliseconds: 240));
    expect(NaviMotion.artworkFlip, const Duration(milliseconds: 320));
    expect(
      NaviMotion.ambient,
      greaterThanOrEqualTo(const Duration(seconds: 10)),
    );
    expect(NaviMotion.curve, Curves.easeOutCubic);
  });

  testWidgets('NaviMotion.reduceMotion follows the system setting', (
    tester,
  ) async {
    bool? reduced;
    Widget probe() => Builder(
      builder: (context) {
        reduced = NaviMotion.reduceMotion(context);
        return const SizedBox();
      },
    );

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: probe(),
      ),
    );
    expect(reduced, isTrue);

    await tester.pumpWidget(
      MediaQuery(data: const MediaQueryData(), child: probe()),
    );
    expect(reduced, isFalse);
  });

  testWidgets('persistent dock exposes all five localized destinations', (
    tester,
  ) async {
    var selected = -1;
    await tester.pumpWidget(
      MaterialApp(
        theme: NaviTheme.dark(),
        home: Scaffold(
          body: const SizedBox.expand(),
          bottomNavigationBar: NaviPersistentDock(
            destinations: _destinations,
            selectedIndex: 0,
            onDestinationSelected: (value) => selected = value,
          ),
        ),
      ),
    );

    for (final destination in _destinations) {
      expect(find.text(destination.label), findsOneWidget);
    }
    expect(find.byType(BackdropFilter), findsNothing);

    await tester.tap(find.text('Sök'));
    await tester.pump();
    expect(selected, 4);
  });

  testWidgets('app header uses a highly translucent blurred surface', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: NaviTheme.dark(),
        home: NaviChromeStyle(
          topBarTransparency: 0.55,
          topBarBlurSigma: 12,
          child: Scaffold(
            body: CustomScrollView(
              slivers: const [NaviSliverHeader(title: Text('Söngr'))],
            ),
          ),
        ),
      ),
    );

    final appBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
    expect(appBar.shape, isNull);
    expect(find.byType(BackdropFilter), findsOneWidget);
    final headerBlur = tester.widget<BackdropFilter>(
      find.byType(BackdropFilter),
    );
    expect(headerBlur.filter.toString(), contains('12.0'));
    final surface = tester.widget<ColoredBox>(
      find.byKey(const ValueKey('navi-header-translucent-surface')),
    );
    expect(
      tester.getSize(
        find.byKey(const ValueKey('navi-header-translucent-surface')),
      ),
      const Size(800, 44),
    );
    expect(surface.color.a, closeTo(0.45, 0.01));
  });

  testWidgets('dock separates the selected destination with light and fill', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: NaviTheme.dark(),
        home: MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.only(bottom: 16)),
          child: Scaffold(
            bottomNavigationBar: NaviPersistentDock(
              destinations: _destinations,
              selectedIndex: 0,
              onDestinationSelected: (_) {},
            ),
          ),
        ),
      ),
    );

    final selectedIcon = tester.widget<Icon>(find.byIcon(Icons.home_rounded));
    expect(selectedIcon.color, NaviColors.textPrimary);
    final idleIcon = tester.widget<Icon>(find.byIcon(Icons.radio_outlined));
    expect(idleIcon.color, NaviColors.textTertiary);
    expect(
      find.descendant(
        of: find.byType(NaviPersistentDock),
        matching: find.byType(BackdropFilter),
      ),
      findsNothing,
    );
  });

  testWidgets('dock spans the full width on an opaque dark surface', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: NaviTheme.dark(),
        home: Scaffold(
          bottomNavigationBar: NaviPersistentDock(
            destinations: _destinations,
            selectedIndex: 0,
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    );

    final dock = find.byKey(const ValueKey('navi-persistent-dock'));
    final navigationDecoration =
        tester
                .widget<DecoratedBox>(
                  find.byKey(const ValueKey('navi-dock-navigation-surface')),
                )
                .decoration
            as BoxDecoration;
    final screenHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    final contentPadding = tester.widget<Padding>(
      find.byKey(const ValueKey('navi-dock-content-padding')),
    );

    expect(navigationDecoration.color, NaviColors.surfaceRaised);
    expect(contentPadding.padding.resolve(TextDirection.ltr).top, 0);
    expect(contentPadding.padding.resolve(TextDirection.ltr).bottom, 18);
    expect(tester.getBottomLeft(dock).dy, closeTo(screenHeight, 0.1));
    expect(tester.getTopLeft(dock).dx, 0);
    expect(
      tester.getTopRight(dock).dx,
      tester.view.physicalSize.width / tester.view.devicePixelRatio,
    );
  });

  testWidgets('the play control rings while a tapped song is starting', (
    tester,
  ) async {
    Widget dock({required bool starting}) => MaterialApp(
      theme: NaviTheme.dark(),
      home: Scaffold(
        bottomNavigationBar: NaviPersistentDock(
          destinations: _destinations,
          selectedIndex: 2,
          onDestinationSelected: (_) {},
          nowPlaying: NaviMiniPlayerData(
            title: 'Fresh tap',
            subtitle: 'Artist',
            artwork: const ColoredBox(color: Colors.deepPurple),
            progress: 0,
            isPlaying: false,
            starting: starting,
            playLabel: 'Spela',
            pauseLabel: 'Pausa',
            skipNextLabel: 'Nästa',
          ),
          onTogglePlayback: () {},
        ),
      ),
    );

    await tester.pumpWidget(dock(starting: true));
    expect(find.text('Fresh tap'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);

    await tester.pumpWidget(dock(starting: false));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
  });

  testWidgets('mini player remains integrated above navigation', (
    tester,
  ) async {
    var opened = false;
    var toggled = false;
    var previous = false;
    var next = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: NaviTheme.dark(),
        home: Scaffold(
          bottomNavigationBar: NaviPersistentDock(
            destinations: _destinations,
            selectedIndex: 2,
            onDestinationSelected: (_) {},
            nowPlaying: const NaviMiniPlayerData(
              title: 'Northern Lights',
              subtitle: 'Aurora',
              artwork: ColoredBox(color: Colors.deepPurple),
              progress: 0.4,
              isPlaying: true,
              playLabel: 'Spela',
              pauseLabel: 'Pausa',
              skipNextLabel: 'Nästa',
            ),
            onOpenPlayer: () => opened = true,
            onTogglePlayback: () => toggled = true,
            onSkipPrevious: () => previous = true,
            onSkipNext: () => next = true,
          ),
        ),
      ),
    );

    expect(find.text('Northern Lights'), findsOneWidget);
    expect(find.text('Aurora'), findsOneWidget);
    final playerSurface = tester.widget<ColoredBox>(
      find.byKey(const ValueKey('navi-dock-player-surface')),
    );
    expect(playerSurface.color.a, 1);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    // Without a cover to sample the bar falls back to a neutral grey instead
    // of the accent yellow.
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .color,
      NaviColors.textTertiary,
    );

    await tester.tap(find.text('Northern Lights'));
    expect(opened, isTrue);
    await tester.tap(find.byTooltip('Pausa'));
    expect(toggled, isTrue);

    await tester.fling(
      find.text('Northern Lights'),
      const Offset(-400, 0),
      1000,
    );
    await tester.pumpAndSettle();
    expect(next, isTrue);

    await tester.fling(
      find.text('Northern Lights'),
      const Offset(400, 0),
      1000,
    );
    await tester.pumpAndSettle();
    expect(previous, isTrue);

    toggled = false;
    await tester.tap(find.byTooltip('Pausa'));
    await tester.pump();
    expect(toggled, isTrue, reason: 'swiping must never steal control taps');
  });

  testWidgets('position ticks rebuild only the mini progress indicator', (
    tester,
  ) async {
    final position = ValueNotifier(Duration.zero);
    addTearDown(position.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: NaviTheme.dark(),
        home: Scaffold(
          bottomNavigationBar: NaviPersistentDock(
            destinations: _destinations,
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            nowPlaying: NaviMiniPlayerData(
              title: 'Calm track',
              subtitle: 'Artist',
              artwork: const ColoredBox(color: Colors.deepPurple),
              progress: 0,
              isPlaying: true,
              playLabel: 'Spela',
              pauseLabel: 'Pausa',
              skipNextLabel: 'Nästa',
              positionListenable: position,
              duration: const Duration(seconds: 100),
            ),
          ),
        ),
      ),
    );

    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      0,
    );
    position.value = const Duration(seconds: 42);
    await tester.pump();
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      closeTo(0.42, 0.001),
    );
  });

  testWidgets('artwork atmosphere always ends on the stable canvas', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NaviArtworkAtmosphere(
          primary: Colors.orange,
          secondary: Colors.blue,
          child: const Text('Content'),
        ),
      ),
    );

    expect(find.text('Content'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsNothing);
    final canvas = tester.widget<ColoredBox>(
      find.descendant(
        of: find.byType(NaviArtworkAtmosphere),
        matching: find.byType(ColoredBox),
      ),
    );
    expect(canvas.color, NaviColors.canvas);
  });

  testWidgets('NaviPressable leaves corner content reachable by default', (
    tester,
  ) async {
    var cornerTapped = false;
    var pressableTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: NaviPressable(
            onTap: () => pressableTapped = true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 144, height: 144),
                GestureDetector(
                  onTap: () => cornerTapped = true,
                  child: const Text('Song title that reaches the corner'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(
      find.descendant(
        of: find.byType(NaviPressable),
        matching: find.byType(ClipRRect),
      ),
      findsNothing,
    );

    // The bottom-left pixel of the last text line sits inside the 18 pt
    // corner radius; a rounded clip would both paint over and reject it.
    final corner = tester.getBottomLeft(find.byType(NaviPressable));
    expect(tester.getBottomLeft(find.byType(Text)).dx, corner.dx);
    await tester.tapAt(corner + const Offset(1, -1));
    expect(cornerTapped, isTrue);
    expect(pressableTapped, isFalse);
  });

  testWidgets('NaviPressable clips only when asked', (tester) async {
    var cornerTapped = false;
    var pressableTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: NaviPressable(
            clip: true,
            onTap: () => pressableTapped = true,
            child: GestureDetector(
              onTap: () => cornerTapped = true,
              child: const SizedBox(width: 144, height: 144),
            ),
          ),
        ),
      ),
    );

    expect(
      find.descendant(
        of: find.byType(NaviPressable),
        matching: find.byType(ClipRRect),
      ),
      findsOneWidget,
    );
    final corner = tester.getBottomLeft(find.byType(NaviPressable));
    await tester.tapAt(corner + const Offset(1, -1));
    expect(cornerTapped, isFalse, reason: 'the corner is clipped away');
    expect(pressableTapped, isTrue);
  });

  testWidgets('NaviLift never adds a resting shadow', (tester) async {
    Widget lift(bool elevated) => MaterialApp(
      home: Center(
        child: NaviLift(
          elevated: elevated,
          child: const SizedBox(width: 120, height: 120),
        ),
      ),
    );

    await tester.pumpWidget(lift(true));
    await tester.pumpAndSettle();
    expect(_liftShadows(tester), isEmpty);

    await tester.pumpWidget(lift(false));
    await tester.pumpAndSettle();
    expect(_liftShadows(tester), isEmpty);
  });

  testWidgets('NaviPressable compresses while touched', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: NaviPressable(
            lift: true,
            onTap: () {},
            child: const SizedBox(width: 120, height: 46),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    AnimatedScale scale() => tester.widget<AnimatedScale>(
      find
          .descendant(
            of: find.byType(NaviPressable),
            matching: find.byType(AnimatedScale),
          )
          .first,
    );
    expect(scale().scale, 1);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(NaviPressable)),
    );
    await tester.pumpAndSettle();
    expect(scale().scale, 0.985);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(scale().scale, 1);
  });
}

List<BoxShadow> _liftShadows(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(
    find.descendant(
      of: find.byType(NaviLift),
      matching: find.byType(DecoratedBox),
    ),
  );
  return (box.decoration as BoxDecoration).boxShadow ?? const [];
}

const _destinations = [
  NaviDockDestination(
    label: 'Hem',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
  ),
  NaviDockDestination(
    label: 'Nytt',
    icon: Icons.auto_awesome_outlined,
    selectedIcon: Icons.auto_awesome,
  ),
  NaviDockDestination(
    label: 'Radio',
    icon: Icons.radio_outlined,
    selectedIcon: Icons.radio,
  ),
  NaviDockDestination(
    label: 'Bibliotek',
    icon: Icons.library_music_outlined,
    selectedIcon: Icons.library_music,
  ),
  NaviDockDestination(
    label: 'Sök',
    icon: Icons.search_outlined,
    selectedIcon: Icons.search,
  ),
];
