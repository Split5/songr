import 'package:flutter/foundation.dart';

import '../../api/subsonic_api.dart';
import '../../models/models.dart';

enum ServerCapabilityState { unknown, checking, available, unavailable }

/// Discovers optional Navidrome features through the normal Subsonic client.
/// The app never talks to plugin services directly.
class V2ServerCapabilities extends ChangeNotifier {
  V2ServerCapabilities({
    required this.serverUrl,
    required this.sampleSongs,
    required this.loadSimilarSongs,
    required this.loadLyrics,
  });

  final String serverUrl;
  final Future<List<Song>> Function(int limit) sampleSongs;
  final Future<List<Song>> Function(String songId) loadSimilarSongs;
  final Future<String?> Function(String songId) loadLyrics;

  ServerCapabilityState smartMixes = ServerCapabilityState.unknown;
  ServerCapabilityState lyrics = ServerCapabilityState.unknown;
  DateTime? lastChecked;
  Future<void>? _probeInFlight;
  bool _disposed = false;

  Uri? get uri => Uri.tryParse(serverUrl);
  bool get isLocalServer {
    final host = uri?.host;
    return host != null && SubsonicApi.isPrivateHost(host);
  }

  bool get isHttps => uri?.scheme == 'https';
  bool get smartMixesDisabled =>
      smartMixes == ServerCapabilityState.unavailable;
  bool get lyricsDisabled => lyrics == ServerCapabilityState.unavailable;
  bool get isChecking =>
      smartMixes == ServerCapabilityState.checking ||
      lyrics == ServerCapabilityState.checking;

  /// Checks the server's optional features.
  ///
  /// [checkLyrics] is off by default on purpose: probing lyrics downloads
  /// them for sample songs, and nothing about the lyrics may load before the
  /// listener opens the lyrics view. The server setup screen asks for it
  /// explicitly because it is the only place that reports lyrics support.
  Future<void> refresh({bool checkLyrics = false}) {
    return _probeInFlight ??= _probe(checkLyrics: checkLyrics).whenComplete(() {
      _probeInFlight = null;
    });
  }

  Future<void> _probe({required bool checkLyrics}) async {
    if (_disposed) return;
    smartMixes = ServerCapabilityState.checking;
    if (checkLyrics) lyrics = ServerCapabilityState.checking;
    _notify();

    List<Song> samples;
    try {
      samples = await sampleSongs(3);
    } catch (_) {
      samples = const [];
    }

    final similarChecks = Future.wait(samples.map(_hasSimilarSongs));
    final lyricChecks = checkLyrics
        ? Future.wait(samples.map(_hasLyrics))
        : null;
    final similarResults = await similarChecks;
    final lyricResults = await lyricChecks;

    if (_disposed) return;
    smartMixes = _stateFrom(similarResults);
    if (lyricResults != null) lyrics = _stateFrom(lyricResults);
    lastChecked = DateTime.now();
    _notify();
  }

  Future<bool?> _hasSimilarSongs(Song song) async {
    try {
      return (await loadSimilarSongs(song.id)).isNotEmpty;
    } catch (_) {
      return null;
    }
  }

  Future<bool?> _hasLyrics(Song song) async {
    try {
      return (await loadLyrics(song.id))?.isNotEmpty == true;
    } catch (_) {
      return null;
    }
  }

  ServerCapabilityState _stateFrom(List<bool?> results) {
    if (results.contains(true)) return ServerCapabilityState.available;
    if (results.isNotEmpty && results.every((result) => result == null)) {
      // A failed network probe is not proof that an optional plugin is absent.
      return ServerCapabilityState.unknown;
    }
    // An empty answer isn't proof that the optional server feature is missing.
    return ServerCapabilityState.unknown;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
