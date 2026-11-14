import '../../models/models.dart';

abstract interface class RadioRepository {
  Future<List<InternetRadioStation>> stations();
  Future<List<String>> genres({int limit = 12});
  Future<List<ArtistSummary>> artists({int limit = 12});
  Future<List<Song>> songsForGenre(String genre, {int limit = 80});
  Future<List<Song>> songsForArtist(ArtistSummary artist);
}
