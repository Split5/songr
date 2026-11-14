import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/home/home_repository.dart';
import '../../domain/home/quick_picks_service.dart';
import '../../models/models.dart';

typedef QuickPicksLoader =
    Future<List<QuickPick>> Function(HomeSnapshot source, int rotation);

@immutable
class HomeViewState {
  const HomeViewState({
    this.loading = false,
    this.recentlyPlayedSongs = const [],
    this.recentlyAddedSongs = const [],
    this.mostPlayedSongs = const [],
    this.librarySongRotation = const [],
    this.recentlyPlayedAlbums = const [],
    this.recentlyAddedAlbums = const [],
    this.mostPlayedAlbums = const [],
    this.libraryRotation = const [],
    this.recentlyPlayedPlaylists = const [],
    this.quickPicks = const [],
    this.error,
    this.revision = 0,
    this.quickPicksRevision = 0,
  });

  final bool loading;
  final List<Song> recentlyPlayedSongs;
  final List<Song> recentlyAddedSongs;
  final List<Song> mostPlayedSongs;
  final List<Song> librarySongRotation;
  final List<Album> recentlyPlayedAlbums;
  final List<Album> recentlyAddedAlbums;
  final List<Album> mostPlayedAlbums;
  final List<Album> libraryRotation;
  final List<Playlist> recentlyPlayedPlaylists;
  final List<QuickPick> quickPicks;
  final Object? error;

  /// Increments on every completed reload. The Home screen keys its horizontal
  /// standard carousels on it. Quick Picks only rewinds with its own selection.
  final int revision;
  final int quickPicksRevision;

  HomeViewState copyWith({
    bool? loading,
    List<Song>? recentlyPlayedSongs,
    List<Song>? recentlyAddedSongs,
    List<Song>? mostPlayedSongs,
    List<Song>? librarySongRotation,
    List<Album>? recentlyPlayedAlbums,
    List<Album>? recentlyAddedAlbums,
    List<Album>? mostPlayedAlbums,
    List<Album>? libraryRotation,
    List<Playlist>? recentlyPlayedPlaylists,
    List<QuickPick>? quickPicks,
    Object? error,
    int? revision,
    int? quickPicksRevision,
    bool clearError = false,
  }) => HomeViewState(
    loading: loading ?? this.loading,
    recentlyPlayedSongs: recentlyPlayedSongs ?? this.recentlyPlayedSongs,
    recentlyAddedSongs: recentlyAddedSongs ?? this.recentlyAddedSongs,
    mostPlayedSongs: mostPlayedSongs ?? this.mostPlayedSongs,
    librarySongRotation: librarySongRotation ?? this.librarySongRotation,
    recentlyPlayedAlbums: recentlyPlayedAlbums ?? this.recentlyPlayedAlbums,
    recentlyAddedAlbums: recentlyAddedAlbums ?? this.recentlyAddedAlbums,
    mostPlayedAlbums: mostPlayedAlbums ?? this.mostPlayedAlbums,
    libraryRotation: libraryRotation ?? this.libraryRotation,
    recentlyPlayedPlaylists:
        recentlyPlayedPlaylists ?? this.recentlyPlayedPlaylists,
    quickPicks: quickPicks ?? this.quickPicks,
    error: clearError ? null : error ?? this.error,
    revision: revision ?? this.revision,
    quickPicksRevision: quickPicksRevision ?? this.quickPicksRevision,
  );
}

class HomeController extends ChangeNotifier {
  HomeController({required this.repository, this.quickPicksLoader});

  final HomeRepository repository;
  final QuickPicksLoader? quickPicksLoader;
  HomeViewState _state = const HomeViewState();
  int _generation = 0;
  int _quickPickRotation = DateTime.now().millisecondsSinceEpoch;
  int _quickPicksGeneration = 0;
  HomeSnapshot? _lastSnapshot;
  Future<void>? _inFlight;
  Future<void>? _quickPicksInFlight;

  HomeViewState get state => _state;
  bool get hasContent => _hasContent;

  Future<void> initialize() async {
    if (_state.loading || _hasContent) return;
    await refresh();
  }

  /// Recommendations can rotate from the last local snapshot while a server
  /// sync or the newest-albums request is still pending.
  Future<void> refreshQuickPicks() {
    final active = _quickPicksInFlight;
    if (active != null) return active;
    final snapshot = _lastSnapshot;
    if (snapshot == null) return Future<void>.value();
    final run = _loadQuickPicks(snapshot);
    _quickPicksInFlight = run;
    unawaited(
      run.whenComplete(() {
        if (identical(_quickPicksInFlight, run)) _quickPicksInFlight = null;
      }),
    );
    return run;
  }

  /// Reloads every shelf. Concurrent callers share one run: the app resume,
  /// the track refresh and the Home tab switch can all ask at once without
  /// stacking three identical loads.
  Future<void> refresh({
    bool rotateLibrary = false,
    bool rotateQuickPicks = true,
  }) {
    final active = _inFlight;
    if (active != null) return active;
    final run = _load(rotateLibrary, rotateQuickPicks);
    _inFlight = run;
    unawaited(
      run.whenComplete(() {
        if (identical(_inFlight, run)) _inFlight = null;
      }),
    );
    return run;
  }

  Future<void> _load(bool rotateLibrary, bool rotateQuickPicks) async {
    final generation = ++_generation;
    _setState(_state.copyWith(loading: true, clearError: true));
    try {
      final snapshot = await repository.load(
        refreshLibraryRotation: rotateLibrary,
      );
      if (generation != _generation) return;
      _lastSnapshot = snapshot;
      _setState(
        HomeViewState(
          recentlyPlayedSongs: _diversifySongs(snapshot.recentlyPlayedSongs),
          recentlyAddedSongs: _diversifySongs(snapshot.recentlyAddedSongs),
          mostPlayedSongs: _diversifySongs(snapshot.mostPlayedSongs),
          librarySongRotation: _diversifySongs(snapshot.librarySongRotation),
          recentlyPlayedAlbums: _diversify(snapshot.recentlyPlayedAlbums),
          recentlyAddedAlbums: _diversify(snapshot.recentlyAddedAlbums),
          mostPlayedAlbums: _diversify(snapshot.mostPlayedAlbums),
          libraryRotation: _diversify(snapshot.libraryRotation),
          recentlyPlayedPlaylists: snapshot.recentlyPlayedPlaylists,
          quickPicks: _state.quickPicks,
          revision: _state.revision + 1,
          quickPicksRevision: _state.quickPicksRevision,
        ),
      );
      if (rotateQuickPicks || _state.quickPicks.isEmpty) {
        await refreshQuickPicks();
      }
    } catch (error) {
      if (generation != _generation) return;
      _setState(_state.copyWith(loading: false, error: error));
    }
  }

  Future<void> _loadQuickPicks(HomeSnapshot snapshot) async {
    final loader = quickPicksLoader;
    if (loader == null) return;
    final generation = ++_quickPicksGeneration;
    final rotation = _quickPickRotation++;
    try {
      final picks = await loader(snapshot, rotation);
      if (generation != _quickPicksGeneration) return;
      _setState(
        _state.copyWith(
          quickPicks: picks,
          quickPicksRevision: _state.quickPicksRevision + 1,
        ),
      );
    } catch (_) {
      // Keep the last usable selection when recommendation loading fails.
    }
  }

  @override
  void dispose() {
    _generation++;
    _quickPicksGeneration++;
    super.dispose();
  }

  bool get _hasContent =>
      _state.recentlyPlayedSongs.isNotEmpty ||
      _state.recentlyAddedSongs.isNotEmpty ||
      _state.mostPlayedSongs.isNotEmpty ||
      _state.librarySongRotation.isNotEmpty ||
      _state.recentlyPlayedAlbums.isNotEmpty ||
      _state.recentlyAddedAlbums.isNotEmpty ||
      _state.mostPlayedAlbums.isNotEmpty ||
      _state.libraryRotation.isNotEmpty ||
      _state.recentlyPlayedPlaylists.isNotEmpty ||
      _state.quickPicks.isNotEmpty;

  /// Fill every shelf with unique primary artists before allowing a second
  /// album from one artist. This keeps the first screen varied even when one
  /// artist dominates the server play counter.
  List<Album> _diversify(
    List<Album> candidates, {
    int limit = 12,
    int maxPerArtist = 2,
  }) {
    final selected = <Album>[];
    final selectedIds = <String>{};
    final perArtist = <String, int>{};
    for (
      var pass = 1;
      pass <= maxPerArtist && selected.length < limit;
      pass++
    ) {
      for (final album in candidates) {
        if (selected.length >= limit || selectedIds.contains(album.id)) {
          continue;
        }
        final artist = primaryArtistName(album.artist).toLowerCase();
        if ((perArtist[artist] ?? 0) >= pass) continue;
        selected.add(album);
        selectedIds.add(album.id);
        perArtist[artist] = (perArtist[artist] ?? 0) + 1;
      }
    }
    return List.unmodifiable(selected);
  }

  List<Song> _diversifySongs(
    List<Song> candidates, {
    int limit = 16,
    int maxPerArtist = 2,
  }) {
    final selected = <Song>[];
    final selectedIds = <String>{};
    final perArtist = <String, int>{};
    for (
      var pass = 1;
      pass <= maxPerArtist && selected.length < limit;
      pass++
    ) {
      for (final song in candidates) {
        if (selected.length >= limit || selectedIds.contains(song.id)) {
          continue;
        }
        final artist = primaryArtistName(song.artist).toLowerCase();
        if ((perArtist[artist] ?? 0) >= pass) continue;
        selected.add(song);
        selectedIds.add(song.id);
        perArtist[artist] = (perArtist[artist] ?? 0) + 1;
      }
    }
    return List.unmodifiable(selected);
  }

  void _setState(HomeViewState state) {
    _state = state;
    notifyListeners();
  }
}
