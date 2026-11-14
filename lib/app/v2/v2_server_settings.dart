import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/subsonic_api.dart';

class V2ServerSettings extends ChangeNotifier {
  static const _urlKey = 'server_url';
  static const _userKey = 'server_user';
  static const _passwordKey = 'server_pass';

  /// Keys used by the removed direct AudioMuse connection. The client now only
  /// talks to Navidrome (the AudioMuse plugin answers `getSimilarSongs2`), so
  /// any value still stored under these keys is deleted on load to make sure
  /// no bearer token lingers on the device.
  static const legacyAudioMuseUrlKey = 'audiomuse_url';
  static const legacyAudioMuseTokenKey = 'audiomuse_token';
  static const _secure = FlutterSecureStorage();

  String url = '';
  String username = '';
  String password = '';
  bool loaded = false;
  SubsonicApi? _api;

  bool get isConfigured =>
      url.isNotEmpty && username.isNotEmpty && password.isNotEmpty;
  SubsonicApi? get api => _api;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    url = preferences.getString(_urlKey) ?? '';
    username = preferences.getString(_userKey) ?? '';
    password = await _readSecret(preferences, _passwordKey);
    await _purgeLegacyAudioMuseValues(preferences);
    if (isConfigured) _rebuildApi();
    loaded = true;
    notifyListeners();
  }

  /// Removes everything the old direct AudioMuse integration persisted, in
  /// both SharedPreferences and the secure keychain store.
  Future<void> _purgeLegacyAudioMuseValues(
    SharedPreferences preferences,
  ) async {
    for (final key in const [legacyAudioMuseUrlKey, legacyAudioMuseTokenKey]) {
      if (preferences.containsKey(key)) await preferences.remove(key);
      try {
        await _secure.delete(key: key);
      } catch (_) {
        // Secure storage may be unavailable (locked keyring, tests); the
        // SharedPreferences copy is already gone in that case.
      }
    }
  }

  Future<String> _readSecret(SharedPreferences preferences, String key) async {
    try {
      final secure = await _secure.read(key: key);
      if (secure != null) return secure;
    } catch (_) {}
    final legacy = preferences.getString(key) ?? '';
    if (legacy.isNotEmpty) {
      try {
        await _secure.write(key: key, value: legacy);
        await preferences.remove(key);
      } catch (_) {}
    }
    return legacy;
  }

  Future<void> saveAndVerify({
    required String url,
    required String username,
    required String password,
  }) async {
    final candidate = SubsonicApi(
      baseUrl: url,
      username: username,
      password: password,
    );
    await candidate.ping();
    try {
      await _secure.write(key: _passwordKey, value: password);
    } catch (_) {
      candidate.dispose();
      rethrow;
    }
    _api?.dispose();
    _api = candidate;
    this.url = candidate.baseUrl;
    this.username = username.trim();
    this.password = password;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_urlKey, this.url);
    await preferences.setString(_userKey, this.username);
    await preferences.remove(_passwordKey);
    notifyListeners();
  }

  void _rebuildApi() {
    _api?.dispose();
    _api = SubsonicApi(baseUrl: url, username: username, password: password);
  }

  @override
  void dispose() {
    _api?.dispose();
    super.dispose();
  }
}
