import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/app/v2/v2_server_capabilities.dart';
import 'package:navimusic/models/models.dart';

void main() {
  Song song(String id) => Song(
    id: id,
    title: id,
    artist: 'Artist',
    artistId: 'artist',
    album: 'Album',
    albumId: 'album',
  );

  test('a plain refresh never downloads lyrics', () async {
    var lyricsCalls = 0;
    final capabilities = V2ServerCapabilities(
      serverUrl: 'https://music.example.test',
      sampleSongs: (_) async => [song('one')],
      loadSimilarSongs: (_) async => [song('two')],
      loadLyrics: (_) async {
        lyricsCalls++;
        return '[00:01]Text';
      },
    );

    await capabilities.refresh();

    // Lyrics may only be fetched once the listener opens the lyrics view. The
    // startup probe used to pull them for three sample songs.
    expect(lyricsCalls, 0);
    expect(capabilities.lyrics, ServerCapabilityState.unknown);
  });

  test(
    'optional features are available when either sample returns data',
    () async {
      var similarCalls = 0;
      var lyricsCalls = 0;
      final capabilities = V2ServerCapabilities(
        serverUrl: 'https://music.example.test',
        sampleSongs: (_) async => [song('one'), song('two')],
        loadSimilarSongs: (_) async {
          similarCalls++;
          return const [];
        },
        loadLyrics: (id) async {
          lyricsCalls++;
          return id == 'two' ? '[00:01]Text' : null;
        },
      );

      await capabilities.refresh(checkLyrics: true);

      expect(similarCalls, 2);
      expect(lyricsCalls, 2);
      expect(capabilities.smartMixes, ServerCapabilityState.unknown);
      expect(capabilities.lyrics, ServerCapabilityState.available);
      expect(capabilities.smartMixesDisabled, isFalse);
      expect(capabilities.lyricsDisabled, isFalse);
    },
  );

  test(
    'network probe errors stay unknown instead of disabling features',
    () async {
      final capabilities = V2ServerCapabilities(
        serverUrl: 'http://192.168.1.10:4533',
        sampleSongs: (_) async => [song('one')],
        loadSimilarSongs: (_) async => throw StateError('unsupported'),
        loadLyrics: (_) async => '[00:01]Text',
      );

      await capabilities.refresh(checkLyrics: true);

      expect(capabilities.smartMixes, ServerCapabilityState.unknown);
      expect(capabilities.lyrics, ServerCapabilityState.available);
      expect(capabilities.isLocalServer, isTrue);
      expect(capabilities.isHttps, isFalse);
    },
  );

  test('disposing during a probe does not notify or throw', () async {
    final response = Completer<List<Song>>();
    final capabilities = V2ServerCapabilities(
      serverUrl: 'https://music.example.test',
      sampleSongs: (_) async => [song('one')],
      loadSimilarSongs: (_) => response.future,
      loadLyrics: (_) async => null,
    );

    final probe = capabilities.refresh();
    capabilities.dispose();
    response.complete(const []);

    await expectLater(probe, completes);
    expect(capabilities.smartMixes, ServerCapabilityState.checking);
  });
}
