enum SongQuality { any, lossy, lossless, hiRes }

enum SongSort {
  title,
  artist,
  album,
  newest,
  recentlyPlayed,
  mostPlayed,
  random,
  yearNewest,
  durationLongest,
  bitRateHighest,
}

const defaultFavoriteSongFilter = SongFilter(
  favoritesOnly: true,
  sort: SongSort.newest,
);

/// Immutable query contract shared by the Songs controller and SQLite layer.
/// Empty collections mean no restriction.
class SongFilter {
  const SongFilter({
    this.query = '',
    this.genres = const {},
    this.formats = const {},
    this.quality = SongQuality.any,
    this.minimumYear,
    this.maximumYear,
    this.minimumDuration,
    this.maximumDuration,
    this.minimumBitRate,
    this.maximumBitRate,
    this.favoritesOnly = false,
    this.sort = SongSort.title,
    this.randomSeed = 0,
  });

  final String query;
  final Set<String> genres;
  final Set<String> formats;
  final SongQuality quality;
  final int? minimumYear;
  final int? maximumYear;
  final Duration? minimumDuration;
  final Duration? maximumDuration;
  final int? minimumBitRate;
  final int? maximumBitRate;
  final bool favoritesOnly;
  final SongSort sort;
  final int randomSeed;

  factory SongFilter.fromJson(Map<String, dynamic> json) => SongFilter(
    query: json['query'] as String? ?? '',
    genres: (json['genres'] as List? ?? const []).cast<String>().toSet(),
    formats: (json['formats'] as List? ?? const []).cast<String>().toSet(),
    quality: _enumByName(
      SongQuality.values,
      json['quality'] as String?,
      SongQuality.any,
    ),
    minimumYear: json['minimumYear'] as int?,
    maximumYear: json['maximumYear'] as int?,
    minimumDuration: _durationFromMilliseconds(json['minimumDurationMs']),
    maximumDuration: _durationFromMilliseconds(json['maximumDurationMs']),
    minimumBitRate: json['minimumBitRate'] as int?,
    maximumBitRate: json['maximumBitRate'] as int?,
    favoritesOnly: json['favoritesOnly'] as bool? ?? false,
    sort: _enumByName(SongSort.values, json['sort'] as String?, SongSort.title),
    randomSeed: json['randomSeed'] as int? ?? 0,
  ).normalized();

  Map<String, dynamic> toJson() => {
    'query': query,
    'genres': genres.toList(growable: false),
    'formats': formats.toList(growable: false),
    'quality': quality.name,
    'minimumYear': minimumYear,
    'maximumYear': maximumYear,
    'minimumDurationMs': minimumDuration?.inMilliseconds,
    'maximumDurationMs': maximumDuration?.inMilliseconds,
    'minimumBitRate': minimumBitRate,
    'maximumBitRate': maximumBitRate,
    'favoritesOnly': favoritesOnly,
    'sort': sort.name,
    'randomSeed': randomSeed,
  };

  bool get isActive => activeFilterCount > 0;

  int get activeFilterCount => [
    query.trim().isNotEmpty,
    genres.isNotEmpty,
    formats.isNotEmpty,
    quality != SongQuality.any,
    minimumYear != null || maximumYear != null,
    minimumDuration != null || maximumDuration != null,
    minimumBitRate != null || maximumBitRate != null,
    favoritesOnly,
  ].where((active) => active).length;

  SongFilter withQuery(String value) => SongFilter(
    query: value,
    genres: genres,
    formats: formats,
    quality: quality,
    minimumYear: minimumYear,
    maximumYear: maximumYear,
    minimumDuration: minimumDuration,
    maximumDuration: maximumDuration,
    minimumBitRate: minimumBitRate,
    maximumBitRate: maximumBitRate,
    favoritesOnly: favoritesOnly,
    sort: sort,
    randomSeed: randomSeed,
  );

  SongFilter withQuality(SongQuality value) => SongFilter(
    query: query,
    genres: genres,
    formats: formats,
    quality: value,
    minimumYear: minimumYear,
    maximumYear: maximumYear,
    minimumDuration: minimumDuration,
    maximumDuration: maximumDuration,
    minimumBitRate: minimumBitRate,
    maximumBitRate: maximumBitRate,
    favoritesOnly: favoritesOnly,
    sort: sort,
    randomSeed: randomSeed,
  );

  SongFilter withFavoritesOnly(bool value) => SongFilter(
    query: query,
    genres: genres,
    formats: formats,
    quality: quality,
    minimumYear: minimumYear,
    maximumYear: maximumYear,
    minimumDuration: minimumDuration,
    maximumDuration: maximumDuration,
    minimumBitRate: minimumBitRate,
    maximumBitRate: maximumBitRate,
    favoritesOnly: value,
    sort: sort,
    randomSeed: randomSeed,
  );

  SongFilter withSort(SongSort value, {int? randomSeed}) => SongFilter(
    query: query,
    genres: genres,
    formats: formats,
    quality: quality,
    minimumYear: minimumYear,
    maximumYear: maximumYear,
    minimumDuration: minimumDuration,
    maximumDuration: maximumDuration,
    minimumBitRate: minimumBitRate,
    maximumBitRate: maximumBitRate,
    favoritesOnly: favoritesOnly,
    sort: value,
    randomSeed: value == SongSort.random ? (randomSeed ?? this.randomSeed) : 0,
  );

  SongFilter normalized() => SongFilter(
    query: query.trim(),
    genres: genres
        .map((value) => value.trim().toLowerCase())
        .where((value) => value.isNotEmpty)
        .toSet(),
    formats: formats
        .map((value) => value.trim().toLowerCase().replaceFirst('.', ''))
        .where((value) => value.isNotEmpty)
        .toSet(),
    quality: quality,
    minimumYear: minimumYear,
    maximumYear: maximumYear,
    minimumDuration: minimumDuration,
    maximumDuration: maximumDuration,
    minimumBitRate: minimumBitRate,
    maximumBitRate: maximumBitRate,
    favoritesOnly: favoritesOnly,
    sort: sort,
    randomSeed: randomSeed,
  );
}

T _enumByName<T extends Enum>(List<T> values, String? name, T fallback) {
  if (name == null) return fallback;
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}

Duration? _durationFromMilliseconds(Object? value) =>
    value is int && value >= 0 ? Duration(milliseconds: value) : null;
