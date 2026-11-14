import 'package:drift/drift.dart';

import '../../domain/library/catalog_repository.dart';
import '../../domain/library/song_filter.dart';
import '../../domain/library/song_library_repository.dart';
import '../../domain/radio/radio_repository.dart';
import '../../models/models.dart';
import 'app_database.dart';

class DriftRadioRepository implements RadioRepository {
  const DriftRadioRepository({
    required this.database,
    required this.catalog,
    required this.songs,
  });

  final AppDatabase database;
  final CatalogRepository catalog;
  final SongLibraryRepository songs;

  @override
  Future<List<InternetRadioStation>> stations() async =>
      (await (database.select(database.localInternetRadioStations)..orderBy([
                (row) => OrderingTerm.asc(row.name.collate(Collate.noCase)),
              ]))
              .get())
          .map(
            (row) => InternetRadioStation(
              id: row.id,
              name: row.name,
              streamUrl: row.streamUrl,
              homePageUrl: row.homePageUrl,
            ),
          )
          .toList(growable: false);

  @override
  Future<List<String>> genres({int limit = 12}) => catalog.genres(limit: limit);

  @override
  Future<List<ArtistSummary>> artists({int limit = 12}) async {
    final rows = await database
        .customSelect(
          '''
      SELECT
        MIN(a.id) AS id,
        COALESCE(NULLIF(a.sort_name, ''), a.name) AS canonical_name,
        COALESCE(
          MAX(NULLIF(a.cover_art, '')),
          MAX(NULLIF(s.cover_art, ''))
        ) AS cover_art,
        MAX(a.album_count) AS album_count,
        MAX(CASE WHEN a.starred THEN 1 ELSE 0 END) AS starred,
        COALESCE(SUM(s.play_count), 0) AS total_plays
      FROM local_artists a
      LEFT JOIN local_songs s
        ON lower(s.canonical_artist) =
           lower(COALESCE(NULLIF(a.sort_name, ''), a.name))
      GROUP BY lower(COALESCE(NULLIF(a.sort_name, ''), a.name))
      HAVING COUNT(s.id) > 0
      ORDER BY total_plays DESC, canonical_name COLLATE NOCASE
      LIMIT ?
      ''',
          variables: [Variable(limit.clamp(1, 50))],
          readsFrom: {database.localArtists, database.localSongs},
        )
        .get();
    return rows
        .map(
          (row) => ArtistSummary(
            id: row.read<String>('id'),
            name: row.read<String>('canonical_name'),
            coverArt: row.readNullable<String>('cover_art'),
            albumCount: row.read<int>('album_count'),
            starred: row.read<int>('starred') != 0,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<Song>> songsForGenre(String genre, {int limit = 80}) =>
      songs.page(
        filter: SongFilter(genres: {genre}, sort: SongSort.bitRateHighest),
        limit: limit,
        offset: 0,
      );

  @override
  Future<List<Song>> songsForArtist(ArtistSummary artist) =>
      catalog.songsForArtist(artist);
}
