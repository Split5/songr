import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/library/catalog_repository.dart';
import '../../models/models.dart';

typedef CatalogCountLoader = Future<int> Function(String query);
typedef CatalogPageLoader<T> =
    Future<List<T>> Function(String query, int limit, int offset);
typedef CatalogSortedPageLoader<T> =
    Future<List<T>> Function(
      String query,
      int limit,
      int offset,
      String sort,
      int randomSeed,
    );

@immutable
class PagedCatalogState<T> {
  const PagedCatalogState({
    this.items = const [],
    this.totalCount = 0,
    this.query = '',
    this.sort = 'default',
    this.randomSeed = 0,
    this.loading = false,
    this.loadingMore = false,
    this.error,
  });

  final List<T> items;
  final int totalCount;
  final String query;
  final String sort;
  final int randomSeed;
  final bool loading;
  final bool loadingMore;
  final Object? error;

  bool get hasMore => items.length < totalCount;
}

class PagedCatalogController<T> extends ChangeNotifier {
  PagedCatalogController({
    required this.countLoader,
    required this.pageLoader,
    this.sortedPageLoader,
    this.initialSort = 'default',
    this.pageSize = 60,
    this.searchDebounce = const Duration(milliseconds: 250),
  });

  final CatalogCountLoader countLoader;
  final CatalogPageLoader<T> pageLoader;
  final CatalogSortedPageLoader<T>? sortedPageLoader;
  final String initialSort;
  final int pageSize;
  final Duration searchDebounce;
  late PagedCatalogState<T> _state = PagedCatalogState(sort: initialSort);
  int _randomSeed = 0;
  int _generation = 0;
  Timer? _searchTimer;

  PagedCatalogState<T> get state => _state;

  Future<void> initialize() async {
    if (_state.loading || _state.items.isNotEmpty) return;
    await refresh();
  }

  void setQuery(String query) {
    _searchTimer?.cancel();
    _searchTimer = Timer(searchDebounce, () => refresh(query: query));
  }

  Future<void> refresh({String? query}) async {
    final normalized = (query ?? _state.query).trim();
    final generation = ++_generation;
    _state = PagedCatalogState<T>(
      items: _state.items,
      totalCount: _state.totalCount,
      query: normalized,
      sort: _state.sort,
      randomSeed: _state.randomSeed,
      loading: true,
    );
    notifyListeners();
    try {
      final results = await Future.wait([
        countLoader(normalized),
        _loadPage(normalized, pageSize, 0),
      ]);
      if (generation != _generation) return;
      _state = PagedCatalogState<T>(
        items: List.unmodifiable(results[1] as List<T>),
        totalCount: results[0] as int,
        query: normalized,
        sort: _state.sort,
        randomSeed: _state.randomSeed,
      );
    } catch (error) {
      if (generation != _generation) return;
      _state = PagedCatalogState<T>(
        items: _state.items,
        totalCount: _state.totalCount,
        query: normalized,
        sort: _state.sort,
        randomSeed: _state.randomSeed,
        error: error,
      );
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_state.loading || _state.loadingMore || !_state.hasMore) return;
    final generation = _generation;
    _state = PagedCatalogState<T>(
      items: _state.items,
      totalCount: _state.totalCount,
      query: _state.query,
      sort: _state.sort,
      randomSeed: _state.randomSeed,
      loadingMore: true,
    );
    notifyListeners();
    try {
      final page = await _loadPage(_state.query, pageSize, _state.items.length);
      if (generation != _generation) return;
      _state = PagedCatalogState<T>(
        items: List.unmodifiable([..._state.items, ...page]),
        totalCount: _state.totalCount,
        query: _state.query,
        sort: _state.sort,
        randomSeed: _state.randomSeed,
      );
    } catch (error) {
      if (generation != _generation) return;
      _state = PagedCatalogState<T>(
        items: _state.items,
        totalCount: _state.totalCount,
        query: _state.query,
        sort: _state.sort,
        randomSeed: _state.randomSeed,
        error: error,
      );
    }
    notifyListeners();
  }

  Future<void> setSort(String value, {bool randomize = false}) async {
    if (sortedPageLoader == null) return;
    if (randomize) _randomSeed++;
    _state = PagedCatalogState<T>(
      items: _state.items,
      totalCount: _state.totalCount,
      query: _state.query,
      sort: value,
      randomSeed: _randomSeed,
    );
    await refresh();
  }

  Future<List<T>> _loadPage(String query, int limit, int offset) {
    final sortedLoader = sortedPageLoader;
    return sortedLoader == null
        ? pageLoader(query, limit, offset)
        : sortedLoader(query, limit, offset, _state.sort, _state.randomSeed);
  }

  @override
  void dispose() {
    _generation++;
    _searchTimer?.cancel();
    super.dispose();
  }
}

@immutable
class LibraryOverviewState {
  const LibraryOverviewState({
    this.artistCount = 0,
    this.albumCount = 0,
    this.playlists = const [],
    this.genres = const [],
    this.recentlyAddedAlbums = const [],
    this.loading = false,
    this.error,
  });

  final int artistCount;
  final int albumCount;
  final List<Playlist> playlists;
  final List<String> genres;
  final List<Album> recentlyAddedAlbums;
  final bool loading;
  final Object? error;
}

class LibraryOverviewController extends ChangeNotifier {
  LibraryOverviewController(this.repository);

  final CatalogRepository repository;
  LibraryOverviewState _state = const LibraryOverviewState();
  int _generation = 0;

  LibraryOverviewState get state => _state;

  void removePlaylist(String playlistId) {
    final playlists = _state.playlists
        .where((playlist) => playlist.id != playlistId)
        .toList(growable: false);
    if (playlists.length == _state.playlists.length) return;
    _state = LibraryOverviewState(
      artistCount: _state.artistCount,
      albumCount: _state.albumCount,
      playlists: List.unmodifiable(playlists),
      genres: _state.genres,
      recentlyAddedAlbums: _state.recentlyAddedAlbums,
      loading: _state.loading,
      error: _state.error,
    );
    notifyListeners();
  }

  Future<void> initialize() async {
    if (_state.loading || _state.artistCount > 0 || _state.albumCount > 0) {
      return;
    }
    await refresh();
  }

  Future<void> refresh() async {
    final generation = ++_generation;
    _state = LibraryOverviewState(
      artistCount: _state.artistCount,
      albumCount: _state.albumCount,
      playlists: _state.playlists,
      genres: _state.genres,
      recentlyAddedAlbums: _state.recentlyAddedAlbums,
      loading: true,
    );
    notifyListeners();
    try {
      final results = await Future.wait([
        repository.artistCount(),
        repository.albumCount(),
        repository.ownPlaylists(),
        repository.genres(limit: 6),
        repository.albumsPage(limit: 12, newestFirst: true),
      ]);
      if (generation != _generation) return;
      _state = LibraryOverviewState(
        artistCount: results[0] as int,
        albumCount: results[1] as int,
        playlists: List.unmodifiable(results[2] as List<Playlist>),
        genres: List.unmodifiable(results[3] as List<String>),
        recentlyAddedAlbums: List.unmodifiable(results[4] as List<Album>),
      );
    } catch (error) {
      if (generation != _generation) return;
      _state = LibraryOverviewState(
        artistCount: _state.artistCount,
        albumCount: _state.albumCount,
        playlists: _state.playlists,
        genres: _state.genres,
        recentlyAddedAlbums: _state.recentlyAddedAlbums,
        error: error,
      );
    }
    notifyListeners();
  }
}

class SongCollectionController extends ChangeNotifier {
  SongCollectionController(this.loader);

  final Future<List<Song>> Function() loader;
  List<Song> songs = const [];
  bool loading = false;
  Object? error;

  Future<void> initialize() async {
    if (loading || songs.isNotEmpty) return;
    await refresh();
  }

  Future<void> refresh() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      songs = List.unmodifiable(await loader());
    } catch (caught) {
      error = caught;
    }
    loading = false;
    notifyListeners();
  }

  void appendSong(Song song) {
    if (songs.any((item) => item.id == song.id)) return;
    songs = List.unmodifiable([...songs, song]);
    notifyListeners();
  }
}
