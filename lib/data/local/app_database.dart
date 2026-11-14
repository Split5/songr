import 'package:drift/drift.dart';

import '../../domain/diagnostics/diagnostic_text.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../domain/library/song_filter.dart';
import '../../models/models.dart';

part 'app_database.g.dart';

class RecentLocalPlay {
  const RecentLocalPlay({
    required this.song,
    required this.playedAt,
    required this.effectivePlayCount,
  });

  final LocalSong song;
  final DateTime playedAt;
  final int effectivePlayCount;
}

class PendingFavoriteMutation {
  const PendingFavoriteMutation({
    required this.id,
    required this.songId,
    required this.starred,
  });

  final int id;
  final String songId;
  final bool starred;
}

class LocalArtists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get sortName => text().nullable()();
  TextColumn get coverArt => text().nullable()();
  IntColumn get albumCount => integer().withDefault(const Constant(0))();
  BoolColumn get starred => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalAlbums extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get artistId => text().nullable()();
  TextColumn get artist => text()();
  TextColumn get canonicalArtist => text().withDefault(const Constant(''))();
  IntColumn get year => integer().withDefault(const Constant(0))();
  IntColumn get songCount => integer().withDefault(const Constant(0))();
  IntColumn get duration => integer().withDefault(const Constant(0))();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  TextColumn get coverArt => text().nullable()();
  BoolColumn get starred => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class StagedArtists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get sortName => text().nullable()();
  TextColumn get coverArt => text().nullable()();
  IntColumn get albumCount => integer().withDefault(const Constant(0))();
  BoolColumn get starred => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class StagedAlbums extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get artistId => text().nullable()();
  TextColumn get artist => text()();
  TextColumn get canonicalArtist => text().withDefault(const Constant(''))();
  IntColumn get year => integer().withDefault(const Constant(0))();
  IntColumn get songCount => integer().withDefault(const Constant(0))();
  IntColumn get duration => integer().withDefault(const Constant(0))();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  TextColumn get coverArt => text().nullable()();
  BoolColumn get starred => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalSongs extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get albumId => text().nullable()();
  TextColumn get album => text()();
  TextColumn get artistId => text().nullable()();
  TextColumn get artist => text()();
  TextColumn get canonicalArtist => text().withDefault(const Constant(''))();
  IntColumn get track => integer().withDefault(const Constant(0))();
  IntColumn get disc => integer().withDefault(const Constant(0))();
  IntColumn get year => integer().withDefault(const Constant(0))();
  TextColumn get genre => text().nullable()();
  IntColumn get duration => integer().withDefault(const Constant(0))();
  IntColumn get bitRate => integer().nullable()();
  IntColumn get bitDepth => integer().nullable()();
  IntColumn get samplingRate => integer().nullable()();
  TextColumn get suffix => text().nullable()();
  TextColumn get contentType => text().nullable()();
  IntColumn get fileSize => integer().nullable()();
  TextColumn get coverArt => text().nullable()();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  BoolColumn get starred => boolean().withDefault(const Constant(false))();
  DateTimeColumn get starredAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get lastPlayedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Full-sync staging area. UI never reads this table. A completed server scan
/// atomically replaces [LocalSongs] from here; a failed scan simply clears it,
/// leaving the last known-good library untouched.
class StagedSongs extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get albumId => text().nullable()();
  TextColumn get album => text()();
  TextColumn get artistId => text().nullable()();
  TextColumn get artist => text()();
  TextColumn get canonicalArtist => text().withDefault(const Constant(''))();
  IntColumn get track => integer().withDefault(const Constant(0))();
  IntColumn get disc => integer().withDefault(const Constant(0))();
  IntColumn get year => integer().withDefault(const Constant(0))();
  TextColumn get genre => text().nullable()();
  IntColumn get duration => integer().withDefault(const Constant(0))();
  IntColumn get bitRate => integer().nullable()();
  IntColumn get bitDepth => integer().nullable()();
  IntColumn get samplingRate => integer().nullable()();
  TextColumn get suffix => text().nullable()();
  TextColumn get contentType => text().nullable()();
  IntColumn get fileSize => integer().nullable()();
  TextColumn get coverArt => text().nullable()();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  BoolColumn get starred => boolean().withDefault(const Constant(false))();
  DateTimeColumn get starredAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get lastPlayedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalPlaylists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get coverArt => text().nullable()();
  IntColumn get songCount => integer().withDefault(const Constant(0))();
  IntColumn get duration => integer().withDefault(const Constant(0))();
  BoolColumn get serverReadOnly =>
      boolean().withDefault(const Constant(false))();
  TextColumn get owner => text().withDefault(const Constant(''))();
  BoolColumn get isPublic => boolean().withDefault(const Constant(false))();
  BoolColumn get isGenerated => boolean().withDefault(const Constant(false))();
  DateTimeColumn get changedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class StagedPlaylists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get coverArt => text().nullable()();
  IntColumn get songCount => integer().withDefault(const Constant(0))();
  IntColumn get duration => integer().withDefault(const Constant(0))();
  BoolColumn get serverReadOnly =>
      boolean().withDefault(const Constant(false))();
  TextColumn get owner => text().withDefault(const Constant(''))();
  BoolColumn get isPublic => boolean().withDefault(const Constant(false))();
  BoolColumn get isGenerated => boolean().withDefault(const Constant(false))();
  DateTimeColumn get changedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalPlaylistEntries extends Table {
  TextColumn get playlistId => text()();
  TextColumn get songId => text()();
  IntColumn get position => integer()();

  @override
  Set<Column<Object>> get primaryKey => {playlistId, position};
}

class StagedPlaylistEntries extends Table {
  TextColumn get playlistId => text()();
  TextColumn get songId => text()();
  IntColumn get position => integer()();

  @override
  Set<Column<Object>> get primaryKey => {playlistId, position};
}

class LocalFavorites extends Table {
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  DateTimeColumn get starredAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {entityType, entityId};
}

class LocalInternetRadioStations extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get streamUrl => text()();
  TextColumn get homePageUrl => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SyncStates extends Table {
  TextColumn get scope => text()();
  TextColumn get cursor => text().nullable()();
  DateTimeColumn get lastSuccessfulAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {scope};
}

class PendingMutations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get kind => text()();
  TextColumn get entityId => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
}

/// One immutable identity per playback occurrence. This history survives a
/// catalogue refresh because song snapshots are replaceable server data while
/// listening activity is local user data.
class LocalPlayEvents extends Table {
  TextColumn get playbackId => text()();
  TextColumn get songId => text()();
  DateTimeColumn get startedAt => dateTime()();
  IntColumn get durationMilliseconds =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get scrobbledAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  BoolColumn get skipped => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {playbackId};
}

/// Fast per-song activity used by Home and Replay without scanning the event
/// log. [unacknowledgedPlayCount] is reduced when a later Navidrome snapshot
/// contains the corresponding server-side play-count increase.
class LocalSongActivities extends Table {
  TextColumn get songId => text()();
  IntColumn get localPlayCount => integer().withDefault(const Constant(0))();
  IntColumn get unacknowledgedPlayCount =>
      integer().withDefault(const Constant(0))();
  IntColumn get serverPlayCountSeen =>
      integer().withDefault(const Constant(0))();
  IntColumn get skipCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastStartedAt => dateTime().nullable()();
  DateTimeColumn get lastPlayedAt => dateTime().nullable()();
  DateTimeColumn get lastCompletedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {songId};
}

class LocalQueueSessions extends Table {
  TextColumn get id => text()();
  TextColumn get currentEntryId => text().nullable()();
  BoolColumn get autoPlayEnabled =>
      boolean().withDefault(const Constant(true))();
  IntColumn get positionMilliseconds =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalQueueEntries extends Table {
  TextColumn get sessionId => text()();
  TextColumn get entryId => text()();
  TextColumn get songId => text()();
  IntColumn get position => integer()();

  @override
  Set<Column<Object>> get primaryKey => {sessionId, entryId};
}

class SavedQueueSnapshots extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get currentIndex => integer()();
  BoolColumn get autoPlayEnabled =>
      boolean().withDefault(const Constant(true))();
  IntColumn get positionMilliseconds =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SavedQueueSnapshotEntries extends Table {
  TextColumn get snapshotId => text()();
  TextColumn get songId => text()();
  IntColumn get position => integer()();

  @override
  Set<Column<Object>> get primaryKey => {snapshotId, position};
}

/// Cached OpenSubsonic lyrics. A null [lrc] is a deliberate negative cache so
/// an unavailable lyric does not trigger a network request on every opening.
class LocalLyrics extends Table {
  TextColumn get songId => text()();
  TextColumn get lrc => text().nullable()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {songId};
}

@DriftDatabase(
  tables: [
    LocalArtists,
    LocalAlbums,
    StagedArtists,
    StagedAlbums,
    LocalSongs,
    StagedSongs,
    LocalPlaylists,
    StagedPlaylists,
    LocalPlaylistEntries,
    StagedPlaylistEntries,
    LocalFavorites,
    LocalInternetRadioStations,
    SyncStates,
    PendingMutations,
    LocalPlayEvents,
    LocalSongActivities,
    LocalQueueSessions,
    LocalQueueEntries,
    SavedQueueSnapshots,
    SavedQueueSnapshotEntries,
    LocalLyrics,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase()
    : super(
        driftDatabase(
          name: 'navimusic-v2',
          native: const DriftNativeOptions(shareAcrossIsolates: true),
        ),
      );

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _createIndexes();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) await migrator.createTable(stagedSongs);
      if (from < 3) {
        await migrator.createTable(localPlayEvents);
        await migrator.createTable(localSongActivities);
      }
      if (from < 4) {
        await migrator.addColumn(localAlbums, localAlbums.playCount);
        await migrator.addColumn(localPlaylists, localPlaylists.owner);
        await migrator.addColumn(localPlaylists, localPlaylists.isPublic);
        await migrator.addColumn(localPlaylists, localPlaylists.isGenerated);
        await migrator.createTable(stagedArtists);
        await migrator.createTable(stagedAlbums);
        await migrator.createTable(stagedPlaylists);
        await migrator.createTable(stagedPlaylistEntries);
      }
      if (from < 5) {
        await migrator.addColumn(localAlbums, localAlbums.canonicalArtist);
        await migrator.addColumn(localSongs, localSongs.canonicalArtist);
        await migrator.addColumn(stagedAlbums, stagedAlbums.canonicalArtist);
        await migrator.addColumn(stagedSongs, stagedSongs.canonicalArtist);
      }
      if (from < 6) {
        await migrator.createTable(localInternetRadioStations);
      }
      if (from < 7) {
        await migrator.createTable(localQueueSessions);
        await migrator.createTable(localQueueEntries);
      }
      if (from < 8) await migrator.createTable(localLyrics);
      if (from < 9) {
        await migrator.createTable(savedQueueSnapshots);
        await migrator.createTable(savedQueueSnapshotEntries);
      }
      if (from < 10) {
        await migrator.addColumn(localSongs, localSongs.starredAt);
        await migrator.addColumn(stagedSongs, stagedSongs.starredAt);
        await customStatement('''
          UPDATE local_songs
          SET starred_at = (
            SELECT starred_at FROM local_favorites
            WHERE entity_type = 'song' AND entity_id = local_songs.id
          )
          WHERE starred = 1
        ''');
      }
      await _createIndexes();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA journal_mode = WAL');
    },
  );

  Future<void> _createIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS songs_title_idx ON local_songs(title COLLATE NOCASE)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS songs_artist_idx ON local_songs(artist COLLATE NOCASE)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS songs_canonical_artist_idx ON local_songs(canonical_artist COLLATE NOCASE)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS songs_album_idx ON local_songs(album_id, disc, track)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS songs_created_idx ON local_songs(created_at DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS songs_last_played_idx ON local_songs(last_played_at DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS songs_starred_at_idx ON local_songs(starred_at DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS playlist_entries_song_idx ON local_playlist_entries(song_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS albums_created_idx ON local_albums(created_at DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS albums_canonical_idx ON local_albums(canonical_artist COLLATE NOCASE, name COLLATE NOCASE)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS artists_name_idx ON local_artists(name COLLATE NOCASE)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS playlists_generated_idx ON local_playlists(is_generated, name COLLATE NOCASE)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS pending_mutations_created_idx ON pending_mutations(created_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS play_events_song_started_idx ON local_play_events(song_id, started_at DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS song_activities_recent_idx ON local_song_activities(last_played_at DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS queue_entries_position_idx ON local_queue_entries(session_id, position)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS saved_queue_snapshot_entries_position_idx ON saved_queue_snapshot_entries(snapshot_id, position)',
    );
  }

  Future<void> replaceInternetRadioStations(
    Iterable<LocalInternetRadioStationsCompanion> stations,
  ) => transaction(() async {
    await delete(localInternetRadioStations).go();
    final values = stations.toList(growable: false);
    if (values.isNotEmpty) {
      await batch(
        (batch) => batch.insertAll(localInternetRadioStations, values),
      );
    }
  });

  Future<void> setSongStarred(
    String songId, {
    required bool starred,
    DateTime? starredAt,
  }) => transaction(() async {
    await (update(localSongs)..where((row) => row.id.equals(songId))).write(
      LocalSongsCompanion(
        starred: Value(starred),
        starredAt: Value(starred ? starredAt ?? DateTime.now() : null),
      ),
    );
    await (delete(localFavorites)..where(
          (row) => row.entityType.equals('song') & row.entityId.equals(songId),
        ))
        .go();
    if (starred) {
      await into(localFavorites).insertOnConflictUpdate(
        LocalFavoritesCompanion.insert(
          entityType: 'song',
          entityId: songId,
          starredAt: Value(starredAt ?? DateTime.now()),
        ),
      );
    }
  });

  Future<void> queueFavoriteMutation({
    required String songId,
    required bool starred,
  }) => transaction(() async {
    await (delete(pendingMutations)..where(
          (row) => row.kind.equals('favorite') & row.entityId.equals(songId),
        ))
        .go();
    await into(pendingMutations).insert(
      PendingMutationsCompanion.insert(
        kind: 'favorite',
        entityId: songId,
        payloadJson: '$starred',
        createdAt: DateTime.now(),
      ),
    );
  });

  Future<List<PendingFavoriteMutation>> pendingFavoriteMutations() async {
    final rows =
        await (select(pendingMutations)
              ..where((row) => row.kind.equals('favorite'))
              ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
            .get();
    return rows
        .map(
          (row) => PendingFavoriteMutation(
            id: row.id,
            songId: row.entityId,
            starred: row.payloadJson == 'true',
          ),
        )
        .toList(growable: false);
  }

  Future<void> deletePendingMutation(int id) =>
      (delete(pendingMutations)..where((row) => row.id.equals(id))).go();

  Future<int> songCount() async {
    final count = localSongs.id.count();
    final row = await (selectOnly(localSongs)..addColumns([count])).getSingle();
    return row.read(count) ?? 0;
  }

  Future<List<LocalSong>> songsPage({
    int limit = 100,
    int offset = 0,
    String? query,
  }) {
    final statement = select(localSongs)
      ..orderBy([(row) => OrderingTerm.asc(row.title)])
      ..limit(limit.clamp(1, 500), offset: offset < 0 ? 0 : offset);
    final normalized = query?.trim();
    if (normalized != null && normalized.isNotEmpty) {
      statement.where(
        (row) =>
            row.title.contains(normalized) |
            row.artist.contains(normalized) |
            row.album.contains(normalized),
      );
    }
    return statement.get();
  }

  Future<List<LocalSong>> filteredSongsPage({
    required SongFilter filter,
    int limit = 100,
    int offset = 0,
  }) {
    final normalized = filter.normalized();
    final statement = select(localSongs)
      ..where((row) => _songFilterExpression(row, normalized))
      ..orderBy(_songOrdering(normalized))
      ..limit(limit.clamp(1, 500), offset: offset < 0 ? 0 : offset);
    return statement.get();
  }

  Future<int> filteredSongCount(SongFilter filter) async {
    final normalized = filter.normalized();
    final count = localSongs.id.count();
    final row =
        await (selectOnly(localSongs)
              ..addColumns([count])
              ..where(_songFilterExpression(localSongs, normalized)))
            .getSingle();
    return row.read(count) ?? 0;
  }

  Expression<bool> _songFilterExpression(
    $LocalSongsTable row,
    SongFilter filter,
  ) {
    Expression<bool> result = const Constant(true);
    if (filter.query.isNotEmpty) {
      result =
          result &
          (row.title.contains(filter.query) |
              row.artist.contains(filter.query) |
              row.album.contains(filter.query));
    }

    if (filter.genres.isNotEmpty) {
      Expression<bool> genreExpression = const Constant(false);
      for (final genre in filter.genres) {
        genreExpression = genreExpression | _containsGenreToken(genre.trim());
      }
      result = result & row.genre.isNotNull() & genreExpression;
    }

    final formats = filter.formats;
    if (formats.isNotEmpty) {
      result = result & row.suffix.lower().isIn(formats);
    }

    const losslessFormats = {
      'flac',
      'alac',
      'wav',
      'wave',
      'aif',
      'aiff',
      'ape',
    };
    final lossless = row.suffix.lower().isIn(losslessFormats);
    switch (filter.quality) {
      case SongQuality.any:
        break;
      case SongQuality.lossy:
        result = result & row.suffix.isNotNull() & lossless.not();
      case SongQuality.lossless:
        result = result & lossless;
      case SongQuality.hiRes:
        result =
            result &
            lossless &
            (row.bitDepth.isBiggerThanValue(16) |
                row.samplingRate.isBiggerThanValue(48000));
    }

    if (filter.minimumYear case final value?) {
      result = result & row.year.isBiggerOrEqualValue(value);
    }
    if (filter.maximumYear case final value?) {
      result = result & row.year.isSmallerOrEqualValue(value);
    }
    if (filter.minimumDuration case final value?) {
      result = result & row.duration.isBiggerOrEqualValue(value.inSeconds);
    }
    if (filter.maximumDuration case final value?) {
      result = result & row.duration.isSmallerOrEqualValue(value.inSeconds);
    }
    if (filter.minimumBitRate case final value?) {
      result = result & row.bitRate.isBiggerOrEqualValue(value);
    }
    if (filter.maximumBitRate case final value?) {
      result = result & row.bitRate.isSmallerOrEqualValue(value);
    }
    if (filter.favoritesOnly) result = result & row.starred.equals(true);
    return result;
  }

  List<OrderClauseGenerator<$LocalSongsTable>> _songOrdering(
    SongFilter filter,
  ) => switch (filter.sort) {
    SongSort.title => [
      (row) => OrderingTerm.asc(row.title.collate(Collate.noCase)),
      (row) => OrderingTerm.asc(row.artist.collate(Collate.noCase)),
    ],
    SongSort.artist => [
      (row) => OrderingTerm.asc(row.artist.collate(Collate.noCase)),
      (row) => OrderingTerm.asc(row.title.collate(Collate.noCase)),
    ],
    SongSort.album => [
      (row) => OrderingTerm.asc(row.album.collate(Collate.noCase)),
      (row) => OrderingTerm.asc(row.disc),
      (row) => OrderingTerm.asc(row.track),
      (row) => OrderingTerm.asc(row.title.collate(Collate.noCase)),
    ],
    SongSort.newest =>
      filter.favoritesOnly
          ? [
              (row) => OrderingTerm.desc(
                const CustomExpression<int>(
                  'COALESCE(local_songs.starred_at, local_songs.created_at, 0)',
                ),
              ),
              (row) => OrderingTerm.asc(row.title.collate(Collate.noCase)),
            ]
          : [
              (row) => OrderingTerm.desc(row.createdAt),
              (row) => OrderingTerm.asc(row.title.collate(Collate.noCase)),
            ],
    SongSort.recentlyPlayed => [
      (row) => OrderingTerm.desc(
        const CustomExpression<int>(
          'COALESCE((SELECT MAX(COALESCE(activity.last_played_at, local_songs.last_played_at)) '
          'FROM local_song_activities AS activity '
          'WHERE activity.song_id = local_songs.id), local_songs.last_played_at, 0)',
        ),
      ),
      (row) => OrderingTerm.asc(row.title.collate(Collate.noCase)),
    ],
    SongSort.mostPlayed => [
      (row) => OrderingTerm.desc(
        const CustomExpression<int>(
          '(local_songs.play_count + COALESCE((SELECT unacknowledged_play_count '
          'FROM local_song_activities AS activity '
          'WHERE activity.song_id = local_songs.id), 0))',
        ),
      ),
      (row) => OrderingTerm.asc(row.title.collate(Collate.noCase)),
    ],
    SongSort.random => [
      (row) => OrderingTerm.asc(
        CustomExpression<int>(
          '(((length(local_songs.id) * 1103515245 + '
          'COALESCE(unicode(substr(local_songs.id, 1, 1)), 0) * 12345 + '
          'COALESCE(unicode(substr(local_songs.id, 2, 1)), 0) * 6789 + '
          'COALESCE(unicode(substr(local_songs.id, 3, 1)), 0) * 345 + '
          '${filter.randomSeed.abs()} * 48271) * 1664525 + 1013904223) '
          '% 2147483647)',
        ),
      ),
      (row) => OrderingTerm.asc(row.id),
    ],
    SongSort.yearNewest => [
      (row) => OrderingTerm.desc(row.year),
      (row) => OrderingTerm.asc(row.title.collate(Collate.noCase)),
    ],
    SongSort.durationLongest => [
      (row) => OrderingTerm.desc(row.duration),
      (row) => OrderingTerm.asc(row.title.collate(Collate.noCase)),
    ],
    SongSort.bitRateHighest => [
      (row) => OrderingTerm.desc(row.bitRate),
      (row) => OrderingTerm.asc(row.title.collate(Collate.noCase)),
    ],
  };

  Stream<List<LocalSong>> watchRecentlyAdded({int limit = 40}) =>
      (select(localSongs)
            ..where((row) => row.createdAt.isNotNull())
            ..orderBy([(row) => OrderingTerm.desc(row.createdAt)])
            ..limit(limit.clamp(1, 200)))
          .watch();

  Stream<List<RecentLocalPlay>> watchRecentlyPlayed({int limit = 40}) {
    final query =
        select(localSongs).join([
            innerJoin(
              localSongActivities,
              localSongActivities.songId.equalsExp(localSongs.id),
            ),
          ])
          ..where(localSongActivities.lastPlayedAt.isNotNull())
          ..orderBy([OrderingTerm.desc(localSongActivities.lastPlayedAt)])
          ..limit(limit.clamp(1, 200));
    return query.watch().map(
      (rows) => rows
          .map((row) {
            final song = row.readTable(localSongs);
            final activity = row.readTable(localSongActivities);
            return RecentLocalPlay(
              song: song,
              playedAt: activity.lastPlayedAt!,
              effectivePlayCount:
                  song.playCount + activity.unacknowledgedPlayCount,
            );
          })
          .toList(growable: false),
    );
  }

  /// One offline snapshot combining Navidrome's last-played timestamp with
  /// newer local activity that may not have reached the server yet.
  Future<List<RecentLocalPlay>> recentlyPlayedSnapshot({int limit = 40}) async {
    final boundedLimit = limit.clamp(1, 200);
    final local = await watchRecentlyPlayed(limit: boundedLimit * 2).first;
    final server =
        await (select(localSongs)
              ..where((row) => row.lastPlayedAt.isNotNull())
              ..orderBy([(row) => OrderingTerm.desc(row.lastPlayedAt)])
              ..limit(boundedLimit * 2))
            .get();
    final bySong = <String, RecentLocalPlay>{
      for (final item in local) item.song.id: item,
    };
    for (final song in server) {
      final playedAt = song.lastPlayedAt!;
      final existing = bySong[song.id];
      if (existing == null || playedAt.isAfter(existing.playedAt)) {
        bySong[song.id] = RecentLocalPlay(
          song: song,
          playedAt: playedAt,
          effectivePlayCount: existing?.effectivePlayCount ?? song.playCount,
        );
      }
    }
    final result = bySong.values.toList()
      ..sort((a, b) => b.playedAt.compareTo(a.playedAt));
    return result.take(boundedLimit).toList(growable: false);
  }

  Future<List<Playlist>> recentlyPlayedPlaylists() async {
    final rows = await customSelect(
      '''
      SELECT
        p.id,
        p.name,
        p.cover_art,
        p.song_count,
        p.duration,
        p.owner,
        p.server_read_only,
        p.is_public,
        p.is_generated,
        p.changed_at,
        MAX(
          CASE
            WHEN activity.last_played_at IS NULL THEN s.last_played_at
            WHEN s.last_played_at IS NULL THEN activity.last_played_at
            WHEN activity.last_played_at > s.last_played_at
              THEN activity.last_played_at
            ELSE s.last_played_at
          END
        ) AS effective_last_played_at
      FROM local_playlists AS p
      LEFT JOIN local_playlist_entries AS e ON e.playlist_id = p.id
      LEFT JOIN local_songs AS s ON s.id = e.song_id
      LEFT JOIN local_song_activities AS activity
        ON activity.song_id = s.id
      GROUP BY p.id
      ORDER BY
        effective_last_played_at DESC,
        p.name COLLATE NOCASE
      ''',
      readsFrom: {
        localPlaylists,
        localPlaylistEntries,
        localSongs,
        localSongActivities,
      },
    ).get();
    return rows
        .map(
          (row) => Playlist(
            id: row.read<String>('id'),
            name: row.read<String>('name'),
            coverArt: row.readNullable<String>('cover_art'),
            songCount: row.read<int>('song_count'),
            duration: row.read<int>('duration'),
            owner: row.read<String>('owner'),
            readonly: row.read<int>('server_read_only') != 0,
            isPublic: row.read<int>('is_public') != 0,
            changed: row.readNullable<DateTime>('changed_at'),
          ),
        )
        .toList(growable: false);
  }

  Future<void> clearAccountCache() => transaction(() async {
    await delete(stagedPlaylistEntries).go();
    await delete(stagedPlaylists).go();
    await delete(stagedSongs).go();
    await delete(stagedAlbums).go();
    await delete(stagedArtists).go();
    await delete(localPlaylistEntries).go();
    await delete(localPlaylists).go();
    await delete(localSongs).go();
    await delete(localAlbums).go();
    await delete(localArtists).go();
    await delete(localFavorites).go();
    await delete(localInternetRadioStations).go();
    await delete(localPlayEvents).go();
    await delete(localSongActivities).go();
    await delete(localQueueEntries).go();
    await delete(localQueueSessions).go();
    await delete(savedQueueSnapshotEntries).go();
    await delete(savedQueueSnapshots).go();
    await delete(localLyrics).go();
    await delete(pendingMutations).go();
    await delete(syncStates).go();
  });

  Future<List<LocalSong>> startListeningSongs({int limit = 60}) async {
    final boundedLimit = limit.clamp(1, 200);
    final unheard =
        await (select(localSongs)
              ..where((row) => row.playCount.equals(0))
              ..orderBy([
                (row) => OrderingTerm.desc(row.starred),
                (row) => OrderingTerm.desc(row.createdAt),
                (row) => OrderingTerm.asc(row.title.collate(Collate.noCase)),
              ])
              ..limit(boundedLimit))
            .get();
    if (unheard.length >= boundedLimit) return unheard;
    final seenIds = unheard.map((song) => song.id).toSet();
    final newest =
        await (select(localSongs)
              ..orderBy([
                (row) => OrderingTerm.desc(row.createdAt),
                (row) => OrderingTerm.asc(row.title.collate(Collate.noCase)),
              ])
              ..limit(boundedLimit))
            .get();
    return [
      ...unheard,
      ...newest.where((song) => seenIds.add(song.id)),
    ].take(boundedLimit).toList(growable: false);
  }

  Future<List<LocalSong>> genreShelfSongs(String genre, {int limit = 80}) {
    final normalized = genre.trim().toLowerCase();
    if (normalized.isEmpty) return Future.value(const []);
    return (select(localSongs)
          ..where((_) => _containsGenreToken(normalized))
          ..orderBy([
            (row) => OrderingTerm.desc(row.playCount),
            (row) => OrderingTerm.desc(row.createdAt),
          ])
          ..limit(limit.clamp(1, 200)))
        .get();
  }

  Future<List<LocalSong>> replaySongs({int limit = 80}) =>
      (select(localSongs)
            ..where((row) => row.playCount.isBiggerThanValue(0))
            ..orderBy([
              (row) => OrderingTerm.desc(row.playCount),
              (row) => OrderingTerm.desc(row.lastPlayedAt),
            ])
            ..limit(limit.clamp(1, 200)))
          .get();

  /// A fresh local-library sample for Home. The bounded SQL query keeps the
  /// operation database-backed instead of materializing the full catalogue.
  Future<List<LocalSong>> randomSongs({int limit = 80}) => customSelect(
    'SELECT * FROM local_songs ORDER BY RANDOM() LIMIT ?',
    variables: [Variable(limit.clamp(1, 200))],
    readsFrom: {localSongs},
  ).map((row) => localSongs.map(row.data)).get();

  Future<void> beginPlayback({
    required String playbackId,
    required String songId,
    required DateTime startedAt,
    required Duration duration,
  }) => transaction(() async {
    final inserted = await into(localPlayEvents).insert(
      LocalPlayEventsCompanion.insert(
        playbackId: playbackId,
        songId: songId,
        startedAt: startedAt,
        durationMilliseconds: Value(
          duration.isNegative ? 0 : duration.inMilliseconds,
        ),
      ),
      mode: InsertMode.insertOrIgnore,
    );
    if (inserted == 0) return;

    final activity = await (select(
      localSongActivities,
    )..where((row) => row.songId.equals(songId))).getSingleOrNull();
    if (activity == null) {
      final song = await (select(
        localSongs,
      )..where((row) => row.id.equals(songId))).getSingleOrNull();
      await into(localSongActivities).insert(
        LocalSongActivitiesCompanion.insert(
          songId: songId,
          serverPlayCountSeen: Value(song?.playCount ?? 0),
          lastStartedAt: Value(startedAt),
          updatedAt: startedAt,
        ),
      );
    } else {
      await (update(
        localSongActivities,
      )..where((row) => row.songId.equals(songId))).write(
        LocalSongActivitiesCompanion(
          lastStartedAt: Value(startedAt),
          updatedAt: Value(startedAt),
        ),
      );
    }
  });

  /// Returns true only when this playback occurrence is counted for the first
  /// time. Retried position/completion callbacks are therefore idempotent.
  Future<bool> markPlaybackScrobbled({
    required String playbackId,
    required DateTime at,
  }) => transaction(() async {
    final event = await (select(
      localPlayEvents,
    )..where((row) => row.playbackId.equals(playbackId))).getSingleOrNull();
    if (event == null || event.scrobbledAt != null) return false;

    await (update(localPlayEvents)
          ..where((row) => row.playbackId.equals(playbackId)))
        .write(LocalPlayEventsCompanion(scrobbledAt: Value(at)));
    final activity = await (select(
      localSongActivities,
    )..where((row) => row.songId.equals(event.songId))).getSingleOrNull();
    if (activity == null) {
      final song = await (select(
        localSongs,
      )..where((row) => row.id.equals(event.songId))).getSingleOrNull();
      await into(localSongActivities).insert(
        LocalSongActivitiesCompanion.insert(
          songId: event.songId,
          localPlayCount: const Value(1),
          unacknowledgedPlayCount: const Value(1),
          serverPlayCountSeen: Value(song?.playCount ?? 0),
          lastPlayedAt: Value(at),
          updatedAt: at,
        ),
      );
    } else {
      await (update(
        localSongActivities,
      )..where((row) => row.songId.equals(event.songId))).write(
        LocalSongActivitiesCompanion(
          localPlayCount: Value(activity.localPlayCount + 1),
          unacknowledgedPlayCount: Value(activity.unacknowledgedPlayCount + 1),
          lastPlayedAt: Value(at),
          updatedAt: Value(at),
        ),
      );
    }
    return true;
  });

  Future<void> completePlayback({
    required String playbackId,
    required DateTime at,
  }) => transaction(() async {
    final event = await (select(
      localPlayEvents,
    )..where((row) => row.playbackId.equals(playbackId))).getSingleOrNull();
    if (event == null || event.completedAt != null) return;
    await (update(localPlayEvents)
          ..where((row) => row.playbackId.equals(playbackId)))
        .write(LocalPlayEventsCompanion(completedAt: Value(at)));
    await (update(
      localSongActivities,
    )..where((row) => row.songId.equals(event.songId))).write(
      LocalSongActivitiesCompanion(
        lastCompletedAt: Value(at),
        updatedAt: Value(at),
      ),
    );
  });

  Future<void> endPlayback({
    required String playbackId,
    required DateTime at,
    bool skipped = false,
  }) => transaction(() async {
    final event = await (select(
      localPlayEvents,
    )..where((row) => row.playbackId.equals(playbackId))).getSingleOrNull();
    if (event == null || event.endedAt != null) return;
    await (update(
      localPlayEvents,
    )..where((row) => row.playbackId.equals(playbackId))).write(
      LocalPlayEventsCompanion(endedAt: Value(at), skipped: Value(skipped)),
    );
    if (!skipped) return;
    final activity = await (select(
      localSongActivities,
    )..where((row) => row.songId.equals(event.songId))).getSingleOrNull();
    if (activity == null) return;
    await (update(
      localSongActivities,
    )..where((row) => row.songId.equals(event.songId))).write(
      LocalSongActivitiesCompanion(
        skipCount: Value(activity.skipCount + 1),
        updatedAt: Value(at),
      ),
    );
  });

  Future<void> upsertSongs(Iterable<LocalSongsCompanion> songs) =>
      transaction(() async {
        await batch(
          (batch) =>
              batch.insertAllOnConflictUpdate(localSongs, songs.toList()),
        );
      });

  Future<void> beginSongStaging() => transaction(() async {
    await delete(stagedSongs).go();
  });

  Future<void> stageSongs(Iterable<StagedSongsCompanion> songs) =>
      transaction(() async {
        final page = songs.toList();
        if (page.isEmpty) return;
        await batch(
          (batch) => batch.insertAllOnConflictUpdate(stagedSongs, page),
        );
      });

  /// Swap only after the complete remote scan succeeded. SQLite transactions
  /// make the replacement invisible to readers until both statements finish.
  Future<void> commitStagedSongs() => transaction(() async {
    // A server counter increase acknowledges locally submitted plays. Keep any
    // remaining delta so the UI still updates immediately while offline.
    await customStatement('''
          UPDATE local_song_activities
          SET
            unacknowledged_play_count = MAX(
              0,
              unacknowledged_play_count - MAX(
                0,
                (SELECT play_count FROM staged_songs
                  WHERE staged_songs.id = local_song_activities.song_id)
                  - server_play_count_seen
              )
            ),
            server_play_count_seen = MAX(
              server_play_count_seen,
              (SELECT play_count FROM staged_songs
                WHERE staged_songs.id = local_song_activities.song_id)
            )
          WHERE EXISTS (
            SELECT 1 FROM staged_songs
            WHERE staged_songs.id = local_song_activities.song_id
          )
        ''');
    await delete(localSongs).go();
    await customStatement('''
          INSERT INTO local_songs (
            id, title, album_id, album, artist_id, artist, canonical_artist,
            track, disc, year,
            genre, duration, bit_rate, bit_depth, sampling_rate, suffix,
            content_type, file_size, cover_art, play_count, starred,
            created_at, last_played_at, starred_at, updated_at
          )
          SELECT
            id, title, album_id, album, artist_id, artist, canonical_artist,
            track, disc, year,
            genre, duration, bit_rate, bit_depth, sampling_rate, suffix,
            content_type, file_size, cover_art, play_count, starred,
            created_at, last_played_at, starred_at, updated_at
          FROM staged_songs
        ''');
    await delete(stagedSongs).go();
  });

  Future<void> discardStagedSongs() => delete(stagedSongs).go();

  Future<int> stagedSongCount() async {
    final count = stagedSongs.id.count();
    final row = await (selectOnly(
      stagedSongs,
    )..addColumns([count])).getSingle();
    return row.read(count) ?? 0;
  }

  Future<void> beginArtistStaging() => delete(stagedArtists).go();

  Future<void> stageArtists(Iterable<StagedArtistsCompanion> artists) async {
    final page = artists.toList();
    if (page.isEmpty) return;
    await batch(
      (batch) => batch.insertAllOnConflictUpdate(stagedArtists, page),
    );
  }

  Future<void> commitStagedArtists() => transaction(() async {
    await delete(localArtists).go();
    await customStatement('''
      INSERT INTO local_artists
        (id, name, sort_name, cover_art, album_count, starred, updated_at)
      SELECT id, name, sort_name, cover_art, album_count, starred, updated_at
      FROM staged_artists
    ''');
    await delete(stagedArtists).go();
  });

  Future<void> discardStagedArtists() => delete(stagedArtists).go();

  Future<int> stagedArtistCount() async {
    final count = stagedArtists.id.count();
    final row = await (selectOnly(
      stagedArtists,
    )..addColumns([count])).getSingle();
    return row.read(count) ?? 0;
  }

  Future<void> beginAlbumStaging() => delete(stagedAlbums).go();

  Future<void> stageAlbums(Iterable<StagedAlbumsCompanion> albums) async {
    final page = albums.toList();
    if (page.isEmpty) return;
    await batch((batch) => batch.insertAllOnConflictUpdate(stagedAlbums, page));
  }

  Future<void> commitStagedAlbums() => transaction(() async {
    await delete(localAlbums).go();
    await customStatement('''
      INSERT INTO local_albums (
        id, name, artist_id, artist, canonical_artist, year, song_count,
        duration, play_count,
        cover_art, starred, created_at, updated_at
      )
      SELECT
        id, name, artist_id, artist, canonical_artist, year, song_count,
        duration, play_count,
        cover_art, starred, created_at, updated_at
      FROM staged_albums
    ''');
    await delete(stagedAlbums).go();
  });

  Future<void> discardStagedAlbums() => delete(stagedAlbums).go();

  Future<int> stagedAlbumCount() async {
    final count = stagedAlbums.id.count();
    final row = await (selectOnly(
      stagedAlbums,
    )..addColumns([count])).getSingle();
    return row.read(count) ?? 0;
  }

  Future<void> beginPlaylistStaging() => transaction(() async {
    await delete(stagedPlaylistEntries).go();
    await delete(stagedPlaylists).go();
  });

  Future<void> stagePlaylists(
    Iterable<StagedPlaylistsCompanion> playlists,
  ) async {
    final values = playlists.toList();
    if (values.isEmpty) return;
    await batch(
      (batch) => batch.insertAllOnConflictUpdate(stagedPlaylists, values),
    );
  }

  Future<void> stagePlaylistEntries(
    Iterable<StagedPlaylistEntriesCompanion> entries,
  ) async {
    final values = entries.toList();
    if (values.isEmpty) return;
    await batch(
      (batch) => batch.insertAllOnConflictUpdate(stagedPlaylistEntries, values),
    );
  }

  Future<void> commitStagedPlaylists() => transaction(() async {
    await delete(localPlaylistEntries).go();
    await delete(localPlaylists).go();
    await customStatement('''
      INSERT INTO local_playlists (
        id, name, cover_art, song_count, duration, server_read_only,
        owner, is_public, is_generated, changed_at
      )
      SELECT
        id, name, cover_art, song_count, duration, server_read_only,
        owner, is_public, is_generated, changed_at
      FROM staged_playlists
    ''');
    await customStatement('''
      INSERT INTO local_playlist_entries (playlist_id, song_id, position)
      SELECT playlist_id, song_id, position FROM staged_playlist_entries
    ''');
    await delete(stagedPlaylistEntries).go();
    await delete(stagedPlaylists).go();
  });

  Future<void> discardStagedPlaylists() => transaction(() async {
    await delete(stagedPlaylistEntries).go();
    await delete(stagedPlaylists).go();
  });

  /// Last successful run for [scope], or null when it never completed.
  Future<DateTime?> lastSuccessAt(String scope) async {
    final row = await (select(
      syncStates,
    )..where((state) => state.scope.equals(scope))).getSingleOrNull();
    return row?.lastSuccessfulAt;
  }

  /// Insert-or-update single rows. Unlike the staging swap this leaves every
  /// other row untouched, which is what an incremental refresh needs.
  Future<void> upsertAlbums(Iterable<LocalAlbumsCompanion> albums) => batch(
    (batch) => batch.insertAllOnConflictUpdate(
      localAlbums,
      albums.toList(growable: false),
    ),
  );

  Future<void> recordSyncSuccess(String scope, DateTime at) =>
      into(syncStates).insertOnConflictUpdate(
        SyncStatesCompanion.insert(
          scope: scope,
          lastSuccessfulAt: Value(at),
          lastError: const Value(null),
        ),
      );

  Future<void> recordSyncFailure(String scope, Object error) =>
      into(syncStates).insertOnConflictUpdate(
        SyncStatesCompanion.insert(
          scope: scope,
          lastError: Value(sanitizeDiagnosticText(error.toString())),
        ),
      );

  Expression<bool> _containsGenreToken(String genre) {
    final token = genre.toLowerCase().replaceAll("'", "''");
    return CustomExpression<bool>(
      "instr(',' || replace(replace(replace(replace(lower(COALESCE(genre, '')), "
      "';', ','), '/', ','), '|', ','), ', ', ',') || ',', ',$token,') > 0",
    );
  }
}
