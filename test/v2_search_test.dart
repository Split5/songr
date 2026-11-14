import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/app/v2/v2_shell.dart';
import 'package:navimusic/design_system/navi_theme.dart';
import 'package:navimusic/domain/library/catalog_repository.dart';
import 'package:navimusic/domain/library/song_filter.dart';
import 'package:navimusic/domain/library/song_library_repository.dart';
import 'package:navimusic/features/search/search_controller.dart';
import 'package:navimusic/features/search/v2_search_screen.dart';
import 'package:navimusic/l10n/app_localizations.dart';
import 'package:navimusic/models/models.dart';

void main() {
  testWidgets('search starts with genres and returns canonical local results', (
    tester,
  ) async {
    final controller = V2SearchController(
      catalog: _Catalog(),
      songLibrary: _Songs(),
      debounce: Duration.zero,
    );
    addTearDown(controller.dispose);
    ArtistSummary? tapped;

    await tester.pumpWidget(
      _app(
        V2SearchScreen(
          controller: controller,
          onSongTap: (_) {},
          onAlbumTap: (_) {},
          onArtistTap: (artist) => tapped = artist,
          onPlaylistTap: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.getCenter(find.byType(TextField)).dy, lessThan(200));

    await tester.enterText(find.byType(TextField), 'Alex');
    await tester.pumpAndSettle();
    expect(find.text('Alex Warren'), findsWidgets);
    expect(find.text('Alex Warren, ROSÉ'), findsNothing);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    final artistTile = find.widgetWithText(ListTile, 'Alex Warren').last;
    await tester.tap(artistTile);
    expect(tapped?.id, 'artist');
  });

  testWidgets('activating the Search tab focuses the search field', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = V2SearchController(
      catalog: _Catalog(),
      songLibrary: _Songs(),
      debounce: Duration.zero,
    );
    addTearDown(controller.dispose);
    final host = GlobalKey<_ActivationHostState>();

    await tester.pumpWidget(
      _app(
        _ActivationHost(
          key: host,
          child: V2SearchScreen(
            controller: controller,
            onSongTap: (_) {},
            onAlbumTap: (_) {},
            onArtistTap: (_) {},
            onPlaylistTap: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    var field = tester.widget<TextField>(find.byType(TextField));
    expect(field.focusNode?.hasFocus, isFalse);

    host.currentState!.triggerSearch();
    await tester.pumpAndSettle();

    field = tester.widget<TextField>(find.byType(TextField));
    expect(field.focusNode?.hasFocus, isTrue);
  });

  testWidgets('the first typed character keeps the same focused search field', (
    tester,
  ) async {
    final controller = V2SearchController(
      catalog: _Catalog(),
      songLibrary: _Songs(),
      debounce: Duration.zero,
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _app(
        V2SearchScreen(
          controller: controller,
          onSongTap: (_) {},
          onAlbumTap: (_) {},
          onArtistTap: (_) {},
          onPlaylistTap: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final field = find.byType(TextField);
    await tester.tap(field);
    await tester.pump();
    final before = tester.state<EditableTextState>(find.byType(EditableText));
    expect(tester.widget<TextField>(field).focusNode?.hasFocus, isTrue);

    await tester.enterText(field, 'A');
    await tester.pumpAndSettle();

    final after = tester.state<EditableTextState>(find.byType(EditableText));
    expect(
      identical(after, before),
      isTrue,
      reason: 'Showing result filters must not replace the active TextField.',
    );
    expect(tester.widget<TextField>(field).focusNode?.hasFocus, isTrue);
    expect(tester.testTextInput.isRegistered, isTrue);
  });

  testWidgets('all result types stay grouped in one live list', (tester) async {
    final controller = V2SearchController(
      catalog: _Catalog(),
      songLibrary: _ManySongs(),
      debounce: Duration.zero,
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _app(
        V2SearchScreen(
          controller: controller,
          onSongTap: (_) {},
          onAlbumTap: (_) {},
          onArtistTap: (_) {},
          onPlaylistTap: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Alex');
    await tester.pumpAndSettle();

    expect(find.text('Song 0'), findsOneWidget);
    expect(find.text('Album'), findsWidgets);
    expect(find.text('Alex Warren'), findsWidgets);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Song 6'), findsOneWidget);
  });

  testWidgets('an exact album match is shown before incidental song matches', (
    tester,
  ) async {
    final controller = V2SearchController(
      catalog: _EncantoCatalog(),
      songLibrary: _EncantoSongs(),
      debounce: Duration.zero,
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _app(
        V2SearchScreen(
          controller: controller,
          onSongTap: (_) {},
          onAlbumTap: (_) {},
          onArtistTap: (_) {},
          onPlaylistTap: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Encanto');
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.text('Encanto (Original Soundtrack)')).dy,
      lessThan(tester.getTopLeft(find.text('Surface Pressure')).dy),
    );
  });

  testWidgets('song results expose the shared song actions menu', (
    tester,
  ) async {
    final controller = V2SearchController(
      catalog: _Catalog(),
      songLibrary: _Songs(),
      debounce: Duration.zero,
    );
    addTearDown(controller.dispose);
    Song? menuSong;

    await tester.pumpWidget(
      _app(
        V2SearchScreen(
          controller: controller,
          onSongTap: (_) {},
          onSongMenu: (song) => menuSong = song,
          onAlbumTap: (_) {},
          onArtistTap: (_) {},
          onPlaylistTap: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Alex');
    await tester.pumpAndSettle();
    controller.setCategory(SearchCategory.songs);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('search-song-menu-song')));
    expect(menuSong?.id, 'song');
  });

  test('exact and prefix matches rank ahead of incidental matches', () async {
    final controller = V2SearchController(
      catalog: _Catalog(),
      songLibrary: _RankingSongs(),
      debounce: Duration.zero,
    );
    controller.setQuery('Alex');
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(controller.state.songs.map((song) => song.id), [
      'exact',
      'prefix',
      'word',
      'artist',
    ]);
    controller.dispose();
  });

  test('generated playlists cannot leak into search results', () async {
    final controller = V2SearchController(
      catalog: _Catalog(),
      songLibrary: _Songs(),
      debounce: Duration.zero,
    );
    controller.setQuery('automatic');
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(controller.state.playlists, isEmpty);
    controller.dispose();
  });
}

class _Catalog implements CatalogRepository {
  @override
  Future<List<String>> genres({int limit = 24}) async => ['Pop', 'Rock'];

  @override
  Future<int> albumCount({String query = ''}) async => 1;

  @override
  Future<List<Album>> albumsPage({
    String query = '',
    int limit = 60,
    int offset = 0,
    bool newestFirst = false,
    AlbumSort sort = AlbumSort.title,
    int randomSeed = 0,
  }) async => query.isEmpty
      ? const []
      : [
          Album(
            id: 'album',
            name: 'Album',
            artist: 'Alex Warren',
            artistId: 'artist',
          ),
        ];

  @override
  Future<int> artistCount({String query = ''}) async => 1;

  @override
  Future<List<ArtistSummary>> artistsPage({
    String query = '',
    int limit = 60,
    int offset = 0,
    ArtistSort sort = ArtistSort.name,
    int randomSeed = 0,
  }) async => query.isEmpty
      ? const []
      : [ArtistSummary(id: 'artist', name: 'Alex Warren')];

  @override
  Future<List<Playlist>> ownPlaylists() async => [
    Playlist(id: 'mine', name: 'My playlist'),
  ];

  @override
  Future<List<Song>> songsForAlbum(Album album) async => const [];

  @override
  Future<List<Song>> songsForArtist(ArtistSummary artist) async => const [];

  @override
  Future<List<Album>> albumsForArtist(ArtistSummary artist) async => const [];

  @override
  Future<List<Song>> songsForPlaylist(String playlistId) async => const [];
}

class _Songs implements SongLibraryRepository {
  @override
  Future<int> count(SongFilter filter) async => 1;

  @override
  Future<List<Song>> page({
    required SongFilter filter,
    required int limit,
    required int offset,
  }) async => filter.query.isEmpty
      ? const []
      : [
          Song(
            id: 'song',
            title: 'Song',
            artist: 'Alex Warren',
            artistId: 'artist',
            album: 'Album',
            albumId: 'album',
          ),
        ];
}

class _ManySongs implements SongLibraryRepository {
  @override
  Future<int> count(SongFilter filter) async => 10;

  @override
  Future<List<Song>> page({
    required SongFilter filter,
    required int limit,
    required int offset,
  }) async => [
    for (var index = 0; index < 10; index++)
      Song(
        id: 'song-$index',
        title: 'Song $index',
        artist: 'Alex Warren',
        artistId: 'artist',
        album: 'Album',
        albumId: 'album',
      ),
  ];
}

class _RankingSongs implements SongLibraryRepository {
  @override
  Future<int> count(SongFilter filter) async => 4;

  @override
  Future<List<Song>> page({
    required SongFilter filter,
    required int limit,
    required int offset,
  }) async => [
    Song(
      id: 'artist',
      title: 'Different title',
      artist: 'Alex Warren',
      artistId: 'alex-warren',
      album: 'Album',
      albumId: 'album',
    ),
    Song(
      id: 'word',
      title: 'The Alex song',
      artist: 'Other',
      artistId: 'other',
      album: 'Album',
      albumId: 'album',
    ),
    Song(
      id: 'prefix',
      title: 'Alexandra',
      artist: 'Other',
      artistId: 'other',
      album: 'Album',
      albumId: 'album',
    ),
    Song(
      id: 'exact',
      title: 'Alex',
      artist: 'Other',
      artistId: 'other',
      album: 'Album',
      albumId: 'album',
    ),
  ];
}

class _EncantoCatalog extends _Catalog {
  @override
  Future<List<Album>> albumsPage({
    String query = '',
    int limit = 60,
    int offset = 0,
    bool newestFirst = false,
    AlbumSort sort = AlbumSort.title,
    int randomSeed = 0,
  }) async => query.isEmpty
      ? const []
      : [
          Album(
            id: 'encanto',
            name: 'Encanto (Original Soundtrack)',
            artist: 'Lin-Manuel Miranda',
            artistId: 'lin-manuel-miranda',
            songCount: 2,
          ),
        ];

  @override
  Future<List<ArtistSummary>> artistsPage({
    String query = '',
    int limit = 60,
    int offset = 0,
    ArtistSort sort = ArtistSort.name,
    int randomSeed = 0,
  }) async => const [];
}

class _EncantoSongs implements SongLibraryRepository {
  @override
  Future<int> count(SongFilter filter) async => 1;

  @override
  Future<List<Song>> page({
    required SongFilter filter,
    required int limit,
    required int offset,
  }) async => [
    Song(
      id: 'surface-pressure',
      title: 'Surface Pressure',
      artist: 'Jessica Darrow',
      artistId: 'jessica-darrow',
      album: 'Encanto (Original Soundtrack)',
      albumId: 'encanto',
    ),
  ];
}

class _ActivationHost extends StatefulWidget {
  const _ActivationHost({super.key, required this.child});

  final Widget child;

  @override
  State<_ActivationHost> createState() => _ActivationHostState();
}

class _ActivationHostState extends State<_ActivationHost> {
  var active = false;
  var activation = 0;

  void triggerSearch() => setState(() {
    active = true;
    activation++;
  });

  @override
  Widget build(BuildContext context) => V2TabActivity(
    isActive: active,
    activation: activation,
    child: widget.child,
  );
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
