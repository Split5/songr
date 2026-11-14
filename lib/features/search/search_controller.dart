import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/library/catalog_repository.dart';
import '../../domain/library/song_filter.dart';
import '../../domain/library/song_library_repository.dart';
import '../../models/models.dart';

enum SearchCategory { all, songs, albums, artists, playlists }

/// Lower scores are stronger matches. Kept outside the controller so the UI
/// can order whole result sections by the same rules used within each section.
int searchMatchScore(String primary, String secondary, String query) {
  final main = primary.toLowerCase();
  final detail = secondary.toLowerCase();
  if (main == query) return 0;
  if (main.startsWith(query)) return 1;
  if (_searchWordStartsWith(main, query)) return 2;
  if (detail == query) return 3;
  if (detail.startsWith(query) || _searchWordStartsWith(detail, query)) {
    return 4;
  }
  if (main.contains(query)) return 5;
  if (detail.contains(query)) return 6;
  return 7;
}

bool _searchWordStartsWith(String value, String query) =>
    value.split(RegExp(r'[^a-z0-9åäö]+')).any((word) => word.startsWith(query));

@immutable
class SearchViewState {
  const SearchViewState({
    this.query = '',
    this.category = SearchCategory.all,
    this.genres = const [],
    this.songs = const [],
    this.albums = const [],
    this.artists = const [],
    this.playlists = const [],
    this.loading = false,
    this.error,
  });

  final String query;
  final SearchCategory category;
  final List<String> genres;
  final List<Song> songs;
  final List<Album> albums;
  final List<ArtistSummary> artists;
  final List<Playlist> playlists;
  final bool loading;
  final Object? error;
}

class V2SearchController extends ChangeNotifier {
  V2SearchController({
    required this.catalog,
    required this.songLibrary,
    this.debounce = const Duration(milliseconds: 160),
  });

  final CatalogRepository catalog;
  final SongLibraryRepository songLibrary;
  final Duration debounce;
  SearchViewState _state = const SearchViewState();
  Timer? _timer;
  int _generation = 0;

  SearchViewState get state => _state;

  Future<void> initialize() async {
    if (_state.genres.isNotEmpty || _state.loading) return;
    await _loadGenres();
  }

  void setQuery(String query) {
    _timer?.cancel();
    final normalized = query.trim();
    if (normalized.isEmpty) {
      unawaited(_search(''));
      return;
    }
    _timer = Timer(debounce, () => _search(normalized));
  }

  void setCategory(SearchCategory category) {
    if (_state.category == category) return;
    _state = SearchViewState(
      query: _state.query,
      category: category,
      genres: _state.genres,
      songs: _state.songs,
      albums: _state.albums,
      artists: _state.artists,
      playlists: _state.playlists,
      error: _state.error,
    );
    notifyListeners();
  }

  Future<void> selectGenre(String genre) => _search(genre);

  Future<void> _loadGenres() async {
    _state = SearchViewState(
      category: _state.category,
      loading: true,
      genres: _state.genres,
    );
    notifyListeners();
    try {
      final genres = await catalog.genres();
      _state = SearchViewState(
        category: _state.category,
        genres: List.unmodifiable(genres),
      );
    } catch (error) {
      _state = SearchViewState(category: _state.category, error: error);
    }
    notifyListeners();
  }

  Future<void> _search(String query) async {
    final generation = ++_generation;
    if (query.isEmpty) {
      _state = SearchViewState(
        category: _state.category,
        genres: _state.genres,
      );
      notifyListeners();
      return;
    }
    _state = SearchViewState(
      query: query,
      category: _state.category,
      genres: _state.genres,
      loading: true,
    );
    notifyListeners();
    try {
      final results = await Future.wait([
        songLibrary.page(
          filter: SongFilter(query: query),
          limit: 60,
          offset: 0,
        ),
        catalog.albumsPage(query: query, limit: 60),
        catalog.artistsPage(query: query, limit: 60),
        catalog.ownPlaylists(),
      ]);
      if (generation != _generation) return;
      final normalized = query.toLowerCase();
      final matchingPlaylists = (results[3] as List<Playlist>).where(
        (playlist) => playlist.name.toLowerCase().contains(normalized),
      );
      _state = SearchViewState(
        query: query,
        category: _state.category,
        genres: _state.genres,
        songs: _rank(
          results[0] as List<Song>,
          query: normalized,
          primary: (song) => song.title,
          secondary: (song) => '${song.artist} ${song.album}',
          popularity: (song) => song.playCount,
        ),
        albums: _rank(
          results[1] as List<Album>,
          query: normalized,
          primary: (album) => album.name,
          secondary: (album) => album.artist,
          popularity: (album) => album.playCount,
        ),
        artists: _rank(
          results[2] as List<ArtistSummary>,
          query: normalized,
          primary: (artist) => artist.name,
          popularity: (artist) => artist.albumCount,
        ),
        playlists: _rank(
          matchingPlaylists,
          query: normalized,
          primary: (playlist) => playlist.name,
          popularity: (playlist) => playlist.songCount,
        ),
      );
    } catch (error) {
      if (generation != _generation) return;
      _state = SearchViewState(
        query: query,
        category: _state.category,
        genres: _state.genres,
        error: error,
      );
    }
    notifyListeners();
  }

  List<T> _rank<T>(
    Iterable<T> source, {
    required String query,
    required String Function(T item) primary,
    String Function(T item)? secondary,
    int Function(T item)? popularity,
  }) {
    final ranked = [
      for (final item in source)
        (
          item: item,
          score: searchMatchScore(
            primary(item),
            secondary?.call(item) ?? '',
            query,
          ),
          popularity: popularity?.call(item) ?? 0,
          label: primary(item).toLowerCase(),
        ),
    ];
    ranked.sort((a, b) {
      final score = a.score.compareTo(b.score);
      if (score != 0) return score;
      final popularity = b.popularity.compareTo(a.popularity);
      if (popularity != 0) return popularity;
      return a.label.compareTo(b.label);
    });
    return List.unmodifiable(ranked.map((entry) => entry.item));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
