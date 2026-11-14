import '../../../domain/library/song_filter.dart';
import '../../../l10n/app_localizations.dart';

/// Localized label for a [SongSort], shared by every surface that sorts
/// songs (the Songs browser, Favorites, sort sheets).
String songSortLabel(AppLocalizations l, SongSort sort) => switch (sort) {
  SongSort.title => l.sortTitle,
  SongSort.artist => l.sortArtist,
  SongSort.album => l.sortAlbum,
  SongSort.newest => l.sortRecent,
  SongSort.recentlyPlayed => l.sortRecentlyPlayed,
  SongSort.mostPlayed => l.sortPlays,
  SongSort.random => l.sortRandom,
  SongSort.yearNewest => l.sortYear,
  SongSort.durationLongest => l.sortDuration,
  SongSort.bitRateHighest => l.sortBitRate,
};
