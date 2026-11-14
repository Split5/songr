import '../../models/models.dart';

enum QuickPickReason { favorite, rediscover, fresh, sameAlbum }

class QuickPick {
  const QuickPick({required this.song, required this.reason});

  final Song song;
  final QuickPickReason reason;
}

/// Produces a compact blend of trusted listening signals and genuinely new
/// sonic neighbours. Candidates are interleaved by reason, then capped per
/// primary artist, so one prolific artist can never fill the shelf.
class QuickPicksService {
  const QuickPicksService();

  Future<List<QuickPick>> build({
    required List<Song> favorites,
    required List<Song> recentlyPlayed,
    required List<Song> mostPlayed,
    required List<Song> recentlyAdded,
    required List<Song> libraryPool,
    int rotation = 0,
    int limit = 16,
    int maxPerArtist = 2,
  }) async {
    final sourceIds = {
      ...favorites.map((song) => song.id),
      ...recentlyPlayed.map((song) => song.id),
      ...mostPlayed.map((song) => song.id),
    };
    final recentAlbums = recentlyPlayed
        .where((song) => song.albumId.isNotEmpty)
        .map((song) => song.albumId)
        .toSet();
    final sameAlbum = [
      for (final song in [...libraryPool, ...recentlyAdded])
        if (recentAlbums.contains(song.albumId) && !sourceIds.contains(song.id))
          QuickPick(song: song, reason: QuickPickReason.sameAlbum),
    ];
    final rediscoverable = List<Song>.of(favorites)
      ..sort((a, b) {
        final aDate = a.lastPlayed ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.lastPlayed ?? DateTime.fromMillisecondsSinceEpoch(0);
        final date = aDate.compareTo(bDate);
        return date != 0 ? date : b.playCount.compareTo(a.playCount);
      });
    final rediscover = [
      for (final song in rediscoverable)
        QuickPick(song: song, reason: QuickPickReason.rediscover),
    ];
    final fresh = [
      for (final song in recentlyAdded)
        if (song.playCount == 0)
          QuickPick(song: song, reason: QuickPickReason.fresh),
    ];
    final trusted = [
      for (final song in [...mostPlayed, ...favorites])
        QuickPick(song: song, reason: QuickPickReason.favorite),
    ];

    // Rotate the ranked candidates, not their inputs: sorting afterward used
    // to put the same rediscoveries back at the front on every refresh.
    final buckets = [
      for (final bucket in [sameAlbum, rediscover, fresh, trusted])
        _rotate(bucket, rotation, stride: (limit + 3) ~/ 4),
    ];
    final selected = <QuickPick>[];
    final seen = <String>{};
    final perArtist = <String, int>{};
    var round = 0;
    while (selected.length < limit &&
        buckets.any((bucket) => bucket.isNotEmpty)) {
      final bucket = buckets[round % buckets.length];
      round++;
      if (bucket.isEmpty) continue;
      final candidate = bucket.removeAt(0);
      if (!seen.add(candidate.song.id)) continue;
      final artist = _artist(candidate.song);
      if ((perArtist[artist] ?? 0) >= maxPerArtist) continue;
      selected.add(candidate);
      perArtist[artist] = (perArtist[artist] ?? 0) + 1;
    }
    return List.unmodifiable(selected);
  }

  String _artist(Song song) {
    final artist = primaryArtistName(song.artist).trim().toLowerCase();
    return artist.isEmpty ? 'unknown:${song.id}' : artist;
  }

  List<T> _rotate<T>(List<T> songs, int rotation, {required int stride}) {
    if (songs.length < 2 || rotation <= 0) return songs;
    // A stride sharing a divisor with a small bucket can leave it unchanged.
    while (stride.gcd(songs.length) != 1) {
      stride++;
    }
    final offset = (rotation * stride) % songs.length;
    if (offset == 0) return songs;
    return [...songs.skip(offset), ...songs.take(offset)];
  }
}
