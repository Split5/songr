import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/app/v2/song_menu_entries.dart';
import 'package:navimusic/l10n/app_localizations_sv.dart';
import 'package:navimusic/models/models.dart';

void main() {
  final l = AppLocalizationsSv();
  final lastPlaylist = Playlist(id: 'p1', name: 'Kväll');

  test('composes the full superset in the requested order', () {
    final calls = <String>[];
    final entries = songMenuEntries(
      l: l,
      song: _song(),
      downloaded: false,
      lastPlaylist: lastPlaylist,
      actions: _recording(calls),
    );

    expect(entries.map((entry) => entry.label), [
      'Favorit',
      'Spela härnäst',
      'Lägg till i kön',
      'Lägg till i spellista',
      'Lägg till i ”Kväll”',
      'Gå till album',
      'Gå till artist',
      'Skapa mix från låt',
      'Skapa spellista med liknande låtar',
      'Ladda ner',
      'Dela',
    ]);
    expect(entries[4].subtitle, 'Senast använda spellista');
    expect(entries.any((entry) => entry.destructive), isFalse);

    for (final entry in entries) {
      entry.onTap();
    }
    expect(calls, [
      'favorite',
      'playNext',
      'addToQueue',
      'addToPlaylist',
      'addToLast:p1',
      'goToAlbum',
      'goToArtist',
      'createMix',
      'createSimilarPlaylist',
      'download',
      'share',
    ]);
  });

  test('flips favorite and download entries and appends playlist removal', () {
    final calls = <String>[];
    final entries = songMenuEntries(
      l: l,
      song: _song(starred: true),
      downloaded: true,
      actions: _recording(calls, inPlaylist: true),
    );

    expect(entries.first.label, 'Ta bort favorit');
    expect(
      entries.map((entry) => entry.label),
      isNot(contains('Lägg till i ”Kväll”')),
    );
    expect(
      entries.map((entry) => entry.label),
      contains('Ta bort nedladdning'),
    );
    expect(entries.last.label, 'Ta bort från spellistan');
    expect(entries.last.destructive, isTrue);

    entries.firstWhere((entry) => entry.label == 'Ta bort nedladdning').onTap();
    entries.last.onTap();
    expect(calls, ['removeDownload', 'removeFromPlaylist']);
  });

  test('offers album and artist navigation only when the id is known', () {
    List<String> labels({required String albumId, required String artistId}) =>
        songMenuEntries(
          l: l,
          song: _song(albumId: albumId, artistId: artistId),
          downloaded: false,
          actions: _recording([]),
        ).map((entry) => entry.label).toList();

    expect(
      labels(albumId: '', artistId: 'a'),
      allOf(isNot(contains('Gå till album')), contains('Gå till artist')),
    );
    expect(
      labels(albumId: 'al', artistId: ''),
      allOf(contains('Gå till album'), isNot(contains('Gå till artist'))),
    );
    expect(
      labels(albumId: '', artistId: ''),
      allOf(
        isNot(contains('Gå till album')),
        isNot(contains('Gå till artist')),
      ),
    );
  });
}

Song _song({
  bool starred = false,
  String albumId = 'al',
  String artistId = 'a',
}) => Song(
  id: 's',
  title: 'Låten',
  artist: 'Artisten',
  artistId: artistId,
  album: 'Albumet',
  albumId: albumId,
  starred: starred,
);

SongMenuActions _recording(List<String> calls, {bool inPlaylist = false}) =>
    SongMenuActions(
      toggleFavorite: () => calls.add('favorite'),
      playNext: () => calls.add('playNext'),
      addToQueue: () => calls.add('addToQueue'),
      addToPlaylist: () => calls.add('addToPlaylist'),
      addToLastPlaylist: (playlist) => calls.add('addToLast:${playlist.id}'),
      goToAlbum: () => calls.add('goToAlbum'),
      goToArtist: () => calls.add('goToArtist'),
      createMix: () => calls.add('createMix'),
      createSimilarPlaylist: () => calls.add('createSimilarPlaylist'),
      download: () => calls.add('download'),
      removeDownload: () => calls.add('removeDownload'),
      share: () => calls.add('share'),
      removeFromPlaylist: inPlaylist
          ? () => calls.add('removeFromPlaylist')
          : null,
    );
