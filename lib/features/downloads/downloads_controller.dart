import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/downloads/downloaded_library_repository.dart';
import '../../domain/library/song_filter.dart';
import '../../models/models.dart';
import '../../state/download_provider.dart';

class V2DownloadsController extends ChangeNotifier {
  V2DownloadsController({required this.downloads, required this.repository}) {
    downloads.addListener(_downloadStateChanged);
  }

  final DownloadProvider downloads;
  final DownloadedLibraryRepository repository;
  List<DownloadedEntry> entries = const [];
  List<Song> songs = const [];
  bool loading = false;
  Object? error;
  String query = '';
  SongSort sort = SongSort.title;
  int _generation = 0;
  int _randomSeed = 0;
  Timer? _debounce;

  List<DownloadedEntry> get visibleEntries {
    final normalized = query.trim().toLowerCase();
    final result = entries.where((entry) {
      final song = entry.song;
      return song != null &&
          (normalized.isEmpty ||
              song.title.toLowerCase().contains(normalized) ||
              song.artist.toLowerCase().contains(normalized) ||
              song.album.toLowerCase().contains(normalized));
    }).toList();
    result.sort((a, b) => _compareSongs(a.song!, b.song!));
    return List.unmodifiable(result);
  }

  List<Song> get visibleSongs =>
      List.unmodifiable(visibleEntries.map((entry) => entry.song!));

  int _compareSongs(Song a, Song b) {
    final compared = switch (sort) {
      SongSort.title => _text(a.title, b.title),
      SongSort.artist => _text(a.artist, b.artist),
      SongSort.album => _text(a.album, b.album),
      SongSort.newest => _newest(a.created, b.created),
      SongSort.recentlyPlayed => _newest(a.lastPlayed, b.lastPlayed),
      SongSort.mostPlayed => b.playCount.compareTo(a.playCount),
      SongSort.random => _randomRank(
        a.id,
        _randomSeed,
      ).compareTo(_randomRank(b.id, _randomSeed)),
      SongSort.yearNewest => b.year.compareTo(a.year),
      SongSort.durationLongest => b.duration.compareTo(a.duration),
      SongSort.bitRateHighest => b.bitRate.compareTo(a.bitRate),
    };
    return compared != 0 ? compared : _text(a.title, b.title);
  }

  void setQuery(String value) {
    if (query == value) return;
    query = value;
    notifyListeners();
  }

  void setSort(SongSort value) {
    if (sort == value) return;
    if (value == SongSort.random) _randomSeed++;
    sort = value;
    notifyListeners();
  }

  Future<void> initialize() => refresh();

  Future<void> refresh() async {
    final generation = ++_generation;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final current = downloads.allEntries.toList(growable: false);
      final missingIds = {
        for (final entry in current)
          if (entry.song == null &&
              entry.accountScope == downloads.accountScope)
            entry.songId,
      };
      final resolved = missingIds.isEmpty
          ? const <Song>[]
          : await repository.songsForIds(missingIds);
      final resolvedById = {for (final song in resolved) song.id: song};
      for (final entry in current) {
        if (entry.song == null &&
            entry.accountScope == downloads.accountScope) {
          final song = resolvedById[entry.songId];
          if (song != null) {
            entry.song = song;
            downloads.attachSongMetadata(song);
          }
        }
      }
      if (generation != _generation) return;
      entries = List.unmodifiable(current.where((entry) => entry.song != null));
      songs = List.unmodifiable(entries.map((entry) => entry.song!));
    } catch (caught) {
      if (generation != _generation) return;
      error = caught;
    }
    loading = false;
    notifyListeners();
  }

  void _downloadStateChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 120), refresh);
  }

  Future<void> remove(DownloadedEntry entry) => downloads.removeEntry(entry);

  @override
  void dispose() {
    downloads.removeListener(_downloadStateChanged);
    _debounce?.cancel();
    super.dispose();
  }
}

int _text(String a, String b) => a.toLowerCase().compareTo(b.toLowerCase());

int _newest(DateTime? a, DateTime? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return b.compareTo(a);
}

int _randomRank(String value, int seed) {
  var hash = 17;
  for (final unit in value.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  return (hash ^ seed) & 0x7fffffff;
}
