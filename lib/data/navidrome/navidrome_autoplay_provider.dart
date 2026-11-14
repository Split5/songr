import 'dart:math';

import '../../api/subsonic_api.dart';
import '../../domain/playback/auto_play_profile.dart';
import '../../domain/playback/playback_coordinator.dart';
import '../../models/models.dart';
import '../local/app_database.dart';

class NavidromeAutoPlayProvider implements AutoPlayCandidateProvider {
  const NavidromeAutoPlayProvider({required this.api, required this.database});

  final SubsonicApi api;
  final AppDatabase database;

  @override
  Future<List<String>> candidates({
    required String seedSongId,
    required Set<String> excludedSongIds,
    required int limit,
    required AutoPlayProfile profile,
  }) async {
    final selected = <String>[];
    final seen = {...excludedSongIds};
    final perArtist = <String, int>{};
    try {
      final overfetch = (limit * (3 + (profile.exploration * 3).round())).clamp(
        limit,
        200,
      );
      final similar = await api.getSimilarSongs2(seedSongId, count: overfetch);
      for (final song in _explore(
        similar,
        seedSongId: seedSongId,
        amount: profile.exploration,
      )) {
        if (!seen.add(song.id)) continue;
        final artist = _artistKey(song.artist, song.id);
        if ((perArtist[artist] ?? 0) >= profile.maxSongsPerArtist) continue;
        perArtist[artist] = (perArtist[artist] ?? 0) + 1;
        selected.add(song.id);
        if (selected.length >= limit) return selected;
      }
    } catch (_) {}

    final seed = await (database.select(
      database.localSongs,
    )..where((song) => song.id.equals(seedSongId))).getSingleOrNull();
    final genre = seed?.genre?.trim();
    if (genre != null && genre.isNotEmpty) {
      final local = await database.genreShelfSongs(genre, limit: limit * 4);
      for (final song in local) {
        if (!seen.add(song.id)) continue;
        final artist = _artistKey(song.artist, song.id);
        if ((perArtist[artist] ?? 0) >= profile.maxSongsPerArtist) continue;
        perArtist[artist] = (perArtist[artist] ?? 0) + 1;
        selected.add(song.id);
        if (selected.length >= limit) return selected;
      }
    }

    // Keep the radio useful offline or when the similarity agent is briefly
    // unavailable. This is deliberately only a final fallback; the server's
    // sonic order (getSimilarSongs2) always wins whenever Navidrome returns it.
    final replay = await database.replaySongs(limit: limit * 4);
    for (final song in replay) {
      if (!seen.add(song.id)) continue;
      final artist = _artistKey(song.artist, song.id);
      if ((perArtist[artist] ?? 0) >= profile.maxSongsPerArtist) continue;
      perArtist[artist] = (perArtist[artist] ?? 0) + 1;
      selected.add(song.id);
      if (selected.length >= limit) return selected;
    }
    final fresh = await database.startListeningSongs(limit: limit * 4);
    for (final song in fresh) {
      if (!seen.add(song.id)) continue;
      final artist = _artistKey(song.artist, song.id);
      if ((perArtist[artist] ?? 0) >= profile.maxSongsPerArtist) continue;
      perArtist[artist] = (perArtist[artist] ?? 0) + 1;
      selected.add(song.id);
      if (selected.length >= limit) break;
    }
    return selected;
  }

  /// Navidrome's similarity ranking remains the source of relevance.
  /// Exploration only changes how deeply the client samples within that
  /// already-ranked candidate pool.
  List<Song> _explore(
    List<Song> candidates, {
    required String seedSongId,
    required double amount,
  }) {
    final bounded = amount.clamp(0.0, 1.0);
    if (bounded <= 0.01 || candidates.length < 3) return candidates;
    final result = <({Song song, double score})>[];
    final denominator = max(1, candidates.length - 1);
    for (var index = 0; index < candidates.length; index++) {
      final song = candidates[index];
      final rank = index / denominator;
      final noise = _stableUnit('$seedSongId:${song.id}');
      result.add((
        song: song,
        score: rank * (1 - 0.65 * bounded) + noise * 0.65 * bounded,
      ));
    }
    result.sort((a, b) => a.score.compareTo(b.score));
    return result.map((item) => item.song).toList(growable: false);
  }

  String _artistKey(String raw, String fallback) {
    final artist = primaryArtistName(raw).trim().toLowerCase();
    return artist.isEmpty ? 'unknown:$fallback' : artist;
  }

  double _stableUnit(String value) {
    var hash = 0x811c9dc5;
    for (final unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash / 0x7fffffff;
  }
}
