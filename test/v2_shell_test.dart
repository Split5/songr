import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/app/v2/v2_shell.dart';
import 'package:navimusic/design_system/navi_theme.dart';
import 'package:navimusic/design_system/widgets/navi_persistent_dock.dart';

void main() {
  testWidgets('dock remains visible when a tab pushes a detail route', (
    tester,
  ) async {
    await tester.pumpWidget(_app());

    await tester.tap(find.byKey(const Key('push-home-detail')));
    await tester.pumpAndSettle();

    expect(find.text('Home detail'), findsOneWidget);
    expect(find.text('Hem'), findsOneWidget);
    expect(find.text('Bibliotek'), findsOneWidget);
    expect(find.text('Current song'), findsOneWidget);
  });

  testWidgets('content ends exactly where the dock begins', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    final content = find.byType(IndexedStack);
    final dock = find.byKey(const ValueKey('navi-persistent-dock'));

    expect(
      tester.getBottomLeft(content).dy,
      closeTo(tester.getTopLeft(dock).dy, 0.1),
    );
  });

  testWidgets('each tab keeps its own navigation stack', (tester) async {
    await tester.pumpWidget(_app());
    await tester.tap(find.byKey(const Key('push-home-detail')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bibliotek'));
    await tester.pumpAndSettle();
    expect(find.text('Library root'), findsOneWidget);
    expect(find.text('Home detail'), findsNothing);

    await tester.tap(find.text('Hem'));
    await tester.pumpAndSettle();
    expect(find.text('Home detail'), findsOneWidget);
  });

  testWidgets('reselecting the active tab returns to its root', (tester) async {
    await tester.pumpWidget(_app());
    await tester.tap(find.byKey(const Key('push-home-detail')));
    await tester.pumpAndSettle();
    expect(find.text('Home detail'), findsOneWidget);

    await tester.tap(find.text('Hem'));
    await tester.pumpAndSettle();

    expect(find.text('Home root'), findsOneWidget);
    expect(find.text('Home detail'), findsNothing);
  });

  testWidgets('switching destinations never recreates root state', (
    tester,
  ) async {
    await tester.pumpWidget(_app());

    await tester.tap(find.byKey(const Key('increment-home')));
    await tester.pump();
    expect(find.text('Count 1'), findsOneWidget);
    await tester.tap(find.text('Radio'));
    await tester.pump();
    await tester.tap(find.text('Hem'));
    await tester.pump();

    expect(find.text('Count 1'), findsOneWidget);
  });

  testWidgets('selecting and reselecting Search emits fresh activation', (
    tester,
  ) async {
    await tester.pumpWidget(_app());

    await tester.tap(find.text('Sök'));
    await tester.pump();
    expect(find.text('Search active 1'), findsOneWidget);

    await tester.tap(find.text('Sök'));
    await tester.pump();
    expect(find.text('Search active 2'), findsOneWidget);
  });

  testWidgets('keyboard yields the bottom edge to the active search field', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pump();

    final blockers = tester.widgetList<IgnorePointer>(
      find.ancestor(
        of: find.byType(NaviPersistentDock),
        matching: find.byType(IgnorePointer),
      ),
    );
    expect(blockers.any((widget) => widget.ignoring), isTrue);
  });
}

Widget _app() => MaterialApp(
  theme: NaviTheme.dark(),
  home: V2Shell(
    tabs: [
      V2TabSpec(
        destination: _destinations[0],
        rootBuilder: (_) => const _StatefulHome(),
      ),
      V2TabSpec(
        destination: _destinations[1],
        rootBuilder: (_) => const _RootPage(title: 'New root'),
      ),
      V2TabSpec(
        destination: _destinations[2],
        rootBuilder: (_) => const _RootPage(title: 'Radio root'),
      ),
      V2TabSpec(
        destination: _destinations[3],
        rootBuilder: (_) => const _RootPage(title: 'Library root'),
      ),
      V2TabSpec(
        destination: _destinations[4],
        rootBuilder: (_) => const _SearchActivityPage(),
      ),
    ],
    nowPlaying: const NaviMiniPlayerData(
      title: 'Current song',
      subtitle: 'Current artist',
      artwork: ColoredBox(color: Colors.orange),
      progress: 0.25,
      isPlaying: true,
      playLabel: 'Spela',
      pauseLabel: 'Pausa',
      skipNextLabel: 'Nästa',
    ),
  ),
);

class _StatefulHome extends StatefulWidget {
  const _StatefulHome();

  @override
  State<_StatefulHome> createState() => _StatefulHomeState();
}

class _StatefulHomeState extends State<_StatefulHome> {
  var count = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        const Text('Home root'),
        Text('Count $count'),
        TextButton(
          key: const Key('increment-home'),
          onPressed: () => setState(() => count++),
          child: const Text('Increment'),
        ),
        TextButton(
          key: const Key('push-home-detail'),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const _RootPage(title: 'Home detail'),
            ),
          ),
          child: const Text('Open detail'),
        ),
      ],
    ),
  );
}

class _RootPage extends StatelessWidget {
  const _RootPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(body: Text(title));
}

class _SearchActivityPage extends StatelessWidget {
  const _SearchActivityPage();

  @override
  Widget build(BuildContext context) {
    final activity = V2TabActivity.maybeOf(context);
    return Scaffold(
      body: Text(
        'Search ${activity?.isActive == true ? 'active' : 'inactive'} '
        '${activity?.activation}',
      ),
    );
  }
}

const _destinations = [
  NaviDockDestination(
    label: 'Hem',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
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
