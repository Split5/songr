import 'package:flutter/foundation.dart';

import '../../domain/radio/radio_repository.dart';
import '../../models/models.dart';

@immutable
class RadioViewState {
  const RadioViewState({
    this.loading = false,
    this.stations = const [],
    this.genres = const [],
    this.artists = const [],
    this.error,
  });

  final bool loading;
  final List<InternetRadioStation> stations;
  final List<String> genres;
  final List<ArtistSummary> artists;
  final Object? error;

  bool get hasContent =>
      stations.isNotEmpty || genres.isNotEmpty || artists.isNotEmpty;
}

class RadioController extends ChangeNotifier {
  RadioController({required this.repository});

  final RadioRepository repository;
  RadioViewState _state = const RadioViewState();
  int _generation = 0;

  RadioViewState get state => _state;

  Future<void> initialize() async {
    if (_state.loading || _state.hasContent) return;
    await refresh();
  }

  Future<void> refresh() async {
    final generation = ++_generation;
    _state = RadioViewState(
      loading: true,
      stations: _state.stations,
      genres: _state.genres,
      artists: _state.artists,
    );
    notifyListeners();
    try {
      final values = await Future.wait([
        repository.stations(),
        repository.genres(),
        repository.artists(),
      ]);
      if (generation != _generation) return;
      _state = RadioViewState(
        stations: List.unmodifiable(values[0] as List<InternetRadioStation>),
        genres: List.unmodifiable(values[1] as List<String>),
        artists: List.unmodifiable(values[2] as List<ArtistSummary>),
      );
    } catch (error) {
      if (generation != _generation) return;
      _state = RadioViewState(
        stations: _state.stations,
        genres: _state.genres,
        artists: _state.artists,
        error: error,
      );
    }
    notifyListeners();
  }

  Future<List<Song>> genreRadio(String genre) =>
      repository.songsForGenre(genre);

  Future<List<Song>> artistRadio(ArtistSummary artist) =>
      repository.songsForArtist(artist);
}
