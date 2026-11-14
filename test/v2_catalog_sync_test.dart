import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/data/local/app_database.dart';
import 'package:navimusic/domain/sync/catalog_sync_service.dart';
import 'package:navimusic/domain/sync/library_sync_progress.dart';
import 'package:navimusic/models/models.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => database.close());

  test('all catalogue scopes page and commit complete snapshots', () async {
    final gateway = _Gateway(
      artistPages: [
        [_artist('a1'), _artist('a2')],
        [_artist('a3')],
      ],
      albumPages: [
        [_album('al1'), _album('al2')],
        [_album('al3')],
      ],
      playlists: [
        _playlist('mine', 'Road trip'),
        _playlist('generated', 'Sad_Pop_automatic', isPublic: true),
      ],
      playlistSongs: {
        'mine': [_song('s1'), _song('s2')],
        'generated': [_song('s3')],
      },
    );
    final service = CatalogSyncService(database: database, gateway: gateway);

    final progress = <LibrarySyncProgress>[];
    final report = await service.syncAll(pageSize: 2, onProgress: progress.add);
    expect(
      progress
          .where((p) => p.stage == LibrarySyncStage.artists)
          .map((p) => p.processed),
      [0, 2, 3],
    );
    expect(
      progress
          .where((p) => p.stage == LibrarySyncStage.albums)
          .map((p) => p.processed),
      [0, 2, 3],
    );
    final playlistsProgress = progress
        .where((p) => p.stage == LibrarySyncStage.playlists)
        .toList();
    expect(playlistsProgress.map((p) => p.processed), [0, 0, 1]);
    expect(playlistsProgress.last.total, 1);
    expect(playlistsProgress.last.fraction, 1);

    expect(report.artistCount, 3);
    expect(report.albumCount, 3);
    expect(report.playlistCount, 1);
    expect(report.playlistEntryCount, 2);
    expect(gateway.artistOffsets, [0, 2]);
    expect(gateway.albumOffsets, [0, 2]);
    expect(await database.select(database.localArtists).get(), hasLength(3));
    expect(await database.select(database.localAlbums).get(), hasLength(3));
    expect(
      await database.select(database.localPlaylistEntries).get(),
      hasLength(2),
    );
    final playlists = await database.select(database.localPlaylists).get();
    expect(
      playlists.singleWhere((item) => item.id == 'mine').isGenerated,
      isFalse,
    );
    expect(playlists.map((item) => item.id), ['mine']);
    expect(gateway.playlistRequests, ['mine']);
  });

  test('failed artist page keeps previous artist snapshot', () async {
    await database
        .into(database.localArtists)
        .insert(LocalArtistsCompanion.insert(id: 'old', name: 'Old artist'));
    final gateway = _Gateway(
      artistPages: [
        [_artist('new-1'), _artist('new-2')],
      ],
      failArtistOffset: 2,
    );

    await expectLater(
      CatalogSyncService(
        database: database,
        gateway: gateway,
      ).syncAll(pageSize: 2),
      throwsStateError,
    );

    final artists = await database.select(database.localArtists).get();
    expect(artists.single.id, 'old');
    expect(await database.select(database.stagedArtists).get(), isEmpty);
  });

  test('failed playlist hydration keeps all prior playlist entries', () async {
    await database
        .into(database.localPlaylists)
        .insert(
          LocalPlaylistsCompanion.insert(id: 'old', name: 'Old playlist'),
        );
    await database
        .into(database.localPlaylistEntries)
        .insert(
          LocalPlaylistEntriesCompanion.insert(
            playlistId: 'old',
            songId: 'old-song',
            position: 0,
          ),
        );
    final gateway = _Gateway(
      artistPages: const [[]],
      albumPages: const [[]],
      playlists: [_playlist('new', 'New playlist')],
      failPlaylistId: 'new',
    );

    await expectLater(
      CatalogSyncService(database: database, gateway: gateway).syncAll(),
      throwsStateError,
    );

    expect(
      (await database.select(database.localPlaylists).get()).single.id,
      'old',
    );
    expect(
      (await database.select(database.localPlaylistEntries).get())
          .single
          .songId,
      'old-song',
    );
  });

  test(
    'generated playlists are excluded but user-owned public playlists remain',
    () async {
      final gateway = _Gateway(
        artistPages: const [[]],
        albumPages: const [[]],
        playlists: [
          _playlist('mine', 'Mine'),
          _playlist('readonly', 'Server rules', readonly: true),
          _playlist('public', 'Shared with friends', isPublic: true),
          _playlist('cluster', 'Cluster_automatic', isPublic: true),
        ],
      );
      await CatalogSyncService(database: database, gateway: gateway).syncAll();

      final own = await (database.select(
        database.localPlaylists,
      )..where((row) => row.isGenerated.equals(false))).get();
      expect(own.map((playlist) => playlist.id).toList()..sort(), [
        'mine',
        'public',
      ]);
    },
  );

  test('full sync and direct playlist sync never overlap staging', () async {
    final gateway = _Gateway(playlists: [_playlist('mine', 'Mine')]);
    final blocker = Completer<void>();
    final started = Completer<void>();
    gateway.blockNextPlaylistFetch = blocker;
    gateway.onPlaylistFetchStarted = started.complete;
    final service = CatalogSyncService(database: database, gateway: gateway);

    final full = service.syncAll();
    await started.future;
    final direct = service.syncPlaylists();
    await Future<void>.delayed(Duration.zero);

    expect(gateway.fetchPlaylistsCalls, 1);
    blocker.complete();
    await Future.wait([full, direct]);
    expect(gateway.fetchPlaylistsCalls, 2);
  });

  test('collaboration variants receive one canonical artist key', () async {
    final gateway = _Gateway(
      artistPages: [
        [
          ArtistSummary(id: 'solo', name: 'Alex Warren'),
          ArtistSummary(id: 'duet', name: 'Alex Warren, ROSÉ'),
        ],
      ],
      albumPages: [
        [
          Album(
            id: 'album-solo',
            name: "You'll Be Alright, Kid",
            artist: 'Alex Warren',
            artistId: 'solo',
          ),
          Album(
            id: 'album-duet',
            name: "You'll Be Alright, Kid",
            artist: 'Alex Warren, ROSÉ',
            artistId: 'duet',
          ),
        ],
      ],
    );
    await CatalogSyncService(database: database, gateway: gateway).syncAll();

    final artists = await database.select(database.localArtists).get();
    final albums = await database.select(database.localAlbums).get();
    expect(artists.map((artist) => artist.sortName).toSet(), {'Alex Warren'});
    expect(albums.map((album) => album.canonicalArtist).toSet(), {
      'Alex Warren',
    });
  });
}

class _Gateway implements NavidromeCatalogGateway {
  _Gateway({
    this.artistPages = const [[]],
    this.albumPages = const [[]],
    this.playlists = const [],
    this.playlistSongs = const {},
    this.failArtistOffset,
    this.failPlaylistId,
  });

  final List<List<ArtistSummary>> artistPages;
  final List<List<Album>> albumPages;
  final List<Playlist> playlists;
  final Map<String, List<Song>> playlistSongs;
  final int? failArtistOffset;
  final String? failPlaylistId;
  final List<int> artistOffsets = [];
  final List<int> albumOffsets = [];
  final List<String> playlistRequests = [];
  int fetchPlaylistsCalls = 0;
  Completer<void>? blockNextPlaylistFetch;
  void Function()? onPlaylistFetchStarted;

  @override
  Future<List<ArtistSummary>> fetchArtistPage({
    required int offset,
    required int limit,
  }) async {
    artistOffsets.add(offset);
    if (offset == failArtistOffset) throw StateError('artist network failure');
    final index = offset ~/ limit;
    return index < artistPages.length ? artistPages[index] : const [];
  }

  @override
  Future<List<Album>> fetchAlbumPage({
    required int offset,
    required int limit,
  }) async {
    albumOffsets.add(offset);
    final index = offset ~/ limit;
    return index < albumPages.length ? albumPages[index] : const [];
  }

  @override
  Future<List<Playlist>> fetchPlaylists() async {
    fetchPlaylistsCalls++;
    onPlaylistFetchStarted?.call();
    onPlaylistFetchStarted = null;
    final blocker = blockNextPlaylistFetch;
    blockNextPlaylistFetch = null;
    if (blocker != null) await blocker.future;
    return playlists;
  }

  @override
  Future<List<Song>> fetchPlaylistSongs(String playlistId) async {
    playlistRequests.add(playlistId);
    if (playlistId == failPlaylistId) {
      throw StateError('playlist network failure');
    }
    return playlistSongs[playlistId] ?? const [];
  }
}

ArtistSummary _artist(String id) => ArtistSummary(id: id, name: 'Artist $id');

Album _album(String id) => Album(
  id: id,
  name: 'Album $id',
  artist: 'Artist $id',
  artistId: 'artist-$id',
  playCount: 4,
);

Playlist _playlist(
  String id,
  String name, {
  bool readonly = false,
  bool isPublic = false,
}) => Playlist(id: id, name: name, readonly: readonly, isPublic: isPublic);

Song _song(String id) => Song(
  id: id,
  title: 'Song $id',
  artist: 'Artist',
  artistId: 'artist',
  album: 'Album',
  albumId: 'album',
);
