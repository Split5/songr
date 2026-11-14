import '../../domain/downloads/downloaded_library_repository.dart';
import '../../models/models.dart';
import 'app_database.dart';

class DriftDownloadedLibraryRepository implements DownloadedLibraryRepository {
  const DriftDownloadedLibraryRepository(this.database);

  final AppDatabase database;

  @override
  Future<List<Song>> songsForIds(Iterable<String> songIds) async {
    final ids = songIds.toSet();
    if (ids.isEmpty) return const [];
    final songs = <LocalSong>[];
    final values = ids.toList(growable: false);
    for (var offset = 0; offset < values.length; offset += 400) {
      final chunk = values.skip(offset).take(400).toList(growable: false);
      songs.addAll(
        await (database.select(
          database.localSongs,
        )..where((row) => row.id.isIn(chunk))).get(),
      );
    }
    songs.sort(
      (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    );
    return songs.map(_mapSong).toList(growable: false);
  }

  Song _mapSong(LocalSong song) => Song(
    id: song.id,
    title: song.title,
    artist: song.artist,
    artistId: song.artistId ?? '',
    album: song.album,
    albumId: song.albumId ?? '',
    coverArt: song.coverArt,
    duration: song.duration,
    playCount: song.playCount,
    year: song.year,
    bitRate: song.bitRate ?? 0,
    bitDepth: song.bitDepth ?? 0,
    samplingRate: song.samplingRate ?? 0,
    fileSize: song.fileSize ?? 0,
    track: song.track,
    disc: song.disc,
    suffix: song.suffix ?? '',
    contentType: song.contentType,
    created: song.createdAt,
    lastPlayed: song.lastPlayedAt,
    genre: song.genre,
    starred: song.starred,
    starredAt: song.starredAt,
  );
}
