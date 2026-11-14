import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/models/models.dart';

void main() {
  group('primaryArtistName', () {
    test('takes the first name of a comma-separated collaboration', () {
      expect(primaryArtistName('Justin Bieber,Kehlani'), 'Justin Bieber');
      expect(primaryArtistName('Justin Bieber, Quavo'), 'Justin Bieber');
      expect(primaryArtistName('Chappell Roan'), 'Chappell Roan');
      expect(primaryArtistName(''), '');
    });

    test('semicolons separate too, but "&" belongs to band names', () {
      expect(primaryArtistName('Alan Walker; Sorana'), 'Alan Walker');
      expect(primaryArtistName('Madonna;Sickick'), 'Madonna');
      expect(primaryArtistName('Norlie & KKV'), 'Norlie & KKV');
    });

    test('surrounding whitespace never leaks into the main artist', () {
      expect(primaryArtistName('  Alan Walker ;Sorana'), 'Alan Walker');
      expect(primaryArtistName('Norlie & KKV , Molly'), 'Norlie & KKV');
    });
  });

  group('Song toJson/fromJson round-trip', () {
    test('preserves every field, including a starred flag', () {
      final song = Song(
        id: 's1',
        title: 'Title',
        artist: 'Artist',
        artistId: 'a1',
        album: 'Album',
        albumId: 'al1',
        coverArt: 'cover1',
        duration: 200,
        playCount: 5,
        year: 2024,
        bitRate: 320,
        bitDepth: 24,
        samplingRate: 96000,
        fileSize: 73400320,
        track: 4,
        disc: 2,
        suffix: 'flac',
        contentType: 'audio/flac',
        comment: 'https://youtu.be/x',
        created: DateTime(2026, 1, 2),
        lastPlayed: DateTime(2026, 8, 28, 10, 30),
        genre: 'Pop',
        starred: true,
      );
      final restored = Song.fromJson(song.toJson());
      expect(restored.id, song.id);
      expect(restored.title, song.title);
      expect(restored.artist, song.artist);
      expect(restored.artistId, song.artistId);
      expect(restored.album, song.album);
      expect(restored.albumId, song.albumId);
      expect(restored.coverArt, song.coverArt);
      expect(restored.duration, song.duration);
      expect(restored.playCount, song.playCount);
      expect(restored.year, song.year);
      expect(restored.bitRate, song.bitRate);
      expect(restored.bitDepth, song.bitDepth);
      expect(restored.samplingRate, song.samplingRate);
      expect(restored.fileSize, song.fileSize);
      expect(restored.track, song.track);
      expect(restored.disc, song.disc);
      expect(restored.suffix, song.suffix);
      expect(restored.contentType, song.contentType);
      expect(restored.comment, song.comment);
      expect(restored.created, song.created);
      expect(restored.lastPlayed, song.lastPlayed);
      expect(restored.genre, song.genre);
      expect(restored.starred, isTrue);
    });

    test('an unstarred song round-trips as unstarred', () {
      final song = Song(
        id: 's2',
        title: 't',
        artist: 'a',
        artistId: 'a1',
        album: 'al',
        albumId: 'al1',
      );
      final restored = Song.fromJson(song.toJson());
      expect(restored.starred, isFalse);
    });
  });

  group('Album/ArtistSummary toJson/fromJson round-trip', () {
    test('Album preserves fields and starred flag', () {
      final album = Album(
        id: 'al1',
        name: 'Album',
        artist: 'Artist',
        artistId: 'a1',
        songCount: 10,
        starred: true,
      );
      final restored = Album.fromJson(album.toJson());
      expect(restored.id, album.id);
      expect(restored.name, album.name);
      expect(restored.songCount, album.songCount);
      expect(restored.starred, isTrue);
    });

    test('ArtistSummary preserves fields and starred flag', () {
      final artist = ArtistSummary(
        id: 'a1',
        name: 'Artist',
        albumCount: 3,
        starred: true,
      );
      final restored = ArtistSummary.fromJson(artist.toJson());
      expect(restored.id, artist.id);
      expect(restored.name, artist.name);
      expect(restored.albumCount, artist.albumCount);
      expect(restored.starred, isTrue);
    });
  });
}
