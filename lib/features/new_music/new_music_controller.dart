import 'package:flutter/foundation.dart';

import '../../domain/library/catalog_repository.dart';
import '../../domain/library/song_filter.dart';
import '../../domain/library/song_library_repository.dart';
import '../../models/models.dart';

@immutable
class NewMusicState {
  const NewMusicState({
    this.albums = const [],
    this.songs = const [],
    this.loading = false,
    this.error,
  });

  final List<Album> albums;
  final List<Song> songs;
  final bool loading;
  final Object? error;
}

class NewMusicController extends ChangeNotifier {
  NewMusicController({required this.catalog, required this.songs});

  final CatalogRepository catalog;
  final SongLibraryRepository songs;
  NewMusicState _state = const NewMusicState();
  int _generation = 0;

  NewMusicState get state => _state;

  Future<void> initialize() async {
    if (_state.loading || _state.albums.isNotEmpty || _state.songs.isNotEmpty) {
      return;
    }
    await refresh();
  }

  Future<void> refresh() async {
    final generation = ++_generation;
    _state = NewMusicState(
      albums: _state.albums,
      songs: _state.songs,
      loading: true,
    );
    notifyListeners();
    try {
      final results = await Future.wait([
        catalog.albumsPage(limit: 30, newestFirst: true),
        songs.page(
          filter: const SongFilter(sort: SongSort.newest),
          limit: 80,
          offset: 0,
        ),
      ]);
      if (generation != _generation) return;
      final newestSongs = results[1] as List<Song>;
      final catalogAlbums = results[0] as List<Album>;
      final songAlbums = _albumsFromSongs(newestSongs);
      // The song library is the same source of truth as the "recently added
      // songs" list, so the album shelf matches it exactly (and Navidrome's
      // recently added ordering) even when the separately synced album
      // catalogue is missing or stale entries. The catalogue is only a
      // fallback for a fresh install where the song sync has not run yet.
      final albums = songAlbums.isNotEmpty ? songAlbums : catalogAlbums;
      _state = NewMusicState(
        albums: List.unmodifiable(albums),
        songs: List.unmodifiable(newestSongs),
      );
    } catch (error) {
      if (generation != _generation) return;
      _state = NewMusicState(
        albums: _state.albums,
        songs: _state.songs,
        error: error,
      );
    }
    notifyListeners();
  }

  /// Groups the newest songs into albums. Every album built this way contains
  /// at least the songs visible on the same screen, and the newest song's
  /// `created` timestamp determines the album's position, matching
  /// Navidrome's newest-album ordering.
  List<Album> _albumsFromSongs(List<Song> songs) {
    final groups = <String, List<Song>>{};
    final order = <String>[];
    for (final song in songs) {
      final key = song.albumId.isNotEmpty
          ? 'id:${song.albumId}'
          : 'name:${song.album.trim().toLowerCase()}'
                '\u0000${primaryArtistName(song.artist).toLowerCase()}';
      final bucket = groups.putIfAbsent(key, () {
        order.add(key);
        return <Song>[];
      });
      bucket.add(song);
    }

    final albums = <Album>[];
    for (final key in order) {
      final bucket = groups[key]!;
      final first = bucket.first;
      Album album = Album(
        id: first.albumId,
        name: first.album,
        artist: primaryArtistName(first.artist),
        artistId: first.artistId,
        coverArt: first.coverArt,
        songCount: bucket.length,
        duration: bucket.fold(0, (sum, song) => sum + song.duration),
        playCount: bucket.fold(0, (sum, song) => sum + song.playCount),
        year: bucket
            .map((song) => song.year)
            .where((year) => year > 0)
            .fold(0, (a, b) => a > b ? a : b),
        created: bucket
            .map((song) => song.created)
            .whereType<DateTime>()
            .fold<DateTime?>(null, (a, b) => a == null || b.isAfter(a) ? b : a),
        starred: bucket.any((song) => song.starred),
      );
      // Prefer a non-empty id from any song in the album; Navidrome albums
      // normally carry the same albumId on every song, but tolerate gaps.
      if (album.id.isEmpty) {
        var nonEmptyId = '';
        for (final song in bucket) {
          if (song.albumId.isNotEmpty) {
            nonEmptyId = song.albumId;
            break;
          }
        }
        album = Album(
          id: nonEmptyId,
          name: album.name,
          artist: album.artist,
          artistId: album.artistId,
          coverArt: album.coverArt,
          songCount: album.songCount,
          duration: album.duration,
          playCount: album.playCount,
          year: album.year,
          created: album.created,
          starred: album.starred,
        );
      }
      albums.add(album);
    }
    albums.sort((a, b) {
      final aCreated = a.created ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bCreated = b.created ?? DateTime.fromMillisecondsSinceEpoch(0);
      final byDate = bCreated.compareTo(aCreated);
      return byDate != 0
          ? byDate
          : a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return albums;
  }
}
