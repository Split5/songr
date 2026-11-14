/// Small hand-rolled Subsonic API client for Navidrome.
///
/// Uses token auth: t = md5(password + salt), s = salt, v = 1.16.1,
/// c = Soengr, f = json. All endpoints used here are verified against the
/// live server in API_CAPABILITIES.md.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../models/models.dart';

/// Pure auth-token helpers, kept static so they can be unit tested.
class SubsonicAuth {
  static const _saltChars = 'abcdefghijklmnopqrstuvwxyz0123456789';

  /// md5(password + salt), hex encoded — the `t` parameter.
  static String generateToken(String password, String salt) =>
      md5.convert(utf8.encode(password + salt)).toString();

  /// Random salt for the `s` parameter.
  static String generateSalt({int length = 12, Random? random}) {
    final rng = random ?? Random.secure();
    return List.generate(
      length,
      (_) => _saltChars[rng.nextInt(_saltChars.length)],
    ).join();
  }
}

class SubsonicException implements Exception {
  final int code;
  final String message;
  SubsonicException(this.code, this.message);

  @override
  String toString() => 'SubsonicException($code): $message';
}

class SubsonicPlayQueue {
  const SubsonicPlayQueue({
    required this.songs,
    required this.currentSongId,
    required this.position,
    required this.changedAt,
    required this.changedBy,
  });

  final List<Song> songs;
  final String? currentSongId;
  final Duration position;
  final DateTime? changedAt;
  final String? changedBy;
}

class SubsonicShare {
  const SubsonicShare({required this.id, required this.url});

  final String id;
  final Uri url;
}

class SubsonicApi {
  static const apiVersion = '1.16.1';
  static const clientName = 'Soengr';
  static const int defaultMaxJsonResponseBytes = 8 * 1024 * 1024;
  static const int defaultMaxCoverArtResponseBytes = 16 * 1024 * 1024;

  final String baseUrl; // e.g. https://music.example.com (no trailing slash)
  final String username;
  final String password;
  final http.Client _client;
  final int maxJsonResponseBytes;
  final int maxCoverArtResponseBytes;
  final Duration retryBaseDelay;

  /// One salt+token per session is sufficient; Navidrome accepts reuse.
  late final String _salt = SubsonicAuth.generateSalt();
  late final String _token = SubsonicAuth.generateToken(password, _salt);

  SubsonicApi({
    required String baseUrl,
    required this.username,
    required this.password,
    http.Client? client,
    this.maxJsonResponseBytes = defaultMaxJsonResponseBytes,
    this.maxCoverArtResponseBytes = defaultMaxCoverArtResponseBytes,
    this.retryBaseDelay = const Duration(milliseconds: 300),
  }) : baseUrl = normalizeBaseUrl(baseUrl),
       _client = client ?? http.Client();

  static String normalizeBaseUrl(String value) {
    final normalized = value.trim().replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.tryParse(normalized);
    if (uri == null ||
        uri.host.isEmpty ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw ArgumentError.value(value, 'baseUrl', 'must be an http(s) URL');
    }
    if (uri.scheme == 'http' && !isPrivateHost(uri.host)) {
      throw ArgumentError.value(
        value,
        'baseUrl',
        'public HTTP server URLs are not allowed',
      );
    }
    return normalized;
  }

  static bool isPrivateHost(String host) {
    final normalized = host.toLowerCase();
    if (normalized == 'localhost' ||
        normalized == '::1' ||
        normalized.endsWith('.local')) {
      return true;
    }
    if (normalized.contains(':')) {
      return normalized.startsWith('fc') ||
          normalized.startsWith('fd') ||
          normalized.startsWith('fe80:');
    }
    if (!normalized.contains('.')) return true;
    final parts = normalized.split('.');
    if (parts.length != 4) return false;
    final numbers = parts.map(int.tryParse).toList(growable: false);
    if (numbers.any((value) => value == null || value < 0 || value > 255)) {
      return false;
    }
    final a = numbers[0]!;
    final b = numbers[1]!;
    return a == 10 ||
        a == 127 ||
        (a == 192 && b == 168) ||
        (a == 172 && b >= 16 && b <= 31) ||
        (a == 169 && b == 254);
  }

  Map<String, String> get _authParams => {
    'u': username,
    't': _token,
    's': _salt,
    'v': apiVersion,
    'c': clientName,
    'f': 'json',
  };

  /// [params] values may be String or `Iterable<String>` (repeated
  /// parameter, e.g. `songId=a&songId=b` for createPlaylist).
  Uri uri(String endpoint, [Map<String, dynamic> params = const {}]) =>
      Uri.parse(
        '$baseUrl/rest/$endpoint',
      ).replace(queryParameters: {..._authParams, ...params});

  Future<Map<String, dynamic>> _get(
    String endpoint, {
    Map<String, dynamic> params = const {},
    bool retryable = false,
  }) async {
    const maxAttempts = 3;
    var attempt = 0;
    while (true) {
      attempt++;
      try {
        final res = await _client
            .send(http.Request('GET', uri(endpoint, params)))
            .timeout(const Duration(seconds: 20));
        final bodyBytes = await _readBounded(
          res.stream,
          limit: maxJsonResponseBytes,
        ).timeout(const Duration(seconds: 20));
        if (res.statusCode == 200) return _decodeResponse(bodyBytes);
        if (retryable &&
            attempt < maxAttempts &&
            _isTransientStatus(res.statusCode)) {
          await _waitBeforeRetry(attempt);
          continue;
        }
        throw SubsonicException(res.statusCode, 'HTTP ${res.statusCode}');
      } catch (error) {
        if (!retryable || attempt >= maxAttempts || !_isTransientError(error)) {
          rethrow;
        }
        await _waitBeforeRetry(attempt);
      }
    }
  }

  bool _isTransientStatus(int status) =>
      status == 408 || status == 429 || status >= 500;

  bool _isTransientError(Object error) =>
      error is TimeoutException ||
      error is SocketException ||
      error is http.ClientException;

  Future<void> _waitBeforeRetry(int attempt) async {
    if (retryBaseDelay == Duration.zero) return;
    final exponential = retryBaseDelay * (1 << (attempt - 1));
    final jitter = Random.secure().nextInt(exponential.inMilliseconds + 1);
    await Future<void>.delayed(
      Duration(milliseconds: exponential.inMilliseconds + jitter),
    );
  }

  /// POST is used for potentially long repeated-id requests such as a saved
  /// play queue or a shared playlist. Keeping those ids out of the URL avoids
  /// proxy/browser URL-length limits for large collections.
  Future<Map<String, dynamic>> _post(
    String endpoint, [
    Map<String, dynamic> params = const {},
  ]) async {
    final requestUri = uri(endpoint, params);
    final request = http.Request('POST', requestUri.replace(query: ''))
      ..headers['content-type'] =
          'application/x-www-form-urlencoded; charset=utf-8'
      ..body = requestUri.query;
    final res = await _client
        .send(request)
        .timeout(const Duration(seconds: 20));
    final bodyBytes = await _readBounded(
      res.stream,
      limit: maxJsonResponseBytes,
    ).timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) {
      throw SubsonicException(res.statusCode, 'HTTP ${res.statusCode}');
    }
    return _decodeResponse(bodyBytes);
  }

  Future<List<int>> _readBounded(
    Stream<List<int>> stream, {
    required int limit,
  }) async {
    final builder = BytesBuilder(copy: false);
    var total = 0;
    await for (final chunk in stream) {
      total += chunk.length;
      if (total > limit) {
        throw SubsonicException(-2, 'Response exceeds $limit bytes');
      }
      builder.add(chunk);
    }
    return builder.takeBytes();
  }

  Map<String, dynamic> _decodeResponse(List<int> bytes) {
    final body = json.decode(utf8.decode(bytes)) as Map<String, dynamic>;
    final sr = body['subsonic-response'] as Map<String, dynamic>;
    if (sr['status'] != 'ok') {
      final err = (sr['error'] ?? const {}) as Map<String, dynamic>;
      throw SubsonicException(
        (err['code'] ?? -1) as int,
        (err['message'] ?? 'okänt fel') as String,
      );
    }
    return sr;
  }

  Future<void> ping() async => _get('ping', retryable: true);

  Future<List<Playlist>> getPlaylists() async {
    final sr = await _get('getPlaylists', retryable: true);
    final list = (sr['playlists']?['playlist'] ?? const []) as List;
    return list
        .map((e) => Playlist.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Song>> getPlaylist(String id) async {
    final sr = await _get('getPlaylist', params: {'id': id}, retryable: true);
    final list = (sr['playlist']?['entry'] ?? const []) as List;
    return list.map((e) => Song.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Newest albums for the incremental refresh: one request regardless of
  /// library size, unlike paging the whole catalogue through search3.
  Future<List<Album>> getAlbumList2({int size = 50, int offset = 0}) async {
    final sr = await _get(
      'getAlbumList2',
      params: {'type': 'newest', 'size': '$size', 'offset': '$offset'},
      retryable: true,
    );
    final list = (sr['albumList2']?['album'] ?? const []) as List;
    return list
        .map((e) => Album.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Tracks of one album, used for the albums a delta run found.
  Future<List<Song>> getAlbumSongs(String albumId) async {
    final sr = await _get('getAlbum', params: {'id': albumId}, retryable: true);
    final list = (sr['album']?['song'] ?? const []) as List;
    return list.map((e) => Song.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<InternetRadioStation>> getInternetRadioStations() async {
    final sr = await _get('getInternetRadioStations', retryable: true);
    final list =
        (sr['internetRadioStations']?['internetRadioStation'] ?? const [])
            as List;
    return list
        .map(
          (entry) =>
              InternetRadioStation.fromJson(entry as Map<String, dynamic>),
        )
        .where((station) => station.streamUrl.isNotEmpty)
        .toList(growable: false);
  }

  Future<SearchResult> search3(
    String query, {
    int artistCount = 20,
    int artistOffset = 0,
    int albumCount = 20,
    int albumOffset = 0,
    int songCount = 50,
    int songOffset = 0,
  }) async {
    final sr = await _get(
      'search3',
      params: {
        'query': query,
        'artistCount': '$artistCount',
        'artistOffset': '$artistOffset',
        'albumCount': '$albumCount',
        'albumOffset': '$albumOffset',
        'songCount': '$songCount',
        'songOffset': '$songOffset',
      },
      retryable: true,
    );
    final r = (sr['searchResult3'] ?? const {}) as Map<String, dynamic>;
    return SearchResult(
      songs: ((r['song'] ?? const []) as List)
          .map((e) => Song.fromJson(e as Map<String, dynamic>))
          .toList(),
      albums: ((r['album'] ?? const []) as List)
          .map((e) => Album.fromJson(e as Map<String, dynamic>))
          .toList(),
      artists: ((r['artist'] ?? const []) as List)
          .map((e) => ArtistSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Create a playlist with the given songs (in order) and return its id.
  /// Subsonic 1.14+ echoes the created playlist; older servers answer with
  /// an empty response, in which case the list is looked up again by name
  /// (newest match wins).
  Future<String> createPlaylist(String name, List<String> songIds) async {
    final sr = await _get(
      'createPlaylist',
      params: {'name': name, 'songId': songIds},
    );
    final created = sr['playlist'];
    if (created is Map<String, dynamic> && created['id'] is String) {
      return created['id'] as String;
    }
    final playlists = await getPlaylists();
    Playlist? match;
    for (final playlist in playlists) {
      if (playlist.name != name) continue;
      if (match == null ||
          (playlist.changed != null &&
              (match.changed == null ||
                  playlist.changed!.isAfter(match.changed!)))) {
        match = playlist;
      }
    }
    if (match == null) {
      throw SubsonicException(-1, 'Playlist "$name" was not created');
    }
    return match.id;
  }

  /// Rename and/or add/remove songs (removal by playlist index).
  Future<void> updatePlaylist(
    String playlistId, {
    String? name,
    List<String> addSongIds = const [],
    List<int> removeIndexes = const [],
  }) async {
    await _get(
      'updatePlaylist',
      params: {
        'playlistId': playlistId,
        'name': ?name,
        if (addSongIds.isNotEmpty) 'songIdToAdd': addSongIds,
        if (removeIndexes.isNotEmpty)
          'songIndexToRemove': removeIndexes.map((i) => '$i').toList(),
      },
    );
  }

  Future<void> deletePlaylist(String id) async {
    await _get('deletePlaylist', params: {'id': id});
  }

  /// The user's cross-client queue stored by Navidrome.
  Future<SubsonicPlayQueue?> getPlayQueue() async {
    final sr = await _get('getPlayQueue', retryable: true);
    final raw = sr['playQueue'];
    if (raw is! Map<String, dynamic>) return null;
    final entries = (raw['entry'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Song.fromJson)
        .toList(growable: false);
    final position = raw['position'];
    return SubsonicPlayQueue(
      songs: entries,
      currentSongId: raw['current'] as String?,
      position: Duration(milliseconds: position is num ? position.toInt() : 0),
      changedAt: raw['changed'] is String
          ? DateTime.tryParse(raw['changed'] as String)
          : null,
      changedBy: raw['changedBy'] as String?,
    );
  }

  Future<void> savePlayQueue({
    required List<String> songIds,
    String? currentSongId,
    Duration position = Duration.zero,
  }) async {
    await _post('savePlayQueue', {
      if (songIds.isNotEmpty) 'id': songIds,
      'current': ?currentSongId,
      if (currentSongId != null)
        'position': '${position.isNegative ? 0 : position.inMilliseconds}',
    });
  }

  /// Creates a public Navidrome share. The signed URL returned by the server
  /// contains no app credentials and can safely be handed to the OS share UI.
  Future<SubsonicShare> createShare(
    List<String> ids, {
    String? description,
    DateTime? expires,
  }) async {
    if (ids.isEmpty) throw ArgumentError.value(ids, 'ids', 'must not be empty');
    final sr = await _post('createShare', {
      'id': ids,
      if (description?.trim().isNotEmpty == true)
        'description': description!.trim(),
      if (expires != null) 'expires': '${expires.millisecondsSinceEpoch}',
    });
    final shares = (sr['shares']?['share'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
    if (shares.isEmpty) {
      throw const FormatException('Navidrome returned no share');
    }
    final raw = shares.first;
    final id = raw['id'] as String?;
    final url = Uri.tryParse(raw['url'] as String? ?? '');
    if (id == null || url == null || !url.hasScheme) {
      throw const FormatException('Navidrome returned an invalid share');
    }
    return SubsonicShare(id: id, url: url);
  }

  /// Similar songs from the library for a song/album/artist id.
  /// Requires Last.fm to be configured on the server (it is since 2026-07-17);
  /// returns an empty list otherwise.
  Future<List<Song>> getSimilarSongs2(String id, {int count = 20}) async {
    final sr = await _get(
      'getSimilarSongs2',
      params: {'id': id, 'count': '$count'},
      retryable: true,
    );
    final list = (sr['similarSongs2']?['song'] ?? const []) as List;
    return list.map((e) => Song.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Scrobble. NB: the server silently accepts invalid ids (status ok), so a
  /// successful response is not a delivery guarantee.
  Future<void> scrobble(String id, {required bool submission}) async {
    await _get('scrobble', params: {'id': id, 'submission': '$submission'});
  }

  Future<void> star({String? id, String? albumId, String? artistId}) =>
      _starUnstar('star', id: id, albumId: albumId, artistId: artistId);

  Future<void> unstar({String? id, String? albumId, String? artistId}) =>
      _starUnstar('unstar', id: id, albumId: albumId, artistId: artistId);

  Future<void> _starUnstar(
    String endpoint, {
    String? id,
    String? albumId,
    String? artistId,
  }) async {
    await _get(
      endpoint,
      params: {'id': ?id, 'albumId': ?albumId, 'artistId': ?artistId},
    );
  }

  /// Stream URL for playback (Accept-Ranges verified → seeking works).
  /// [maxBitRate] (kbps) asks the server to transcode down to at most that
  /// bitrate — used for data-saver mode. `format: mp3` is sent alongside it
  /// so lossless sources (FLAC etc.) actually get transcoded down rather
  /// than streamed raw; Navidrome returns the source unaltered if it's
  /// already at or below the requested bitrate.
  Uri streamUri(String songId, {int? maxBitRate}) => uri('stream', {
    'id': songId,
    if (maxBitRate != null) 'maxBitRate': '$maxBitRate',
    if (maxBitRate != null) 'format': 'mp3',
  });

  Future<http.StreamedResponse> openStream(String songId) => _client
      .send(http.Request('GET', streamUri(songId)))
      .timeout(const Duration(minutes: 10));

  /// Cover art URL for image widgets; null-safe convenience.
  String? coverArtUrl(String? coverArt, {int size = 300}) => coverArt == null
      ? null
      : uri('getCoverArt', {'id': coverArt, 'size': '$size'}).toString();

  /// Raw cover-art bytes (for saving alongside downloaded songs).
  Future<List<int>?> fetchCoverArt(String coverArtId, {int size = 600}) async {
    try {
      final res = await _client
          .send(
            http.Request(
              'GET',
              Uri.parse(coverArtUrl(coverArtId, size: size)!),
            ),
          )
          .timeout(const Duration(seconds: 20));
      final bytes = await _readBounded(
        res.stream,
        limit: maxCoverArtResponseBytes,
      ).timeout(const Duration(seconds: 20));
      if (res.statusCode != 200 || bytes.isEmpty) return null;
      return bytes;
    } catch (_) {
      return null;
    }
  }

  /// Lyrics for [songId] as LRC text (OpenSubsonic getLyricsBySongId;
  /// Navidrome ≥ 0.52). Synced lines become `[mm:ss.xx]text`, unsynced
  /// become plain text lines. Null when the server has no lyrics.
  Future<String?> getLyricsLrc(String songId) async {
    final sr = await _get(
      'getLyricsBySongId',
      params: {'id': songId},
      retryable: true,
    );
    final list = (sr['lyricsList']?['structuredLyrics'] as List? ?? const [])
        .cast<Map<String, dynamic>>();
    if (list.isEmpty) return null;
    String fmt(int ms) {
      final d = Duration(milliseconds: ms);
      final m = d.inMinutes;
      final s = d.inSeconds % 60;
      final cs = (d.inMilliseconds % 1000) ~/ 10;
      return '[${m.toString().padLeft(2, '0')}:'
          '${s.toString().padLeft(2, '0')}.'
          '${cs.toString().padLeft(2, '0')}]';
    }

    // Prefer a synced variant; fall back to the first unsynced one.
    list.sort(
      (a, b) =>
          ((b['synced'] == true) ? 1 : 0) - ((a['synced'] == true) ? 1 : 0),
    );
    final chosen = list.first;
    final lines = (chosen['line'] as List? ?? const [])
        .cast<Map<String, dynamic>>();
    if (lines.isEmpty) return null;
    final synced = chosen['synced'] == true;
    final out = StringBuffer();
    for (final line in lines) {
      final value = (line['value'] ?? '') as String;
      final start = line['start'];
      if (synced && start is num) {
        out.writeln('${fmt(start.toInt())}$value');
      } else {
        out.writeln(value);
      }
    }
    final text = out.toString().trim();
    return text.isEmpty ? null : text;
  }

  void dispose() => _client.close();
}
