import 'dart:math';

import '../../models/models.dart';

typedef SimilarSongsLoader =
    Future<List<Song>> Function(String songId, int count);

/// Builds collection-level recommendations from Navidrome's Subsonic
/// `getSimilarSongs2` endpoint. On this server that endpoint is answered by
/// the AudioMuse-AI Navidrome plugin, so the sonic similarity comes from the
/// plugin without the client ever calling AudioMuse directly.
///
/// Several representative source tracks are queried and combined with
/// reciprocal-rank scoring, so a playlist or set of favourites is
/// represented by more than its first song.
class NavidromeSimilarityService {
  NavidromeSimilarityService({required this.loadSimilarSongs});

  final SimilarSongsLoader loadSimilarSongs;
  final Map<String, List<Song>> _cache = {};

  Future<List<Song>> recommendations(
    List<Song> source, {
    int limit = 12,
    bool refresh = false,
  }) async {
    final uniqueSource = _unique(source);
    if (uniqueSource.isEmpty || limit <= 0) return const [];
    final key = '${_fingerprint(uniqueSource)}:$limit';
    final cached = _cache[key];
    if (!refresh && cached != null) return cached;

    final seeds = representativeSeeds(uniqueSource);
    final batches = await Future.wait([
      for (final seed in seeds)
        () async {
          try {
            return await loadSimilarSongs(seed.id, max(24, limit * 3));
          } catch (_) {
            return <Song>[];
          }
        }(),
    ]);
    final excluded = uniqueSource.map((song) => song.id).toSet();
    final scored = <String, ({Song song, double score})>{};
    for (var batchIndex = 0; batchIndex < batches.length; batchIndex++) {
      final batch = batches[batchIndex];
      for (var rank = 0; rank < batch.length; rank++) {
        final song = batch[rank];
        if (excluded.contains(song.id)) continue;
        final rankScore = 1 / (rank + 1.5);
        final prior = log(song.playCount + 1) * 0.025;
        final existing = scored[song.id];
        scored[song.id] = (
          song: existing?.song ?? song,
          score: (existing?.score ?? 0) + rankScore + prior,
        );
      }
    }

    final ranked = scored.values.toList()
      ..sort((a, b) {
        final score = b.score.compareTo(a.score);
        if (score != 0) return score;
        final popularity = b.song.playCount.compareTo(a.song.playCount);
        if (popularity != 0) return popularity;
        return a.song.title.toLowerCase().compareTo(b.song.title.toLowerCase());
      });
    final selected = <Song>[];
    final perArtist = <String, int>{};
    for (final candidate in ranked) {
      final artist = _artistKey(candidate.song);
      if ((perArtist[artist] ?? 0) >= 2) continue;
      selected.add(candidate.song);
      perArtist[artist] = (perArtist[artist] ?? 0) + 1;
      if (selected.length >= limit) break;
    }
    final result = List<Song>.unmodifiable(selected);
    _cache[key] = result;
    return result;
  }

  Future<List<Song>> mixFrom(
    List<Song> source, {
    int limit = 30,
    bool refresh = true,
  }) async {
    final uniqueSource = _unique(source);
    if (uniqueSource.isEmpty || limit <= 0) return const [];
    final seeds = representativeSeeds(uniqueSource, maxSeeds: 6);
    final related = await recommendations(
      uniqueSource,
      limit: max(0, limit - seeds.length),
      refresh: refresh,
    );
    final result = <Song>[];
    final seen = <String>{};
    var seedIndex = 0;
    var relatedIndex = 0;
    while (result.length < limit &&
        (seedIndex < seeds.length || relatedIndex < related.length)) {
      if (seedIndex < seeds.length) {
        final seed = seeds[seedIndex++];
        if (seen.add(seed.id)) result.add(seed);
      }
      for (
        var index = 0;
        index < 3 && relatedIndex < related.length && result.length < limit;
        index++
      ) {
        final song = related[relatedIndex++];
        if (seen.add(song.id)) result.add(song);
      }
    }
    return List.unmodifiable(result);
  }

  List<Song> representativeSeeds(List<Song> source, {int maxSeeds = 5}) {
    final candidates = _unique(source)
      ..sort((a, b) {
        final plays = b.playCount.compareTo(a.playCount);
        if (plays != 0) return plays;
        return a.id.compareTo(b.id);
      });
    final selected = <Song>[];
    final artists = <String>{};
    for (final song in candidates) {
      if (!artists.add(_artistKey(song))) continue;
      selected.add(song);
      if (selected.length >= maxSeeds) return selected;
    }
    for (final song in candidates) {
      if (selected.any((item) => item.id == song.id)) continue;
      selected.add(song);
      if (selected.length >= maxSeeds) break;
    }
    return selected;
  }

  List<Song> _unique(Iterable<Song> songs) {
    final byId = <String, Song>{};
    for (final song in songs) {
      byId.putIfAbsent(song.id, () => song);
    }
    return byId.values.toList();
  }

  String _artistKey(Song song) {
    final value = primaryArtistName(song.artist).trim().toLowerCase();
    return value.isEmpty ? 'unknown:${song.id}' : value;
  }

  String _fingerprint(List<Song> songs) {
    var hash = 0x811c9dc5;
    for (final song in songs) {
      for (final unit in song.id.codeUnits) {
        hash ^= unit;
        hash = (hash * 0x01000193) & 0x7fffffff;
      }
    }
    return hash.toRadixString(16);
  }
}
