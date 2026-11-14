import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/app/v2/song_menu_entries.dart';
import 'package:navimusic/design_system/navi_theme.dart';
import 'package:navimusic/design_system/widgets/navi_widgets.dart';
import 'package:navimusic/l10n/app_localizations.dart';
import 'package:navimusic/models/models.dart';

void main() {
  testWidgets('playlist picker offers a new playlist first and creates it', (
    tester,
  ) async {
    final playlists = [
      Playlist(id: 'p1', name: 'Kväll'),
      Playlist(id: 'p2', name: 'Morgon'),
    ];
    final created = <String>[];
    Playlist? picked;
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => showNaviPlaylistPicker(
                  context: context,
                  playlists: playlists,
                  lastPlaylistId: 'p2',
                  onPick: (playlist) => picked = playlist,
                  onCreate: created.add,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final tiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
    expect(tiles, hasLength(3));
    expect((tiles.first.title! as Text).data, 'Ny spellista…');
    expect(find.text('Senast använda spellista'), findsOneWidget);

    await tester.tap(find.text('Ny spellista…'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '  Träning  ');
    await tester.tap(find.text('Skapa'));
    await tester.pumpAndSettle();

    expect(created, ['Träning']);
    expect(picked, isNull);
    expect(find.byType(ListTile), findsNothing, reason: 'sheet closed');

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kväll'));
    await tester.pumpAndSettle();
    expect(picked?.id, 'p1');
  });

  testWidgets('song menu renders the composed superset in order', (
    tester,
  ) async {
    // Tall enough that the lazily built sheet renders every entry.
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final song = Song(
      id: 's',
      title: 'Låten',
      artist: 'Artisten, Gäst',
      artistId: 'a',
      album: 'Albumet',
      albumId: 'al',
    );
    final invoked = <String>[];
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => showNaviSongMenu(
                  context: context,
                  song: song,
                  entries: songMenuEntries(
                    l: AppLocalizations.of(context),
                    song: song,
                    downloaded: false,
                    lastPlaylist: Playlist(id: 'p1', name: 'Kväll'),
                    actions: _recording(invoked),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Låten'), findsOneWidget);
    expect(find.text('Artisten · Albumet'), findsOneWidget);
    final titles = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .map((tile) => (tile.title! as Text).data)
        .toList();
    expect(titles, [
      'Favorit',
      'Spela härnäst',
      'Lägg till i kön',
      'Lägg till i spellista',
      'Lägg till i ”Kväll”',
      'Gå till album',
      'Gå till artist',
      'Skapa mix från låt',
      'Skapa spellista med liknande låtar',
      'Ladda ner',
      'Dela',
    ]);

    await tester.tap(find.text('Lägg till i kön'));
    await tester.pumpAndSettle();
    expect(invoked, ['addToQueue']);
    expect(find.byType(ListTile), findsNothing, reason: 'sheet closed');
  });

  testWidgets('song menu can be dragged down with the standard sheet gesture', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final song = Song(
      id: 's',
      title: 'Låten',
      artist: 'Artisten',
      artistId: 'a',
      album: 'Albumet',
      albumId: 'al',
    );
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => showNaviSongMenu(
                  context: context,
                  song: song,
                  entries: songMenuEntries(
                    l: AppLocalizations.of(context),
                    song: song,
                    downloaded: false,
                    lastPlaylist: null,
                    actions: _recording([]),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const ValueKey('navi-modal-handle')),
      const Offset(0, 520),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('navi-modal-surface')), findsNothing);
  });
}

SongMenuActions _recording(List<String> calls) => SongMenuActions(
  toggleFavorite: () => calls.add('favorite'),
  playNext: () => calls.add('playNext'),
  addToQueue: () => calls.add('addToQueue'),
  addToPlaylist: () => calls.add('addToPlaylist'),
  addToLastPlaylist: (playlist) => calls.add('addToLast:${playlist.id}'),
  goToAlbum: () => calls.add('goToAlbum'),
  goToArtist: () => calls.add('goToArtist'),
  createMix: () => calls.add('createMix'),
  createSimilarPlaylist: () => calls.add('createSimilarPlaylist'),
  download: () => calls.add('download'),
  removeDownload: () => calls.add('removeDownload'),
  share: () => calls.add('share'),
);

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
