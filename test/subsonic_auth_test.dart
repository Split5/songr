import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:navimusic/api/subsonic_api.dart';

void main() {
  group('SubsonicAuth.generateToken', () {
    test('matches reference md5(password + salt)', () {
      // echo -n "opensesameabc123" | md5sum
      expect(
        SubsonicAuth.generateToken('opensesame', 'abc123'),
        '808fc40d2ee2c117845c35b050775860',
      );
      // echo -n "hemligt99xyz" | md5sum
      expect(
        SubsonicAuth.generateToken('hemligt99', 'xyz'),
        'a3b7369ddfec7396386db5d8ec9f1c37',
      );
    });

    test('handles non-ASCII (UTF-8) passwords and salts', () {
      // echo -n "åäö-lösenordsalt42" | md5sum
      expect(
        SubsonicAuth.generateToken('åäö-lösenord', 'salt42'),
        'b0e9d5b6dc74420761e3042688e012a8',
      );
    });

    test('is lowercase hex of length 32', () {
      final t = SubsonicAuth.generateToken('pw', 'salt');
      expect(t, matches(RegExp(r'^[0-9a-f]{32}$')));
    });
  });

  group('SubsonicAuth.generateSalt', () {
    test('respects length and charset', () {
      final s = SubsonicAuth.generateSalt(length: 16);
      expect(s.length, 16);
      expect(s, matches(RegExp(r'^[a-z0-9]{16}$')));
    });

    test('is deterministic with an injected Random', () {
      final a = SubsonicAuth.generateSalt(random: Random(7));
      final b = SubsonicAuth.generateSalt(random: Random(7));
      expect(a, b);
    });

    test('differs between calls with secure random', () {
      expect(SubsonicAuth.generateSalt(), isNot(SubsonicAuth.generateSalt()));
    });
  });

  group('SubsonicApi.uri', () {
    test('builds a correct auth query string', () {
      final api = SubsonicApi(
        baseUrl: 'https://example.com:4533/',
        username: 'simon',
        password: 'pw',
      );
      final u = api.uri('ping');
      expect(u.path, '/rest/ping');
      expect(u.queryParameters['u'], 'simon');
      expect(u.queryParameters['v'], '1.16.1');
      expect(u.queryParameters['c'], 'Soengr');
      expect(u.queryParameters['f'], 'json');
      final salt = u.queryParameters['s']!;
      expect(u.queryParameters['t'], SubsonicAuth.generateToken('pw', salt));
      // Trailing slash on baseUrl must not produce a double slash.
      expect(u.toString(), startsWith('https://example.com:4533/rest/ping?'));
    });

    test('supports repeated parameters (createPlaylist songId list)', () {
      final api = SubsonicApi(
        baseUrl: 'http://x',
        username: 'u',
        password: 'p',
      );
      final u = api.uri('createPlaylist', {
        'name': 'Min mix',
        'songId': ['a', 'b', 'c'],
      });
      expect(u.queryParametersAll['songId'], ['a', 'b', 'c']);
      expect(u.queryParameters['name'], 'Min mix');
    });

    test('stream and cover art URLs carry auth and ids', () {
      final api = SubsonicApi(
        baseUrl: 'http://x',
        username: 'u',
        password: 'p',
      );
      final stream = api.streamUri('song1');
      expect(stream.queryParameters['id'], 'song1');
      expect(stream.queryParameters['t'], isNotEmpty);
      final cover = api.coverArtUrl('mf-1', size: 300)!;
      expect(cover, contains('getCoverArt'));
      expect(cover, contains('size=300'));
      expect(api.coverArtUrl(null), isNull);
    });

    test('allows cleartext only for private or local hosts', () {
      expect(
        SubsonicApi.normalizeBaseUrl('http://192.168.0.252:4533'),
        'http://192.168.0.252:4533',
      );
      expect(
        SubsonicApi.normalizeBaseUrl('http://localhost:4533'),
        'http://localhost:4533',
      );
      expect(
        () => SubsonicApi.normalizeBaseUrl('http://music.example.com'),
        throwsArgumentError,
      );
      expect(
        SubsonicApi.normalizeBaseUrl('https://music.example.com'),
        'https://music.example.com',
      );
    });

    test('lyrics HTTP errors are not reported as missing lyrics', () async {
      final api = SubsonicApi(
        baseUrl: 'https://example.test',
        username: 'u',
        password: 'p',
        client: MockClient((_) async => http.Response('unavailable', 503)),
      );

      await expectLater(
        api.getLyricsLrc('song'),
        throwsA(isA<SubsonicException>()),
      );
    });

    test('rejects an oversized JSON response before decoding it', () async {
      final api = SubsonicApi(
        baseUrl: 'https://example.test',
        username: 'u',
        password: 'p',
        maxJsonResponseBytes: 4,
        client: MockClient((_) async => http.Response('12345', 200)),
      );
      addTearDown(api.dispose);

      await expectLater(
        api.getPlaylists(),
        throwsA(
          isA<SubsonicException>().having((error) => error.code, 'code', -2),
        ),
      );
    });

    test('retries a transient read response and then succeeds', () async {
      var requests = 0;
      final api = SubsonicApi(
        baseUrl: 'https://example.test',
        username: 'u',
        password: 'p',
        retryBaseDelay: Duration.zero,
        client: MockClient((_) async {
          requests++;
          if (requests < 3) return http.Response('busy', 503);
          return http.Response(
            '{"subsonic-response":{"status":"ok","playlists":{}}}',
            200,
          );
        }),
      );
      addTearDown(api.dispose);

      expect(await api.getPlaylists(), isEmpty);
      expect(requests, 3);
    });

    test('does not retry a potentially non-idempotent mutation', () async {
      var requests = 0;
      final api = SubsonicApi(
        baseUrl: 'https://example.test',
        username: 'u',
        password: 'p',
        retryBaseDelay: Duration.zero,
        client: MockClient((_) async {
          requests++;
          return http.Response('busy', 503);
        }),
      );
      addTearDown(api.dispose);

      await expectLater(
        api.deletePlaylist('p'),
        throwsA(isA<SubsonicException>()),
      );
      expect(requests, 1);
    });
  });
}
