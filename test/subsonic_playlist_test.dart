import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:navimusic/api/subsonic_api.dart';

void main() {
  test('createPlaylist returns the id echoed by the server', () async {
    final api = _api((request) async {
      expect(request.url.path, '/rest/createPlaylist');
      final fields = _fields(request);
      expect(fields['name'], ['Träning']);
      expect(fields['songId'], ['one', 'two']);
      return _ok({
        'playlist': {'id': 'pl-9', 'name': 'Träning', 'songCount': 2},
      });
    });

    expect(await api.createPlaylist('Träning', ['one', 'two']), 'pl-9');
  });

  test(
    'createPlaylist falls back to the newest playlist with that name',
    () async {
      var lookups = 0;
      final api = _api((request) async {
        switch (request.url.path) {
          case '/rest/createPlaylist':
            return _ok({});
          case '/rest/getPlaylists':
            lookups++;
            return _ok({
              'playlists': {
                'playlist': [
                  _playlist('older', 'Träning', '2026-08-01T10:00:00Z'),
                  _playlist('other', 'Annat', '2026-09-01T10:00:00Z'),
                  _playlist('newest', 'Träning', '2026-08-30T10:00:00Z'),
                  _playlist('undated', 'Träning', null),
                ],
              },
            });
        }
        fail('unexpected request ${request.url.path}');
      });

      expect(await api.createPlaylist('Träning', ['one']), 'newest');
      expect(lookups, 1);
    },
  );

  test(
    'createPlaylist throws when the server neither echoes nor lists it',
    () async {
      final api = _api((request) async {
        switch (request.url.path) {
          case '/rest/createPlaylist':
            return _ok({});
          case '/rest/getPlaylists':
            return _ok({
              'playlists': {
                'playlist': [_playlist('other', 'Annat', null)],
              },
            });
        }
        fail('unexpected request ${request.url.path}');
      });

      await expectLater(
        api.createPlaylist('Träning', ['one']),
        throwsA(isA<SubsonicException>()),
      );
    },
  );
}

SubsonicApi _api(Future<http.Response> Function(http.Request) handler) =>
    SubsonicApi(
      baseUrl: 'https://example.test',
      username: 'u',
      password: 'p',
      client: MockClient(handler),
    );

/// Parameters regardless of whether the call went out as GET or POST.
Map<String, List<String>> _fields(http.Request request) => {
  ...request.url.queryParametersAll,
  ...Uri(query: request.body).queryParametersAll,
};

/// UTF-8 bytes, since `http.Response(String)` would encode 'ä' as Latin-1.
http.Response _ok(Map<String, Object?> body) => http.Response.bytes(
  utf8.encode(
    jsonEncode({
      'subsonic-response': {'status': 'ok', ...body},
    }),
  ),
  200,
  headers: const {'content-type': 'application/json; charset=utf-8'},
);

Map<String, Object?> _playlist(String id, String name, String? changed) => {
  'id': id,
  'name': name,
  'changed': ?changed,
};
