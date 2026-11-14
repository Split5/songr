import '../../models/models.dart';

enum AlbumSort {
  title,
  artist,
  recentlyAdded,
  recentlyPlayed,
  mostPlayed,
  random,
}

enum ArtistSort { name, albumCount, random }

abstract interface class CatalogRepository {
  Future<int> artistCount({String query = ''});
  Future<List<ArtistSummary>> artistsPage({
    String query = '',
    int limit = 60,
    int offset = 0,
    ArtistSort sort = ArtistSort.name,
    int randomSeed = 0,
  });

  Future<int> albumCount({String query = ''});
  Future<List<Album>> albumsPage({
    String query = '',
    int limit = 60,
    int offset = 0,
    bool newestFirst = false,
    AlbumSort sort = AlbumSort.title,
    int randomSeed = 0,
  });

  Future<List<Playlist>> ownPlaylists();
  Future<List<String>> genres({int limit = 24});
  Future<List<Song>> songsForAlbum(Album album);
  Future<List<Song>> songsForArtist(ArtistSummary artist);
  Future<List<Album>> albumsForArtist(ArtistSummary artist);
  Future<List<Song>> songsForPlaylist(String playlistId);
}
