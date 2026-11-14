import 'song_filter.dart';

class SavedSongFilter {
  const SavedSongFilter({
    required this.id,
    required this.name,
    required this.filter,
    required this.createdAt,
  });

  final String id;
  final String name;
  final SongFilter filter;
  final DateTime createdAt;
}

abstract interface class SongFilterPresetStore {
  Future<List<SavedSongFilter>> load();
  Future<void> save(List<SavedSongFilter> presets);
}
