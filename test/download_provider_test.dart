import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:navimusic/api/subsonic_api.dart';
import 'package:navimusic/domain/downloads/downloaded_library_repository.dart';
import 'package:navimusic/domain/library/song_filter.dart';
import 'package:navimusic/features/downloads/downloads_controller.dart';
import 'package:navimusic/models/models.dart';
import 'package:navimusic/state/download_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('downloads can be searched and sorted locally', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final directory = await Directory.systemTemp.createTemp('navimusic-list-');
    addTearDown(() => directory.delete(recursive: true));
    await File('${directory.path}/zeta.m4a').writeAsBytes([1]);
    await File('${directory.path}/alpha.m4a').writeAsBytes([2]);
    SharedPreferences.setMockInitialValues({
      'download_manifest_v2': jsonEncode({
        downloadEntryKey('local', 'zeta'): {
          'name': 'zeta.m4a',
          'bytes': 1,
          'reasons': [manualDownloadReason],
          'accountScope': 'local',
          'songId': 'zeta',
        },
        downloadEntryKey('local', 'alpha'): {
          'name': 'alpha.m4a',
          'bytes': 1,
          'reasons': [manualDownloadReason],
          'accountScope': 'local',
          'songId': 'alpha',
        },
      }),
    });
    final provider = DownloadProvider(
      downloadDirectory: () async => directory,
      legacyDownloadDirectory: () async => Directory('${directory.path}/old'),
    );
    addTearDown(provider.dispose);
    await provider.load();
    final controller = V2DownloadsController(
      downloads: provider,
      repository: _DownloadedSongs([
        _song('zeta', title: 'Zeta', artist: 'Alpha'),
        _song('alpha', title: 'Alpha', artist: 'Beta'),
      ]),
    );
    addTearDown(controller.dispose);

    await controller.initialize();
    expect(controller.visibleSongs.map((song) => song.id), ['alpha', 'zeta']);

    controller.setQuery('zeta');
    expect(controller.visibleSongs.map((song) => song.id), ['zeta']);

    controller
      ..setQuery('')
      ..setSort(SongSort.artist);
    expect(controller.visibleSongs.map((song) => song.id), ['zeta', 'alpha']);
  });

  group('diffPlaylistSongs', () {
    test('detects songs added to and removed from a playlist', () {
      final diff = diffPlaylistSongs({'a', 'b', 'c'}, {'b', 'c', 'd'});
      expect(diff.added, {'d'});
      expect(diff.removed, {'a'});
    });

    test('no changes yields empty added/removed', () {
      final diff = diffPlaylistSongs({'a', 'b'}, {'a', 'b'});
      expect(diff.added, isEmpty);
      expect(diff.removed, isEmpty);
    });

    test(
      'a brand new (previously empty) playlist reports everything added',
      () {
        final diff = diffPlaylistSongs(const {}, {'a', 'b'});
        expect(diff.added, {'a', 'b'});
        expect(diff.removed, isEmpty);
      },
    );
  });

  group('reason key builders', () {
    test('are stable and distinct per id', () {
      expect(playlistDownloadReason('p1'), 'playlist:p1');
      expect(albumDownloadReason('al1'), 'album:al1');
      expect(playlistDownloadReason('p1'), isNot(albumDownloadReason('p1')));
    });
  });

  test('offline snapshot contains only songs downloaded for that playlist', () {
    final songs = [_song('a'), _song('b')];
    final entries = {
      'a': DownloadedEntry(
        path: '/a',
        bytes: 1,
        reasons: {playlistDownloadReason('p1')},
        accountScope: 'local',
        songId: 'a',
      ),
      'b': DownloadedEntry(
        path: '/b',
        bytes: 1,
        reasons: {manualDownloadReason},
        accountScope: 'local',
        songId: 'b',
      ),
    };

    expect(
      downloadedPlaylistSongIds(songs, entries, playlistDownloadReason('p1')),
      {'a'},
    );
  });

  test('disabled download reasons reject new and finished work', () {
    expect(
      downloadReasonIsActive(
        playlistDownloadReason('p1'),
        offlinePlaylistIds: const {},
        favoritesOfflineEnabled: true,
      ),
      isFalse,
    );
    expect(
      downloadReasonIsActive(
        favoritesDownloadReason,
        offlinePlaylistIds: const {},
        favoritesOfflineEnabled: false,
      ),
      isFalse,
    );
    expect(
      downloadReasonIsActive(
        manualDownloadReason,
        offlinePlaylistIds: const {},
        favoritesOfflineEnabled: false,
      ),
      isTrue,
    );
  });

  test(
    'successful download is atomically renamed from its partial file',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      final directory = await Directory.systemTemp.createTemp(
        'navimusic-download-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final provider = DownloadProvider(
        downloadDirectory: () async => directory,
        legacyDownloadDirectory: () async =>
            Directory('${directory.path}/legacy'),
      );
      addTearDown(provider.dispose);
      await provider.load();
      final api = SubsonicApi(
        baseUrl: 'https://example.test',
        username: 'u',
        password: 'p',
        client: MockClient((_) async => http.Response.bytes([1, 2, 3], 200)),
      );
      addTearDown(api.dispose);

      expect(
        await provider.downloadSong(_song('song'), api, manualDownloadReason),
        isTrue,
      );
      final path = provider.localPathFor('song')!;
      expect(File(path).existsSync(), isTrue);
      expect(path.endsWith('.m4a'), isTrue);
      expect(path.contains('soengr-'), isTrue);
      expect(File('$path.part').existsSync(), isFalse);
      final stem = downloadFileStem('local', 'song');
      final artwork = File('${directory.path}/$stem.jpg')
        ..writeAsBytesSync([1]);
      final lyrics = File('${directory.path}/$stem.lrc')
        ..writeAsStringSync('x');
      expect(provider.localArtworkPathFor('song'), artwork.path);
      expect(provider.localLyricsPathFor('song'), lyrics.path);
    },
  );

  test('a stalled response stream is abandoned after inactivity', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final directory = await Directory.systemTemp.createTemp(
      'navimusic-stalled-download-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final stalledStreams = <StreamController<List<int>>>[];
    final provider = DownloadProvider(
      downloadDirectory: () async => directory,
      legacyDownloadDirectory: () async => Directory('${directory.path}/old'),
      downloadInactivityTimeout: const Duration(milliseconds: 20),
      downloadRetryBaseDelay: Duration.zero,
    );
    addTearDown(provider.dispose);
    await provider.load();
    final api = SubsonicApi(
      baseUrl: 'https://example.test',
      username: 'u',
      password: 'p',
      client: MockClient.streaming((_, _) async {
        final stalled = StreamController<List<int>>();
        stalledStreams.add(stalled);
        return http.StreamedResponse(stalled.stream, 200);
      }),
    );
    addTearDown(api.dispose);
    addTearDown(() {
      for (final stalled in stalledStreams) {
        unawaited(stalled.close());
      }
    });

    expect(
      await provider
          .downloadSong(_song('stalled'), api, manualDownloadReason)
          .timeout(const Duration(seconds: 2)),
      isFalse,
    );
    expect(provider.downloadingIds, isEmpty);
    expect(
      directory.listSync().where((entry) => entry.path.endsWith('.part')),
      isEmpty,
    );
  });

  test('a transient download failure is retried before giving up', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final directory = await Directory.systemTemp.createTemp(
      'navimusic-download-retry-',
    );
    addTearDown(() => directory.delete(recursive: true));
    var requests = 0;
    final provider = DownloadProvider(
      downloadDirectory: () async => directory,
      legacyDownloadDirectory: () async => Directory('${directory.path}/old'),
      downloadRetryBaseDelay: Duration.zero,
    );
    addTearDown(provider.dispose);
    await provider.load();
    final api = SubsonicApi(
      baseUrl: 'https://example.test',
      username: 'u',
      password: 'p',
      client: MockClient((_) async {
        requests++;
        return requests == 1
            ? http.Response('busy', 503)
            : http.Response.bytes([1, 2, 3], 200);
      }),
    );
    addTearDown(api.dispose);

    expect(
      await provider.downloadSong(_song('retry'), api, manualDownloadReason),
      isTrue,
    );
    expect(requests, 2);
    expect(provider.localPathFor('retry'), isNotNull);
  });

  test(
    'server-controlled ids and suffixes cannot escape the download root',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      final directory = await Directory.systemTemp.createTemp(
        'navimusic-safe-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final provider = DownloadProvider(
        accountScope: 'server-a',
        downloadDirectory: () async => directory,
        legacyDownloadDirectory: () async => Directory('${directory.path}/old'),
      );
      addTearDown(provider.dispose);
      await provider.load();
      final api = SubsonicApi(
        baseUrl: 'https://example.test',
        username: 'u',
        password: 'p',
        client: MockClient((_) async => http.Response.bytes([1, 2, 3], 200)),
      );
      addTearDown(api.dispose);
      final song = Song(
        id: '../../outside',
        title: 'Unsafe',
        artist: 'Artist',
        artistId: 'artist',
        album: 'Album',
        albumId: 'album',
        suffix: '../exe',
      );

      expect(
        await provider.downloadSong(song, api, manualDownloadReason),
        isTrue,
      );
      final path = provider.localPathFor(song.id)!;
      expect(File(path).parent.path, directory.path);
      expect(path.endsWith('.audio'), isTrue);
    },
  );

  test('startup cleanup removes only app-owned partial files', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final directory = await Directory.systemTemp.createTemp(
      'navimusic-cleanup-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final owned = File(
      '${directory.path}/${downloadFileStem('local', 'song')}'
      '.m4a.soengr.part',
    );
    final foreign = File('${directory.path}/other-app.part');
    await owned.writeAsBytes([1]);
    await foreign.writeAsBytes([2]);
    final provider = DownloadProvider(
      downloadDirectory: () async => directory,
      legacyDownloadDirectory: () async => Directory('${directory.path}/old'),
    );
    addTearDown(provider.dispose);

    await provider.load();

    expect(owned.existsSync(), isFalse);
    expect(foreign.existsSync(), isTrue);
  });

  test(
    'downloads from different accounts coexist and stay globally visible',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      final directory = await Directory.systemTemp.createTemp(
        'navimusic-accounts-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final api = SubsonicApi(
        baseUrl: 'https://example.test',
        username: 'u',
        password: 'p',
        client: MockClient((_) async => http.Response.bytes([1, 2, 3], 200)),
      );
      addTearDown(api.dispose);

      final first = DownloadProvider(
        accountScope: 'server-a',
        downloadDirectory: () async => directory,
        legacyDownloadDirectory: () async => Directory('${directory.path}/old'),
      );
      addTearDown(first.dispose);
      await first.load();
      await first.downloadSong(
        _song('same-id', title: 'First'),
        api,
        manualDownloadReason,
      );
      final firstPath = first.localPathFor('same-id');

      final second = DownloadProvider(
        accountScope: 'server-b',
        downloadDirectory: () async => directory,
        legacyDownloadDirectory: () async => Directory('${directory.path}/old'),
      );
      addTearDown(second.dispose);
      await second.load();

      expect(second.allEntries, hasLength(1));
      expect(second.entries, isEmpty);
      expect(second.localPathFor('same-id'), isNull);

      await second.downloadSong(
        _song('same-id', title: 'Second'),
        api,
        manualDownloadReason,
      );

      expect(second.allEntries, hasLength(2));
      expect(second.localPathFor('same-id'), isNot(firstPath));
      expect(
        second
            .entryForPlaybackKey(second.entries['same-id']!.playbackKey)
            ?.song
            ?.title,
        'Second',
      );
      final controller = V2DownloadsController(
        downloads: second,
        repository: const _DownloadedSongs([]),
      );
      addTearDown(controller.dispose);
      await controller.initialize();
      expect(controller.songs.map((song) => song.title).toSet(), {
        'First',
        'Second',
      });
    },
  );

  test('legacy file migration keeps the existing manifest reasons', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final directory = await Directory.systemTemp.createTemp('navimusic-old-');
    addTearDown(() => directory.delete(recursive: true));
    final music = Directory('${directory.path}/music');
    final legacy = Directory('${directory.path}/legacy');
    await legacy.create(recursive: true);
    final oldFile = File('${legacy.path}/song.m4a');
    await oldFile.writeAsBytes([1, 2, 3]);
    SharedPreferences.setMockInitialValues({
      'download_manifest_v1': jsonEncode({
        'song': {
          'path': oldFile.path,
          'bytes': 3,
          'reasons': [manualDownloadReason],
        },
      }),
    });
    final provider = DownloadProvider(
      downloadDirectory: () async => music,
      legacyDownloadDirectory: () async => legacy,
    );
    addTearDown(provider.dispose);

    await provider.load();

    expect(provider.isDownloaded('song'), isTrue);
    expect(provider.entries['song']!.reasons, contains(manualDownloadReason));
    expect(await File('${music.path}/song.m4a').exists(), isTrue);
  });
}

Song _song(String id, {String? title, String? artist}) => Song(
  id: id,
  title: title ?? id,
  artist: artist ?? 'Artist',
  artistId: 'artist',
  album: 'Album',
  albumId: 'album',
  suffix: 'm4a',
);

class _DownloadedSongs implements DownloadedLibraryRepository {
  const _DownloadedSongs(this.songs);

  final List<Song> songs;

  @override
  Future<List<Song>> songsForIds(Iterable<String> songIds) async => songs;
}
