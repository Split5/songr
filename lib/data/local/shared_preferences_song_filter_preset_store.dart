import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/library/song_filter.dart';
import '../../domain/library/song_filter_preset_store.dart';

class SharedPreferencesSongFilterPresetStore implements SongFilterPresetStore {
  SharedPreferencesSongFilterPresetStore({required String scope})
    : _key = 'v2_song_filter_presets_${_stableKey(scope)}';

  final String _key;

  @override
  Future<List<SavedSongFilter>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getStringList(_key) ?? const [];
    final result = <SavedSongFilter>[];
    for (final value in encoded) {
      try {
        final json = jsonDecode(value) as Map<String, dynamic>;
        final id = json['id'] as String?;
        final name = json['name'] as String?;
        final filter = json['filter'] as Map<String, dynamic>?;
        final createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '');
        if (id == null || name == null || filter == null || createdAt == null) {
          continue;
        }
        result.add(
          SavedSongFilter(
            id: id,
            name: name,
            filter: SongFilter.fromJson(filter),
            createdAt: createdAt,
          ),
        );
      } catch (_) {}
    }
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(result);
  }

  @override
  Future<void> save(List<SavedSongFilter> presets) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_key, [
      for (final preset in presets)
        jsonEncode({
          'id': preset.id,
          'name': preset.name,
          'createdAt': preset.createdAt.toIso8601String(),
          'filter': preset.filter.toJson(),
        }),
    ]);
  }

  static String _stableKey(String value) =>
      base64Url.encode(utf8.encode(value)).replaceAll('=', '');
}
