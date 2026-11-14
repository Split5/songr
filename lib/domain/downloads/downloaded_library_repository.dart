import '../../models/models.dart';

abstract interface class DownloadedLibraryRepository {
  Future<List<Song>> songsForIds(Iterable<String> songIds);
}
