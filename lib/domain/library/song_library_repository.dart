import '../../models/models.dart';
import 'song_filter.dart';

abstract interface class SongLibraryRepository {
  Future<int> count(SongFilter filter);

  Future<List<Song>> page({
    required SongFilter filter,
    required int limit,
    required int offset,
  });
}
