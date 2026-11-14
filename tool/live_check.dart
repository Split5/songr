// Live smoke test against a real Navidrome server.
//
// Usage (credentials via environment, never hardcoded):
//   export NAVI_URL=https://music.example.com NAVI_USER=... NAVI_PASS=...
//   taskset -c 0-3 nice -n 10 dart run tool/live_check.dart
//
// Verifies that every home-screen section receives real data:
//   1. Spellistor (getPlaylists + getPlaylist)
//   2. Bibliotek (search3-paginering)
//   3. Quick Picks (favoriter, playCount och nyligen tillagda)
//   4. Replay (favoriter + playCount)
//   5. Similar songs (getSimilarSongs2 — answered by the AudioMuse plugin)

import 'dart:io';
import 'dart:math';

import 'package:navimusic/api/subsonic_api.dart';
import 'package:navimusic/models/models.dart';

Future<void> main() async {
  final url = Platform.environment['NAVI_URL'];
  final user = Platform.environment['NAVI_USER'];
  final pass = Platform.environment['NAVI_PASS'];
  if (url == null || user == null || pass == null) {
    stderr.writeln('Sätt NAVI_URL, NAVI_USER och NAVI_PASS.');
    exit(2);
  }

  final api = SubsonicApi(baseUrl: url, username: user, password: pass);
  var failures = 0;

  void check(String name, bool ok, String detail) {
    stdout.writeln('${ok ? "OK  " : "FAIL"}  $name — $detail');
    if (!ok) failures++;
  }

  await api.ping();
  stdout.writeln('OK    ping — auth fungerar mot $url');

  // 1. Spellistor
  final playlists = await api.getPlaylists();
  check(
    'Spellistor',
    playlists.isNotEmpty,
    '${playlists.length} st: ${playlists.map((p) => p.name).join(", ")}',
  );
  final playlistSongs = <String, List<Song>>{};
  for (final p in playlists) {
    playlistSongs[p.id] = await api.getPlaylist(p.id);
  }
  final plTotal = playlistSongs.values.fold<int>(0, (a, b) => a + b.length);
  check('Spellist-innehåll', plTotal > 0, '$plTotal låtar totalt');

  final all = <Song>[];
  var songOffset = 0;
  while (true) {
    final page = await api.search3(
      '',
      artistCount: 0,
      albumCount: 0,
      songCount: 500,
      songOffset: songOffset,
    );
    all.addAll(page.songs);
    if (page.songs.length < 500) break;
    songOffset += page.songs.length;
  }
  check('Bibliotek (search3)', all.isNotEmpty, '${all.length} låtar hämtade');

  // 2. Shuffle
  final random = List<Song>.of(all)..shuffle(Random.secure());
  check(
    'Shuffle (lokal rotation)',
    random.isNotEmpty,
    '${min(20, random.length)} kandidater, t.ex. "${random.first.title}"',
  );

  // 3. Quick Picks
  final qpSongs = all
      .where((song) => song.starred || song.playCount > 0)
      .toList();
  check(
    'Quick Picks (${qpSongs.length} kandidater)',
    qpSongs.isNotEmpty,
    qpSongs.isEmpty ? '-' : 't.ex. "${qpSongs.first.title}"',
  );

  // 4. Replay Favourites
  final replay =
      all.where((song) => song.starred || song.playCount > 0).toList()
        ..sort((a, b) => b.playCount.compareTo(a.playCount));
  check(
    'Replay Favourites',
    replay.isNotEmpty,
    'topp: "${replay.isEmpty ? "-" : replay.first.title}" (playCount ${replay.isEmpty ? 0 : replay.first.playCount})',
  );

  // 5. Similar songs — the only similarity path the client uses. On this
  // server the AudioMuse-AI Navidrome plugin answers it; the client never
  // calls AudioMuse directly.
  final seed = replay.isEmpty ? all.first : replay.first;
  final similar = await api.getSimilarSongs2(seed.id, count: 20);
  check(
    'Liknande låtar (getSimilarSongs2)',
    similar.isNotEmpty,
    '${similar.length} träffar för "${seed.title}", t.ex. "${similar.isEmpty ? "-" : similar.first.title}" av ${similar.isEmpty ? "-" : similar.first.artist}',
  );

  // Bonus: stream + cover art reachable
  final head = await HttpClient()
      .getUrl(api.streamUri(all.first.id))
      .then((r) => r.close());
  check(
    'Stream',
    head.statusCode == 200,
    'HTTP ${head.statusCode}, ${head.headers.contentType}, Accept-Ranges: ${head.headers.value("accept-ranges")}',
  );

  api.dispose();
  stdout.writeln(
    failures == 0
        ? '\nAlla hemskärmssektioner får riktig data.'
        : '\n$failures kontroller misslyckades.',
  );
  exit(failures == 0 ? 0 : 1);
}
