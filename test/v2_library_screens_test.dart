import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/design_system/navi_theme.dart';
import 'package:navimusic/domain/library/catalog_repository.dart';
import 'package:navimusic/features/library/catalog_controllers.dart';
import 'package:navimusic/features/library/v2_library_screens.dart';
import 'package:navimusic/l10n/app_localizations.dart';
import 'package:navimusic/models/models.dart';

void main() {
  test(
    'artist preparation may finish after its controller is disposed',
    () async {
      final page = Completer<List<ArtistSummary>>();
      final controller = PagedCatalogController<ArtistSummary>(
        countLoader: (_) async => 1,
        pageLoader: (_, _, _) => page.future,
      );
      final loading = controller.refresh();
      controller.dispose();
      page.complete([ArtistSummary(id: 'artist', name: 'Artist')]);
      await loading;
    },
  );

  testWidgets('artist rows keep their width while artwork loads', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final ready = ValueNotifier(false);
    addTearDown(ready.dispose);
    final artist = ArtistSummary(
      id: 'collaboration',
      name: '21 Savage/Metro Boomin/Young Nudy',
    );
    final controller = PagedCatalogController<ArtistSummary>(
      countLoader: (_) async => 1,
      pageLoader: (_, _, _) async => [artist],
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _app(
        V2ArtistsScreen(
          controller: controller,
          onArtistTap: (_) {},
          artworkBuilder: (_, _, _) => ValueListenableBuilder(
            valueListenable: ready,
            builder: (_, loaded, _) => SizedBox(
              key: const ValueKey('delayed-artist-art'),
              width: loaded ? 52 : 320,
              height: 52,
              child: const ColoredBox(color: Colors.grey),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final name = find.text(artist.name);
    final before = tester.getRect(name);
    expect(
      tester.getSize(find.byKey(const ValueKey('delayed-artist-art'))).width,
      52,
    );
    expect(before.width, greaterThan(220));
    expect(before.height, lessThan(60));
    ready.value = true;
    await tester.pumpAndSettle();
    expect(tester.getRect(name), before);
  });

  testWidgets('library root contains personal playlists and secondary tools', (
    tester,
  ) async {
    final repository = _Repository();
    final controller = LibraryOverviewController(repository);
    addTearDown(controller.dispose);
    var opened = '';
    var preparations = 0;

    await tester.pumpWidget(
      _app(
        V2LibraryScreen(
          controller: controller,
          onPrepareArtists: () async => preparations++,
          onAlbumTap: (_) {},
          onOpenPlaylists: () => opened = 'playlists',
          onOpenRadio: () => opened = 'radio',
          onOpenArtists: () => opened = 'artists',
          onOpenAlbums: () => opened = 'albums',
          onOpenSongs: () => opened = 'songs',
          onOpenDownloads: () => opened = 'downloads',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Spellistor'), findsOneWidget);
    expect(preparations, 1);
    expect(find.text('Radio'), findsOneWidget);
    expect(find.text('Artister'), findsOneWidget);
    expect(find.text('2 artister'), findsOneWidget);
    expect(find.text('2 album'), findsOneWidget);
    expect(find.text('Nytt'), findsNothing);
    expect(find.text('Smart playlists'), findsNothing);
    await tester.tap(find.text('Spellistor'));
    expect(opened, 'playlists');
    await tester.tap(find.text('Låtar'));
    expect(opened, 'songs');
    await tester.tap(find.text('Artister'));
    expect(opened, 'artists');
  });

  testWidgets('artist browser is paged, searchable and forwards selection', (
    tester,
  ) async {
    final repository = _Repository();
    final controller = PagedCatalogController<ArtistSummary>(
      countLoader: (query) => repository.artistCount(query: query),
      pageLoader: (query, limit, offset) =>
          repository.artistsPage(query: query, limit: limit, offset: offset),
      searchDebounce: Duration.zero,
    );
    addTearDown(controller.dispose);
    ArtistSummary? selected;

    await tester.pumpWidget(
      _app(
        V2ArtistsScreen(
          controller: controller,
          onArtistTap: (artist) => selected = artist,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Alex Warren'), findsOneWidget);
    await tester.tap(find.text('Alex Warren'));
    expect(selected?.id, 'artist-1');

    await tester.enterText(find.byType(TextField), 'ros');
    await tester.pumpAndSettle();
    expect(find.text('ROSÉ'), findsOneWidget);
    expect(find.text('Alex Warren'), findsNothing);
  });

  testWidgets('artist browser shows a retry state instead of a blank screen', (
    tester,
  ) async {
    var attempts = 0;
    final controller = PagedCatalogController<ArtistSummary>(
      countLoader: (_) async {
        attempts++;
        if (attempts == 1) throw StateError('artist query failed');
        return 1;
      },
      pageLoader: (_, _, _) async => [
        ArtistSummary(id: 'artist-1', name: 'Alex Warren'),
      ],
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _app(V2ArtistsScreen(controller: controller, onArtistTap: (_) {})),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Kunde inte ladda biblioteket'), findsOneWidget);
    expect(find.text('Försök igen'), findsOneWidget);

    await tester.tap(find.text('Försök igen'));
    await tester.pumpAndSettle();
    expect(find.text('Alex Warren'), findsOneWidget);
  });

  testWidgets('album cards show a distinct record count', (tester) async {
    final repository = _Repository();
    final controller = PagedCatalogController<Album>(
      countLoader: (query) => repository.albumCount(query: query),
      pageLoader: (query, limit, offset) =>
          repository.albumsPage(query: query, limit: limit, offset: offset),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _app(V2AlbumsScreen(controller: controller, onAlbumTap: (_) {})),
    );
    await tester.pumpAndSettle();

    expect(find.text('First Record'), findsOneWidget);
    expect(find.text('1 låt'), findsOneWidget);
    expect(find.byKey(const ValueKey('album-card-album-1')), findsOneWidget);
  });

  testWidgets('playlist root is compact, live and forwards primary actions', (
    tester,
  ) async {
    final controller = LibraryOverviewController(_Repository());
    addTearDown(controller.dispose);
    Playlist? selected;
    var created = false;

    await tester.pumpWidget(
      _app(
        V2PlaylistsScreen(
          controller: controller,
          onPlaylistTap: (playlist) => selected = playlist,
          onCreatePlaylist: () => created = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mine'), findsOneWidget);
    expect(find.textContaining('4 låtar'), findsOneWidget);
    await tester.tap(find.text('Mine'));
    expect(selected?.id, 'mine');
    await tester.tap(find.byTooltip('Ny spellista…'));
    expect(created, isTrue);
  });

  testWidgets('playlist row can be swiped left to delete', (tester) async {
    final controller = LibraryOverviewController(_Repository());
    addTearDown(controller.dispose);
    Playlist? deleted;

    await tester.pumpWidget(
      _app(
        V2PlaylistsScreen(
          controller: controller,
          onPlaylistTap: (_) {},
          onCreatePlaylist: () {},
          onDeletePlaylist: (playlist) async {
            deleted = playlist;
            controller.removePlaylist(playlist.id);
            return true;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.text('Mine'), const Offset(-300, 0));
    await tester.pumpAndSettle();

    expect(deleted?.id, 'mine');
    expect(find.text('Mine'), findsNothing);
  });

  testWidgets('collection play and tapped song remain distinct actions', (
    tester,
  ) async {
    final songs = [_song('first'), _song('second')];
    final controller = SongCollectionController(() async => songs);
    addTearDown(controller.dispose);
    var playPressed = false;
    Song? tapped;

    await tester.pumpWidget(
      _app(
        V2SongCollectionScreen(
          title: 'Album',
          controller: controller,
          onPlay: () => playPressed = true,
          onSongTap: (song) => tapped = song,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Spela'));
    expect(playPressed, isTrue);
    await tester.ensureVisible(find.text('Song second'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Song second'));
    expect(tapped?.id, 'second');
  });

  testWidgets('playlist shows similar-song suggestions and adds one inline', (
    tester,
  ) async {
    final controller = SongCollectionController(() async => [_song('source')]);
    addTearDown(controller.dispose);
    Song? added;

    await tester.pumpWidget(
      _app(
        V2SongCollectionScreen(
          title: 'My playlist',
          controller: controller,
          onSongTap: (_) {},
          suggestionLoader: (_, {refresh = false}) async => [
            _song('suggested'),
          ],
          onAddSuggestion: (song) async => added = song,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Förslag till spellistan'), findsOneWidget);
    expect(find.text('Song suggested'), findsOneWidget);
    await tester.ensureVisible(find.text('Song suggested'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Lägg till i spellista'));
    await tester.pumpAndSettle();

    expect(added?.id, 'suggested');
    expect(controller.songs.map((song) => song.id), ['source', 'suggested']);
    expect(find.text('Song suggested'), findsOneWidget);
  });

  test('catalog sorting updates the active order and random seed', () async {
    final calls = <(String, int)>[];
    final controller = PagedCatalogController<String>(
      countLoader: (_) async => 0,
      pageLoader: (_, _, _) async => const [],
      sortedPageLoader: (_, _, _, sort, seed) async {
        calls.add((sort, seed));
        return const [];
      },
    );
    addTearDown(controller.dispose);

    await controller.setSort('recentlyAdded');
    await controller.setSort('random', randomize: true);
    await controller.setSort('random', randomize: true);

    expect(calls, [('recentlyAdded', 0), ('random', 1), ('random', 2)]);
    expect(controller.state.sort, 'random');
    expect(controller.state.randomSeed, 2);
  });
}

class _Repository implements CatalogRepository {
  final artists = [
    ArtistSummary(id: 'artist-1', name: 'Alex Warren', albumCount: 2),
    ArtistSummary(id: 'artist-2', name: 'ROSÉ', albumCount: 1),
  ];

  @override
  Future<int> albumCount({String query = ''}) async => 2;

  @override
  Future<List<Album>> albumsPage({
    String query = '',
    int limit = 60,
    int offset = 0,
    bool newestFirst = false,
    AlbumSort sort = AlbumSort.title,
    int randomSeed = 0,
  }) async => offset > 0
      ? const []
      : [
          Album(
            id: 'album-1',
            name: 'First Record',
            artist: 'Alex Warren',
            artistId: 'artist-1',
            songCount: 1,
            year: 2026,
          ),
        ];

  @override
  Future<int> artistCount({String query = ''}) async =>
      artists.where((artist) => _matches(artist.name, query)).length;

  @override
  Future<List<ArtistSummary>> artistsPage({
    String query = '',
    int limit = 60,
    int offset = 0,
    ArtistSort sort = ArtistSort.name,
    int randomSeed = 0,
  }) async => artists
      .where((artist) => _matches(artist.name, query))
      .skip(offset)
      .take(limit)
      .toList();

  @override
  Future<List<String>> genres({int limit = 24}) async => ['Pop'];

  @override
  Future<List<Playlist>> ownPlaylists() async => [
    Playlist(id: 'mine', name: 'Mine', songCount: 4),
  ];

  @override
  Future<List<Song>> songsForAlbum(Album album) async => const [];

  @override
  Future<List<Song>> songsForArtist(ArtistSummary artist) async => const [];

  @override
  Future<List<Album>> albumsForArtist(ArtistSummary artist) async => const [];

  @override
  Future<List<Song>> songsForPlaylist(String playlistId) async => const [];

  bool _matches(String value, String query) =>
      query.isEmpty || value.toLowerCase().contains(query.toLowerCase());
}

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
  artist: 'Artist',
  artistId: 'artist',
  album: 'Album',
  albumId: 'album',
);
