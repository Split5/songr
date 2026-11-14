import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/domain/home/quick_picks_service.dart';
import 'package:navimusic/models/models.dart';

void main() {
  test('default refresh stride also rotates a four-song bucket', () async {
    const service = QuickPicksService();
    final songs = [for (var i = 0; i < 4; i++) _song('fresh-$i', 'Artist $i')];
    Future<List<String>> ids(int rotation) async => [
      for (final pick in await service.build(
        favorites: const [],
        recentlyPlayed: const [],
        mostPlayed: const [],
        recentlyAdded: songs,
        libraryPool: const [],
        rotation: rotation,
      ))
        pick.song.id,
    ];
    expect((await ids(1)).first, isNot((await ids(0)).first));
  });

  test('refresh rotates rediscoveries after ranking them', () async {
    const service = QuickPicksService();
    final favorites = [
      for (var i = 0; i < 30; i++)
        _song(
          'favorite-$i',
          'Artist $i',
          lastPlayed: DateTime.utc(2020, 1, i + 1),
        ),
    ];
    Future<List<String>> rediscoveries(int rotation) async => [
      for (final pick in await service.build(
        favorites: favorites,
        recentlyPlayed: const [],
        mostPlayed: const [],
        recentlyAdded: const [],
        libraryPool: const [],
        rotation: rotation,
        limit: 8,
      ))
        if (pick.reason == QuickPickReason.rediscover) pick.song.id,
    ];
    expect(
      (await rediscoveries(1)).first,
      isNot((await rediscoveries(0)).first),
    );
  });

  test('Quick Picks interleaves reasons and enforces the artist cap', () async {
    const service = QuickPicksService();
    final seed = _song('seed', 'Seed Artist', albumId: 'seed-album');
    final favorite = _song(
      'favorite',
      'Favorite Artist',
      playCount: 12,
      lastPlayed: DateTime.utc(2020),
    );

    final picks = await service.build(
      favorites: [favorite],
      recentlyPlayed: [seed],
      mostPlayed: [seed],
      recentlyAdded: [_song('fresh', 'Fresh Artist')],
      libraryPool: [_song('same-album', 'Album Artist', albumId: 'seed-album')],
      limit: 8,
      maxPerArtist: 1,
    );

    final artistCounts = <String, int>{};
    for (final pick in picks) {
      final artist = primaryArtistName(pick.song.artist).toLowerCase();
      artistCounts[artist] = (artistCounts[artist] ?? 0) + 1;
    }
    expect(artistCounts.values.every((count) => count <= 1), isTrue);
    expect(
      picks.map((pick) => pick.reason).toSet(),
      containsAll([
        QuickPickReason.sameAlbum,
        QuickPickReason.rediscover,
        QuickPickReason.fresh,
      ]),
    );
  });

  test('Quick Picks rotation changes the same-album selection', () async {
    const service = QuickPicksService();
    final seed = _song('seed', 'Seed Artist', albumId: 'album');
    final pool = [
      for (var index = 0; index < 8; index++)
        _song('candidate-$index', 'Artist $index', albumId: 'album'),
    ];

    Future<List<String>> ids(int rotation) async => [
      for (final pick in await service.build(
        favorites: const [],
        recentlyPlayed: [seed],
        mostPlayed: const [],
        recentlyAdded: const [],
        libraryPool: pool,
        rotation: rotation,
        limit: 3,
        maxPerArtist: 1,
      ))
        pick.song.id,
    ];

    expect(await ids(0), ['candidate-0', 'candidate-1', 'candidate-2']);
    expect(await ids(1), ['candidate-1', 'candidate-2', 'candidate-3']);
  });
}

Song _song(
  String id,
  String artist, {
  String albumId = '',
  int playCount = 0,
  DateTime? lastPlayed,
}) => Song(
  id: id,
  title: id,
  artist: artist,
  artistId: artist,
  album: albumId,
  albumId: albumId,
  playCount: playCount,
  lastPlayed: lastPlayed,
);
