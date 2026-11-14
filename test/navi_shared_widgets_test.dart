import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/design_system/navi_design_tokens.dart';
import 'package:navimusic/design_system/navi_theme.dart';
import 'package:navimusic/design_system/widgets/navi_widgets.dart';
import 'package:navimusic/l10n/app_localizations.dart';
import 'package:navimusic/models/models.dart';

void main() {
  group('NaviSongRow', () {
    testWidgets('long-press and the trailing button open the same menu', (
      tester,
    ) async {
      var menuOpened = 0;
      var tapped = 0;
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: NaviSongRow(
              song: _song('a'),
              onTap: () => tapped++,
              onMenu: () => menuOpened++,
            ),
          ),
        ),
      );

      await tester.longPress(find.text('Song a'));
      await tester.pumpAndSettle();
      expect(menuOpened, 1);
      expect(tapped, 0);

      await tester.tap(find.byTooltip('Visa mer'));
      expect(menuOpened, 2);

      await tester.tap(find.text('Song a'));
      await tester.pumpAndSettle();
      expect(tapped, 1);
      expect(
        tester.getSize(find.byType(NaviSongRow)).height,
        greaterThanOrEqualTo(NaviSongRow.minHeight),
      );
    });

    testWidgets('the current song gets an accent title and the glyph', (
      tester,
    ) async {
      final current = ValueNotifier<String?>('b');
      final playing = ValueNotifier<bool>(false);
      addTearDown(current.dispose);
      addTearDown(playing.dispose);
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: Column(
              children: [
                for (final id in ['a', 'b'])
                  NaviSongRow(
                    song: _song(id),
                    leadingText: id,
                    nowPlayingListenable: current,
                    playingListenable: playing,
                  ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(NaviNowPlayingGlyph), findsOneWidget);
      expect(_titleColor(tester, 'Song b'), NaviColors.accent);
      expect(_titleColor(tester, 'Song a'), isNot(NaviColors.accent));
      expect(find.text('b'), findsNothing, reason: 'glyph replaces number');
      expect(find.text('a'), findsOneWidget);

      current.value = 'a';
      await tester.pump();
      expect(_titleColor(tester, 'Song a'), NaviColors.accent);
      expect(_titleColor(tester, 'Song b'), isNot(NaviColors.accent));
      expect(find.text('b'), findsOneWidget);

      playing.value = true;
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        tester
            .widget<NaviNowPlayingGlyph>(find.byType(NaviNowPlayingGlyph))
            .playing,
        isTrue,
      );
    });

    testWidgets('a starred song shows a quiet heart', (tester) async {
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: Column(
              children: [
                NaviSongRow(song: _song('a'), starred: true),
                NaviSongRow(song: _song('b')),
              ],
            ),
          ),
        ),
      );

      final hearts = find.byIcon(Icons.favorite_rounded);
      expect(hearts, findsOneWidget);
      expect(tester.widget<Icon>(hearts).color, NaviColors.textSecondary);
    });
  });

  group('NaviMediaCard', () {
    testWidgets('does not clip its text corner and marks the current song', (
      tester,
    ) async {
      var opened = false;
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: Center(
              child: NaviMediaCard(
                title: 'A title long enough to reach the corner',
                subtitle: 'Artist',
                artwork: const ColoredBox(color: Colors.red),
                onTap: () => opened = true,
              ),
            ),
          ),
        ),
      );

      // Only the artwork is clipped; the text column below is not.
      final clips = find.descendant(
        of: find.byType(NaviMediaCard),
        matching: find.byType(ClipRRect),
      );
      expect(clips, findsOneWidget);
      expect(tester.getSize(clips).height, 144);
      expect(
        find.byKey(const ValueKey('navi-media-card-now-playing')),
        findsNothing,
      );

      final corner = tester.getBottomLeft(find.byType(NaviMediaCard));
      await tester.tapAt(corner + const Offset(1, -1));
      expect(opened, isTrue, reason: 'the bottom corner is still the card');

      await tester.pumpWidget(
        _app(
          const Scaffold(
            body: Center(
              child: NaviMediaCard(
                title: 'Now',
                subtitle: 'Artist',
                artwork: ColoredBox(color: Colors.red),
                nowPlaying: true,
              ),
            ),
          ),
        ),
      );
      expect(
        find.byKey(const ValueKey('navi-media-card-now-playing')),
        findsOneWidget,
      );
      expect(find.byType(NaviLift), findsOneWidget);
      expect(_titleColor(tester, 'Now'), NaviColors.accent);
    });

    testWidgets('heightFor matches the laid-out card', (tester) async {
      late double expected;
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: Builder(
              builder: (context) {
                expected = NaviMediaCard.heightFor(context, withCaption: true);
                return const Center(
                  child: NaviMediaCard(
                    title: 'Title',
                    subtitle: 'Artist',
                    caption: 'Album',
                    artwork: ColoredBox(color: Colors.red),
                  ),
                );
              },
            ),
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(NaviMediaCard)).height,
        closeTo(expected, 0.5),
      );
    });
  });

  group('NaviSongSwipeActions', () {
    testWidgets('swipe-left opens the shared song menu', (tester) async {
      var moreOpened = 0;
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: NaviSongSwipeActions(
              dismissibleKey: const ValueKey('swipe'),
              onMore: () => moreOpened++,
              child: NaviSongRow(song: _song('a')),
            ),
          ),
        ),
      );

      await tester.drag(find.text('Song a'), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(moreOpened, 1);
      expect(find.text('Song a'), findsOneWidget, reason: 'never dismissed');
    });
  });
}

Color? _titleColor(WidgetTester tester, String title) =>
    tester.widget<Text>(find.text(title)).style?.color;

Widget _app(Widget home) => MaterialApp(
  locale: const Locale('sv'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  theme: NaviTheme.dark(),
  home: home,
);

Song _song(String id) => Song(
  id: id,
  title: 'Song $id',
  artist: 'Artist $id',
  artistId: 'artist',
  album: 'Album',
  albumId: 'album',
  duration: 187,
);
