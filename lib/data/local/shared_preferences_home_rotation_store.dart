import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/home/home_repository.dart';

class SharedPreferencesHomeRotationStore implements HomeRotationStore {
  SharedPreferencesHomeRotationStore({required String scope})
    : _prefix = 'v2_home_rotation_${_stableKey(scope)}';

  final String _prefix;

  String get _songsKey => '${_prefix}_songs';
  String get _albumsKey => '${_prefix}_albums';

  @override
  Future<HomeRotationSelection?> read() async {
    final preferences = await SharedPreferences.getInstance();
    final songs = preferences.getStringList(_songsKey);
    final albums = preferences.getStringList(_albumsKey);
    if (songs == null && albums == null) return null;
    return HomeRotationSelection(
      songIds: List.unmodifiable(songs ?? const []),
      albumIds: List.unmodifiable(albums ?? const []),
    );
  }

  @override
  Future<void> write(HomeRotationSelection selection) async {
    final preferences = await SharedPreferences.getInstance();
    await Future.wait([
      preferences.setStringList(_songsKey, selection.songIds),
      preferences.setStringList(_albumsKey, selection.albumIds),
    ]);
  }

  static String _stableKey(String value) =>
      base64Url.encode(utf8.encode(value)).replaceAll('=', '');
}
