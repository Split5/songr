import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/domain/library/navidrome_similarity_service.dart';
import 'package:navimusic/models/models.dart';

void main() {
  test(
    'combines several seeds, excludes source and caps each artist',
    () async {
      final calls = <String>[];
      final source = [
        _song('source-a', artist: 'Source A', plays: 20),
        _song('source-b', artist: 'Source B', plays: 15),
        _song('source-c', artist: 'Source C', plays: 10),
      ];
      final shared = _song('shared', artist: 'Related X');
      final service = NavidromeSimilarityService(
        loadSimilarSongs: (songId, count) async {
          calls.add(songId);
          return [
            shared,
            source.first,
            _song('x-two', artist: 'Related X'),
            _song('x-three', artist: 'Related X'),
            _song('y-one', artist: 'Related Y'),
            _song('z-one', artist: 'Related Z'),
          ];
        },
      );

      final result = await service.recommendations(source, limit: 5);

      expect(calls.toSet(), {'source-a', 'source-b', 'source-c'});
      expect(result.first.id, 'shared');
      expect(
        result
            .map((song) => song.id)
            .toSet()
            .intersection(source.map((song) => song.id).toSet()),
        isEmpty,
      );
      expect(
        result.where((song) => song.artist == 'Related X').length,
        lessThanOrEqualTo(2),
      );
    },
  );

  test('favorites mix interleaves favorites with related songs', () async {
    final favorites = [
      _song('favorite-a', artist: 'Favorite A', plays: 12),
      _song('favorite-b', artist: 'Favorite B', plays: 8),
    ];
    final service = NavidromeSimilarityService(
      loadSimilarSongs: (songId, count) async => [
        _song('related-$songId-1', artist: 'Related 1'),
        _song('related-$songId-2', artist: 'Related 2'),
      ],
    );

    final mix = await service.mixFrom(favorites, limit: 6);

    expect(favorites.map((song) => song.id), contains(mix.first.id));
    expect(mix.map((song) => song.id).toSet(), hasLength(mix.length));
    expect(mix.any((song) => song.id.startsWith('related-')), isTrue);
  });
}

Song _song(String id, {required String artist, int plays = 0}) => Song(
  id: id,
  title: 'Song $id',
  artist: artist,
  artistId: 'artist-$artist',
  album: 'Album $id',
  albumId: 'album-$id',
  playCount: plays,
);
