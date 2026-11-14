import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/domain/library/library_mutation_service.dart';
import 'package:navimusic/domain/library/playlist_ordering.dart';
import 'package:navimusic/models/models.dart';

void main() {
  test('last-used playlist comes first and the rest stay alphabetical', () {
    final playlists = [
      Playlist(id: 'z', name: 'Zulu'),
      Playlist(id: 'a', name: 'Alpha'),
      Playlist(id: 'm', name: 'Mix'),
    ];

    final ordered = prioritizeLastPlaylist(playlists, 'm');

    expect(ordered.map((playlist) => playlist.id), ['m', 'a', 'z']);
    expect(playlists.map((playlist) => playlist.id), ['z', 'a', 'm']);
  });

  test('removal resolves the selected duplicate by occurrence', () {
    final songs = [_song('a'), _song('b'), _song('a')];

    expect(playlistOccurrenceIndex(songs, 'a', 0), 0);
    expect(playlistOccurrenceIndex(songs, 'a', 1), 2);
    expect(playlistOccurrenceIndex(songs, 'a', 2), -1);
  });
}

Song _song(String id) => Song(
  id: id,
  title: id,
  artist: 'Artist',
  artistId: 'artist',
  album: 'Album',
  albumId: 'album',
);
