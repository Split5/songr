import '../../models/models.dart';

class HomeSnapshot {
  const HomeSnapshot({
    this.recentlyPlayedSongs = const [],
    this.recentlyAddedSongs = const [],
    this.mostPlayedSongs = const [],
    this.librarySongRotation = const [],
    this.recentlyPlayedAlbums = const [],
    this.recentlyAddedAlbums = const [],
    this.mostPlayedAlbums = const [],
    this.libraryRotation = const [],
    this.recentlyPlayedPlaylists = const [],
  });

  final List<Song> recentlyPlayedSongs;
  final List<Song> recentlyAddedSongs;
  final List<Song> mostPlayedSongs;
  final List<Song> librarySongRotation;
  final List<Album> recentlyPlayedAlbums;
  final List<Album> recentlyAddedAlbums;
  final List<Album> mostPlayedAlbums;
  final List<Album> libraryRotation;
  final List<Playlist> recentlyPlayedPlaylists;
}

class HomeRotationSelection {
  const HomeRotationSelection({
    this.songIds = const [],
    this.albumIds = const [],
  });

  final List<String> songIds;
  final List<String> albumIds;

  bool get isEmpty => songIds.isEmpty && albumIds.isEmpty;
}

/// Persists the discovery shelf independently from normal catalogue refreshes.
/// The implementation is scoped to one server/user so reconnecting to another
/// library can never reuse unrelated ids.
abstract interface class HomeRotationStore {
  Future<HomeRotationSelection?> read();
  Future<void> write(HomeRotationSelection selection);
}

abstract interface class HomeRepository {
  Future<HomeSnapshot> load({bool refreshLibraryRotation = false});
}
