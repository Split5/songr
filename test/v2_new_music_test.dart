import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/design_system/navi_theme.dart';
import 'package:navimusic/domain/library/catalog_repository.dart';
import 'package:navimusic/domain/library/song_filter.dart';
import 'package:navimusic/domain/library/song_library_repository.dart';
import 'package:navimusic/features/new_music/new_music_controller.dart';
import 'package:navimusic/features/new_music/v2_new_music_screen.dart';
import 'package:navimusic/l10n/app_localizations.dart';
import 'package:navimusic/models/models.dart';

void main() {
  testWidgets('New shows recently added albums in date order', (tester) async {
    final controller = NewMusicController(catalog: _Catalog(), songs: _Songs());
    addTearDown(controller.dispose);
    Album? albumTap;
    await tester.pumpWidget(
      _app(
        V2NewMusicScreen(
          controller: controller,
          onAlbumTap: (album) => albumTap = album,
          onSongTap: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nytt'), findsWidgets);
    expect(find.text('Senast tillagda'), findsOneWidget);
    expect(find.text('New Album'), findsOneWidget);
    expect(find.text('Older Album'), findsOneWidget);
    expect(find.text('Today song'), findsNothing);
    expect(
      tester.getTopLeft(find.text('New Album')).dy,
      lessThan(tester.getTopLeft(find.text('Older Album')).dy),
    );
    await tester.tap(find.text('New Album'));
    expect(albumTap?.id, 'album');
  });
}

class _Catalog implements CatalogRepository {
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
  }) async => [
    Album(
      id: 'album',
      name: 'New Album',
      artist: 'Artist',
      artistId: 'artist',
      created: DateTime(2026, 8, 28),
    ),
  ];

  @override
  Future<int> artistCount({String query = ''}) async => 0;

  @override
  Future<List<ArtistSummary>> artistsPage({
    String query = '',
    int limit = 60,
    int offset = 0,
    ArtistSort sort = ArtistSort.name,
    int randomSeed = 0,
  }) async => const [];

  @override
  Future<List<String>> genres({int limit = 24}) async => const [];

  @override
  Future<List<Playlist>> ownPlaylists() async => const [];

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
  Future<int> count(SongFilter filter) async => 2;

  @override
  Future<List<Song>> page({
    required SongFilter filter,
    required int limit,
    required int offset,
  }) async => [
    _song(
      'today',
      'Today song',
      DateTime(2026, 8, 28),
      albumId: 'album',
      album: 'New Album',
    ),
    _song(
      'yesterday',
      'Yesterday song',
      DateTime(2026, 8, 27),
      albumId: 'older-album',
      album: 'Older Album',
    ),
  ];
}

Song _song(
  String id,
  String title,
  DateTime created, {
  required String albumId,
  required String album,
}) => Song(
  id: id,
  title: title,
  artist: 'Artist',
  artistId: 'artist',
  album: album,
  albumId: albumId,
  created: created,
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
