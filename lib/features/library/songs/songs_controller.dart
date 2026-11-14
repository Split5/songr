import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../domain/library/song_filter.dart';
import '../../../domain/library/song_filter_preset_store.dart';
import '../../../domain/library/song_library_repository.dart';
import '../../../models/models.dart';

class SongsViewState {
  const SongsViewState({
    required this.filter,
    this.songs = const [],
    this.totalCount = 0,
    this.initialLoading = false,
    this.loadingMore = false,
    this.hasMore = false,
    this.error,
  });

  final SongFilter filter;
  final List<Song> songs;
  final int totalCount;
  final bool initialLoading;
  final bool loadingMore;
  final bool hasMore;
  final Object? error;

  SongsViewState copyWith({
    SongFilter? filter,
    List<Song>? songs,
    int? totalCount,
    bool? initialLoading,
    bool? loadingMore,
    bool? hasMore,
    Object? error,
    bool clearError = false,
  }) => SongsViewState(
    filter: filter ?? this.filter,
    songs: songs ?? this.songs,
    totalCount: totalCount ?? this.totalCount,
    initialLoading: initialLoading ?? this.initialLoading,
    loadingMore: loadingMore ?? this.loadingMore,
    hasMore: hasMore ?? this.hasMore,
    error: clearError ? null : error ?? this.error,
  );
}

class SongsController extends ChangeNotifier {
  SongsController({
    required this.repository,
    this.presetStore,
    this.pageSize = 60,
    this.searchDebounce = const Duration(milliseconds: 250),
    SongFilter initialFilter = const SongFilter(),
  }) : assert(pageSize > 0 && pageSize <= 500),
       _state = SongsViewState(filter: initialFilter.normalized());

  final SongLibraryRepository repository;
  final SongFilterPresetStore? presetStore;
  final int pageSize;
  final Duration searchDebounce;

  SongsViewState _state;
  SongsViewState get state => _state;
  UnmodifiableListView<Song> get songs => UnmodifiableListView(_state.songs);
  List<SavedSongFilter> _savedFilters = const [];
  UnmodifiableListView<SavedSongFilter> get savedFilters =>
      UnmodifiableListView(_savedFilters);

  Timer? _searchTimer;
  int _requestGeneration = 0;
  bool _disposed = false;
  SongsViewState? _cancelFallback;

  Future<void> initialize() async {
    await Future.wait([_loadInitial(_state.filter), _loadPresets()]);
  }

  /// Re-reads the current filter in place.
  ///
  /// The rows that are already on screen stay visible while the query runs, so
  /// a background refresh (a favourite toggle, a sync, a resume) never flashes
  /// a spinner or throws the list back to the top. The page is read at least as
  /// long as the list that is already loaded for the same reason.
  Future<void> refresh() => _loadInitial(_state.filter, keepVisible: true);

  Future<void> applyFilter(SongFilter filter) {
    _searchTimer?.cancel();
    final normalized = filter.normalized();
    return _loadInitial(
      normalized,
      cancelFallback: normalized.sort == SongSort.random ? _state : null,
    );
  }

  void cancelLoading() {
    if (!_state.initialLoading || _state.filter.sort != SongSort.random) {
      return;
    }
    _requestGeneration++;
    final fallback = _cancelFallback;
    _cancelFallback = null;
    _setState(fallback ?? SongsViewState(filter: _state.filter));
  }

  Future<SavedSongFilter> saveCurrentFilter(String name) async {
    final store = presetStore;
    final normalized = name.trim();
    if (store == null || normalized.isEmpty) {
      throw ArgumentError.value(name, 'name');
    }
    final now = DateTime.now();
    final preset = SavedSongFilter(
      id: 'filter-${now.microsecondsSinceEpoch}',
      name: normalized,
      filter: _state.filter.normalized(),
      createdAt: now,
    );
    _savedFilters = List.unmodifiable([preset, ..._savedFilters]);
    notifyListeners();
    await store.save(_savedFilters);
    return preset;
  }

  Future<void> deleteSavedFilter(String id) async {
    final store = presetStore;
    if (store == null) return;
    final next = _savedFilters.where((item) => item.id != id).toList();
    if (next.length == _savedFilters.length) return;
    _savedFilters = List.unmodifiable(next);
    notifyListeners();
    await store.save(_savedFilters);
  }

  Future<void> applySavedFilter(SavedSongFilter preset) =>
      applyFilter(preset.filter);

  Future<void> _loadPresets() async {
    final store = presetStore;
    if (store == null) return;
    _savedFilters = await store.load();
    if (!_disposed) notifyListeners();
  }

  void setQuery(String query) {
    _searchTimer?.cancel();
    _searchTimer = Timer(
      searchDebounce,
      () => applyFilter(_state.filter.withQuery(query)),
    );
  }

  Future<void> loadMore() async {
    if (_state.initialLoading || _state.loadingMore || !_state.hasMore) return;
    final generation = _requestGeneration;
    _setState(_state.copyWith(loadingMore: true, clearError: true));
    try {
      final next = await repository.page(
        filter: _state.filter,
        limit: pageSize,
        offset: _state.songs.length,
      );
      if (!_isCurrent(generation)) return;
      final combined = List<Song>.unmodifiable([..._state.songs, ...next]);
      _setState(
        _state.copyWith(
          songs: combined,
          loadingMore: false,
          hasMore: next.isNotEmpty && combined.length < _state.totalCount,
          clearError: true,
        ),
      );
    } catch (error) {
      if (!_isCurrent(generation)) return;
      _setState(_state.copyWith(loadingMore: false, error: error));
    }
  }

  Future<void> _loadInitial(
    SongFilter filter, {
    SongsViewState? cancelFallback,
    bool keepVisible = false,
  }) async {
    final generation = ++_requestGeneration;
    _cancelFallback = cancelFallback;
    final previous = _state;
    final keep = keepVisible && previous.songs.isNotEmpty;
    _setState(
      keep
          ? previous.copyWith(filter: filter, initialLoading: true)
          : SongsViewState(filter: filter, initialLoading: true),
    );
    try {
      final countRequest = repository.count(filter);
      final pageRequest = repository.page(
        filter: filter,
        limit: keep ? math.max(pageSize, previous.songs.length) : pageSize,
        offset: 0,
      );
      final totalCount = await countRequest;
      final firstPage = await pageRequest;
      if (!_isCurrent(generation)) return;
      _cancelFallback = null;
      _setState(
        SongsViewState(
          filter: filter,
          songs: List.unmodifiable(firstPage),
          totalCount: totalCount,
          hasMore: firstPage.length < totalCount,
        ),
      );
    } catch (error) {
      if (!_isCurrent(generation)) return;
      _cancelFallback = null;
      // A failed refresh keeps the rows the listener can still read; the error
      // is only a full-screen state when there is nothing to show.
      _setState(
        keep
            ? previous.copyWith(initialLoading: false, error: error)
            : SongsViewState(filter: filter, error: error),
      );
    }
  }

  bool _isCurrent(int generation) =>
      !_disposed && generation == _requestGeneration;

  void _setState(SongsViewState value) {
    if (_disposed) return;
    _state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _searchTimer?.cancel();
    super.dispose();
  }
}
