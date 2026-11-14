import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:navimusic/api/subsonic_api.dart';
import 'package:navimusic/data/local/app_database.dart';
import 'package:navimusic/data/local/navidrome_playback_media_resolver.dart';
import 'package:navimusic/domain/playback/playback_media_resolver.dart';
import 'package:navimusic/models/models.dart';
import 'package:navimusic/state/download_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'downloaded audio is preferred even while the server is reachable',
    () async {
      SharedPreferences.setMockInitialValues({});
      final directory = await Directory.systemTemp.createTemp(
        'navimusic-resolver-',
      );
      addTearDown(() => directory.delete(recursive: true));
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
      var requests = 0;
      final api = SubsonicApi(
        baseUrl: 'https://example.test',
        username: 'u',
        password: 'p',
        client: MockClient((_) async {
          requests++;
          return http.Response.bytes([1, 2, 3], 200);
        }),
      );
      addTearDown(api.dispose);
      final downloads = DownloadProvider(
        accountScope: 'server-a\u0000listener',
        downloadDirectory: () async => directory,
        legacyDownloadDirectory: () async => Directory('${directory.path}/old'),
      );
      addTearDown(downloads.dispose);
      await downloads.load();
      await downloads.downloadSong(_song(), api, manualDownloadReason);
      final stem = downloadFileStem('server-a\u0000listener', 'song');
      final artwork = File('${directory.path}/$stem.jpg')
        ..writeAsBytesSync([1]);
      final lyrics = File('${directory.path}/$stem.lrc')
        ..writeAsStringSync('x');
      requests = 0;
      final resolver = NavidromePlaybackMediaResolver(
        database: database,
        api: api,
        localPathFor: downloads.localPathFor,
        localArtworkPathFor: downloads.localArtworkPathFor,
        localLyricsPathFor: downloads.localLyricsPathFor,
      );

      final media = await resolver.resolve('song');

      expect(media.uri.scheme, 'file');
      expect(media.uri.toFilePath(), downloads.localPathFor('song'));
      expect(media.scrobbleSongId, 'song');
      expect(media.localArtworkPath, artwork.path);
      expect(media.localLyricsPath, lyrics.path);
      expect(requests, 0);
    },
  );

  test(
    'cross-account downloads use the local queue without scrobbling',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final api = SubsonicApi(
        baseUrl: 'https://example.test',
        username: 'u',
        password: 'p',
        client: MockClient((_) async => http.Response('', 500)),
      );
      addTearDown(api.dispose);
      final playbackKey = downloadPlaybackKey('server-a', 'same-id');
      final resolver = NavidromePlaybackMediaResolver(
        database: database,
        api: api,
        downloadedMediaResolver: (key) {
          if (key != playbackKey) return null;
          return ResolvedPlaybackMedia(
            song: _song(),
            uri: Uri.file('/tmp/soengr-local.m4a'),
          );
        },
      );

      final media = await resolver.resolve(playbackKey);

      expect(media.song.title, 'Song');
      expect(media.scrobbleSongId, isNull);
    },
  );
}

Song _song() => Song(
  id: 'song',
  title: 'Song',
  artist: 'Artist',
  artistId: 'artist',
  album: 'Album',
  albumId: 'album',
  suffix: 'm4a',
);
