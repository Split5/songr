import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../app/v2/v2_experience_preferences.dart';
import '../../data/local/drift_catalog_repository.dart';
import '../../domain/library/song_filter.dart';
import '../../domain/library/song_library_repository.dart';
import '../../models/models.dart';
import '../library/songs/songs_controller.dart';

enum FavoriteSection { songs, albums, artists }

enum FavoriteAlbumSort { title, artist, yearNewest, newest, mostPlayed }

enum FavoriteArtistSort { name, albumCount }

/// One offline-first state owner for the Favorites root. Explicitly starred
/// albums and artists come from the catalogue snapshot while songs retain the
/// paged/filterable SQLite path used by the full Songs browser.
class FavoritesController extends ChangeNotifier {
  FavoritesController({
    required SongLibraryRepository songLibrary,
    required this.catalog,
    this.preferences,
  }) : _songLibrary = songLibrary,
       songs = SongsController(
         repository: songLibrary,
         initialFilter:
             (preferences?.favoriteSongFilter ?? defaultFavoriteSongFilter)
                 .withFavoritesOnly(true),
       );

  final SongLibraryRepository _songLibrary;
  final DriftCatalogRepository catalog;
  final V2ExperiencePreferences? preferences;
  final SongsController songs;

  FavoriteSection section = FavoriteSection.songs;
  FavoriteAlbumSort albumSort = FavoriteAlbumSort.title;
  FavoriteArtistSort artistSort = FavoriteArtistSort.name;
  List<Album> albums = const [];
  List<ArtistSummary> artists = const [];
  bool loadingCatalog = false;
  Object? error;
  String query = '';
  bool _initialized = false;
  int _generation = 0;

  List<Album> get visibleAlbums {
    final normalized = query.trim().toLowerCase();
    final result = albums
        .where(
          (album) =>
              normalized.isEmpty ||
              album.name.toLowerCase().contains(normalized) ||
              album.artist.toLowerCase().contains(normalized),
        )
        .toList();
    result.sort((a, b) {
      final compared = switch (albumSort) {
        FavoriteAlbumSort.title => _compareText(a.name, b.name),
        FavoriteAlbumSort.artist => _compareText(a.artist, b.artist),
        FavoriteAlbumSort.yearNewest => b.year.compareTo(a.year),
        FavoriteAlbumSort.newest => _compareNewest(a.created, b.created),
        FavoriteAlbumSort.mostPlayed => b.playCount.compareTo(a.playCount),
      };
      return compared != 0 ? compared : _compareText(a.name, b.name);
    });
    return List.unmodifiable(result);
  }

  List<ArtistSummary> get visibleArtists {
    final normalized = query.trim().toLowerCase();
    final result = artists
        .where(
          (artist) =>
              normalized.isEmpty ||
              artist.name.toLowerCase().contains(normalized),
        )
        .toList();
    result.sort((a, b) {
      final compared = switch (artistSort) {
        FavoriteArtistSort.name => _compareText(a.name, b.name),
        FavoriteArtistSort.albumCount => b.albumCount.compareTo(a.albumCount),
      };
      return compared != 0 ? compared : _compareText(a.name, b.name);
    });
    return List.unmodifiable(result);
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    section =
        _favoriteSectionByName(preferences?.favoriteSection) ??
        FavoriteSection.songs;
    albumSort =
        _albumSortByName(preferences?.favoriteAlbumSort) ??
        FavoriteAlbumSort.title;
    artistSort =
        _artistSortByName(preferences?.favoriteArtistSort) ??
        FavoriteArtistSort.name;
    await refresh(
      filter: (preferences?.favoriteSongFilter ?? defaultFavoriteSongFilter)
          .withFavoritesOnly(true),
    );
  }

  Future<void> refresh({SongFilter? filter}) async {
    _initialized = true;
    final generation = ++_generation;
    loadingCatalog = true;
    error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        if (filter == null) songs.refresh() else songs.applyFilter(filter),
        catalog.starredAlbums(),
        catalog.starredArtists(),
      ]);
      if (generation != _generation) return;
      albums = List.unmodifiable(results[1] as List<Album>);
      artists = List.unmodifiable(results[2] as List<ArtistSummary>);
    } catch (caught) {
      if (generation != _generation) return;
      error = caught;
    } finally {
      if (generation == _generation) {
        loadingCatalog = false;
        notifyListeners();
      }
    }
  }

  Future<void> select(FavoriteSection value) async {
    if (section == value) return;
    section = value;
    notifyListeners();
    final preferences = this.preferences;
    if (preferences != null) {
      await preferences.setFavoriteSection(value.name);
    }
  }

  Future<void> setAlbumSort(FavoriteAlbumSort value) async {
    if (albumSort == value) return;
    albumSort = value;
    notifyListeners();
    final preferences = this.preferences;
    if (preferences != null) {
      await preferences.setFavoriteAlbumSort(value.name);
    }
  }

  Future<void> setArtistSort(FavoriteArtistSort value) async {
    if (artistSort == value) return;
    artistSort = value;
    notifyListeners();
    final preferences = this.preferences;
    if (preferences != null) {
      await preferences.setFavoriteArtistSort(value.name);
    }
  }

  void setQuery(String value) {
    query = value;
    songs.setQuery(value);
    notifyListeners();
    final preferences = this.preferences;
    if (preferences != null) {
      unawaited(
        preferences.setFavoriteSongFilter(
          songs.state.filter.withQuery(value).withFavoritesOnly(true),
        ),
      );
    }
  }

  Future<void> applySongFilter(SongFilter filter) async {
    final effective = filter.withFavoritesOnly(true).normalized();
    await songs.applyFilter(effective);
    await preferences?.setFavoriteSongFilter(effective);
  }

  Future<List<Song>> allVisibleSongs() async {
    final filter = songs.state.filter.withFavoritesOnly(true);
    final result = <Song>[];
    var offset = 0;
    const pageSize = 500;
    while (true) {
      final page = await _songLibrary.page(
        filter: filter,
        limit: pageSize,
        offset: offset,
      );
      result.addAll(page);
      if (page.length < pageSize) break;
      offset += page.length;
    }
    return result;
  }

  @override
  void dispose() {
    _generation++;
    songs.dispose();
    super.dispose();
  }
}

int _compareText(String a, String b) =>
    a.toLowerCase().compareTo(b.toLowerCase());

int _compareNewest(DateTime? a, DateTime? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return b.compareTo(a);
}

FavoriteSection? _favoriteSectionByName(String? name) =>
    _enumByName(FavoriteSection.values, name);

FavoriteAlbumSort? _albumSortByName(String? name) =>
    _enumByName(FavoriteAlbumSort.values, name);

FavoriteArtistSort? _artistSortByName(String? name) =>
    _enumByName(FavoriteArtistSort.values, name);

T? _enumByName<T extends Enum>(Iterable<T> values, String? name) {
  if (name == null) return null;
  for (final value in values) {
    if (value.name == name) return value;
  }
  return null;
}
