import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/subsonic_api.dart';
import '../domain/diagnostics/app_metrics.dart';
import '../models/models.dart';

enum _DownloadAttempt { success, stopped, retry }

/// A song kept downloaded because of one or more [reasons] — e.g. `manual`
/// (a standalone song download), `album:ID`, `favorites`, or `playlist:ID`
/// (an offline-marked playlist). The file is only actually deleted once
/// every reason referencing it has been removed, so e.g. un-marking a
/// playlist as offline doesn't delete a song that's also a Favorite.
class DownloadedEntry {
  String path;
  final int bytes;
  final Set<String> reasons;
  final String accountScope;
  final String songId;
  Song? song;

  DownloadedEntry({
    required this.path,
    required this.bytes,
    required this.reasons,
    required this.accountScope,
    required this.songId,
    this.song,
  });

  String get key => downloadEntryKey(accountScope, songId);
  String get playbackKey => downloadPlaybackKey(accountScope, songId);
}

const String downloadPlaybackPrefix = 'download:';

String downloadEntryKey(String accountScope, String songId) =>
    '$accountScope\u0000$songId';

String downloadPlaybackKey(String accountScope, String songId) {
  final encoded = base64Url
      .encode(utf8.encode(downloadEntryKey(accountScope, songId)))
      .replaceAll('=', '');
  return '$downloadPlaybackPrefix$encoded';
}

({String accountScope, String songId})? parseDownloadPlaybackKey(String value) {
  if (!value.startsWith(downloadPlaybackPrefix)) return null;
  try {
    final encoded = value.substring(downloadPlaybackPrefix.length);
    final padded = encoded.padRight((encoded.length + 3) ~/ 4 * 4, '=');
    final decoded = utf8.decode(base64Url.decode(padded));
    final separator = decoded.indexOf('\u0000');
    if (separator < 0) return null;
    return (
      accountScope: decoded.substring(0, separator),
      songId: decoded.substring(separator + 1),
    );
  } on FormatException {
    return null;
  }
}

/// Stable opaque filename stem. Including the account scope allows two servers
/// to expose the same song id without overwriting each other's local file.
String downloadFileStem(String accountScope, String songId) {
  final digest = sha256.convert(
    utf8.encode(downloadEntryKey(accountScope, songId)),
  );
  return 'soengr-$digest';
}

const Set<String> _downloadExtensions = {
  'aac',
  'aiff',
  'alac',
  'ape',
  'dff',
  'dsf',
  'flac',
  'm4b',
  'm4a',
  'mka',
  'mp3',
  'mp2',
  'mp4',
  'oga',
  'ogg',
  'opus',
  'tta',
  'wav',
  'webm',
  'wma',
  'wv',
};

String safeDownloadExtension(Song song) {
  final suffix = song.suffix.trim().toLowerCase().replaceFirst(
    RegExp(r'^\.'),
    '',
  );
  if (_downloadExtensions.contains(suffix)) return suffix;
  final mime = song.contentType?.toLowerCase() ?? '';
  if (mime.contains('mpeg')) return 'mp3';
  if (mime.contains('mp4') || mime.contains('m4a')) return 'm4a';
  if (mime.contains('flac')) return 'flac';
  if (mime.contains('ogg')) return 'ogg';
  if (mime.contains('wav')) return 'wav';
  return 'audio';
}

bool isOwnedPartialFileName(String name) => RegExp(
  r'^soengr-[a-f0-9]{64}\.[a-z0-9]{1,12}\.soengr\.part$',
).hasMatch(name);

/// Given a playlist's previous and current song-id sets, what changed.
/// Pure and top-level so it's unit-testable without any file/network I/O.
({Set<String> added, Set<String> removed}) diffPlaylistSongs(
  Set<String> previous,
  Set<String> current,
) {
  return (
    added: current.difference(previous),
    removed: previous.difference(current),
  );
}

/// Reasons a playlist could be marked offline for.
String playlistDownloadReason(String playlistId) => 'playlist:$playlistId';
String albumDownloadReason(String albumId) => 'album:$albumId';
const String manualDownloadReason = 'manual';
const String favoritesDownloadReason = 'favorites';

Set<String> downloadedPlaylistSongIds(
  Iterable<Song> songs,
  Map<String, DownloadedEntry> entries,
  String reason,
) => {
  for (final song in songs)
    if (entries[song.id]?.reasons.contains(reason) == true) song.id,
};

bool downloadReasonIsActive(
  String reason, {
  required Set<String> offlinePlaylistIds,
  required bool favoritesOfflineEnabled,
}) {
  if (reason == favoritesDownloadReason) return favoritesOfflineEnabled;
  const prefix = 'playlist:';
  if (reason.startsWith(prefix)) {
    return offlinePlaylistIds.contains(reason.substring(prefix.length));
  }
  return true;
}

/// Live progress of a user-visible batch download (an offline-marked
/// playlist, an album, …). Drives the floating progress bar in the shell.
class DownloadBatchProgress {
  final String label;
  final int total;
  int done = 0;
  int failed = 0;
  String currentTitle = '';

  /// 0..1 for the file currently downloading.
  double currentFraction = 0;

  DownloadBatchProgress({required this.label, required this.total});

  /// Overall batch progress 0..1 (completed songs + the current one).
  double get fraction =>
      total == 0 ? 0 : ((done + currentFraction) / total).clamp(0.0, 1.0);
}

/// Summary of the last finished batch — the shell shows it as a one-shot
/// "done" snackbar.
typedef CompletedBatch = ({String label, int done, int failed});

/// Owns local offline downloads: individual songs/albums, "offline"
/// playlists (current songs + anything added later), and keeping Favorites
/// available offline. A song is downloaded once but can be kept for
/// multiple [DownloadedEntry.reasons] at once; it's only deleted from disk
/// once none remain.
class DownloadProvider extends ChangeNotifier {
  DownloadProvider({
    String accountScope = 'local',
    Future<Directory> Function()? downloadDirectory,
    Future<Directory> Function()? legacyDownloadDirectory,
    this.downloadInactivityTimeout = const Duration(seconds: 45),
    this.downloadRetryBaseDelay = const Duration(milliseconds: 400),
  }) : accountScope = accountScope.trim().isEmpty ? 'local' : accountScope,
       _downloadDirectoryProvider = downloadDirectory,
       _legacyDownloadDirectoryProvider = legacyDownloadDirectory;

  static const _manifestKey = 'download_manifest_v2';
  static const _legacyManifestKey = 'download_manifest_v1';
  static const _offlinePlaylistIdsKey = 'offline_playlist_ids_v1';
  static const _scopedOfflinePlaylistIdsKey = 'offline_playlist_ids_v2';
  static const _offlinePlaylistSnapshotKey = 'offline_playlist_snapshot_v1';
  static const _scopedOfflinePlaylistSnapshotKey =
      'offline_playlist_snapshot_v2';
  static const _capKey = 'download_storage_cap_bytes_v1';
  static const _wifiOnlyKey = 'download_wifi_only_v1';
  static const _favoritesOfflineKey = 'download_favorites_offline_v1';
  static const _metadataRefreshAge = Duration(days: 7);

  /// 0 means unlimited.
  static const int defaultCapBytes = 2 * 1024 * 1024 * 1024; // 2 GB

  final String accountScope;
  final Map<String, DownloadedEntry> _entries = {};
  final Map<String, Set<String>> _offlinePlaylistIdsByAccount = {};
  final Future<Directory> Function()? _downloadDirectoryProvider;
  final Future<Directory> Function()? _legacyDownloadDirectoryProvider;
  final Map<String, Set<String>> _offlinePlaylistSnapshot = {};
  final Duration downloadInactivityTimeout;
  final Duration downloadRetryBaseDelay;

  int storageCapBytes = defaultCapBytes;
  bool wifiOnlyEnabled = true;
  bool favoritesOfflineEnabled = true;
  bool loaded = false;

  /// Set whenever a download was skipped because it would exceed
  /// [storageCapBytes] — surfaced by the UI right after a manual action.
  bool capExceeded = false;

  /// Non-null while a user-visible batch (offline playlist, album) is
  /// downloading — drives the floating progress bar in the shell.
  DownloadBatchProgress? activeBatch;

  /// Set when a batch finishes; the shell shows it as a snackbar and then
  /// clears it via [clearCompletedBatch].
  CompletedBatch? completedBatch;

  /// Songs with a download in flight right now — SongTile shows a spinner.
  final Set<String> downloadingIds = {};
  Future<void> _downloadTail = Future.value();

  Set<String> get offlinePlaylistIds =>
      _offlinePlaylistIdsByAccount.putIfAbsent(accountScope, () => <String>{});

  bool isDownloading(String songId) => downloadingIds.contains(songId);
  Future<void> get waitForPendingDownloads => _downloadTail;

  void clearCompletedBatch() {
    completedBatch = null;
  }

  Directory? _dir;

  /// Throttle for progress notifications — a notify per chunk would
  /// rebuild the shell hundreds of times per second on a fast LAN.
  DateTime _lastProgressNotify = DateTime.fromMillisecondsSinceEpoch(0);

  void _notifyProgress() {
    final now = DateTime.now();
    if (now.difference(_lastProgressNotify).inMilliseconds < 150) return;
    _lastProgressNotify = now;
    notifyListeners();
  }

  int get usedBytes => _entries.values.fold(0, (sum, e) => sum + e.bytes);
  bool get hasDownloads => _entries.isNotEmpty;
  bool isDownloaded(String songId) => _entryFor(songId) != null;
  String? localPathFor(String songId) => _entryFor(songId)?.path;
  String? localArtworkPathFor(String songId) =>
      _sidecarPath(_entryFor(songId), 'jpg');
  String? localLyricsPathFor(String songId) =>
      _sidecarPath(_entryFor(songId), 'lrc');
  String? artworkPathForEntry(DownloadedEntry entry) =>
      _sidecarPath(entry, 'jpg');
  String? lyricsPathForEntry(DownloadedEntry entry) =>
      _sidecarPath(entry, 'lrc');
  bool isPlaylistOffline(String playlistId) =>
      offlinePlaylistIds.contains(playlistId);

  /// Current-account entries, indexed by the server's song id.
  Map<String, DownloadedEntry> get entries => Map.unmodifiable({
    for (final entry in _entries.values)
      if (entry.accountScope == accountScope) entry.songId: entry,
  });

  /// All downloads on this device, including files retained from other
  /// account scopes.
  List<DownloadedEntry> get allEntries => List.unmodifiable(_entries.values);

  DownloadedEntry? entryForPlaybackKey(String playbackKey) {
    final parsed = parseDownloadPlaybackKey(playbackKey);
    if (parsed == null) return null;
    return _entries[downloadEntryKey(parsed.accountScope, parsed.songId)];
  }

  void attachSongMetadata(Song song) {
    final entry = _entryFor(song.id);
    if (entry == null || entry.song != null) return;
    entry.song = song;
    unawaited(_persistManifest());
  }

  DownloadedEntry? _entryFor(String songId) =>
      _entries[downloadEntryKey(accountScope, songId)];

  /// Removes a song from offline storage ENTIRELY (all reasons + the file
  /// itself) — the "delete" action of the Downloaded tab.
  Future<void> removeSong(String songId) async {
    final entry = _entryFor(songId);
    if (entry == null) return;
    await removeEntry(entry);
  }

  Future<void> removeEntry(DownloadedEntry entry) async {
    _entries.remove(entry.key);
    try {
      final f = File(entry.path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
    await _deleteSidecars(entry);
    await _persistManifest();
    notifyListeners();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    storageCapBytes = prefs.getInt(_capKey) ?? defaultCapBytes;
    wifiOnlyEnabled = prefs.getBool(_wifiOnlyKey) ?? true;
    favoritesOfflineEnabled = prefs.getBool(_favoritesOfflineKey) ?? true;
    final scopedPlaylistIds = prefs.getString(_scopedOfflinePlaylistIdsKey);
    if (scopedPlaylistIds != null) {
      try {
        final decoded = json.decode(scopedPlaylistIds) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          _offlinePlaylistIdsByAccount[entry.key] = (entry.value as List)
              .cast<String>()
              .toSet();
        }
      } catch (_) {}
    } else {
      offlinePlaylistIds.addAll(
        prefs.getStringList(_offlinePlaylistIdsKey) ?? const [],
      );
    }
    final snapshotRaw =
        prefs.getString(_scopedOfflinePlaylistSnapshotKey) ??
        prefs.getString(_offlinePlaylistSnapshotKey);
    if (snapshotRaw != null) {
      try {
        final decoded = json.decode(snapshotRaw) as Map<String, dynamic>;
        for (final e in decoded.entries) {
          final key = e.key.contains('\u0000')
              ? e.key
              : _scopedPlaylistKey(e.key);
          _offlinePlaylistSnapshot[key] = (e.value as List)
              .cast<String>()
              .toSet();
        }
      } catch (_) {}
    }
    await _migrateDownloadFiles();
    await _cleanupPartialDownloads();
    final manifestRaw =
        prefs.getString(_manifestKey) ?? prefs.getString(_legacyManifestKey);
    if (manifestRaw != null) {
      try {
        final dir = await _downloadDir();
        final decoded = json.decode(manifestRaw) as Map<String, dynamic>;
        for (final e in decoded.entries) {
          final m = e.value as Map<String, dynamic>;
          final entryScope = (m['accountScope'] as String?) ?? accountScope;
          final songId = (m['songId'] as String?) ?? e.key;
          // New format stores the file NAME; legacy entries stored the
          // absolute path — take its basename either way.
          final name = ((m['name'] ?? m['path'] ?? '') as String)
              .split('/')
              .last;
          if (name.isEmpty) continue;
          final path = '${dir.path}/$name';
          // Files can vanish (reinstall, OS cleanup) without the manifest
          // knowing — drop those entries rather than pretend they're there.
          if (await File(path).exists()) {
            Song? song;
            final rawSong = m['song'];
            if (rawSong is Map<String, dynamic>) {
              try {
                song = Song.fromJson(rawSong);
              } catch (_) {}
            }
            final entry = DownloadedEntry(
              path: path,
              bytes: (m['bytes'] ?? 0) as int,
              reasons: (m['reasons'] as List).cast<String>().toSet(),
              accountScope: entryScope,
              songId: songId,
              song: song,
            );
            _entries[entry.key] = entry;
          }
        }
      } catch (_) {}
      await _persistManifest();
    }
    loaded = true;
    notifyListeners();
  }

  Future<Directory> _downloadDir() async {
    final existing = _dir;
    if (existing != null) return existing;
    if (_downloadDirectoryProvider case final provider?) {
      final dir = await provider();
      if (!await dir.exists()) await dir.create(recursive: true);
      _dir = dir;
      return dir;
    }
    // Documents/Music is VISIBLE to the user and other apps via iOS file
    // sharing (UIFileSharingEnabled in Info.plist): the Files app shows it
    // under "On My iPhone", and players like VLC can open the files there.
    // The old app-support/downloads dir was invisible by design — files are
    // migrated on load (see _migrateDownloadFiles).
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/Music');
    if (!await dir.exists()) await dir.create(recursive: true);
    _dir = dir;
    return dir;
  }

  /// Moves files before the manifest is validated so legacy paths survive the
  /// migration into the shared Documents/Music directory.
  Future<void> _migrateDownloadFiles() async {
    final legacyProvider = _legacyDownloadDirectoryProvider;
    final oldDir = legacyProvider == null
        ? Directory(
            '${(await getApplicationSupportDirectory()).path}/downloads',
          )
        : await legacyProvider();
    if (!await oldDir.exists()) return;
    final newDir = await _downloadDir();
    try {
      await for (final f in oldDir.list()) {
        if (f is File) {
          final newPath = '${newDir.path}/${f.path.split('/').last}';
          if (await File(newPath).exists()) {
            await f.delete();
          } else {
            await f.rename(newPath);
          }
        }
      }
      if (await oldDir.list().isEmpty) await oldDir.delete();
    } catch (_) {}
  }

  Future<void> _cleanupPartialDownloads() async {
    try {
      final dir = await _downloadDir();
      await for (final entity in dir.list()) {
        final name = entity.path.split(Platform.pathSeparator).last;
        if (entity is File && isOwnedPartialFileName(name)) {
          await entity.delete();
        }
      }
    } catch (_) {}
  }

  Future<void> _persistManifest() async {
    final prefs = await SharedPreferences.getInstance();
    // Store FILE NAMES, not absolute paths: on iOS the app-container UUID
    // (part of the absolute path) changes on every update/reinstall while
    // the Documents/Music FILES are migrated over — absolute paths made the
    // manifest's exists-check fail after each app update and everything
    // re-downloaded. Names resolve against the current dir at load.
    final encoded = json.encode(
      _entries.map(
        (k, v) => MapEntry(k, {
          'name': v.path.split('/').last,
          'bytes': v.bytes,
          'reasons': v.reasons.toList(),
          'accountScope': v.accountScope,
          'songId': v.songId,
          if (v.song != null) 'song': v.song!.toJson(),
        }),
      ),
    );
    await prefs.setString(_manifestKey, encoded);
  }

  Future<void> _persistOfflinePlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _scopedOfflinePlaylistIdsKey,
      json.encode(
        _offlinePlaylistIdsByAccount.map(
          (key, value) => MapEntry(key, value.toList()),
        ),
      ),
    );
    await prefs.setString(
      _scopedOfflinePlaylistSnapshotKey,
      json.encode(
        _offlinePlaylistSnapshot.map((k, v) => MapEntry(k, v.toList())),
      ),
    );
  }

  Future<void> setStorageCapBytes(int bytes) async {
    storageCapBytes = bytes;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_capKey, bytes);
  }

  Future<void> setWifiOnlyEnabled(bool value) async {
    wifiOnlyEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_wifiOnlyKey, value);
  }

  /// Toggling Favorites-offline off just stops keeping NEW favorites down
  /// and drops the 'favorites' reason from existing ones (their files stay
  /// if kept downloaded for another reason too); toggling it on triggers an
  /// immediate sync.
  Future<void> setFavoritesOfflineEnabled(
    bool value, {
    List<Song> starred = const [],
    SubsonicApi? api,
  }) async {
    favoritesOfflineEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_favoritesOfflineKey, value);
    if (value && api != null) {
      await syncFavorites(starred, api);
    } else if (!value) {
      await removeReasonFromAll(entries.keys, favoritesDownloadReason);
    }
  }

  Future<bool> isOnWifi() async {
    final results = await Connectivity().checkConnectivity();
    return results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);
  }

  /// Whether a background (not directly user-initiated-right-now) download
  /// may proceed — silently skipped on cellular when Wi-Fi-only is on, and
  /// simply retried on the next sync rather than queued.
  Future<bool> _canDownloadInBackground() async {
    if (!wifiOnlyEnabled) return true;
    return isOnWifi();
  }

  /// Downloads [song] tagged with [reason] (or just adds the reason if
  /// already downloaded). [background] gates Wi-Fi-only enforcement — pass
  /// false for a directly user-initiated download, where the caller is
  /// expected to have already confirmed cellular use via
  /// [DownloadProvider.isOnWifi] + a dialog. Returns false if skipped
  /// (blocked on cellular, storage cap reached, or a network error).
  ///
  /// [onProgress] (0..1 per received chunk) powers the batch progress bar.
  /// After the audio file lands, the song's metadata is fetched alongside it:
  /// cover art as `<safe-stem>.jpg` and lyrics as `<safe-stem>.lrc` sidecars
  /// in the shared Music dir, so players like VLC pick them up.
  Future<bool> downloadSong(
    Song song,
    SubsonicApi api,
    String reason, {
    bool background = false,
    void Function(double)? onProgress,
  }) {
    final operation = _downloadTail.then(
      (_) => _downloadSongWithRetries(
        song,
        api,
        reason,
        background: background,
        onProgress: onProgress,
      ),
    );
    _downloadTail = operation.then<void>((_) {}, onError: (_, _) {});
    return operation;
  }

  Future<bool> _downloadSongWithRetries(
    Song song,
    SubsonicApi api,
    String reason, {
    bool background = false,
    void Function(double)? onProgress,
  }) async {
    final stopwatch = Stopwatch()..start();
    for (var attempt = 0; attempt < 3; attempt++) {
      final outcome = await _downloadSongUnlocked(
        song,
        api,
        reason,
        background: background,
        onProgress: onProgress,
      );
      if (outcome == _DownloadAttempt.success) {
        AppMetrics.duration('download', stopwatch.elapsed);
        return true;
      }
      if (outcome == _DownloadAttempt.stopped || attempt == 2) break;
      onProgress?.call(0);
      await _waitBeforeDownloadRetry(attempt);
    }
    AppMetrics.duration('download', stopwatch.elapsed, success: false);
    return false;
  }

  Future<_DownloadAttempt> _downloadSongUnlocked(
    Song song,
    SubsonicApi api,
    String reason, {
    bool background = false,
    void Function(double)? onProgress,
  }) async {
    if (!downloadReasonIsActive(
      reason,
      offlinePlaylistIds: offlinePlaylistIds,
      favoritesOfflineEnabled: favoritesOfflineEnabled,
    )) {
      return _DownloadAttempt.stopped;
    }
    final existing = _entryFor(song.id);
    if (existing != null) {
      final metadataChanged =
          existing.song?.coverArt != song.coverArt ||
          existing.song?.title != song.title ||
          existing.song?.artist != song.artist ||
          existing.song?.album != song.album;
      existing.song = song;
      final reasonAdded = existing.reasons.add(reason);
      if (metadataChanged || reasonAdded) await _persistManifest();
      unawaited(_fetchMetadataSidecars(existing, api, onlyMissing: true));
      onProgress?.call(1);
      return _DownloadAttempt.success;
    }
    if (background && !await _canDownloadInBackground()) {
      return _DownloadAttempt.stopped;
    }

    final stem = downloadFileStem(accountScope, song.id);
    final ext = safeDownloadExtension(song);
    downloadingIds.add(song.id);
    _notifyProgress();
    File? file;
    IOSink? sink;
    try {
      final res = await api.openStream(song.id);
      if (res.statusCode != 200) {
        try {
          await res.stream.drain<void>().timeout(const Duration(seconds: 2));
        } catch (_) {}
        return _isTransientDownloadStatus(res.statusCode)
            ? _DownloadAttempt.retry
            : _DownloadAttempt.stopped;
      }
      final contentLength = res.contentLength;
      final expectedLength =
          contentLength ?? (song.fileSize > 0 ? song.fileSize : null);
      if (expectedLength != null &&
          storageCapBytes > 0 &&
          usedBytes + expectedLength > storageCapBytes) {
        capExceeded = true;
        notifyListeners();
        return _DownloadAttempt.stopped;
      }
      final dir = await _downloadDir();
      final finalFile = File('${dir.path}/$stem.$ext');
      final partial = File('${dir.path}/$stem.$ext.soengr.part');
      if (await partial.exists()) await partial.delete();
      sink = partial.openWrite();
      var written = 0;
      var overCap = false;
      await for (final chunk in res.stream.timeout(downloadInactivityTimeout)) {
        written += chunk.length;
        if (storageCapBytes > 0 && usedBytes + written > storageCapBytes) {
          overCap = true;
          break;
        }
        sink.add(chunk);
        if (onProgress != null &&
            expectedLength != null &&
            expectedLength > 0) {
          onProgress((written / expectedLength).clamp(0.0, 1.0));
        }
      }
      await sink.close();
      sink = null;
      if (overCap) {
        try {
          await partial.delete();
        } catch (_) {}
        capExceeded = true;
        notifyListeners();
        return _DownloadAttempt.stopped;
      }
      if (written == 0 ||
          (expectedLength != null && written != expectedLength)) {
        throw StateError('Incomplete download for ${song.id}');
      }
      if (!downloadReasonIsActive(
        reason,
        offlinePlaylistIds: offlinePlaylistIds,
        favoritesOfflineEnabled: favoritesOfflineEnabled,
      )) {
        await partial.delete();
        return _DownloadAttempt.stopped;
      }
      if (await finalFile.exists()) await finalFile.delete();
      await partial.rename(finalFile.path);
      file = finalFile;
      final entry = DownloadedEntry(
        path: file.path,
        bytes: written,
        reasons: {reason},
        accountScope: accountScope,
        songId: song.id,
        song: song,
      );
      _entries[entry.key] = entry;
      await _persistManifest();
      notifyListeners();
      unawaited(_fetchMetadataSidecars(entry, api));
      return _DownloadAttempt.success;
    } catch (_) {
      try {
        await sink?.close();
      } catch (_) {}
      try {
        final dir = await _downloadDir();
        final partial = File('${dir.path}/$stem.$ext.soengr.part');
        if (await partial.exists()) await partial.delete();
        if (file != null && await file.exists()) await file.delete();
      } catch (_) {}
      return _DownloadAttempt.retry;
    } finally {
      downloadingIds.remove(song.id);
    }
  }

  bool _isTransientDownloadStatus(int status) =>
      status == 408 || status == 429 || status >= 500;

  Future<void> _waitBeforeDownloadRetry(int attempt) async {
    if (downloadRetryBaseDelay == Duration.zero) return;
    final exponential = downloadRetryBaseDelay * (1 << attempt);
    final jitter = Random.secure().nextInt(exponential.inMilliseconds + 1);
    await Future<void>.delayed(
      Duration(milliseconds: exponential.inMilliseconds + jitter),
    );
  }

  /// Cover art + lyrics sidecar files for a freshly downloaded song.
  /// Best-effort: failures are ignored (the audio file is the essential
  /// part; metadata just makes the files nicer in other players).
  Future<void> _fetchMetadataSidecars(
    DownloadedEntry entry,
    SubsonicApi api, {
    bool onlyMissing = false,
  }) async {
    try {
      final song = entry.song;
      if (song == null) return;
      final dir = await _downloadDir();
      final stem = downloadFileStem(entry.accountScope, entry.songId);
      final cover = song.coverArt;
      final coverFile = File('${dir.path}/$stem.jpg');
      if (cover != null && await _sidecarNeedsRefresh(coverFile, onlyMissing)) {
        final bytes = await api.fetchCoverArt(cover);
        if (bytes != null) {
          await coverFile.writeAsBytes(bytes);
        }
      }
      final lyricsFile = File('${dir.path}/$stem.lrc');
      if (await _sidecarNeedsRefresh(lyricsFile, onlyMissing)) {
        final lrc = await api.getLyricsLrc(song.id);
        if (lrc != null) {
          await lyricsFile.writeAsString(lrc);
        } else if (await lyricsFile.exists()) {
          await lyricsFile.delete();
        }
      }
    } catch (_) {}
  }

  Future<bool> _sidecarNeedsRefresh(File file, bool onlyMissing) async {
    if (!await file.exists()) return true;
    if (!onlyMissing) return true;
    final stat = await file.stat();
    return DateTime.now().difference(stat.modified) > _metadataRefreshAge;
  }

  /// Deletes the metadata sidecars belonging to [entry], if any.
  Future<void> _deleteSidecars(DownloadedEntry entry) async {
    try {
      final extensionStart = entry.path.lastIndexOf('.');
      final basePath = extensionStart > 0
          ? entry.path.substring(0, extensionStart)
          : entry.path;
      for (final ext in const ['jpg', 'lrc']) {
        final f = File('$basePath.$ext');
        if (await f.exists()) await f.delete();
      }
    } catch (_) {}
  }

  String? _sidecarPath(DownloadedEntry? entry, String extension) {
    if (entry == null) return null;
    final dot = entry.path.lastIndexOf('.');
    final base = dot > 0 ? entry.path.substring(0, dot) : entry.path;
    final path = '$base.$extension';
    return File(path).existsSync() ? path : null;
  }

  /// One-shot bulk download (album, or a manual multi-song action) — never
  /// auto-synced afterward, unlike an offline-marked playlist. Pass [label]
  /// to surface live progress in the shell (the floating bar + a "done"
  /// snackbar when the batch completes).
  Future<void> downloadSongs(
    List<Song> songs,
    SubsonicApi api,
    String reason, {
    String? label,
  }) async {
    capExceeded = false;
    if (label != null) {
      activeBatch = DownloadBatchProgress(label: label, total: songs.length);
      notifyListeners();
    }
    final batch = activeBatch;
    for (final s in songs) {
      if (batch != null) {
        batch
          ..currentTitle = s.title
          ..currentFraction = 0;
        notifyListeners();
      }
      final ok = await downloadSong(
        s,
        api,
        reason,
        onProgress: batch == null
            ? null
            : (f) {
                batch.currentFraction = f;
                _notifyProgress();
              },
      );
      if (batch != null) {
        if (ok) {
          batch.done++;
        } else {
          batch.failed++;
        }
        batch.currentFraction = 0;
        notifyListeners();
      }
      if (!ok && capExceeded) break;
    }
    if (batch != null) {
      completedBatch = (
        label: batch.label,
        done: batch.done,
        failed: batch.failed,
      );
      activeBatch = null;
      notifyListeners();
    }
  }

  Future<void> removeReason(String songId, String reason) async {
    final entry = _entryFor(songId);
    if (entry == null) return;
    entry.reasons.remove(reason);
    if (entry.reasons.isEmpty) {
      try {
        await File(entry.path).delete();
      } catch (_) {}
      _entries.remove(entry.key);
      await _deleteSidecars(entry);
    }
    await _persistManifest();
    notifyListeners();
  }

  Future<void> removeReasonFromAll(
    Iterable<String> songIds,
    String reason,
  ) async {
    // Bulk variant of [removeReason]: mutate every entry first, then
    // persist the manifest and notify ONCE for the whole operation —
    // per-song persistence made un-marking a large offline playlist (or
    // toggling Favorites-offline off) an O(n) prefs-rewrite storm.
    var changed = false;
    for (final id in songIds) {
      final entry = _entryFor(id);
      if (entry == null) continue;
      entry.reasons.remove(reason);
      if (entry.reasons.isEmpty) {
        try {
          await File(entry.path).delete();
        } catch (_) {}
        _entries.remove(entry.key);
        await _deleteSidecars(entry);
      }
      changed = true;
    }
    if (changed) {
      await _persistManifest();
      notifyListeners();
    }
  }

  /// Marks/unmarks [playlist] as offline. When turning it on: downloads
  /// every current song and remembers the song-id snapshot so future
  /// [syncOfflinePlaylists] calls know what's new. When turning it off:
  /// drops this playlist's reason from every song it had downloaded
  /// (actually deleting only the ones not also kept for another reason).
  Future<void> setPlaylistOffline(
    bool value,
    Playlist playlist,
    List<Song> songs,
    SubsonicApi api,
  ) async {
    final reason = playlistDownloadReason(playlist.id);
    if (value) {
      offlinePlaylistIds.add(playlist.id);
      _offlinePlaylistSnapshot[_scopedPlaylistKey(playlist.id)] =
          downloadedPlaylistSongIds(songs, entries, reason);
      await _persistOfflinePlaylists();
      notifyListeners();
      await downloadSongs(songs, api, reason, label: playlist.name);
      _offlinePlaylistSnapshot[_scopedPlaylistKey(playlist.id)] =
          downloadedPlaylistSongIds(songs, entries, reason);
      await _persistOfflinePlaylists();
    } else {
      offlinePlaylistIds.remove(playlist.id);
      final ids =
          _offlinePlaylistSnapshot.remove(_scopedPlaylistKey(playlist.id)) ??
          songs.map((s) => s.id).toSet();
      await _persistOfflinePlaylists();
      await removeReasonFromAll(ids, reason);
      await waitForPendingDownloads;
      await removeReasonFromAll(ids, reason);
    }
  }

  /// Called after every playlist-content refresh: for each playlist marked
  /// offline, downloads songs newly added to it and drops the local copy of
  /// songs removed from it (per [diffPlaylistSongs]).
  Future<void> syncOfflinePlaylists(
    Map<String, List<Song>> playlistSongs,
    SubsonicApi api,
  ) async {
    for (final playlistId in offlinePlaylistIds) {
      final current = playlistSongs[playlistId];
      if (current == null) continue;
      final reason = playlistDownloadReason(playlistId);
      final currentIds = current.map((s) => s.id).toSet();
      final previousIds =
          _offlinePlaylistSnapshot[_scopedPlaylistKey(playlistId)] ??
          const <String>{};
      final diff = diffPlaylistSongs(previousIds, currentIds);
      final byId = {for (final s in current) s.id: s};
      for (final id in diff.added) {
        final song = byId[id];
        if (song != null) {
          await downloadSong(song, api, reason, background: true);
        }
      }
      await removeReasonFromAll(diff.removed, reason);
      _offlinePlaylistSnapshot[_scopedPlaylistKey(playlistId)] =
          downloadedPlaylistSongIds(current, entries, reason);
    }
    await _persistOfflinePlaylists();
  }

  /// Keeps every currently-starred song downloaded (reason 'favorites'),
  /// dropping the reason from ones that got unstarred. No-op when
  /// [favoritesOfflineEnabled] is off.
  Future<void> syncFavorites(List<Song> starred, SubsonicApi api) async {
    if (!favoritesOfflineEnabled) return;
    final currentIds = starred.map((s) => s.id).toSet();
    for (final entry in List.of(entries.values)) {
      if (entry.reasons.contains(favoritesDownloadReason) &&
          !currentIds.contains(entry.songId)) {
        await removeReason(entry.songId, favoritesDownloadReason);
      }
    }
    for (final s in starred) {
      await downloadSong(s, api, favoritesDownloadReason, background: true);
    }
  }

  /// Deletes every downloaded file and turns off all offline-sync sources
  /// (playlists + Favorites) — otherwise the very next sync would just
  /// re-download everything, defeating the point of "free up space".
  Future<void> clearAllDownloads() async {
    for (final entry in _entries.values) {
      try {
        await File(entry.path).delete();
      } catch (_) {}
    }
    for (final entry in List.of(_entries.values)) {
      await _deleteSidecars(entry);
    }
    _entries.clear();
    _offlinePlaylistIdsByAccount.clear();
    _offlinePlaylistSnapshot.clear();
    favoritesOfflineEnabled = false;
    await _persistManifest();
    await _persistOfflinePlaylists();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_favoritesOfflineKey, false);
    notifyListeners();
  }

  String _scopedPlaylistKey(String playlistId) =>
      downloadEntryKey(accountScope, playlistId);
}
