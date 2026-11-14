import 'dart:async';
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:navimusic/api/subsonic_api.dart';
import 'package:navimusic/data/local/app_database.dart';
import 'package:navimusic/domain/library/library_mutation_service.dart';
import 'package:navimusic/models/models.dart';
import 'package:navimusic/state/download_provider.dart';

void main() {
  test('offline favorite is stored locally and replayed once', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await database.upsertSongs([
      LocalSongsCompanion.insert(
        id: 'song',
        title: 'Song',
        artist: 'Artist',
        album: 'Album',
      ),
    ]);
    var offline = true;
    var starRequests = 0;
    final api = SubsonicApi(
      baseUrl: 'https://example.test',
      username: 'u',
      password: 'p',
      client: MockClient((request) async {
        if (request.url.path == '/rest/star') starRequests++;
        if (offline) return http.Response('offline', 503);
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'subsonic-response': {'status': 'ok'},
            }),
          ),
          200,
        );
      }),
    );
    addTearDown(api.dispose);
    final downloads = DownloadProvider()..favoritesOfflineEnabled = false;
    addTearDown(downloads.dispose);
    final mutations = LibraryMutationService(
      api: api,
      database: database,
      downloads: downloads,
    );
    final song = _song();

    expect(await mutations.toggleFavorite(song), isTrue);
    expect(song.starred, isTrue);
    expect(await database.pendingFavoriteMutations(), hasLength(1));

    offline = false;
    await mutations.replayPendingFavorites();

    expect(starRequests, 2);
    expect(await database.pendingFavoriteMutations(), isEmpty);
  });

  test(
    'favorite updates locally before the server request completes',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      await database.upsertSongs([
        LocalSongsCompanion.insert(
          id: 'song',
          title: 'Song',
          artist: 'Artist',
          album: 'Album',
        ),
      ]);
      final responseGate = Completer<void>();
      final api = SubsonicApi(
        baseUrl: 'https://example.test',
        username: 'u',
        password: 'p',
        client: MockClient((request) async {
          await responseGate.future;
          return http.Response.bytes(
            utf8.encode(
              jsonEncode({
                'subsonic-response': {'status': 'ok'},
              }),
            ),
            200,
          );
        }),
      );
      addTearDown(api.dispose);
      final downloads = DownloadProvider()..favoritesOfflineEnabled = false;
      addTearDown(downloads.dispose);
      final mutations = LibraryMutationService(
        api: api,
        database: database,
        downloads: downloads,
      );
      final song = _song();
      final localChange = Completer<void>();

      final update = mutations.toggleFavorite(
        song,
        onLocalChange: () async => localChange.complete(),
      );
      await localChange.future;

      expect(song.starred, isTrue);
      expect((await database.songsPage(query: 'Song')).single.starred, isTrue);

      responseGate.complete();
      expect(await update, isTrue);
    },
  );

  test('rename playlist sends the trimmed name', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    Uri? request;
    final api = SubsonicApi(
      baseUrl: 'https://example.test',
      username: 'u',
      password: 'p',
      client: MockClient((value) async {
        request = value.url;
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'subsonic-response': {'status': 'ok'},
            }),
          ),
          200,
        );
      }),
    );
    addTearDown(api.dispose);
    final downloads = DownloadProvider();
    addTearDown(downloads.dispose);
    final mutations = LibraryMutationService(
      api: api,
      database: database,
      downloads: downloads,
    );

    await mutations.renamePlaylist(
      Playlist(id: 'playlist-1', name: 'Old name'),
      '  New name  ',
    );

    expect(request?.path, '/rest/updatePlaylist');
    expect(request?.queryParameters['playlistId'], 'playlist-1');
    expect(request?.queryParameters['name'], 'New name');
  });

  test('rapid favorite toggles reach the server in order', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await database.upsertSongs([
      LocalSongsCompanion.insert(
        id: 'song',
        title: 'Song',
        artist: 'Artist',
        album: 'Album',
      ),
    ]);
    final firstRequest = Completer<void>();
    final releaseFirst = Completer<void>();
    final requests = <String>[];
    final api = SubsonicApi(
      baseUrl: 'https://example.test',
      username: 'u',
      password: 'p',
      client: MockClient((request) async {
        requests.add(request.url.pathSegments.last);
        if (requests.length == 1) {
          firstRequest.complete();
          await releaseFirst.future;
        }
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'subsonic-response': {'status': 'ok'},
            }),
          ),
          200,
        );
      }),
    );
    addTearDown(api.dispose);
    final downloads = DownloadProvider()..favoritesOfflineEnabled = false;
    addTearDown(downloads.dispose);
    final mutations = LibraryMutationService(
      api: api,
      database: database,
      downloads: downloads,
    );
    final song = _song();

    final star = mutations.toggleFavorite(song);
    await firstRequest.future;
    final unstar = mutations.toggleFavorite(song);
    await Future<void>.delayed(Duration.zero);
    expect(requests, ['star']);

    releaseFirst.complete();
    await Future.wait([star, unstar]);

    expect(requests, ['star', 'unstar']);
    expect(song.starred, isFalse);
  });
}

Song _song() => Song(
  id: 'song',
  title: 'Song',
  artist: 'Artist',
  artistId: 'artist',
  album: 'Album',
  albumId: 'album',
);
