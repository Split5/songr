import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/data/local/app_database.dart';
import 'package:navimusic/domain/library/song_filter.dart';

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await database.upsertSongs([
      _song(
        id: 'mp3-pop',
        title: 'Alpha Pop',
        artist: 'Zara',
        album: 'Venus',
        genre: 'Pop, Dance',
        year: 2024,
        duration: 180,
        bitRate: 320,
        suffix: 'mp3',
        starred: true,
        starredAt: DateTime.utc(2026, 10, 20),
      ),
      _song(
        id: 'flac-cd',
        title: 'Beta Rock',
        artist: 'Aurora',
        album: 'North',
        genre: 'Rock',
        year: 2020,
        duration: 240,
        bitRate: 900,
        bitDepth: 16,
        samplingRate: 44100,
        suffix: 'flac',
      ),
      _song(
        id: 'flac-hires',
        title: 'Gamma Light',
        artist: 'M83',
        album: 'Midnight',
        genre: 'Electronic, Pop',
        year: 2025,
        duration: 300,
        bitRate: 3010,
        bitDepth: 24,
        samplingRate: 96000,
        suffix: 'flac',
        starred: true,
        starredAt: DateTime.utc(2026, 10, 26),
      ),
      _song(
        id: 'm4a-jazz',
        title: 'Delta Blue',
        artist: 'Miles',
        album: 'Evening',
        genre: 'Jazz',
        year: 2010,
        duration: 120,
        bitRate: 256,
        playCount: 9,
        suffix: 'm4a',
      ),
      _song(
        id: 'wav-hires',
        title: 'Epsilon Field',
        artist: 'Nils',
        album: 'Room',
        genre: 'Ambient',
        year: 2022,
        duration: 480,
        bitRate: 4608,
        bitDepth: 24,
        samplingRate: 96000,
        suffix: 'wav',
      ),
    ]);
  });

  tearDown(() => database.close());

  test('quality filters distinguish lossy, lossless and Hi-Res', () async {
    expect(await _ids(database, quality: SongQuality.lossy), [
      'mp3-pop',
      'm4a-jazz',
    ]);
    expect(await _ids(database, quality: SongQuality.lossless), [
      'wav-hires',
      'flac-hires',
      'flac-cd',
    ]);
    expect(await _ids(database, quality: SongQuality.hiRes), [
      'wav-hires',
      'flac-hires',
    ]);
  });

  test('genre, year, duration and favorite filters compose in SQL', () async {
    const filter = SongFilter(
      genres: {'pop'},
      minimumYear: 2024,
      maximumDuration: Duration(minutes: 4),
      favoritesOnly: true,
    );

    expect(await database.filteredSongCount(filter), 1);
    expect(
      (await database.filteredSongsPage(filter: filter)).single.id,
      'mp3-pop',
    );
  });

  test('favorite newest sort uses the favorite timestamp', () async {
    final ids = (await database.filteredSongsPage(
      filter: defaultFavoriteSongFilter,
    )).map((song) => song.id).toList();

    expect(ids, ['flac-hires', 'mp3-pop']);

    await database.setSongStarred(
      'flac-cd',
      starred: true,
      starredAt: DateTime.utc(2026, 10, 27),
    );
    final updated = (await database.filteredSongsPage(
      filter: defaultFavoriteSongFilter,
    )).map((song) => song.id).toList();
    expect(updated, ['flac-cd', 'flac-hires', 'mp3-pop']);
  });

  test('genre filters match complete tokens, not substrings', () async {
    await database.upsertSongs([
      _song(
        id: 'k-pop',
        title: 'K Pop',
        artist: 'Artist',
        album: 'Album',
        genre: 'K-Pop',
        year: 2024,
        duration: 180,
        bitRate: 320,
        suffix: 'mp3',
      ),
    ]);

    const filter = SongFilter(genres: {'pop'});
    expect(
      (await database.filteredSongsPage(filter: filter)).map((song) => song.id),
      ['mp3-pop', 'flac-hires'],
    );
  });

  test('format values are normalized before querying', () async {
    const filter = SongFilter(formats: {'.FLAC'});

    expect(
      (await database.filteredSongsPage(filter: filter)).map((song) => song.id),
      ['flac-cd', 'flac-hires'],
    );
  });

  test(
    'search covers title, artist and album without loading all rows',
    () async {
      expect(await _queryIds(database, 'aurora'), ['flac-cd']);
      expect(await _queryIds(database, 'midnight'), ['flac-hires']);
      expect(await _queryIds(database, 'alpha'), ['mp3-pop']);
    },
  );

  test('technical sort orders stay deterministic', () async {
    const filter = SongFilter(sort: SongSort.bitRateHighest);
    expect(
      (await database.filteredSongsPage(filter: filter)).map((song) => song.id),
      ['wav-hires', 'flac-hires', 'flac-cd', 'mp3-pop', 'm4a-jazz'],
    );
  });

  test('playback, play count and seeded random sorting are stable', () async {
    await database
        .into(database.localSongActivities)
        .insert(
          LocalSongActivitiesCompanion.insert(
            songId: 'mp3-pop',
            lastPlayedAt: Value(DateTime.utc(2026, 10, 26)),
            updatedAt: DateTime.utc(2026, 10, 26),
          ),
        );

    Future<List<String>> ids(SongSort sort, {int seed = 0}) async =>
        (await database.filteredSongsPage(
          filter: SongFilter(sort: sort, randomSeed: seed),
        )).map((song) => song.id).toList();

    expect((await ids(SongSort.recentlyPlayed)).first, 'mp3-pop');
    expect((await ids(SongSort.mostPlayed)).first, 'm4a-jazz');
    expect(
      await ids(SongSort.random, seed: 123),
      await ids(SongSort.random, seed: 123),
    );
    expect(
      await ids(SongSort.random, seed: 123),
      isNot(await ids(SongSort.random, seed: 456)),
    );
  });

  test('filtered count equals all paged results', () async {
    const filter = SongFilter(minimumYear: 2020, sort: SongSort.title);
    final count = await database.filteredSongCount(filter);
    final first = await database.filteredSongsPage(filter: filter, limit: 2);
    final second = await database.filteredSongsPage(
      filter: filter,
      limit: 2,
      offset: 2,
    );

    expect(count, 4);
    expect([...first, ...second].map((song) => song.id), [
      'mp3-pop',
      'flac-cd',
      'wav-hires',
      'flac-hires',
    ]);
  });

  test('active filter count treats ranges as one user-facing filter', () {
    const filter = SongFilter(
      query: '  light ',
      formats: {'.FLAC'},
      minimumYear: 2020,
      maximumYear: 2026,
      minimumBitRate: 800,
      quality: SongQuality.lossless,
    );

    expect(filter.activeFilterCount, 5);
    expect(filter.normalized().query, 'light');
    expect(filter.normalized().formats, {'flac'});
  });

  test('saved filter JSON preserves every query field', () {
    const filter = SongFilter(
      query: '  light ',
      genres: {'Pop'},
      formats: {'.FLAC'},
      quality: SongQuality.hiRes,
      minimumYear: 2010,
      maximumYear: 2026,
      minimumDuration: Duration(minutes: 2),
      maximumDuration: Duration(minutes: 8),
      minimumBitRate: 800,
      maximumBitRate: 5000,
      favoritesOnly: true,
      sort: SongSort.bitRateHighest,
    );

    final restored = SongFilter.fromJson(filter.toJson());
    expect(restored.query, 'light');
    expect(restored.genres, {'pop'});
    expect(restored.formats, {'flac'});
    expect(restored.quality, SongQuality.hiRes);
    expect(restored.minimumYear, 2010);
    expect(restored.maximumYear, 2026);
    expect(restored.minimumDuration, const Duration(minutes: 2));
    expect(restored.maximumDuration, const Duration(minutes: 8));
    expect(restored.minimumBitRate, 800);
    expect(restored.maximumBitRate, 5000);
    expect(restored.favoritesOnly, isTrue);
    expect(restored.sort, SongSort.bitRateHighest);

    final random = SongFilter.fromJson(
      const SongFilter(sort: SongSort.random, randomSeed: 1234).toJson(),
    );
    expect(random.sort, SongSort.random);
    expect(random.randomSeed, 1234);
  });
}

Future<List<String>> _ids(
  AppDatabase database, {
  required SongQuality quality,
}) async => (await database.filteredSongsPage(
  filter: SongFilter(quality: quality, sort: SongSort.bitRateHighest),
)).map((song) => song.id).toList();

Future<List<String>> _queryIds(AppDatabase database, String query) async =>
    (await database.filteredSongsPage(
      filter: SongFilter(query: query),
    )).map((song) => song.id).toList();

LocalSongsCompanion _song({
  required String id,
  required String title,
  required String artist,
  required String album,
  required String genre,
  required int year,
  required int duration,
  required int bitRate,
  required String suffix,
  int? bitDepth,
  int? samplingRate,
  bool starred = false,
  DateTime? starredAt,
  int playCount = 0,
}) => LocalSongsCompanion.insert(
  id: id,
  title: title,
  artist: artist,
  album: album,
  genre: Value(genre),
  year: Value(year),
  duration: Value(duration),
  bitRate: Value(bitRate),
  bitDepth: Value(bitDepth),
  samplingRate: Value(samplingRate),
  suffix: Value(suffix),
  starred: Value(starred),
  starredAt: Value(starredAt),
  playCount: Value(playCount),
);
