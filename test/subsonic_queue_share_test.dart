import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:navimusic/api/subsonic_api.dart';

void main() {
  test('getPlayQueue parses songs, current position and timestamp', () async {
    final api = SubsonicApi(
      baseUrl: 'https://example.test',
      username: 'u',
      password: 'p',
      client: MockClient((request) async {
        expect(request.url.path, '/rest/getPlayQueue');
        return http.Response(
          jsonEncode({
            'subsonic-response': {
              'status': 'ok',
              'playQueue': {
                'current': 'two',
                'position': 1250,
                'changed': '2026-08-30T10:20:30Z',
                'entry': [_song('one'), _song('two')],
              },
            },
          }),
          200,
        );
      }),
    );

    final queue = await api.getPlayQueue();
    expect(queue!.songs.map((song) => song.id), ['one', 'two']);
    expect(queue.currentSongId, 'two');
    expect(queue.position, const Duration(milliseconds: 1250));
    expect(queue.changedAt, DateTime.utc(2026, 8, 30, 10, 20, 30));
  });

  test('savePlayQueue posts repeated song ids instead of a long URL', () async {
    final api = SubsonicApi(
      baseUrl: 'https://example.test',
      username: 'u',
      password: 'p',
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.query, isEmpty);
        final fields = Uri(query: request.body).queryParametersAll;
        expect(fields['id'], ['one', 'two', 'three']);
        expect(fields['current'], ['two']);
        expect(fields['position'], ['42000']);
        return http.Response(_ok(), 200);
      }),
    );

    await api.savePlayQueue(
      songIds: const ['one', 'two', 'three'],
      currentSongId: 'two',
      position: const Duration(seconds: 42),
    );
  });

  test('createShare returns the public server URL', () async {
    final api = SubsonicApi(
      baseUrl: 'https://example.test',
      username: 'u',
      password: 'p',
      client: MockClient((request) async {
        final fields = Uri(query: request.body).queryParametersAll;
        expect(fields['id'], ['album-1']);
        return http.Response(
          jsonEncode({
            'subsonic-response': {
              'status': 'ok',
              'shares': {
                'share': [
                  {'id': 'share-1', 'url': 'https://music.example/share/abc'},
                ],
              },
            },
          }),
          200,
        );
      }),
    );

    final share = await api.createShare(const ['album-1']);
    expect(share.id, 'share-1');
    expect(share.url.toString(), 'https://music.example/share/abc');
  });
}

Map<String, dynamic> _song(String id) => {
  'id': id,
  'title': id,
  'artist': 'Artist',
  'artistId': 'artist',
  'album': 'Album',
  'albumId': 'album',
};

String _ok() => jsonEncode({
  'subsonic-response': {'status': 'ok'},
});
