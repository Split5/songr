// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalArtistsTable extends LocalArtists
    with TableInfo<$LocalArtistsTable, LocalArtist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalArtistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortNameMeta = const VerificationMeta(
    'sortName',
  );
  @override
  late final GeneratedColumn<String> sortName = GeneratedColumn<String>(
    'sort_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverArtMeta = const VerificationMeta(
    'coverArt',
  );
  @override
  late final GeneratedColumn<String> coverArt = GeneratedColumn<String>(
    'cover_art',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _albumCountMeta = const VerificationMeta(
    'albumCount',
  );
  @override
  late final GeneratedColumn<int> albumCount = GeneratedColumn<int>(
    'album_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _starredMeta = const VerificationMeta(
    'starred',
  );
  @override
  late final GeneratedColumn<bool> starred = GeneratedColumn<bool>(
    'starred',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("starred" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    sortName,
    coverArt,
    albumCount,
    starred,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_artists';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalArtist> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_name')) {
      context.handle(
        _sortNameMeta,
        sortName.isAcceptableOrUnknown(data['sort_name']!, _sortNameMeta),
      );
    }
    if (data.containsKey('cover_art')) {
      context.handle(
        _coverArtMeta,
        coverArt.isAcceptableOrUnknown(data['cover_art']!, _coverArtMeta),
      );
    }
    if (data.containsKey('album_count')) {
      context.handle(
        _albumCountMeta,
        albumCount.isAcceptableOrUnknown(data['album_count']!, _albumCountMeta),
      );
    }
    if (data.containsKey('starred')) {
      context.handle(
        _starredMeta,
        starred.isAcceptableOrUnknown(data['starred']!, _starredMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalArtist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalArtist(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sort_name'],
      ),
      coverArt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_art'],
      ),
      albumCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}album_count'],
      )!,
      starred: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}starred'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $LocalArtistsTable createAlias(String alias) {
    return $LocalArtistsTable(attachedDatabase, alias);
  }
}

class LocalArtist extends DataClass implements Insertable<LocalArtist> {
  final String id;
  final String name;
  final String? sortName;
  final String? coverArt;
  final int albumCount;
  final bool starred;
  final DateTime? updatedAt;
  const LocalArtist({
    required this.id,
    required this.name,
    this.sortName,
    this.coverArt,
    required this.albumCount,
    required this.starred,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || sortName != null) {
      map['sort_name'] = Variable<String>(sortName);
    }
    if (!nullToAbsent || coverArt != null) {
      map['cover_art'] = Variable<String>(coverArt);
    }
    map['album_count'] = Variable<int>(albumCount);
    map['starred'] = Variable<bool>(starred);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  LocalArtistsCompanion toCompanion(bool nullToAbsent) {
    return LocalArtistsCompanion(
      id: Value(id),
      name: Value(name),
      sortName: sortName == null && nullToAbsent
          ? const Value.absent()
          : Value(sortName),
      coverArt: coverArt == null && nullToAbsent
          ? const Value.absent()
          : Value(coverArt),
      albumCount: Value(albumCount),
      starred: Value(starred),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory LocalArtist.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalArtist(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sortName: serializer.fromJson<String?>(json['sortName']),
      coverArt: serializer.fromJson<String?>(json['coverArt']),
      albumCount: serializer.fromJson<int>(json['albumCount']),
      starred: serializer.fromJson<bool>(json['starred']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'sortName': serializer.toJson<String?>(sortName),
      'coverArt': serializer.toJson<String?>(coverArt),
      'albumCount': serializer.toJson<int>(albumCount),
      'starred': serializer.toJson<bool>(starred),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  LocalArtist copyWith({
    String? id,
    String? name,
    Value<String?> sortName = const Value.absent(),
    Value<String?> coverArt = const Value.absent(),
    int? albumCount,
    bool? starred,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => LocalArtist(
    id: id ?? this.id,
    name: name ?? this.name,
    sortName: sortName.present ? sortName.value : this.sortName,
    coverArt: coverArt.present ? coverArt.value : this.coverArt,
    albumCount: albumCount ?? this.albumCount,
    starred: starred ?? this.starred,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  LocalArtist copyWithCompanion(LocalArtistsCompanion data) {
    return LocalArtist(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sortName: data.sortName.present ? data.sortName.value : this.sortName,
      coverArt: data.coverArt.present ? data.coverArt.value : this.coverArt,
      albumCount: data.albumCount.present
          ? data.albumCount.value
          : this.albumCount,
      starred: data.starred.present ? data.starred.value : this.starred,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalArtist(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortName: $sortName, ')
          ..write('coverArt: $coverArt, ')
          ..write('albumCount: $albumCount, ')
          ..write('starred: $starred, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, sortName, coverArt, albumCount, starred, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalArtist &&
          other.id == this.id &&
          other.name == this.name &&
          other.sortName == this.sortName &&
          other.coverArt == this.coverArt &&
          other.albumCount == this.albumCount &&
          other.starred == this.starred &&
          other.updatedAt == this.updatedAt);
}

class LocalArtistsCompanion extends UpdateCompanion<LocalArtist> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> sortName;
  final Value<String?> coverArt;
  final Value<int> albumCount;
  final Value<bool> starred;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const LocalArtistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sortName = const Value.absent(),
    this.coverArt = const Value.absent(),
    this.albumCount = const Value.absent(),
    this.starred = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalArtistsCompanion.insert({
    required String id,
    required String name,
    this.sortName = const Value.absent(),
    this.coverArt = const Value.absent(),
    this.albumCount = const Value.absent(),
    this.starred = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<LocalArtist> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? sortName,
    Expression<String>? coverArt,
    Expression<int>? albumCount,
    Expression<bool>? starred,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sortName != null) 'sort_name': sortName,
      if (coverArt != null) 'cover_art': coverArt,
      if (albumCount != null) 'album_count': albumCount,
      if (starred != null) 'starred': starred,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalArtistsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? sortName,
    Value<String?>? coverArt,
    Value<int>? albumCount,
    Value<bool>? starred,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalArtistsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sortName: sortName ?? this.sortName,
      coverArt: coverArt ?? this.coverArt,
      albumCount: albumCount ?? this.albumCount,
      starred: starred ?? this.starred,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortName.present) {
      map['sort_name'] = Variable<String>(sortName.value);
    }
    if (coverArt.present) {
      map['cover_art'] = Variable<String>(coverArt.value);
    }
    if (albumCount.present) {
      map['album_count'] = Variable<int>(albumCount.value);
    }
    if (starred.present) {
      map['starred'] = Variable<bool>(starred.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalArtistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortName: $sortName, ')
          ..write('coverArt: $coverArt, ')
          ..write('albumCount: $albumCount, ')
          ..write('starred: $starred, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAlbumsTable extends LocalAlbums
    with TableInfo<$LocalAlbumsTable, LocalAlbum> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAlbumsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistIdMeta = const VerificationMeta(
    'artistId',
  );
  @override
  late final GeneratedColumn<String> artistId = GeneratedColumn<String>(
    'artist_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _canonicalArtistMeta = const VerificationMeta(
    'canonicalArtist',
  );
  @override
  late final GeneratedColumn<String> canonicalArtist = GeneratedColumn<String>(
    'canonical_artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _songCountMeta = const VerificationMeta(
    'songCount',
  );
  @override
  late final GeneratedColumn<int> songCount = GeneratedColumn<int>(
    'song_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _playCountMeta = const VerificationMeta(
    'playCount',
  );
  @override
  late final GeneratedColumn<int> playCount = GeneratedColumn<int>(
    'play_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _coverArtMeta = const VerificationMeta(
    'coverArt',
  );
  @override
  late final GeneratedColumn<String> coverArt = GeneratedColumn<String>(
    'cover_art',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _starredMeta = const VerificationMeta(
    'starred',
  );
  @override
  late final GeneratedColumn<bool> starred = GeneratedColumn<bool>(
    'starred',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("starred" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    artistId,
    artist,
    canonicalArtist,
    year,
    songCount,
    duration,
    playCount,
    coverArt,
    starred,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_albums';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAlbum> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('artist_id')) {
      context.handle(
        _artistIdMeta,
        artistId.isAcceptableOrUnknown(data['artist_id']!, _artistIdMeta),
      );
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    } else if (isInserting) {
      context.missing(_artistMeta);
    }
    if (data.containsKey('canonical_artist')) {
      context.handle(
        _canonicalArtistMeta,
        canonicalArtist.isAcceptableOrUnknown(
          data['canonical_artist']!,
          _canonicalArtistMeta,
        ),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('song_count')) {
      context.handle(
        _songCountMeta,
        songCount.isAcceptableOrUnknown(data['song_count']!, _songCountMeta),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    }
    if (data.containsKey('play_count')) {
      context.handle(
        _playCountMeta,
        playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta),
      );
    }
    if (data.containsKey('cover_art')) {
      context.handle(
        _coverArtMeta,
        coverArt.isAcceptableOrUnknown(data['cover_art']!, _coverArtMeta),
      );
    }
    if (data.containsKey('starred')) {
      context.handle(
        _starredMeta,
        starred.isAcceptableOrUnknown(data['starred']!, _starredMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAlbum map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAlbum(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      artistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_id'],
      ),
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      )!,
      canonicalArtist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canonical_artist'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      songCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}song_count'],
      )!,
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      )!,
      playCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}play_count'],
      )!,
      coverArt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_art'],
      ),
      starred: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}starred'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $LocalAlbumsTable createAlias(String alias) {
    return $LocalAlbumsTable(attachedDatabase, alias);
  }
}

class LocalAlbum extends DataClass implements Insertable<LocalAlbum> {
  final String id;
  final String name;
  final String? artistId;
  final String artist;
  final String canonicalArtist;
  final int year;
  final int songCount;
  final int duration;
  final int playCount;
  final String? coverArt;
  final bool starred;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const LocalAlbum({
    required this.id,
    required this.name,
    this.artistId,
    required this.artist,
    required this.canonicalArtist,
    required this.year,
    required this.songCount,
    required this.duration,
    required this.playCount,
    this.coverArt,
    required this.starred,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || artistId != null) {
      map['artist_id'] = Variable<String>(artistId);
    }
    map['artist'] = Variable<String>(artist);
    map['canonical_artist'] = Variable<String>(canonicalArtist);
    map['year'] = Variable<int>(year);
    map['song_count'] = Variable<int>(songCount);
    map['duration'] = Variable<int>(duration);
    map['play_count'] = Variable<int>(playCount);
    if (!nullToAbsent || coverArt != null) {
      map['cover_art'] = Variable<String>(coverArt);
    }
    map['starred'] = Variable<bool>(starred);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  LocalAlbumsCompanion toCompanion(bool nullToAbsent) {
    return LocalAlbumsCompanion(
      id: Value(id),
      name: Value(name),
      artistId: artistId == null && nullToAbsent
          ? const Value.absent()
          : Value(artistId),
      artist: Value(artist),
      canonicalArtist: Value(canonicalArtist),
      year: Value(year),
      songCount: Value(songCount),
      duration: Value(duration),
      playCount: Value(playCount),
      coverArt: coverArt == null && nullToAbsent
          ? const Value.absent()
          : Value(coverArt),
      starred: Value(starred),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory LocalAlbum.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAlbum(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      artistId: serializer.fromJson<String?>(json['artistId']),
      artist: serializer.fromJson<String>(json['artist']),
      canonicalArtist: serializer.fromJson<String>(json['canonicalArtist']),
      year: serializer.fromJson<int>(json['year']),
      songCount: serializer.fromJson<int>(json['songCount']),
      duration: serializer.fromJson<int>(json['duration']),
      playCount: serializer.fromJson<int>(json['playCount']),
      coverArt: serializer.fromJson<String?>(json['coverArt']),
      starred: serializer.fromJson<bool>(json['starred']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'artistId': serializer.toJson<String?>(artistId),
      'artist': serializer.toJson<String>(artist),
      'canonicalArtist': serializer.toJson<String>(canonicalArtist),
      'year': serializer.toJson<int>(year),
      'songCount': serializer.toJson<int>(songCount),
      'duration': serializer.toJson<int>(duration),
      'playCount': serializer.toJson<int>(playCount),
      'coverArt': serializer.toJson<String?>(coverArt),
      'starred': serializer.toJson<bool>(starred),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  LocalAlbum copyWith({
    String? id,
    String? name,
    Value<String?> artistId = const Value.absent(),
    String? artist,
    String? canonicalArtist,
    int? year,
    int? songCount,
    int? duration,
    int? playCount,
    Value<String?> coverArt = const Value.absent(),
    bool? starred,
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => LocalAlbum(
    id: id ?? this.id,
    name: name ?? this.name,
    artistId: artistId.present ? artistId.value : this.artistId,
    artist: artist ?? this.artist,
    canonicalArtist: canonicalArtist ?? this.canonicalArtist,
    year: year ?? this.year,
    songCount: songCount ?? this.songCount,
    duration: duration ?? this.duration,
    playCount: playCount ?? this.playCount,
    coverArt: coverArt.present ? coverArt.value : this.coverArt,
    starred: starred ?? this.starred,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  LocalAlbum copyWithCompanion(LocalAlbumsCompanion data) {
    return LocalAlbum(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      artistId: data.artistId.present ? data.artistId.value : this.artistId,
      artist: data.artist.present ? data.artist.value : this.artist,
      canonicalArtist: data.canonicalArtist.present
          ? data.canonicalArtist.value
          : this.canonicalArtist,
      year: data.year.present ? data.year.value : this.year,
      songCount: data.songCount.present ? data.songCount.value : this.songCount,
      duration: data.duration.present ? data.duration.value : this.duration,
      playCount: data.playCount.present ? data.playCount.value : this.playCount,
      coverArt: data.coverArt.present ? data.coverArt.value : this.coverArt,
      starred: data.starred.present ? data.starred.value : this.starred,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAlbum(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('artistId: $artistId, ')
          ..write('artist: $artist, ')
          ..write('canonicalArtist: $canonicalArtist, ')
          ..write('year: $year, ')
          ..write('songCount: $songCount, ')
          ..write('duration: $duration, ')
          ..write('playCount: $playCount, ')
          ..write('coverArt: $coverArt, ')
          ..write('starred: $starred, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    artistId,
    artist,
    canonicalArtist,
    year,
    songCount,
    duration,
    playCount,
    coverArt,
    starred,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAlbum &&
          other.id == this.id &&
          other.name == this.name &&
          other.artistId == this.artistId &&
          other.artist == this.artist &&
          other.canonicalArtist == this.canonicalArtist &&
          other.year == this.year &&
          other.songCount == this.songCount &&
          other.duration == this.duration &&
          other.playCount == this.playCount &&
          other.coverArt == this.coverArt &&
          other.starred == this.starred &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalAlbumsCompanion extends UpdateCompanion<LocalAlbum> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> artistId;
  final Value<String> artist;
  final Value<String> canonicalArtist;
  final Value<int> year;
  final Value<int> songCount;
  final Value<int> duration;
  final Value<int> playCount;
  final Value<String?> coverArt;
  final Value<bool> starred;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const LocalAlbumsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.artistId = const Value.absent(),
    this.artist = const Value.absent(),
    this.canonicalArtist = const Value.absent(),
    this.year = const Value.absent(),
    this.songCount = const Value.absent(),
    this.duration = const Value.absent(),
    this.playCount = const Value.absent(),
    this.coverArt = const Value.absent(),
    this.starred = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAlbumsCompanion.insert({
    required String id,
    required String name,
    this.artistId = const Value.absent(),
    required String artist,
    this.canonicalArtist = const Value.absent(),
    this.year = const Value.absent(),
    this.songCount = const Value.absent(),
    this.duration = const Value.absent(),
    this.playCount = const Value.absent(),
    this.coverArt = const Value.absent(),
    this.starred = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       artist = Value(artist);
  static Insertable<LocalAlbum> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? artistId,
    Expression<String>? artist,
    Expression<String>? canonicalArtist,
    Expression<int>? year,
    Expression<int>? songCount,
    Expression<int>? duration,
    Expression<int>? playCount,
    Expression<String>? coverArt,
    Expression<bool>? starred,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (artistId != null) 'artist_id': artistId,
      if (artist != null) 'artist': artist,
      if (canonicalArtist != null) 'canonical_artist': canonicalArtist,
      if (year != null) 'year': year,
      if (songCount != null) 'song_count': songCount,
      if (duration != null) 'duration': duration,
      if (playCount != null) 'play_count': playCount,
      if (coverArt != null) 'cover_art': coverArt,
      if (starred != null) 'starred': starred,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAlbumsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? artistId,
    Value<String>? artist,
    Value<String>? canonicalArtist,
    Value<int>? year,
    Value<int>? songCount,
    Value<int>? duration,
    Value<int>? playCount,
    Value<String?>? coverArt,
    Value<bool>? starred,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalAlbumsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      artistId: artistId ?? this.artistId,
      artist: artist ?? this.artist,
      canonicalArtist: canonicalArtist ?? this.canonicalArtist,
      year: year ?? this.year,
      songCount: songCount ?? this.songCount,
      duration: duration ?? this.duration,
      playCount: playCount ?? this.playCount,
      coverArt: coverArt ?? this.coverArt,
      starred: starred ?? this.starred,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (artistId.present) {
      map['artist_id'] = Variable<String>(artistId.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (canonicalArtist.present) {
      map['canonical_artist'] = Variable<String>(canonicalArtist.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (songCount.present) {
      map['song_count'] = Variable<int>(songCount.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (playCount.present) {
      map['play_count'] = Variable<int>(playCount.value);
    }
    if (coverArt.present) {
      map['cover_art'] = Variable<String>(coverArt.value);
    }
    if (starred.present) {
      map['starred'] = Variable<bool>(starred.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAlbumsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('artistId: $artistId, ')
          ..write('artist: $artist, ')
          ..write('canonicalArtist: $canonicalArtist, ')
          ..write('year: $year, ')
          ..write('songCount: $songCount, ')
          ..write('duration: $duration, ')
          ..write('playCount: $playCount, ')
          ..write('coverArt: $coverArt, ')
          ..write('starred: $starred, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StagedArtistsTable extends StagedArtists
    with TableInfo<$StagedArtistsTable, StagedArtist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StagedArtistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortNameMeta = const VerificationMeta(
    'sortName',
  );
  @override
  late final GeneratedColumn<String> sortName = GeneratedColumn<String>(
    'sort_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverArtMeta = const VerificationMeta(
    'coverArt',
  );
  @override
  late final GeneratedColumn<String> coverArt = GeneratedColumn<String>(
    'cover_art',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _albumCountMeta = const VerificationMeta(
    'albumCount',
  );
  @override
  late final GeneratedColumn<int> albumCount = GeneratedColumn<int>(
    'album_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _starredMeta = const VerificationMeta(
    'starred',
  );
  @override
  late final GeneratedColumn<bool> starred = GeneratedColumn<bool>(
    'starred',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("starred" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    sortName,
    coverArt,
    albumCount,
    starred,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'staged_artists';
  @override
  VerificationContext validateIntegrity(
    Insertable<StagedArtist> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_name')) {
      context.handle(
        _sortNameMeta,
        sortName.isAcceptableOrUnknown(data['sort_name']!, _sortNameMeta),
      );
    }
    if (data.containsKey('cover_art')) {
      context.handle(
        _coverArtMeta,
        coverArt.isAcceptableOrUnknown(data['cover_art']!, _coverArtMeta),
      );
    }
    if (data.containsKey('album_count')) {
      context.handle(
        _albumCountMeta,
        albumCount.isAcceptableOrUnknown(data['album_count']!, _albumCountMeta),
      );
    }
    if (data.containsKey('starred')) {
      context.handle(
        _starredMeta,
        starred.isAcceptableOrUnknown(data['starred']!, _starredMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StagedArtist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StagedArtist(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sort_name'],
      ),
      coverArt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_art'],
      ),
      albumCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}album_count'],
      )!,
      starred: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}starred'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $StagedArtistsTable createAlias(String alias) {
    return $StagedArtistsTable(attachedDatabase, alias);
  }
}

class StagedArtist extends DataClass implements Insertable<StagedArtist> {
  final String id;
  final String name;
  final String? sortName;
  final String? coverArt;
  final int albumCount;
  final bool starred;
  final DateTime? updatedAt;
  const StagedArtist({
    required this.id,
    required this.name,
    this.sortName,
    this.coverArt,
    required this.albumCount,
    required this.starred,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || sortName != null) {
      map['sort_name'] = Variable<String>(sortName);
    }
    if (!nullToAbsent || coverArt != null) {
      map['cover_art'] = Variable<String>(coverArt);
    }
    map['album_count'] = Variable<int>(albumCount);
    map['starred'] = Variable<bool>(starred);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  StagedArtistsCompanion toCompanion(bool nullToAbsent) {
    return StagedArtistsCompanion(
      id: Value(id),
      name: Value(name),
      sortName: sortName == null && nullToAbsent
          ? const Value.absent()
          : Value(sortName),
      coverArt: coverArt == null && nullToAbsent
          ? const Value.absent()
          : Value(coverArt),
      albumCount: Value(albumCount),
      starred: Value(starred),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory StagedArtist.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StagedArtist(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sortName: serializer.fromJson<String?>(json['sortName']),
      coverArt: serializer.fromJson<String?>(json['coverArt']),
      albumCount: serializer.fromJson<int>(json['albumCount']),
      starred: serializer.fromJson<bool>(json['starred']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'sortName': serializer.toJson<String?>(sortName),
      'coverArt': serializer.toJson<String?>(coverArt),
      'albumCount': serializer.toJson<int>(albumCount),
      'starred': serializer.toJson<bool>(starred),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  StagedArtist copyWith({
    String? id,
    String? name,
    Value<String?> sortName = const Value.absent(),
    Value<String?> coverArt = const Value.absent(),
    int? albumCount,
    bool? starred,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => StagedArtist(
    id: id ?? this.id,
    name: name ?? this.name,
    sortName: sortName.present ? sortName.value : this.sortName,
    coverArt: coverArt.present ? coverArt.value : this.coverArt,
    albumCount: albumCount ?? this.albumCount,
    starred: starred ?? this.starred,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  StagedArtist copyWithCompanion(StagedArtistsCompanion data) {
    return StagedArtist(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sortName: data.sortName.present ? data.sortName.value : this.sortName,
      coverArt: data.coverArt.present ? data.coverArt.value : this.coverArt,
      albumCount: data.albumCount.present
          ? data.albumCount.value
          : this.albumCount,
      starred: data.starred.present ? data.starred.value : this.starred,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StagedArtist(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortName: $sortName, ')
          ..write('coverArt: $coverArt, ')
          ..write('albumCount: $albumCount, ')
          ..write('starred: $starred, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, sortName, coverArt, albumCount, starred, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StagedArtist &&
          other.id == this.id &&
          other.name == this.name &&
          other.sortName == this.sortName &&
          other.coverArt == this.coverArt &&
          other.albumCount == this.albumCount &&
          other.starred == this.starred &&
          other.updatedAt == this.updatedAt);
}

class StagedArtistsCompanion extends UpdateCompanion<StagedArtist> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> sortName;
  final Value<String?> coverArt;
  final Value<int> albumCount;
  final Value<bool> starred;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const StagedArtistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sortName = const Value.absent(),
    this.coverArt = const Value.absent(),
    this.albumCount = const Value.absent(),
    this.starred = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StagedArtistsCompanion.insert({
    required String id,
    required String name,
    this.sortName = const Value.absent(),
    this.coverArt = const Value.absent(),
    this.albumCount = const Value.absent(),
    this.starred = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<StagedArtist> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? sortName,
    Expression<String>? coverArt,
    Expression<int>? albumCount,
    Expression<bool>? starred,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sortName != null) 'sort_name': sortName,
      if (coverArt != null) 'cover_art': coverArt,
      if (albumCount != null) 'album_count': albumCount,
      if (starred != null) 'starred': starred,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StagedArtistsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? sortName,
    Value<String?>? coverArt,
    Value<int>? albumCount,
    Value<bool>? starred,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return StagedArtistsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sortName: sortName ?? this.sortName,
      coverArt: coverArt ?? this.coverArt,
      albumCount: albumCount ?? this.albumCount,
      starred: starred ?? this.starred,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortName.present) {
      map['sort_name'] = Variable<String>(sortName.value);
    }
    if (coverArt.present) {
      map['cover_art'] = Variable<String>(coverArt.value);
    }
    if (albumCount.present) {
      map['album_count'] = Variable<int>(albumCount.value);
    }
    if (starred.present) {
      map['starred'] = Variable<bool>(starred.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StagedArtistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortName: $sortName, ')
          ..write('coverArt: $coverArt, ')
          ..write('albumCount: $albumCount, ')
          ..write('starred: $starred, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StagedAlbumsTable extends StagedAlbums
    with TableInfo<$StagedAlbumsTable, StagedAlbum> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StagedAlbumsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistIdMeta = const VerificationMeta(
    'artistId',
  );
  @override
  late final GeneratedColumn<String> artistId = GeneratedColumn<String>(
    'artist_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _canonicalArtistMeta = const VerificationMeta(
    'canonicalArtist',
  );
  @override
  late final GeneratedColumn<String> canonicalArtist = GeneratedColumn<String>(
    'canonical_artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _songCountMeta = const VerificationMeta(
    'songCount',
  );
  @override
  late final GeneratedColumn<int> songCount = GeneratedColumn<int>(
    'song_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _playCountMeta = const VerificationMeta(
    'playCount',
  );
  @override
  late final GeneratedColumn<int> playCount = GeneratedColumn<int>(
    'play_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _coverArtMeta = const VerificationMeta(
    'coverArt',
  );
  @override
  late final GeneratedColumn<String> coverArt = GeneratedColumn<String>(
    'cover_art',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _starredMeta = const VerificationMeta(
    'starred',
  );
  @override
  late final GeneratedColumn<bool> starred = GeneratedColumn<bool>(
    'starred',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("starred" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    artistId,
    artist,
    canonicalArtist,
    year,
    songCount,
    duration,
    playCount,
    coverArt,
    starred,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'staged_albums';
  @override
  VerificationContext validateIntegrity(
    Insertable<StagedAlbum> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('artist_id')) {
      context.handle(
        _artistIdMeta,
        artistId.isAcceptableOrUnknown(data['artist_id']!, _artistIdMeta),
      );
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    } else if (isInserting) {
      context.missing(_artistMeta);
    }
    if (data.containsKey('canonical_artist')) {
      context.handle(
        _canonicalArtistMeta,
        canonicalArtist.isAcceptableOrUnknown(
          data['canonical_artist']!,
          _canonicalArtistMeta,
        ),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('song_count')) {
      context.handle(
        _songCountMeta,
        songCount.isAcceptableOrUnknown(data['song_count']!, _songCountMeta),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    }
    if (data.containsKey('play_count')) {
      context.handle(
        _playCountMeta,
        playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta),
      );
    }
    if (data.containsKey('cover_art')) {
      context.handle(
        _coverArtMeta,
        coverArt.isAcceptableOrUnknown(data['cover_art']!, _coverArtMeta),
      );
    }
    if (data.containsKey('starred')) {
      context.handle(
        _starredMeta,
        starred.isAcceptableOrUnknown(data['starred']!, _starredMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StagedAlbum map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StagedAlbum(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      artistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_id'],
      ),
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      )!,
      canonicalArtist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canonical_artist'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      songCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}song_count'],
      )!,
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      )!,
      playCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}play_count'],
      )!,
      coverArt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_art'],
      ),
      starred: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}starred'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $StagedAlbumsTable createAlias(String alias) {
    return $StagedAlbumsTable(attachedDatabase, alias);
  }
}

class StagedAlbum extends DataClass implements Insertable<StagedAlbum> {
  final String id;
  final String name;
  final String? artistId;
  final String artist;
  final String canonicalArtist;
  final int year;
  final int songCount;
  final int duration;
  final int playCount;
  final String? coverArt;
  final bool starred;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const StagedAlbum({
    required this.id,
    required this.name,
    this.artistId,
    required this.artist,
    required this.canonicalArtist,
    required this.year,
    required this.songCount,
    required this.duration,
    required this.playCount,
    this.coverArt,
    required this.starred,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || artistId != null) {
      map['artist_id'] = Variable<String>(artistId);
    }
    map['artist'] = Variable<String>(artist);
    map['canonical_artist'] = Variable<String>(canonicalArtist);
    map['year'] = Variable<int>(year);
    map['song_count'] = Variable<int>(songCount);
    map['duration'] = Variable<int>(duration);
    map['play_count'] = Variable<int>(playCount);
    if (!nullToAbsent || coverArt != null) {
      map['cover_art'] = Variable<String>(coverArt);
    }
    map['starred'] = Variable<bool>(starred);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  StagedAlbumsCompanion toCompanion(bool nullToAbsent) {
    return StagedAlbumsCompanion(
      id: Value(id),
      name: Value(name),
      artistId: artistId == null && nullToAbsent
          ? const Value.absent()
          : Value(artistId),
      artist: Value(artist),
      canonicalArtist: Value(canonicalArtist),
      year: Value(year),
      songCount: Value(songCount),
      duration: Value(duration),
      playCount: Value(playCount),
      coverArt: coverArt == null && nullToAbsent
          ? const Value.absent()
          : Value(coverArt),
      starred: Value(starred),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory StagedAlbum.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StagedAlbum(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      artistId: serializer.fromJson<String?>(json['artistId']),
      artist: serializer.fromJson<String>(json['artist']),
      canonicalArtist: serializer.fromJson<String>(json['canonicalArtist']),
      year: serializer.fromJson<int>(json['year']),
      songCount: serializer.fromJson<int>(json['songCount']),
      duration: serializer.fromJson<int>(json['duration']),
      playCount: serializer.fromJson<int>(json['playCount']),
      coverArt: serializer.fromJson<String?>(json['coverArt']),
      starred: serializer.fromJson<bool>(json['starred']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'artistId': serializer.toJson<String?>(artistId),
      'artist': serializer.toJson<String>(artist),
      'canonicalArtist': serializer.toJson<String>(canonicalArtist),
      'year': serializer.toJson<int>(year),
      'songCount': serializer.toJson<int>(songCount),
      'duration': serializer.toJson<int>(duration),
      'playCount': serializer.toJson<int>(playCount),
      'coverArt': serializer.toJson<String?>(coverArt),
      'starred': serializer.toJson<bool>(starred),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  StagedAlbum copyWith({
    String? id,
    String? name,
    Value<String?> artistId = const Value.absent(),
    String? artist,
    String? canonicalArtist,
    int? year,
    int? songCount,
    int? duration,
    int? playCount,
    Value<String?> coverArt = const Value.absent(),
    bool? starred,
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => StagedAlbum(
    id: id ?? this.id,
    name: name ?? this.name,
    artistId: artistId.present ? artistId.value : this.artistId,
    artist: artist ?? this.artist,
    canonicalArtist: canonicalArtist ?? this.canonicalArtist,
    year: year ?? this.year,
    songCount: songCount ?? this.songCount,
    duration: duration ?? this.duration,
    playCount: playCount ?? this.playCount,
    coverArt: coverArt.present ? coverArt.value : this.coverArt,
    starred: starred ?? this.starred,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  StagedAlbum copyWithCompanion(StagedAlbumsCompanion data) {
    return StagedAlbum(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      artistId: data.artistId.present ? data.artistId.value : this.artistId,
      artist: data.artist.present ? data.artist.value : this.artist,
      canonicalArtist: data.canonicalArtist.present
          ? data.canonicalArtist.value
          : this.canonicalArtist,
      year: data.year.present ? data.year.value : this.year,
      songCount: data.songCount.present ? data.songCount.value : this.songCount,
      duration: data.duration.present ? data.duration.value : this.duration,
      playCount: data.playCount.present ? data.playCount.value : this.playCount,
      coverArt: data.coverArt.present ? data.coverArt.value : this.coverArt,
      starred: data.starred.present ? data.starred.value : this.starred,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StagedAlbum(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('artistId: $artistId, ')
          ..write('artist: $artist, ')
          ..write('canonicalArtist: $canonicalArtist, ')
          ..write('year: $year, ')
          ..write('songCount: $songCount, ')
          ..write('duration: $duration, ')
          ..write('playCount: $playCount, ')
          ..write('coverArt: $coverArt, ')
          ..write('starred: $starred, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    artistId,
    artist,
    canonicalArtist,
    year,
    songCount,
    duration,
    playCount,
    coverArt,
    starred,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StagedAlbum &&
          other.id == this.id &&
          other.name == this.name &&
          other.artistId == this.artistId &&
          other.artist == this.artist &&
          other.canonicalArtist == this.canonicalArtist &&
          other.year == this.year &&
          other.songCount == this.songCount &&
          other.duration == this.duration &&
          other.playCount == this.playCount &&
          other.coverArt == this.coverArt &&
          other.starred == this.starred &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class StagedAlbumsCompanion extends UpdateCompanion<StagedAlbum> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> artistId;
  final Value<String> artist;
  final Value<String> canonicalArtist;
  final Value<int> year;
  final Value<int> songCount;
  final Value<int> duration;
  final Value<int> playCount;
  final Value<String?> coverArt;
  final Value<bool> starred;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const StagedAlbumsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.artistId = const Value.absent(),
    this.artist = const Value.absent(),
    this.canonicalArtist = const Value.absent(),
    this.year = const Value.absent(),
    this.songCount = const Value.absent(),
    this.duration = const Value.absent(),
    this.playCount = const Value.absent(),
    this.coverArt = const Value.absent(),
    this.starred = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StagedAlbumsCompanion.insert({
    required String id,
    required String name,
    this.artistId = const Value.absent(),
    required String artist,
    this.canonicalArtist = const Value.absent(),
    this.year = const Value.absent(),
    this.songCount = const Value.absent(),
    this.duration = const Value.absent(),
    this.playCount = const Value.absent(),
    this.coverArt = const Value.absent(),
    this.starred = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       artist = Value(artist);
  static Insertable<StagedAlbum> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? artistId,
    Expression<String>? artist,
    Expression<String>? canonicalArtist,
    Expression<int>? year,
    Expression<int>? songCount,
    Expression<int>? duration,
    Expression<int>? playCount,
    Expression<String>? coverArt,
    Expression<bool>? starred,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (artistId != null) 'artist_id': artistId,
      if (artist != null) 'artist': artist,
      if (canonicalArtist != null) 'canonical_artist': canonicalArtist,
      if (year != null) 'year': year,
      if (songCount != null) 'song_count': songCount,
      if (duration != null) 'duration': duration,
      if (playCount != null) 'play_count': playCount,
      if (coverArt != null) 'cover_art': coverArt,
      if (starred != null) 'starred': starred,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StagedAlbumsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? artistId,
    Value<String>? artist,
    Value<String>? canonicalArtist,
    Value<int>? year,
    Value<int>? songCount,
    Value<int>? duration,
    Value<int>? playCount,
    Value<String?>? coverArt,
    Value<bool>? starred,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return StagedAlbumsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      artistId: artistId ?? this.artistId,
      artist: artist ?? this.artist,
      canonicalArtist: canonicalArtist ?? this.canonicalArtist,
      year: year ?? this.year,
      songCount: songCount ?? this.songCount,
      duration: duration ?? this.duration,
      playCount: playCount ?? this.playCount,
      coverArt: coverArt ?? this.coverArt,
      starred: starred ?? this.starred,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (artistId.present) {
      map['artist_id'] = Variable<String>(artistId.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (canonicalArtist.present) {
      map['canonical_artist'] = Variable<String>(canonicalArtist.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (songCount.present) {
      map['song_count'] = Variable<int>(songCount.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (playCount.present) {
      map['play_count'] = Variable<int>(playCount.value);
    }
    if (coverArt.present) {
      map['cover_art'] = Variable<String>(coverArt.value);
    }
    if (starred.present) {
      map['starred'] = Variable<bool>(starred.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StagedAlbumsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('artistId: $artistId, ')
          ..write('artist: $artist, ')
          ..write('canonicalArtist: $canonicalArtist, ')
          ..write('year: $year, ')
          ..write('songCount: $songCount, ')
          ..write('duration: $duration, ')
          ..write('playCount: $playCount, ')
          ..write('coverArt: $coverArt, ')
          ..write('starred: $starred, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalSongsTable extends LocalSongs
    with TableInfo<$LocalSongsTable, LocalSong> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSongsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _albumIdMeta = const VerificationMeta(
    'albumId',
  );
  @override
  late final GeneratedColumn<String> albumId = GeneratedColumn<String>(
    'album_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistIdMeta = const VerificationMeta(
    'artistId',
  );
  @override
  late final GeneratedColumn<String> artistId = GeneratedColumn<String>(
    'artist_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _canonicalArtistMeta = const VerificationMeta(
    'canonicalArtist',
  );
  @override
  late final GeneratedColumn<String> canonicalArtist = GeneratedColumn<String>(
    'canonical_artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _trackMeta = const VerificationMeta('track');
  @override
  late final GeneratedColumn<int> track = GeneratedColumn<int>(
    'track',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _discMeta = const VerificationMeta('disc');
  @override
  late final GeneratedColumn<int> disc = GeneratedColumn<int>(
    'disc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
    'genre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bitRateMeta = const VerificationMeta(
    'bitRate',
  );
  @override
  late final GeneratedColumn<int> bitRate = GeneratedColumn<int>(
    'bit_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bitDepthMeta = const VerificationMeta(
    'bitDepth',
  );
  @override
  late final GeneratedColumn<int> bitDepth = GeneratedColumn<int>(
    'bit_depth',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _samplingRateMeta = const VerificationMeta(
    'samplingRate',
  );
  @override
  late final GeneratedColumn<int> samplingRate = GeneratedColumn<int>(
    'sampling_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _suffixMeta = const VerificationMeta('suffix');
  @override
  late final GeneratedColumn<String> suffix = GeneratedColumn<String>(
    'suffix',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentTypeMeta = const VerificationMeta(
    'contentType',
  );
  @override
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
    'content_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverArtMeta = const VerificationMeta(
    'coverArt',
  );
  @override
  late final GeneratedColumn<String> coverArt = GeneratedColumn<String>(
    'cover_art',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _playCountMeta = const VerificationMeta(
    'playCount',
  );
  @override
  late final GeneratedColumn<int> playCount = GeneratedColumn<int>(
    'play_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _starredMeta = const VerificationMeta(
    'starred',
  );
  @override
  late final GeneratedColumn<bool> starred = GeneratedColumn<bool>(
    'starred',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("starred" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _starredAtMeta = const VerificationMeta(
    'starredAt',
  );
  @override
  late final GeneratedColumn<DateTime> starredAt = GeneratedColumn<DateTime>(
    'starred_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastPlayedAtMeta = const VerificationMeta(
    'lastPlayedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPlayedAt = GeneratedColumn<DateTime>(
    'last_played_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    albumId,
    album,
    artistId,
    artist,
    canonicalArtist,
    track,
    disc,
    year,
    genre,
    duration,
    bitRate,
    bitDepth,
    samplingRate,
    suffix,
    contentType,
    fileSize,
    coverArt,
    playCount,
    starred,
    starredAt,
    createdAt,
    lastPlayedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_songs';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSong> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('album_id')) {
      context.handle(
        _albumIdMeta,
        albumId.isAcceptableOrUnknown(data['album_id']!, _albumIdMeta),
      );
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    } else if (isInserting) {
      context.missing(_albumMeta);
    }
    if (data.containsKey('artist_id')) {
      context.handle(
        _artistIdMeta,
        artistId.isAcceptableOrUnknown(data['artist_id']!, _artistIdMeta),
      );
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    } else if (isInserting) {
      context.missing(_artistMeta);
    }
    if (data.containsKey('canonical_artist')) {
      context.handle(
        _canonicalArtistMeta,
        canonicalArtist.isAcceptableOrUnknown(
          data['canonical_artist']!,
          _canonicalArtistMeta,
        ),
      );
    }
    if (data.containsKey('track')) {
      context.handle(
        _trackMeta,
        track.isAcceptableOrUnknown(data['track']!, _trackMeta),
      );
    }
    if (data.containsKey('disc')) {
      context.handle(
        _discMeta,
        disc.isAcceptableOrUnknown(data['disc']!, _discMeta),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('genre')) {
      context.handle(
        _genreMeta,
        genre.isAcceptableOrUnknown(data['genre']!, _genreMeta),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    }
    if (data.containsKey('bit_rate')) {
      context.handle(
        _bitRateMeta,
        bitRate.isAcceptableOrUnknown(data['bit_rate']!, _bitRateMeta),
      );
    }
    if (data.containsKey('bit_depth')) {
      context.handle(
        _bitDepthMeta,
        bitDepth.isAcceptableOrUnknown(data['bit_depth']!, _bitDepthMeta),
      );
    }
    if (data.containsKey('sampling_rate')) {
      context.handle(
        _samplingRateMeta,
        samplingRate.isAcceptableOrUnknown(
          data['sampling_rate']!,
          _samplingRateMeta,
        ),
      );
    }
    if (data.containsKey('suffix')) {
      context.handle(
        _suffixMeta,
        suffix.isAcceptableOrUnknown(data['suffix']!, _suffixMeta),
      );
    }
    if (data.containsKey('content_type')) {
      context.handle(
        _contentTypeMeta,
        contentType.isAcceptableOrUnknown(
          data['content_type']!,
          _contentTypeMeta,
        ),
      );
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    }
    if (data.containsKey('cover_art')) {
      context.handle(
        _coverArtMeta,
        coverArt.isAcceptableOrUnknown(data['cover_art']!, _coverArtMeta),
      );
    }
    if (data.containsKey('play_count')) {
      context.handle(
        _playCountMeta,
        playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta),
      );
    }
    if (data.containsKey('starred')) {
      context.handle(
        _starredMeta,
        starred.isAcceptableOrUnknown(data['starred']!, _starredMeta),
      );
    }
    if (data.containsKey('starred_at')) {
      context.handle(
        _starredAtMeta,
        starredAt.isAcceptableOrUnknown(data['starred_at']!, _starredAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('last_played_at')) {
      context.handle(
        _lastPlayedAtMeta,
        lastPlayedAt.isAcceptableOrUnknown(
          data['last_played_at']!,
          _lastPlayedAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalSong map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSong(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      albumId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_id'],
      ),
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      )!,
      artistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_id'],
      ),
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      )!,
      canonicalArtist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canonical_artist'],
      )!,
      track: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track'],
      )!,
      disc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}disc'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre'],
      ),
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      )!,
      bitRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bit_rate'],
      ),
      bitDepth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bit_depth'],
      ),
      samplingRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sampling_rate'],
      ),
      suffix: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}suffix'],
      ),
      contentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_type'],
      ),
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      ),
      coverArt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_art'],
      ),
      playCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}play_count'],
      )!,
      starred: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}starred'],
      )!,
      starredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}starred_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      lastPlayedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_played_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $LocalSongsTable createAlias(String alias) {
    return $LocalSongsTable(attachedDatabase, alias);
  }
}

class LocalSong extends DataClass implements Insertable<LocalSong> {
  final String id;
  final String title;
  final String? albumId;
  final String album;
  final String? artistId;
  final String artist;
  final String canonicalArtist;
  final int track;
  final int disc;
  final int year;
  final String? genre;
  final int duration;
  final int? bitRate;
  final int? bitDepth;
  final int? samplingRate;
  final String? suffix;
  final String? contentType;
  final int? fileSize;
  final String? coverArt;
  final int playCount;
  final bool starred;
  final DateTime? starredAt;
  final DateTime? createdAt;
  final DateTime? lastPlayedAt;
  final DateTime? updatedAt;
  const LocalSong({
    required this.id,
    required this.title,
    this.albumId,
    required this.album,
    this.artistId,
    required this.artist,
    required this.canonicalArtist,
    required this.track,
    required this.disc,
    required this.year,
    this.genre,
    required this.duration,
    this.bitRate,
    this.bitDepth,
    this.samplingRate,
    this.suffix,
    this.contentType,
    this.fileSize,
    this.coverArt,
    required this.playCount,
    required this.starred,
    this.starredAt,
    this.createdAt,
    this.lastPlayedAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || albumId != null) {
      map['album_id'] = Variable<String>(albumId);
    }
    map['album'] = Variable<String>(album);
    if (!nullToAbsent || artistId != null) {
      map['artist_id'] = Variable<String>(artistId);
    }
    map['artist'] = Variable<String>(artist);
    map['canonical_artist'] = Variable<String>(canonicalArtist);
    map['track'] = Variable<int>(track);
    map['disc'] = Variable<int>(disc);
    map['year'] = Variable<int>(year);
    if (!nullToAbsent || genre != null) {
      map['genre'] = Variable<String>(genre);
    }
    map['duration'] = Variable<int>(duration);
    if (!nullToAbsent || bitRate != null) {
      map['bit_rate'] = Variable<int>(bitRate);
    }
    if (!nullToAbsent || bitDepth != null) {
      map['bit_depth'] = Variable<int>(bitDepth);
    }
    if (!nullToAbsent || samplingRate != null) {
      map['sampling_rate'] = Variable<int>(samplingRate);
    }
    if (!nullToAbsent || suffix != null) {
      map['suffix'] = Variable<String>(suffix);
    }
    if (!nullToAbsent || contentType != null) {
      map['content_type'] = Variable<String>(contentType);
    }
    if (!nullToAbsent || fileSize != null) {
      map['file_size'] = Variable<int>(fileSize);
    }
    if (!nullToAbsent || coverArt != null) {
      map['cover_art'] = Variable<String>(coverArt);
    }
    map['play_count'] = Variable<int>(playCount);
    map['starred'] = Variable<bool>(starred);
    if (!nullToAbsent || starredAt != null) {
      map['starred_at'] = Variable<DateTime>(starredAt);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || lastPlayedAt != null) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  LocalSongsCompanion toCompanion(bool nullToAbsent) {
    return LocalSongsCompanion(
      id: Value(id),
      title: Value(title),
      albumId: albumId == null && nullToAbsent
          ? const Value.absent()
          : Value(albumId),
      album: Value(album),
      artistId: artistId == null && nullToAbsent
          ? const Value.absent()
          : Value(artistId),
      artist: Value(artist),
      canonicalArtist: Value(canonicalArtist),
      track: Value(track),
      disc: Value(disc),
      year: Value(year),
      genre: genre == null && nullToAbsent
          ? const Value.absent()
          : Value(genre),
      duration: Value(duration),
      bitRate: bitRate == null && nullToAbsent
          ? const Value.absent()
          : Value(bitRate),
      bitDepth: bitDepth == null && nullToAbsent
          ? const Value.absent()
          : Value(bitDepth),
      samplingRate: samplingRate == null && nullToAbsent
          ? const Value.absent()
          : Value(samplingRate),
      suffix: suffix == null && nullToAbsent
          ? const Value.absent()
          : Value(suffix),
      contentType: contentType == null && nullToAbsent
          ? const Value.absent()
          : Value(contentType),
      fileSize: fileSize == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSize),
      coverArt: coverArt == null && nullToAbsent
          ? const Value.absent()
          : Value(coverArt),
      playCount: Value(playCount),
      starred: Value(starred),
      starredAt: starredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(starredAt),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      lastPlayedAt: lastPlayedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayedAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory LocalSong.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSong(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      albumId: serializer.fromJson<String?>(json['albumId']),
      album: serializer.fromJson<String>(json['album']),
      artistId: serializer.fromJson<String?>(json['artistId']),
      artist: serializer.fromJson<String>(json['artist']),
      canonicalArtist: serializer.fromJson<String>(json['canonicalArtist']),
      track: serializer.fromJson<int>(json['track']),
      disc: serializer.fromJson<int>(json['disc']),
      year: serializer.fromJson<int>(json['year']),
      genre: serializer.fromJson<String?>(json['genre']),
      duration: serializer.fromJson<int>(json['duration']),
      bitRate: serializer.fromJson<int?>(json['bitRate']),
      bitDepth: serializer.fromJson<int?>(json['bitDepth']),
      samplingRate: serializer.fromJson<int?>(json['samplingRate']),
      suffix: serializer.fromJson<String?>(json['suffix']),
      contentType: serializer.fromJson<String?>(json['contentType']),
      fileSize: serializer.fromJson<int?>(json['fileSize']),
      coverArt: serializer.fromJson<String?>(json['coverArt']),
      playCount: serializer.fromJson<int>(json['playCount']),
      starred: serializer.fromJson<bool>(json['starred']),
      starredAt: serializer.fromJson<DateTime?>(json['starredAt']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      lastPlayedAt: serializer.fromJson<DateTime?>(json['lastPlayedAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'albumId': serializer.toJson<String?>(albumId),
      'album': serializer.toJson<String>(album),
      'artistId': serializer.toJson<String?>(artistId),
      'artist': serializer.toJson<String>(artist),
      'canonicalArtist': serializer.toJson<String>(canonicalArtist),
      'track': serializer.toJson<int>(track),
      'disc': serializer.toJson<int>(disc),
      'year': serializer.toJson<int>(year),
      'genre': serializer.toJson<String?>(genre),
      'duration': serializer.toJson<int>(duration),
      'bitRate': serializer.toJson<int?>(bitRate),
      'bitDepth': serializer.toJson<int?>(bitDepth),
      'samplingRate': serializer.toJson<int?>(samplingRate),
      'suffix': serializer.toJson<String?>(suffix),
      'contentType': serializer.toJson<String?>(contentType),
      'fileSize': serializer.toJson<int?>(fileSize),
      'coverArt': serializer.toJson<String?>(coverArt),
      'playCount': serializer.toJson<int>(playCount),
      'starred': serializer.toJson<bool>(starred),
      'starredAt': serializer.toJson<DateTime?>(starredAt),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'lastPlayedAt': serializer.toJson<DateTime?>(lastPlayedAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  LocalSong copyWith({
    String? id,
    String? title,
    Value<String?> albumId = const Value.absent(),
    String? album,
    Value<String?> artistId = const Value.absent(),
    String? artist,
    String? canonicalArtist,
    int? track,
    int? disc,
    int? year,
    Value<String?> genre = const Value.absent(),
    int? duration,
    Value<int?> bitRate = const Value.absent(),
    Value<int?> bitDepth = const Value.absent(),
    Value<int?> samplingRate = const Value.absent(),
    Value<String?> suffix = const Value.absent(),
    Value<String?> contentType = const Value.absent(),
    Value<int?> fileSize = const Value.absent(),
    Value<String?> coverArt = const Value.absent(),
    int? playCount,
    bool? starred,
    Value<DateTime?> starredAt = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> lastPlayedAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => LocalSong(
    id: id ?? this.id,
    title: title ?? this.title,
    albumId: albumId.present ? albumId.value : this.albumId,
    album: album ?? this.album,
    artistId: artistId.present ? artistId.value : this.artistId,
    artist: artist ?? this.artist,
    canonicalArtist: canonicalArtist ?? this.canonicalArtist,
    track: track ?? this.track,
    disc: disc ?? this.disc,
    year: year ?? this.year,
    genre: genre.present ? genre.value : this.genre,
    duration: duration ?? this.duration,
    bitRate: bitRate.present ? bitRate.value : this.bitRate,
    bitDepth: bitDepth.present ? bitDepth.value : this.bitDepth,
    samplingRate: samplingRate.present ? samplingRate.value : this.samplingRate,
    suffix: suffix.present ? suffix.value : this.suffix,
    contentType: contentType.present ? contentType.value : this.contentType,
    fileSize: fileSize.present ? fileSize.value : this.fileSize,
    coverArt: coverArt.present ? coverArt.value : this.coverArt,
    playCount: playCount ?? this.playCount,
    starred: starred ?? this.starred,
    starredAt: starredAt.present ? starredAt.value : this.starredAt,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    lastPlayedAt: lastPlayedAt.present ? lastPlayedAt.value : this.lastPlayedAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  LocalSong copyWithCompanion(LocalSongsCompanion data) {
    return LocalSong(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      albumId: data.albumId.present ? data.albumId.value : this.albumId,
      album: data.album.present ? data.album.value : this.album,
      artistId: data.artistId.present ? data.artistId.value : this.artistId,
      artist: data.artist.present ? data.artist.value : this.artist,
      canonicalArtist: data.canonicalArtist.present
          ? data.canonicalArtist.value
          : this.canonicalArtist,
      track: data.track.present ? data.track.value : this.track,
      disc: data.disc.present ? data.disc.value : this.disc,
      year: data.year.present ? data.year.value : this.year,
      genre: data.genre.present ? data.genre.value : this.genre,
      duration: data.duration.present ? data.duration.value : this.duration,
      bitRate: data.bitRate.present ? data.bitRate.value : this.bitRate,
      bitDepth: data.bitDepth.present ? data.bitDepth.value : this.bitDepth,
      samplingRate: data.samplingRate.present
          ? data.samplingRate.value
          : this.samplingRate,
      suffix: data.suffix.present ? data.suffix.value : this.suffix,
      contentType: data.contentType.present
          ? data.contentType.value
          : this.contentType,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      coverArt: data.coverArt.present ? data.coverArt.value : this.coverArt,
      playCount: data.playCount.present ? data.playCount.value : this.playCount,
      starred: data.starred.present ? data.starred.value : this.starred,
      starredAt: data.starredAt.present ? data.starredAt.value : this.starredAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastPlayedAt: data.lastPlayedAt.present
          ? data.lastPlayedAt.value
          : this.lastPlayedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSong(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('albumId: $albumId, ')
          ..write('album: $album, ')
          ..write('artistId: $artistId, ')
          ..write('artist: $artist, ')
          ..write('canonicalArtist: $canonicalArtist, ')
          ..write('track: $track, ')
          ..write('disc: $disc, ')
          ..write('year: $year, ')
          ..write('genre: $genre, ')
          ..write('duration: $duration, ')
          ..write('bitRate: $bitRate, ')
          ..write('bitDepth: $bitDepth, ')
          ..write('samplingRate: $samplingRate, ')
          ..write('suffix: $suffix, ')
          ..write('contentType: $contentType, ')
          ..write('fileSize: $fileSize, ')
          ..write('coverArt: $coverArt, ')
          ..write('playCount: $playCount, ')
          ..write('starred: $starred, ')
          ..write('starredAt: $starredAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    title,
    albumId,
    album,
    artistId,
    artist,
    canonicalArtist,
    track,
    disc,
    year,
    genre,
    duration,
    bitRate,
    bitDepth,
    samplingRate,
    suffix,
    contentType,
    fileSize,
    coverArt,
    playCount,
    starred,
    starredAt,
    createdAt,
    lastPlayedAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSong &&
          other.id == this.id &&
          other.title == this.title &&
          other.albumId == this.albumId &&
          other.album == this.album &&
          other.artistId == this.artistId &&
          other.artist == this.artist &&
          other.canonicalArtist == this.canonicalArtist &&
          other.track == this.track &&
          other.disc == this.disc &&
          other.year == this.year &&
          other.genre == this.genre &&
          other.duration == this.duration &&
          other.bitRate == this.bitRate &&
          other.bitDepth == this.bitDepth &&
          other.samplingRate == this.samplingRate &&
          other.suffix == this.suffix &&
          other.contentType == this.contentType &&
          other.fileSize == this.fileSize &&
          other.coverArt == this.coverArt &&
          other.playCount == this.playCount &&
          other.starred == this.starred &&
          other.starredAt == this.starredAt &&
          other.createdAt == this.createdAt &&
          other.lastPlayedAt == this.lastPlayedAt &&
          other.updatedAt == this.updatedAt);
}

class LocalSongsCompanion extends UpdateCompanion<LocalSong> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> albumId;
  final Value<String> album;
  final Value<String?> artistId;
  final Value<String> artist;
  final Value<String> canonicalArtist;
  final Value<int> track;
  final Value<int> disc;
  final Value<int> year;
  final Value<String?> genre;
  final Value<int> duration;
  final Value<int?> bitRate;
  final Value<int?> bitDepth;
  final Value<int?> samplingRate;
  final Value<String?> suffix;
  final Value<String?> contentType;
  final Value<int?> fileSize;
  final Value<String?> coverArt;
  final Value<int> playCount;
  final Value<bool> starred;
  final Value<DateTime?> starredAt;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> lastPlayedAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const LocalSongsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.albumId = const Value.absent(),
    this.album = const Value.absent(),
    this.artistId = const Value.absent(),
    this.artist = const Value.absent(),
    this.canonicalArtist = const Value.absent(),
    this.track = const Value.absent(),
    this.disc = const Value.absent(),
    this.year = const Value.absent(),
    this.genre = const Value.absent(),
    this.duration = const Value.absent(),
    this.bitRate = const Value.absent(),
    this.bitDepth = const Value.absent(),
    this.samplingRate = const Value.absent(),
    this.suffix = const Value.absent(),
    this.contentType = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.coverArt = const Value.absent(),
    this.playCount = const Value.absent(),
    this.starred = const Value.absent(),
    this.starredAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSongsCompanion.insert({
    required String id,
    required String title,
    this.albumId = const Value.absent(),
    required String album,
    this.artistId = const Value.absent(),
    required String artist,
    this.canonicalArtist = const Value.absent(),
    this.track = const Value.absent(),
    this.disc = const Value.absent(),
    this.year = const Value.absent(),
    this.genre = const Value.absent(),
    this.duration = const Value.absent(),
    this.bitRate = const Value.absent(),
    this.bitDepth = const Value.absent(),
    this.samplingRate = const Value.absent(),
    this.suffix = const Value.absent(),
    this.contentType = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.coverArt = const Value.absent(),
    this.playCount = const Value.absent(),
    this.starred = const Value.absent(),
    this.starredAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       album = Value(album),
       artist = Value(artist);
  static Insertable<LocalSong> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? albumId,
    Expression<String>? album,
    Expression<String>? artistId,
    Expression<String>? artist,
    Expression<String>? canonicalArtist,
    Expression<int>? track,
    Expression<int>? disc,
    Expression<int>? year,
    Expression<String>? genre,
    Expression<int>? duration,
    Expression<int>? bitRate,
    Expression<int>? bitDepth,
    Expression<int>? samplingRate,
    Expression<String>? suffix,
    Expression<String>? contentType,
    Expression<int>? fileSize,
    Expression<String>? coverArt,
    Expression<int>? playCount,
    Expression<bool>? starred,
    Expression<DateTime>? starredAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastPlayedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (albumId != null) 'album_id': albumId,
      if (album != null) 'album': album,
      if (artistId != null) 'artist_id': artistId,
      if (artist != null) 'artist': artist,
      if (canonicalArtist != null) 'canonical_artist': canonicalArtist,
      if (track != null) 'track': track,
      if (disc != null) 'disc': disc,
      if (year != null) 'year': year,
      if (genre != null) 'genre': genre,
      if (duration != null) 'duration': duration,
      if (bitRate != null) 'bit_rate': bitRate,
      if (bitDepth != null) 'bit_depth': bitDepth,
      if (samplingRate != null) 'sampling_rate': samplingRate,
      if (suffix != null) 'suffix': suffix,
      if (contentType != null) 'content_type': contentType,
      if (fileSize != null) 'file_size': fileSize,
      if (coverArt != null) 'cover_art': coverArt,
      if (playCount != null) 'play_count': playCount,
      if (starred != null) 'starred': starred,
      if (starredAt != null) 'starred_at': starredAt,
      if (createdAt != null) 'created_at': createdAt,
      if (lastPlayedAt != null) 'last_played_at': lastPlayedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSongsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? albumId,
    Value<String>? album,
    Value<String?>? artistId,
    Value<String>? artist,
    Value<String>? canonicalArtist,
    Value<int>? track,
    Value<int>? disc,
    Value<int>? year,
    Value<String?>? genre,
    Value<int>? duration,
    Value<int?>? bitRate,
    Value<int?>? bitDepth,
    Value<int?>? samplingRate,
    Value<String?>? suffix,
    Value<String?>? contentType,
    Value<int?>? fileSize,
    Value<String?>? coverArt,
    Value<int>? playCount,
    Value<bool>? starred,
    Value<DateTime?>? starredAt,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? lastPlayedAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalSongsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      albumId: albumId ?? this.albumId,
      album: album ?? this.album,
      artistId: artistId ?? this.artistId,
      artist: artist ?? this.artist,
      canonicalArtist: canonicalArtist ?? this.canonicalArtist,
      track: track ?? this.track,
      disc: disc ?? this.disc,
      year: year ?? this.year,
      genre: genre ?? this.genre,
      duration: duration ?? this.duration,
      bitRate: bitRate ?? this.bitRate,
      bitDepth: bitDepth ?? this.bitDepth,
      samplingRate: samplingRate ?? this.samplingRate,
      suffix: suffix ?? this.suffix,
      contentType: contentType ?? this.contentType,
      fileSize: fileSize ?? this.fileSize,
      coverArt: coverArt ?? this.coverArt,
      playCount: playCount ?? this.playCount,
      starred: starred ?? this.starred,
      starredAt: starredAt ?? this.starredAt,
      createdAt: createdAt ?? this.createdAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (albumId.present) {
      map['album_id'] = Variable<String>(albumId.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (artistId.present) {
      map['artist_id'] = Variable<String>(artistId.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (canonicalArtist.present) {
      map['canonical_artist'] = Variable<String>(canonicalArtist.value);
    }
    if (track.present) {
      map['track'] = Variable<int>(track.value);
    }
    if (disc.present) {
      map['disc'] = Variable<int>(disc.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (bitRate.present) {
      map['bit_rate'] = Variable<int>(bitRate.value);
    }
    if (bitDepth.present) {
      map['bit_depth'] = Variable<int>(bitDepth.value);
    }
    if (samplingRate.present) {
      map['sampling_rate'] = Variable<int>(samplingRate.value);
    }
    if (suffix.present) {
      map['suffix'] = Variable<String>(suffix.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (coverArt.present) {
      map['cover_art'] = Variable<String>(coverArt.value);
    }
    if (playCount.present) {
      map['play_count'] = Variable<int>(playCount.value);
    }
    if (starred.present) {
      map['starred'] = Variable<bool>(starred.value);
    }
    if (starredAt.present) {
      map['starred_at'] = Variable<DateTime>(starredAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastPlayedAt.present) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSongsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('albumId: $albumId, ')
          ..write('album: $album, ')
          ..write('artistId: $artistId, ')
          ..write('artist: $artist, ')
          ..write('canonicalArtist: $canonicalArtist, ')
          ..write('track: $track, ')
          ..write('disc: $disc, ')
          ..write('year: $year, ')
          ..write('genre: $genre, ')
          ..write('duration: $duration, ')
          ..write('bitRate: $bitRate, ')
          ..write('bitDepth: $bitDepth, ')
          ..write('samplingRate: $samplingRate, ')
          ..write('suffix: $suffix, ')
          ..write('contentType: $contentType, ')
          ..write('fileSize: $fileSize, ')
          ..write('coverArt: $coverArt, ')
          ..write('playCount: $playCount, ')
          ..write('starred: $starred, ')
          ..write('starredAt: $starredAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StagedSongsTable extends StagedSongs
    with TableInfo<$StagedSongsTable, StagedSong> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StagedSongsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _albumIdMeta = const VerificationMeta(
    'albumId',
  );
  @override
  late final GeneratedColumn<String> albumId = GeneratedColumn<String>(
    'album_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistIdMeta = const VerificationMeta(
    'artistId',
  );
  @override
  late final GeneratedColumn<String> artistId = GeneratedColumn<String>(
    'artist_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _canonicalArtistMeta = const VerificationMeta(
    'canonicalArtist',
  );
  @override
  late final GeneratedColumn<String> canonicalArtist = GeneratedColumn<String>(
    'canonical_artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _trackMeta = const VerificationMeta('track');
  @override
  late final GeneratedColumn<int> track = GeneratedColumn<int>(
    'track',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _discMeta = const VerificationMeta('disc');
  @override
  late final GeneratedColumn<int> disc = GeneratedColumn<int>(
    'disc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
    'genre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bitRateMeta = const VerificationMeta(
    'bitRate',
  );
  @override
  late final GeneratedColumn<int> bitRate = GeneratedColumn<int>(
    'bit_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bitDepthMeta = const VerificationMeta(
    'bitDepth',
  );
  @override
  late final GeneratedColumn<int> bitDepth = GeneratedColumn<int>(
    'bit_depth',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _samplingRateMeta = const VerificationMeta(
    'samplingRate',
  );
  @override
  late final GeneratedColumn<int> samplingRate = GeneratedColumn<int>(
    'sampling_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _suffixMeta = const VerificationMeta('suffix');
  @override
  late final GeneratedColumn<String> suffix = GeneratedColumn<String>(
    'suffix',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentTypeMeta = const VerificationMeta(
    'contentType',
  );
  @override
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
    'content_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverArtMeta = const VerificationMeta(
    'coverArt',
  );
  @override
  late final GeneratedColumn<String> coverArt = GeneratedColumn<String>(
    'cover_art',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _playCountMeta = const VerificationMeta(
    'playCount',
  );
  @override
  late final GeneratedColumn<int> playCount = GeneratedColumn<int>(
    'play_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _starredMeta = const VerificationMeta(
    'starred',
  );
  @override
  late final GeneratedColumn<bool> starred = GeneratedColumn<bool>(
    'starred',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("starred" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _starredAtMeta = const VerificationMeta(
    'starredAt',
  );
  @override
  late final GeneratedColumn<DateTime> starredAt = GeneratedColumn<DateTime>(
    'starred_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastPlayedAtMeta = const VerificationMeta(
    'lastPlayedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPlayedAt = GeneratedColumn<DateTime>(
    'last_played_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    albumId,
    album,
    artistId,
    artist,
    canonicalArtist,
    track,
    disc,
    year,
    genre,
    duration,
    bitRate,
    bitDepth,
    samplingRate,
    suffix,
    contentType,
    fileSize,
    coverArt,
    playCount,
    starred,
    starredAt,
    createdAt,
    lastPlayedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'staged_songs';
  @override
  VerificationContext validateIntegrity(
    Insertable<StagedSong> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('album_id')) {
      context.handle(
        _albumIdMeta,
        albumId.isAcceptableOrUnknown(data['album_id']!, _albumIdMeta),
      );
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    } else if (isInserting) {
      context.missing(_albumMeta);
    }
    if (data.containsKey('artist_id')) {
      context.handle(
        _artistIdMeta,
        artistId.isAcceptableOrUnknown(data['artist_id']!, _artistIdMeta),
      );
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    } else if (isInserting) {
      context.missing(_artistMeta);
    }
    if (data.containsKey('canonical_artist')) {
      context.handle(
        _canonicalArtistMeta,
        canonicalArtist.isAcceptableOrUnknown(
          data['canonical_artist']!,
          _canonicalArtistMeta,
        ),
      );
    }
    if (data.containsKey('track')) {
      context.handle(
        _trackMeta,
        track.isAcceptableOrUnknown(data['track']!, _trackMeta),
      );
    }
    if (data.containsKey('disc')) {
      context.handle(
        _discMeta,
        disc.isAcceptableOrUnknown(data['disc']!, _discMeta),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('genre')) {
      context.handle(
        _genreMeta,
        genre.isAcceptableOrUnknown(data['genre']!, _genreMeta),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    }
    if (data.containsKey('bit_rate')) {
      context.handle(
        _bitRateMeta,
        bitRate.isAcceptableOrUnknown(data['bit_rate']!, _bitRateMeta),
      );
    }
    if (data.containsKey('bit_depth')) {
      context.handle(
        _bitDepthMeta,
        bitDepth.isAcceptableOrUnknown(data['bit_depth']!, _bitDepthMeta),
      );
    }
    if (data.containsKey('sampling_rate')) {
      context.handle(
        _samplingRateMeta,
        samplingRate.isAcceptableOrUnknown(
          data['sampling_rate']!,
          _samplingRateMeta,
        ),
      );
    }
    if (data.containsKey('suffix')) {
      context.handle(
        _suffixMeta,
        suffix.isAcceptableOrUnknown(data['suffix']!, _suffixMeta),
      );
    }
    if (data.containsKey('content_type')) {
      context.handle(
        _contentTypeMeta,
        contentType.isAcceptableOrUnknown(
          data['content_type']!,
          _contentTypeMeta,
        ),
      );
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    }
    if (data.containsKey('cover_art')) {
      context.handle(
        _coverArtMeta,
        coverArt.isAcceptableOrUnknown(data['cover_art']!, _coverArtMeta),
      );
    }
    if (data.containsKey('play_count')) {
      context.handle(
        _playCountMeta,
        playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta),
      );
    }
    if (data.containsKey('starred')) {
      context.handle(
        _starredMeta,
        starred.isAcceptableOrUnknown(data['starred']!, _starredMeta),
      );
    }
    if (data.containsKey('starred_at')) {
      context.handle(
        _starredAtMeta,
        starredAt.isAcceptableOrUnknown(data['starred_at']!, _starredAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('last_played_at')) {
      context.handle(
        _lastPlayedAtMeta,
        lastPlayedAt.isAcceptableOrUnknown(
          data['last_played_at']!,
          _lastPlayedAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StagedSong map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StagedSong(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      albumId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_id'],
      ),
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      )!,
      artistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_id'],
      ),
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      )!,
      canonicalArtist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canonical_artist'],
      )!,
      track: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track'],
      )!,
      disc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}disc'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre'],
      ),
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      )!,
      bitRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bit_rate'],
      ),
      bitDepth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bit_depth'],
      ),
      samplingRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sampling_rate'],
      ),
      suffix: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}suffix'],
      ),
      contentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_type'],
      ),
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      ),
      coverArt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_art'],
      ),
      playCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}play_count'],
      )!,
      starred: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}starred'],
      )!,
      starredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}starred_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      lastPlayedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_played_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $StagedSongsTable createAlias(String alias) {
    return $StagedSongsTable(attachedDatabase, alias);
  }
}

class StagedSong extends DataClass implements Insertable<StagedSong> {
  final String id;
  final String title;
  final String? albumId;
  final String album;
  final String? artistId;
  final String artist;
  final String canonicalArtist;
  final int track;
  final int disc;
  final int year;
  final String? genre;
  final int duration;
  final int? bitRate;
  final int? bitDepth;
  final int? samplingRate;
  final String? suffix;
  final String? contentType;
  final int? fileSize;
  final String? coverArt;
  final int playCount;
  final bool starred;
  final DateTime? starredAt;
  final DateTime? createdAt;
  final DateTime? lastPlayedAt;
  final DateTime? updatedAt;
  const StagedSong({
    required this.id,
    required this.title,
    this.albumId,
    required this.album,
    this.artistId,
    required this.artist,
    required this.canonicalArtist,
    required this.track,
    required this.disc,
    required this.year,
    this.genre,
    required this.duration,
    this.bitRate,
    this.bitDepth,
    this.samplingRate,
    this.suffix,
    this.contentType,
    this.fileSize,
    this.coverArt,
    required this.playCount,
    required this.starred,
    this.starredAt,
    this.createdAt,
    this.lastPlayedAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || albumId != null) {
      map['album_id'] = Variable<String>(albumId);
    }
    map['album'] = Variable<String>(album);
    if (!nullToAbsent || artistId != null) {
      map['artist_id'] = Variable<String>(artistId);
    }
    map['artist'] = Variable<String>(artist);
    map['canonical_artist'] = Variable<String>(canonicalArtist);
    map['track'] = Variable<int>(track);
    map['disc'] = Variable<int>(disc);
    map['year'] = Variable<int>(year);
    if (!nullToAbsent || genre != null) {
      map['genre'] = Variable<String>(genre);
    }
    map['duration'] = Variable<int>(duration);
    if (!nullToAbsent || bitRate != null) {
      map['bit_rate'] = Variable<int>(bitRate);
    }
    if (!nullToAbsent || bitDepth != null) {
      map['bit_depth'] = Variable<int>(bitDepth);
    }
    if (!nullToAbsent || samplingRate != null) {
      map['sampling_rate'] = Variable<int>(samplingRate);
    }
    if (!nullToAbsent || suffix != null) {
      map['suffix'] = Variable<String>(suffix);
    }
    if (!nullToAbsent || contentType != null) {
      map['content_type'] = Variable<String>(contentType);
    }
    if (!nullToAbsent || fileSize != null) {
      map['file_size'] = Variable<int>(fileSize);
    }
    if (!nullToAbsent || coverArt != null) {
      map['cover_art'] = Variable<String>(coverArt);
    }
    map['play_count'] = Variable<int>(playCount);
    map['starred'] = Variable<bool>(starred);
    if (!nullToAbsent || starredAt != null) {
      map['starred_at'] = Variable<DateTime>(starredAt);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || lastPlayedAt != null) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  StagedSongsCompanion toCompanion(bool nullToAbsent) {
    return StagedSongsCompanion(
      id: Value(id),
      title: Value(title),
      albumId: albumId == null && nullToAbsent
          ? const Value.absent()
          : Value(albumId),
      album: Value(album),
      artistId: artistId == null && nullToAbsent
          ? const Value.absent()
          : Value(artistId),
      artist: Value(artist),
      canonicalArtist: Value(canonicalArtist),
      track: Value(track),
      disc: Value(disc),
      year: Value(year),
      genre: genre == null && nullToAbsent
          ? const Value.absent()
          : Value(genre),
      duration: Value(duration),
      bitRate: bitRate == null && nullToAbsent
          ? const Value.absent()
          : Value(bitRate),
      bitDepth: bitDepth == null && nullToAbsent
          ? const Value.absent()
          : Value(bitDepth),
      samplingRate: samplingRate == null && nullToAbsent
          ? const Value.absent()
          : Value(samplingRate),
      suffix: suffix == null && nullToAbsent
          ? const Value.absent()
          : Value(suffix),
      contentType: contentType == null && nullToAbsent
          ? const Value.absent()
          : Value(contentType),
      fileSize: fileSize == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSize),
      coverArt: coverArt == null && nullToAbsent
          ? const Value.absent()
          : Value(coverArt),
      playCount: Value(playCount),
      starred: Value(starred),
      starredAt: starredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(starredAt),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      lastPlayedAt: lastPlayedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayedAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory StagedSong.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StagedSong(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      albumId: serializer.fromJson<String?>(json['albumId']),
      album: serializer.fromJson<String>(json['album']),
      artistId: serializer.fromJson<String?>(json['artistId']),
      artist: serializer.fromJson<String>(json['artist']),
      canonicalArtist: serializer.fromJson<String>(json['canonicalArtist']),
      track: serializer.fromJson<int>(json['track']),
      disc: serializer.fromJson<int>(json['disc']),
      year: serializer.fromJson<int>(json['year']),
      genre: serializer.fromJson<String?>(json['genre']),
      duration: serializer.fromJson<int>(json['duration']),
      bitRate: serializer.fromJson<int?>(json['bitRate']),
      bitDepth: serializer.fromJson<int?>(json['bitDepth']),
      samplingRate: serializer.fromJson<int?>(json['samplingRate']),
      suffix: serializer.fromJson<String?>(json['suffix']),
      contentType: serializer.fromJson<String?>(json['contentType']),
      fileSize: serializer.fromJson<int?>(json['fileSize']),
      coverArt: serializer.fromJson<String?>(json['coverArt']),
      playCount: serializer.fromJson<int>(json['playCount']),
      starred: serializer.fromJson<bool>(json['starred']),
      starredAt: serializer.fromJson<DateTime?>(json['starredAt']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      lastPlayedAt: serializer.fromJson<DateTime?>(json['lastPlayedAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'albumId': serializer.toJson<String?>(albumId),
      'album': serializer.toJson<String>(album),
      'artistId': serializer.toJson<String?>(artistId),
      'artist': serializer.toJson<String>(artist),
      'canonicalArtist': serializer.toJson<String>(canonicalArtist),
      'track': serializer.toJson<int>(track),
      'disc': serializer.toJson<int>(disc),
      'year': serializer.toJson<int>(year),
      'genre': serializer.toJson<String?>(genre),
      'duration': serializer.toJson<int>(duration),
      'bitRate': serializer.toJson<int?>(bitRate),
      'bitDepth': serializer.toJson<int?>(bitDepth),
      'samplingRate': serializer.toJson<int?>(samplingRate),
      'suffix': serializer.toJson<String?>(suffix),
      'contentType': serializer.toJson<String?>(contentType),
      'fileSize': serializer.toJson<int?>(fileSize),
      'coverArt': serializer.toJson<String?>(coverArt),
      'playCount': serializer.toJson<int>(playCount),
      'starred': serializer.toJson<bool>(starred),
      'starredAt': serializer.toJson<DateTime?>(starredAt),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'lastPlayedAt': serializer.toJson<DateTime?>(lastPlayedAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  StagedSong copyWith({
    String? id,
    String? title,
    Value<String?> albumId = const Value.absent(),
    String? album,
    Value<String?> artistId = const Value.absent(),
    String? artist,
    String? canonicalArtist,
    int? track,
    int? disc,
    int? year,
    Value<String?> genre = const Value.absent(),
    int? duration,
    Value<int?> bitRate = const Value.absent(),
    Value<int?> bitDepth = const Value.absent(),
    Value<int?> samplingRate = const Value.absent(),
    Value<String?> suffix = const Value.absent(),
    Value<String?> contentType = const Value.absent(),
    Value<int?> fileSize = const Value.absent(),
    Value<String?> coverArt = const Value.absent(),
    int? playCount,
    bool? starred,
    Value<DateTime?> starredAt = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> lastPlayedAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => StagedSong(
    id: id ?? this.id,
    title: title ?? this.title,
    albumId: albumId.present ? albumId.value : this.albumId,
    album: album ?? this.album,
    artistId: artistId.present ? artistId.value : this.artistId,
    artist: artist ?? this.artist,
    canonicalArtist: canonicalArtist ?? this.canonicalArtist,
    track: track ?? this.track,
    disc: disc ?? this.disc,
    year: year ?? this.year,
    genre: genre.present ? genre.value : this.genre,
    duration: duration ?? this.duration,
    bitRate: bitRate.present ? bitRate.value : this.bitRate,
    bitDepth: bitDepth.present ? bitDepth.value : this.bitDepth,
    samplingRate: samplingRate.present ? samplingRate.value : this.samplingRate,
    suffix: suffix.present ? suffix.value : this.suffix,
    contentType: contentType.present ? contentType.value : this.contentType,
    fileSize: fileSize.present ? fileSize.value : this.fileSize,
    coverArt: coverArt.present ? coverArt.value : this.coverArt,
    playCount: playCount ?? this.playCount,
    starred: starred ?? this.starred,
    starredAt: starredAt.present ? starredAt.value : this.starredAt,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    lastPlayedAt: lastPlayedAt.present ? lastPlayedAt.value : this.lastPlayedAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  StagedSong copyWithCompanion(StagedSongsCompanion data) {
    return StagedSong(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      albumId: data.albumId.present ? data.albumId.value : this.albumId,
      album: data.album.present ? data.album.value : this.album,
      artistId: data.artistId.present ? data.artistId.value : this.artistId,
      artist: data.artist.present ? data.artist.value : this.artist,
      canonicalArtist: data.canonicalArtist.present
          ? data.canonicalArtist.value
          : this.canonicalArtist,
      track: data.track.present ? data.track.value : this.track,
      disc: data.disc.present ? data.disc.value : this.disc,
      year: data.year.present ? data.year.value : this.year,
      genre: data.genre.present ? data.genre.value : this.genre,
      duration: data.duration.present ? data.duration.value : this.duration,
      bitRate: data.bitRate.present ? data.bitRate.value : this.bitRate,
      bitDepth: data.bitDepth.present ? data.bitDepth.value : this.bitDepth,
      samplingRate: data.samplingRate.present
          ? data.samplingRate.value
          : this.samplingRate,
      suffix: data.suffix.present ? data.suffix.value : this.suffix,
      contentType: data.contentType.present
          ? data.contentType.value
          : this.contentType,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      coverArt: data.coverArt.present ? data.coverArt.value : this.coverArt,
      playCount: data.playCount.present ? data.playCount.value : this.playCount,
      starred: data.starred.present ? data.starred.value : this.starred,
      starredAt: data.starredAt.present ? data.starredAt.value : this.starredAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastPlayedAt: data.lastPlayedAt.present
          ? data.lastPlayedAt.value
          : this.lastPlayedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StagedSong(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('albumId: $albumId, ')
          ..write('album: $album, ')
          ..write('artistId: $artistId, ')
          ..write('artist: $artist, ')
          ..write('canonicalArtist: $canonicalArtist, ')
          ..write('track: $track, ')
          ..write('disc: $disc, ')
          ..write('year: $year, ')
          ..write('genre: $genre, ')
          ..write('duration: $duration, ')
          ..write('bitRate: $bitRate, ')
          ..write('bitDepth: $bitDepth, ')
          ..write('samplingRate: $samplingRate, ')
          ..write('suffix: $suffix, ')
          ..write('contentType: $contentType, ')
          ..write('fileSize: $fileSize, ')
          ..write('coverArt: $coverArt, ')
          ..write('playCount: $playCount, ')
          ..write('starred: $starred, ')
          ..write('starredAt: $starredAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    title,
    albumId,
    album,
    artistId,
    artist,
    canonicalArtist,
    track,
    disc,
    year,
    genre,
    duration,
    bitRate,
    bitDepth,
    samplingRate,
    suffix,
    contentType,
    fileSize,
    coverArt,
    playCount,
    starred,
    starredAt,
    createdAt,
    lastPlayedAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StagedSong &&
          other.id == this.id &&
          other.title == this.title &&
          other.albumId == this.albumId &&
          other.album == this.album &&
          other.artistId == this.artistId &&
          other.artist == this.artist &&
          other.canonicalArtist == this.canonicalArtist &&
          other.track == this.track &&
          other.disc == this.disc &&
          other.year == this.year &&
          other.genre == this.genre &&
          other.duration == this.duration &&
          other.bitRate == this.bitRate &&
          other.bitDepth == this.bitDepth &&
          other.samplingRate == this.samplingRate &&
          other.suffix == this.suffix &&
          other.contentType == this.contentType &&
          other.fileSize == this.fileSize &&
          other.coverArt == this.coverArt &&
          other.playCount == this.playCount &&
          other.starred == this.starred &&
          other.starredAt == this.starredAt &&
          other.createdAt == this.createdAt &&
          other.lastPlayedAt == this.lastPlayedAt &&
          other.updatedAt == this.updatedAt);
}

class StagedSongsCompanion extends UpdateCompanion<StagedSong> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> albumId;
  final Value<String> album;
  final Value<String?> artistId;
  final Value<String> artist;
  final Value<String> canonicalArtist;
  final Value<int> track;
  final Value<int> disc;
  final Value<int> year;
  final Value<String?> genre;
  final Value<int> duration;
  final Value<int?> bitRate;
  final Value<int?> bitDepth;
  final Value<int?> samplingRate;
  final Value<String?> suffix;
  final Value<String?> contentType;
  final Value<int?> fileSize;
  final Value<String?> coverArt;
  final Value<int> playCount;
  final Value<bool> starred;
  final Value<DateTime?> starredAt;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> lastPlayedAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const StagedSongsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.albumId = const Value.absent(),
    this.album = const Value.absent(),
    this.artistId = const Value.absent(),
    this.artist = const Value.absent(),
    this.canonicalArtist = const Value.absent(),
    this.track = const Value.absent(),
    this.disc = const Value.absent(),
    this.year = const Value.absent(),
    this.genre = const Value.absent(),
    this.duration = const Value.absent(),
    this.bitRate = const Value.absent(),
    this.bitDepth = const Value.absent(),
    this.samplingRate = const Value.absent(),
    this.suffix = const Value.absent(),
    this.contentType = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.coverArt = const Value.absent(),
    this.playCount = const Value.absent(),
    this.starred = const Value.absent(),
    this.starredAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StagedSongsCompanion.insert({
    required String id,
    required String title,
    this.albumId = const Value.absent(),
    required String album,
    this.artistId = const Value.absent(),
    required String artist,
    this.canonicalArtist = const Value.absent(),
    this.track = const Value.absent(),
    this.disc = const Value.absent(),
    this.year = const Value.absent(),
    this.genre = const Value.absent(),
    this.duration = const Value.absent(),
    this.bitRate = const Value.absent(),
    this.bitDepth = const Value.absent(),
    this.samplingRate = const Value.absent(),
    this.suffix = const Value.absent(),
    this.contentType = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.coverArt = const Value.absent(),
    this.playCount = const Value.absent(),
    this.starred = const Value.absent(),
    this.starredAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       album = Value(album),
       artist = Value(artist);
  static Insertable<StagedSong> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? albumId,
    Expression<String>? album,
    Expression<String>? artistId,
    Expression<String>? artist,
    Expression<String>? canonicalArtist,
    Expression<int>? track,
    Expression<int>? disc,
    Expression<int>? year,
    Expression<String>? genre,
    Expression<int>? duration,
    Expression<int>? bitRate,
    Expression<int>? bitDepth,
    Expression<int>? samplingRate,
    Expression<String>? suffix,
    Expression<String>? contentType,
    Expression<int>? fileSize,
    Expression<String>? coverArt,
    Expression<int>? playCount,
    Expression<bool>? starred,
    Expression<DateTime>? starredAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastPlayedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (albumId != null) 'album_id': albumId,
      if (album != null) 'album': album,
      if (artistId != null) 'artist_id': artistId,
      if (artist != null) 'artist': artist,
      if (canonicalArtist != null) 'canonical_artist': canonicalArtist,
      if (track != null) 'track': track,
      if (disc != null) 'disc': disc,
      if (year != null) 'year': year,
      if (genre != null) 'genre': genre,
      if (duration != null) 'duration': duration,
      if (bitRate != null) 'bit_rate': bitRate,
      if (bitDepth != null) 'bit_depth': bitDepth,
      if (samplingRate != null) 'sampling_rate': samplingRate,
      if (suffix != null) 'suffix': suffix,
      if (contentType != null) 'content_type': contentType,
      if (fileSize != null) 'file_size': fileSize,
      if (coverArt != null) 'cover_art': coverArt,
      if (playCount != null) 'play_count': playCount,
      if (starred != null) 'starred': starred,
      if (starredAt != null) 'starred_at': starredAt,
      if (createdAt != null) 'created_at': createdAt,
      if (lastPlayedAt != null) 'last_played_at': lastPlayedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StagedSongsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? albumId,
    Value<String>? album,
    Value<String?>? artistId,
    Value<String>? artist,
    Value<String>? canonicalArtist,
    Value<int>? track,
    Value<int>? disc,
    Value<int>? year,
    Value<String?>? genre,
    Value<int>? duration,
    Value<int?>? bitRate,
    Value<int?>? bitDepth,
    Value<int?>? samplingRate,
    Value<String?>? suffix,
    Value<String?>? contentType,
    Value<int?>? fileSize,
    Value<String?>? coverArt,
    Value<int>? playCount,
    Value<bool>? starred,
    Value<DateTime?>? starredAt,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? lastPlayedAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return StagedSongsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      albumId: albumId ?? this.albumId,
      album: album ?? this.album,
      artistId: artistId ?? this.artistId,
      artist: artist ?? this.artist,
      canonicalArtist: canonicalArtist ?? this.canonicalArtist,
      track: track ?? this.track,
      disc: disc ?? this.disc,
      year: year ?? this.year,
      genre: genre ?? this.genre,
      duration: duration ?? this.duration,
      bitRate: bitRate ?? this.bitRate,
      bitDepth: bitDepth ?? this.bitDepth,
      samplingRate: samplingRate ?? this.samplingRate,
      suffix: suffix ?? this.suffix,
      contentType: contentType ?? this.contentType,
      fileSize: fileSize ?? this.fileSize,
      coverArt: coverArt ?? this.coverArt,
      playCount: playCount ?? this.playCount,
      starred: starred ?? this.starred,
      starredAt: starredAt ?? this.starredAt,
      createdAt: createdAt ?? this.createdAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (albumId.present) {
      map['album_id'] = Variable<String>(albumId.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (artistId.present) {
      map['artist_id'] = Variable<String>(artistId.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (canonicalArtist.present) {
      map['canonical_artist'] = Variable<String>(canonicalArtist.value);
    }
    if (track.present) {
      map['track'] = Variable<int>(track.value);
    }
    if (disc.present) {
      map['disc'] = Variable<int>(disc.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (bitRate.present) {
      map['bit_rate'] = Variable<int>(bitRate.value);
    }
    if (bitDepth.present) {
      map['bit_depth'] = Variable<int>(bitDepth.value);
    }
    if (samplingRate.present) {
      map['sampling_rate'] = Variable<int>(samplingRate.value);
    }
    if (suffix.present) {
      map['suffix'] = Variable<String>(suffix.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (coverArt.present) {
      map['cover_art'] = Variable<String>(coverArt.value);
    }
    if (playCount.present) {
      map['play_count'] = Variable<int>(playCount.value);
    }
    if (starred.present) {
      map['starred'] = Variable<bool>(starred.value);
    }
    if (starredAt.present) {
      map['starred_at'] = Variable<DateTime>(starredAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastPlayedAt.present) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StagedSongsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('albumId: $albumId, ')
          ..write('album: $album, ')
          ..write('artistId: $artistId, ')
          ..write('artist: $artist, ')
          ..write('canonicalArtist: $canonicalArtist, ')
          ..write('track: $track, ')
          ..write('disc: $disc, ')
          ..write('year: $year, ')
          ..write('genre: $genre, ')
          ..write('duration: $duration, ')
          ..write('bitRate: $bitRate, ')
          ..write('bitDepth: $bitDepth, ')
          ..write('samplingRate: $samplingRate, ')
          ..write('suffix: $suffix, ')
          ..write('contentType: $contentType, ')
          ..write('fileSize: $fileSize, ')
          ..write('coverArt: $coverArt, ')
          ..write('playCount: $playCount, ')
          ..write('starred: $starred, ')
          ..write('starredAt: $starredAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalPlaylistsTable extends LocalPlaylists
    with TableInfo<$LocalPlaylistsTable, LocalPlaylist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalPlaylistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverArtMeta = const VerificationMeta(
    'coverArt',
  );
  @override
  late final GeneratedColumn<String> coverArt = GeneratedColumn<String>(
    'cover_art',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _songCountMeta = const VerificationMeta(
    'songCount',
  );
  @override
  late final GeneratedColumn<int> songCount = GeneratedColumn<int>(
    'song_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverReadOnlyMeta = const VerificationMeta(
    'serverReadOnly',
  );
  @override
  late final GeneratedColumn<bool> serverReadOnly = GeneratedColumn<bool>(
    'server_read_only',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("server_read_only" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _ownerMeta = const VerificationMeta('owner');
  @override
  late final GeneratedColumn<String> owner = GeneratedColumn<String>(
    'owner',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isPublicMeta = const VerificationMeta(
    'isPublic',
  );
  @override
  late final GeneratedColumn<bool> isPublic = GeneratedColumn<bool>(
    'is_public',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_public" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isGeneratedMeta = const VerificationMeta(
    'isGenerated',
  );
  @override
  late final GeneratedColumn<bool> isGenerated = GeneratedColumn<bool>(
    'is_generated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_generated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _changedAtMeta = const VerificationMeta(
    'changedAt',
  );
  @override
  late final GeneratedColumn<DateTime> changedAt = GeneratedColumn<DateTime>(
    'changed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    coverArt,
    songCount,
    duration,
    serverReadOnly,
    owner,
    isPublic,
    isGenerated,
    changedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_playlists';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalPlaylist> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('cover_art')) {
      context.handle(
        _coverArtMeta,
        coverArt.isAcceptableOrUnknown(data['cover_art']!, _coverArtMeta),
      );
    }
    if (data.containsKey('song_count')) {
      context.handle(
        _songCountMeta,
        songCount.isAcceptableOrUnknown(data['song_count']!, _songCountMeta),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    }
    if (data.containsKey('server_read_only')) {
      context.handle(
        _serverReadOnlyMeta,
        serverReadOnly.isAcceptableOrUnknown(
          data['server_read_only']!,
          _serverReadOnlyMeta,
        ),
      );
    }
    if (data.containsKey('owner')) {
      context.handle(
        _ownerMeta,
        owner.isAcceptableOrUnknown(data['owner']!, _ownerMeta),
      );
    }
    if (data.containsKey('is_public')) {
      context.handle(
        _isPublicMeta,
        isPublic.isAcceptableOrUnknown(data['is_public']!, _isPublicMeta),
      );
    }
    if (data.containsKey('is_generated')) {
      context.handle(
        _isGeneratedMeta,
        isGenerated.isAcceptableOrUnknown(
          data['is_generated']!,
          _isGeneratedMeta,
        ),
      );
    }
    if (data.containsKey('changed_at')) {
      context.handle(
        _changedAtMeta,
        changedAt.isAcceptableOrUnknown(data['changed_at']!, _changedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalPlaylist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalPlaylist(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      coverArt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_art'],
      ),
      songCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}song_count'],
      )!,
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      )!,
      serverReadOnly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}server_read_only'],
      )!,
      owner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner'],
      )!,
      isPublic: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_public'],
      )!,
      isGenerated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_generated'],
      )!,
      changedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}changed_at'],
      ),
    );
  }

  @override
  $LocalPlaylistsTable createAlias(String alias) {
    return $LocalPlaylistsTable(attachedDatabase, alias);
  }
}

class LocalPlaylist extends DataClass implements Insertable<LocalPlaylist> {
  final String id;
  final String name;
  final String? coverArt;
  final int songCount;
  final int duration;
  final bool serverReadOnly;
  final String owner;
  final bool isPublic;
  final bool isGenerated;
  final DateTime? changedAt;
  const LocalPlaylist({
    required this.id,
    required this.name,
    this.coverArt,
    required this.songCount,
    required this.duration,
    required this.serverReadOnly,
    required this.owner,
    required this.isPublic,
    required this.isGenerated,
    this.changedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || coverArt != null) {
      map['cover_art'] = Variable<String>(coverArt);
    }
    map['song_count'] = Variable<int>(songCount);
    map['duration'] = Variable<int>(duration);
    map['server_read_only'] = Variable<bool>(serverReadOnly);
    map['owner'] = Variable<String>(owner);
    map['is_public'] = Variable<bool>(isPublic);
    map['is_generated'] = Variable<bool>(isGenerated);
    if (!nullToAbsent || changedAt != null) {
      map['changed_at'] = Variable<DateTime>(changedAt);
    }
    return map;
  }

  LocalPlaylistsCompanion toCompanion(bool nullToAbsent) {
    return LocalPlaylistsCompanion(
      id: Value(id),
      name: Value(name),
      coverArt: coverArt == null && nullToAbsent
          ? const Value.absent()
          : Value(coverArt),
      songCount: Value(songCount),
      duration: Value(duration),
      serverReadOnly: Value(serverReadOnly),
      owner: Value(owner),
      isPublic: Value(isPublic),
      isGenerated: Value(isGenerated),
      changedAt: changedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(changedAt),
    );
  }

  factory LocalPlaylist.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalPlaylist(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      coverArt: serializer.fromJson<String?>(json['coverArt']),
      songCount: serializer.fromJson<int>(json['songCount']),
      duration: serializer.fromJson<int>(json['duration']),
      serverReadOnly: serializer.fromJson<bool>(json['serverReadOnly']),
      owner: serializer.fromJson<String>(json['owner']),
      isPublic: serializer.fromJson<bool>(json['isPublic']),
      isGenerated: serializer.fromJson<bool>(json['isGenerated']),
      changedAt: serializer.fromJson<DateTime?>(json['changedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'coverArt': serializer.toJson<String?>(coverArt),
      'songCount': serializer.toJson<int>(songCount),
      'duration': serializer.toJson<int>(duration),
      'serverReadOnly': serializer.toJson<bool>(serverReadOnly),
      'owner': serializer.toJson<String>(owner),
      'isPublic': serializer.toJson<bool>(isPublic),
      'isGenerated': serializer.toJson<bool>(isGenerated),
      'changedAt': serializer.toJson<DateTime?>(changedAt),
    };
  }

  LocalPlaylist copyWith({
    String? id,
    String? name,
    Value<String?> coverArt = const Value.absent(),
    int? songCount,
    int? duration,
    bool? serverReadOnly,
    String? owner,
    bool? isPublic,
    bool? isGenerated,
    Value<DateTime?> changedAt = const Value.absent(),
  }) => LocalPlaylist(
    id: id ?? this.id,
    name: name ?? this.name,
    coverArt: coverArt.present ? coverArt.value : this.coverArt,
    songCount: songCount ?? this.songCount,
    duration: duration ?? this.duration,
    serverReadOnly: serverReadOnly ?? this.serverReadOnly,
    owner: owner ?? this.owner,
    isPublic: isPublic ?? this.isPublic,
    isGenerated: isGenerated ?? this.isGenerated,
    changedAt: changedAt.present ? changedAt.value : this.changedAt,
  );
  LocalPlaylist copyWithCompanion(LocalPlaylistsCompanion data) {
    return LocalPlaylist(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      coverArt: data.coverArt.present ? data.coverArt.value : this.coverArt,
      songCount: data.songCount.present ? data.songCount.value : this.songCount,
      duration: data.duration.present ? data.duration.value : this.duration,
      serverReadOnly: data.serverReadOnly.present
          ? data.serverReadOnly.value
          : this.serverReadOnly,
      owner: data.owner.present ? data.owner.value : this.owner,
      isPublic: data.isPublic.present ? data.isPublic.value : this.isPublic,
      isGenerated: data.isGenerated.present
          ? data.isGenerated.value
          : this.isGenerated,
      changedAt: data.changedAt.present ? data.changedAt.value : this.changedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalPlaylist(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('coverArt: $coverArt, ')
          ..write('songCount: $songCount, ')
          ..write('duration: $duration, ')
          ..write('serverReadOnly: $serverReadOnly, ')
          ..write('owner: $owner, ')
          ..write('isPublic: $isPublic, ')
          ..write('isGenerated: $isGenerated, ')
          ..write('changedAt: $changedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    coverArt,
    songCount,
    duration,
    serverReadOnly,
    owner,
    isPublic,
    isGenerated,
    changedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalPlaylist &&
          other.id == this.id &&
          other.name == this.name &&
          other.coverArt == this.coverArt &&
          other.songCount == this.songCount &&
          other.duration == this.duration &&
          other.serverReadOnly == this.serverReadOnly &&
          other.owner == this.owner &&
          other.isPublic == this.isPublic &&
          other.isGenerated == this.isGenerated &&
          other.changedAt == this.changedAt);
}

class LocalPlaylistsCompanion extends UpdateCompanion<LocalPlaylist> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> coverArt;
  final Value<int> songCount;
  final Value<int> duration;
  final Value<bool> serverReadOnly;
  final Value<String> owner;
  final Value<bool> isPublic;
  final Value<bool> isGenerated;
  final Value<DateTime?> changedAt;
  final Value<int> rowid;
  const LocalPlaylistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.coverArt = const Value.absent(),
    this.songCount = const Value.absent(),
    this.duration = const Value.absent(),
    this.serverReadOnly = const Value.absent(),
    this.owner = const Value.absent(),
    this.isPublic = const Value.absent(),
    this.isGenerated = const Value.absent(),
    this.changedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalPlaylistsCompanion.insert({
    required String id,
    required String name,
    this.coverArt = const Value.absent(),
    this.songCount = const Value.absent(),
    this.duration = const Value.absent(),
    this.serverReadOnly = const Value.absent(),
    this.owner = const Value.absent(),
    this.isPublic = const Value.absent(),
    this.isGenerated = const Value.absent(),
    this.changedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<LocalPlaylist> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? coverArt,
    Expression<int>? songCount,
    Expression<int>? duration,
    Expression<bool>? serverReadOnly,
    Expression<String>? owner,
    Expression<bool>? isPublic,
    Expression<bool>? isGenerated,
    Expression<DateTime>? changedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (coverArt != null) 'cover_art': coverArt,
      if (songCount != null) 'song_count': songCount,
      if (duration != null) 'duration': duration,
      if (serverReadOnly != null) 'server_read_only': serverReadOnly,
      if (owner != null) 'owner': owner,
      if (isPublic != null) 'is_public': isPublic,
      if (isGenerated != null) 'is_generated': isGenerated,
      if (changedAt != null) 'changed_at': changedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalPlaylistsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? coverArt,
    Value<int>? songCount,
    Value<int>? duration,
    Value<bool>? serverReadOnly,
    Value<String>? owner,
    Value<bool>? isPublic,
    Value<bool>? isGenerated,
    Value<DateTime?>? changedAt,
    Value<int>? rowid,
  }) {
    return LocalPlaylistsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      coverArt: coverArt ?? this.coverArt,
      songCount: songCount ?? this.songCount,
      duration: duration ?? this.duration,
      serverReadOnly: serverReadOnly ?? this.serverReadOnly,
      owner: owner ?? this.owner,
      isPublic: isPublic ?? this.isPublic,
      isGenerated: isGenerated ?? this.isGenerated,
      changedAt: changedAt ?? this.changedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (coverArt.present) {
      map['cover_art'] = Variable<String>(coverArt.value);
    }
    if (songCount.present) {
      map['song_count'] = Variable<int>(songCount.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (serverReadOnly.present) {
      map['server_read_only'] = Variable<bool>(serverReadOnly.value);
    }
    if (owner.present) {
      map['owner'] = Variable<String>(owner.value);
    }
    if (isPublic.present) {
      map['is_public'] = Variable<bool>(isPublic.value);
    }
    if (isGenerated.present) {
      map['is_generated'] = Variable<bool>(isGenerated.value);
    }
    if (changedAt.present) {
      map['changed_at'] = Variable<DateTime>(changedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalPlaylistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('coverArt: $coverArt, ')
          ..write('songCount: $songCount, ')
          ..write('duration: $duration, ')
          ..write('serverReadOnly: $serverReadOnly, ')
          ..write('owner: $owner, ')
          ..write('isPublic: $isPublic, ')
          ..write('isGenerated: $isGenerated, ')
          ..write('changedAt: $changedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StagedPlaylistsTable extends StagedPlaylists
    with TableInfo<$StagedPlaylistsTable, StagedPlaylist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StagedPlaylistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverArtMeta = const VerificationMeta(
    'coverArt',
  );
  @override
  late final GeneratedColumn<String> coverArt = GeneratedColumn<String>(
    'cover_art',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _songCountMeta = const VerificationMeta(
    'songCount',
  );
  @override
  late final GeneratedColumn<int> songCount = GeneratedColumn<int>(
    'song_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverReadOnlyMeta = const VerificationMeta(
    'serverReadOnly',
  );
  @override
  late final GeneratedColumn<bool> serverReadOnly = GeneratedColumn<bool>(
    'server_read_only',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("server_read_only" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _ownerMeta = const VerificationMeta('owner');
  @override
  late final GeneratedColumn<String> owner = GeneratedColumn<String>(
    'owner',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isPublicMeta = const VerificationMeta(
    'isPublic',
  );
  @override
  late final GeneratedColumn<bool> isPublic = GeneratedColumn<bool>(
    'is_public',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_public" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isGeneratedMeta = const VerificationMeta(
    'isGenerated',
  );
  @override
  late final GeneratedColumn<bool> isGenerated = GeneratedColumn<bool>(
    'is_generated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_generated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _changedAtMeta = const VerificationMeta(
    'changedAt',
  );
  @override
  late final GeneratedColumn<DateTime> changedAt = GeneratedColumn<DateTime>(
    'changed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    coverArt,
    songCount,
    duration,
    serverReadOnly,
    owner,
    isPublic,
    isGenerated,
    changedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'staged_playlists';
  @override
  VerificationContext validateIntegrity(
    Insertable<StagedPlaylist> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('cover_art')) {
      context.handle(
        _coverArtMeta,
        coverArt.isAcceptableOrUnknown(data['cover_art']!, _coverArtMeta),
      );
    }
    if (data.containsKey('song_count')) {
      context.handle(
        _songCountMeta,
        songCount.isAcceptableOrUnknown(data['song_count']!, _songCountMeta),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    }
    if (data.containsKey('server_read_only')) {
      context.handle(
        _serverReadOnlyMeta,
        serverReadOnly.isAcceptableOrUnknown(
          data['server_read_only']!,
          _serverReadOnlyMeta,
        ),
      );
    }
    if (data.containsKey('owner')) {
      context.handle(
        _ownerMeta,
        owner.isAcceptableOrUnknown(data['owner']!, _ownerMeta),
      );
    }
    if (data.containsKey('is_public')) {
      context.handle(
        _isPublicMeta,
        isPublic.isAcceptableOrUnknown(data['is_public']!, _isPublicMeta),
      );
    }
    if (data.containsKey('is_generated')) {
      context.handle(
        _isGeneratedMeta,
        isGenerated.isAcceptableOrUnknown(
          data['is_generated']!,
          _isGeneratedMeta,
        ),
      );
    }
    if (data.containsKey('changed_at')) {
      context.handle(
        _changedAtMeta,
        changedAt.isAcceptableOrUnknown(data['changed_at']!, _changedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StagedPlaylist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StagedPlaylist(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      coverArt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_art'],
      ),
      songCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}song_count'],
      )!,
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      )!,
      serverReadOnly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}server_read_only'],
      )!,
      owner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner'],
      )!,
      isPublic: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_public'],
      )!,
      isGenerated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_generated'],
      )!,
      changedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}changed_at'],
      ),
    );
  }

  @override
  $StagedPlaylistsTable createAlias(String alias) {
    return $StagedPlaylistsTable(attachedDatabase, alias);
  }
}

class StagedPlaylist extends DataClass implements Insertable<StagedPlaylist> {
  final String id;
  final String name;
  final String? coverArt;
  final int songCount;
  final int duration;
  final bool serverReadOnly;
  final String owner;
  final bool isPublic;
  final bool isGenerated;
  final DateTime? changedAt;
  const StagedPlaylist({
    required this.id,
    required this.name,
    this.coverArt,
    required this.songCount,
    required this.duration,
    required this.serverReadOnly,
    required this.owner,
    required this.isPublic,
    required this.isGenerated,
    this.changedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || coverArt != null) {
      map['cover_art'] = Variable<String>(coverArt);
    }
    map['song_count'] = Variable<int>(songCount);
    map['duration'] = Variable<int>(duration);
    map['server_read_only'] = Variable<bool>(serverReadOnly);
    map['owner'] = Variable<String>(owner);
    map['is_public'] = Variable<bool>(isPublic);
    map['is_generated'] = Variable<bool>(isGenerated);
    if (!nullToAbsent || changedAt != null) {
      map['changed_at'] = Variable<DateTime>(changedAt);
    }
    return map;
  }

  StagedPlaylistsCompanion toCompanion(bool nullToAbsent) {
    return StagedPlaylistsCompanion(
      id: Value(id),
      name: Value(name),
      coverArt: coverArt == null && nullToAbsent
          ? const Value.absent()
          : Value(coverArt),
      songCount: Value(songCount),
      duration: Value(duration),
      serverReadOnly: Value(serverReadOnly),
      owner: Value(owner),
      isPublic: Value(isPublic),
      isGenerated: Value(isGenerated),
      changedAt: changedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(changedAt),
    );
  }

  factory StagedPlaylist.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StagedPlaylist(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      coverArt: serializer.fromJson<String?>(json['coverArt']),
      songCount: serializer.fromJson<int>(json['songCount']),
      duration: serializer.fromJson<int>(json['duration']),
      serverReadOnly: serializer.fromJson<bool>(json['serverReadOnly']),
      owner: serializer.fromJson<String>(json['owner']),
      isPublic: serializer.fromJson<bool>(json['isPublic']),
      isGenerated: serializer.fromJson<bool>(json['isGenerated']),
      changedAt: serializer.fromJson<DateTime?>(json['changedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'coverArt': serializer.toJson<String?>(coverArt),
      'songCount': serializer.toJson<int>(songCount),
      'duration': serializer.toJson<int>(duration),
      'serverReadOnly': serializer.toJson<bool>(serverReadOnly),
      'owner': serializer.toJson<String>(owner),
      'isPublic': serializer.toJson<bool>(isPublic),
      'isGenerated': serializer.toJson<bool>(isGenerated),
      'changedAt': serializer.toJson<DateTime?>(changedAt),
    };
  }

  StagedPlaylist copyWith({
    String? id,
    String? name,
    Value<String?> coverArt = const Value.absent(),
    int? songCount,
    int? duration,
    bool? serverReadOnly,
    String? owner,
    bool? isPublic,
    bool? isGenerated,
    Value<DateTime?> changedAt = const Value.absent(),
  }) => StagedPlaylist(
    id: id ?? this.id,
    name: name ?? this.name,
    coverArt: coverArt.present ? coverArt.value : this.coverArt,
    songCount: songCount ?? this.songCount,
    duration: duration ?? this.duration,
    serverReadOnly: serverReadOnly ?? this.serverReadOnly,
    owner: owner ?? this.owner,
    isPublic: isPublic ?? this.isPublic,
    isGenerated: isGenerated ?? this.isGenerated,
    changedAt: changedAt.present ? changedAt.value : this.changedAt,
  );
  StagedPlaylist copyWithCompanion(StagedPlaylistsCompanion data) {
    return StagedPlaylist(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      coverArt: data.coverArt.present ? data.coverArt.value : this.coverArt,
      songCount: data.songCount.present ? data.songCount.value : this.songCount,
      duration: data.duration.present ? data.duration.value : this.duration,
      serverReadOnly: data.serverReadOnly.present
          ? data.serverReadOnly.value
          : this.serverReadOnly,
      owner: data.owner.present ? data.owner.value : this.owner,
      isPublic: data.isPublic.present ? data.isPublic.value : this.isPublic,
      isGenerated: data.isGenerated.present
          ? data.isGenerated.value
          : this.isGenerated,
      changedAt: data.changedAt.present ? data.changedAt.value : this.changedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StagedPlaylist(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('coverArt: $coverArt, ')
          ..write('songCount: $songCount, ')
          ..write('duration: $duration, ')
          ..write('serverReadOnly: $serverReadOnly, ')
          ..write('owner: $owner, ')
          ..write('isPublic: $isPublic, ')
          ..write('isGenerated: $isGenerated, ')
          ..write('changedAt: $changedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    coverArt,
    songCount,
    duration,
    serverReadOnly,
    owner,
    isPublic,
    isGenerated,
    changedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StagedPlaylist &&
          other.id == this.id &&
          other.name == this.name &&
          other.coverArt == this.coverArt &&
          other.songCount == this.songCount &&
          other.duration == this.duration &&
          other.serverReadOnly == this.serverReadOnly &&
          other.owner == this.owner &&
          other.isPublic == this.isPublic &&
          other.isGenerated == this.isGenerated &&
          other.changedAt == this.changedAt);
}

class StagedPlaylistsCompanion extends UpdateCompanion<StagedPlaylist> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> coverArt;
  final Value<int> songCount;
  final Value<int> duration;
  final Value<bool> serverReadOnly;
  final Value<String> owner;
  final Value<bool> isPublic;
  final Value<bool> isGenerated;
  final Value<DateTime?> changedAt;
  final Value<int> rowid;
  const StagedPlaylistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.coverArt = const Value.absent(),
    this.songCount = const Value.absent(),
    this.duration = const Value.absent(),
    this.serverReadOnly = const Value.absent(),
    this.owner = const Value.absent(),
    this.isPublic = const Value.absent(),
    this.isGenerated = const Value.absent(),
    this.changedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StagedPlaylistsCompanion.insert({
    required String id,
    required String name,
    this.coverArt = const Value.absent(),
    this.songCount = const Value.absent(),
    this.duration = const Value.absent(),
    this.serverReadOnly = const Value.absent(),
    this.owner = const Value.absent(),
    this.isPublic = const Value.absent(),
    this.isGenerated = const Value.absent(),
    this.changedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<StagedPlaylist> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? coverArt,
    Expression<int>? songCount,
    Expression<int>? duration,
    Expression<bool>? serverReadOnly,
    Expression<String>? owner,
    Expression<bool>? isPublic,
    Expression<bool>? isGenerated,
    Expression<DateTime>? changedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (coverArt != null) 'cover_art': coverArt,
      if (songCount != null) 'song_count': songCount,
      if (duration != null) 'duration': duration,
      if (serverReadOnly != null) 'server_read_only': serverReadOnly,
      if (owner != null) 'owner': owner,
      if (isPublic != null) 'is_public': isPublic,
      if (isGenerated != null) 'is_generated': isGenerated,
      if (changedAt != null) 'changed_at': changedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StagedPlaylistsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? coverArt,
    Value<int>? songCount,
    Value<int>? duration,
    Value<bool>? serverReadOnly,
    Value<String>? owner,
    Value<bool>? isPublic,
    Value<bool>? isGenerated,
    Value<DateTime?>? changedAt,
    Value<int>? rowid,
  }) {
    return StagedPlaylistsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      coverArt: coverArt ?? this.coverArt,
      songCount: songCount ?? this.songCount,
      duration: duration ?? this.duration,
      serverReadOnly: serverReadOnly ?? this.serverReadOnly,
      owner: owner ?? this.owner,
      isPublic: isPublic ?? this.isPublic,
      isGenerated: isGenerated ?? this.isGenerated,
      changedAt: changedAt ?? this.changedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (coverArt.present) {
      map['cover_art'] = Variable<String>(coverArt.value);
    }
    if (songCount.present) {
      map['song_count'] = Variable<int>(songCount.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (serverReadOnly.present) {
      map['server_read_only'] = Variable<bool>(serverReadOnly.value);
    }
    if (owner.present) {
      map['owner'] = Variable<String>(owner.value);
    }
    if (isPublic.present) {
      map['is_public'] = Variable<bool>(isPublic.value);
    }
    if (isGenerated.present) {
      map['is_generated'] = Variable<bool>(isGenerated.value);
    }
    if (changedAt.present) {
      map['changed_at'] = Variable<DateTime>(changedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StagedPlaylistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('coverArt: $coverArt, ')
          ..write('songCount: $songCount, ')
          ..write('duration: $duration, ')
          ..write('serverReadOnly: $serverReadOnly, ')
          ..write('owner: $owner, ')
          ..write('isPublic: $isPublic, ')
          ..write('isGenerated: $isGenerated, ')
          ..write('changedAt: $changedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalPlaylistEntriesTable extends LocalPlaylistEntries
    with TableInfo<$LocalPlaylistEntriesTable, LocalPlaylistEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalPlaylistEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [playlistId, songId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_playlist_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalPlaylistEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playlistId, position};
  @override
  LocalPlaylistEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalPlaylistEntry(
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playlist_id'],
      )!,
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $LocalPlaylistEntriesTable createAlias(String alias) {
    return $LocalPlaylistEntriesTable(attachedDatabase, alias);
  }
}

class LocalPlaylistEntry extends DataClass
    implements Insertable<LocalPlaylistEntry> {
  final String playlistId;
  final String songId;
  final int position;
  const LocalPlaylistEntry({
    required this.playlistId,
    required this.songId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playlist_id'] = Variable<String>(playlistId);
    map['song_id'] = Variable<String>(songId);
    map['position'] = Variable<int>(position);
    return map;
  }

  LocalPlaylistEntriesCompanion toCompanion(bool nullToAbsent) {
    return LocalPlaylistEntriesCompanion(
      playlistId: Value(playlistId),
      songId: Value(songId),
      position: Value(position),
    );
  }

  factory LocalPlaylistEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalPlaylistEntry(
      playlistId: serializer.fromJson<String>(json['playlistId']),
      songId: serializer.fromJson<String>(json['songId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playlistId': serializer.toJson<String>(playlistId),
      'songId': serializer.toJson<String>(songId),
      'position': serializer.toJson<int>(position),
    };
  }

  LocalPlaylistEntry copyWith({
    String? playlistId,
    String? songId,
    int? position,
  }) => LocalPlaylistEntry(
    playlistId: playlistId ?? this.playlistId,
    songId: songId ?? this.songId,
    position: position ?? this.position,
  );
  LocalPlaylistEntry copyWithCompanion(LocalPlaylistEntriesCompanion data) {
    return LocalPlaylistEntry(
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      songId: data.songId.present ? data.songId.value : this.songId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalPlaylistEntry(')
          ..write('playlistId: $playlistId, ')
          ..write('songId: $songId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playlistId, songId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalPlaylistEntry &&
          other.playlistId == this.playlistId &&
          other.songId == this.songId &&
          other.position == this.position);
}

class LocalPlaylistEntriesCompanion
    extends UpdateCompanion<LocalPlaylistEntry> {
  final Value<String> playlistId;
  final Value<String> songId;
  final Value<int> position;
  final Value<int> rowid;
  const LocalPlaylistEntriesCompanion({
    this.playlistId = const Value.absent(),
    this.songId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalPlaylistEntriesCompanion.insert({
    required String playlistId,
    required String songId,
    required int position,
    this.rowid = const Value.absent(),
  }) : playlistId = Value(playlistId),
       songId = Value(songId),
       position = Value(position);
  static Insertable<LocalPlaylistEntry> custom({
    Expression<String>? playlistId,
    Expression<String>? songId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playlistId != null) 'playlist_id': playlistId,
      if (songId != null) 'song_id': songId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalPlaylistEntriesCompanion copyWith({
    Value<String>? playlistId,
    Value<String>? songId,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return LocalPlaylistEntriesCompanion(
      playlistId: playlistId ?? this.playlistId,
      songId: songId ?? this.songId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalPlaylistEntriesCompanion(')
          ..write('playlistId: $playlistId, ')
          ..write('songId: $songId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StagedPlaylistEntriesTable extends StagedPlaylistEntries
    with TableInfo<$StagedPlaylistEntriesTable, StagedPlaylistEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StagedPlaylistEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [playlistId, songId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'staged_playlist_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<StagedPlaylistEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playlistId, position};
  @override
  StagedPlaylistEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StagedPlaylistEntry(
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playlist_id'],
      )!,
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $StagedPlaylistEntriesTable createAlias(String alias) {
    return $StagedPlaylistEntriesTable(attachedDatabase, alias);
  }
}

class StagedPlaylistEntry extends DataClass
    implements Insertable<StagedPlaylistEntry> {
  final String playlistId;
  final String songId;
  final int position;
  const StagedPlaylistEntry({
    required this.playlistId,
    required this.songId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playlist_id'] = Variable<String>(playlistId);
    map['song_id'] = Variable<String>(songId);
    map['position'] = Variable<int>(position);
    return map;
  }

  StagedPlaylistEntriesCompanion toCompanion(bool nullToAbsent) {
    return StagedPlaylistEntriesCompanion(
      playlistId: Value(playlistId),
      songId: Value(songId),
      position: Value(position),
    );
  }

  factory StagedPlaylistEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StagedPlaylistEntry(
      playlistId: serializer.fromJson<String>(json['playlistId']),
      songId: serializer.fromJson<String>(json['songId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playlistId': serializer.toJson<String>(playlistId),
      'songId': serializer.toJson<String>(songId),
      'position': serializer.toJson<int>(position),
    };
  }

  StagedPlaylistEntry copyWith({
    String? playlistId,
    String? songId,
    int? position,
  }) => StagedPlaylistEntry(
    playlistId: playlistId ?? this.playlistId,
    songId: songId ?? this.songId,
    position: position ?? this.position,
  );
  StagedPlaylistEntry copyWithCompanion(StagedPlaylistEntriesCompanion data) {
    return StagedPlaylistEntry(
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      songId: data.songId.present ? data.songId.value : this.songId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StagedPlaylistEntry(')
          ..write('playlistId: $playlistId, ')
          ..write('songId: $songId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playlistId, songId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StagedPlaylistEntry &&
          other.playlistId == this.playlistId &&
          other.songId == this.songId &&
          other.position == this.position);
}

class StagedPlaylistEntriesCompanion
    extends UpdateCompanion<StagedPlaylistEntry> {
  final Value<String> playlistId;
  final Value<String> songId;
  final Value<int> position;
  final Value<int> rowid;
  const StagedPlaylistEntriesCompanion({
    this.playlistId = const Value.absent(),
    this.songId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StagedPlaylistEntriesCompanion.insert({
    required String playlistId,
    required String songId,
    required int position,
    this.rowid = const Value.absent(),
  }) : playlistId = Value(playlistId),
       songId = Value(songId),
       position = Value(position);
  static Insertable<StagedPlaylistEntry> custom({
    Expression<String>? playlistId,
    Expression<String>? songId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playlistId != null) 'playlist_id': playlistId,
      if (songId != null) 'song_id': songId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StagedPlaylistEntriesCompanion copyWith({
    Value<String>? playlistId,
    Value<String>? songId,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return StagedPlaylistEntriesCompanion(
      playlistId: playlistId ?? this.playlistId,
      songId: songId ?? this.songId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StagedPlaylistEntriesCompanion(')
          ..write('playlistId: $playlistId, ')
          ..write('songId: $songId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalFavoritesTable extends LocalFavorites
    with TableInfo<$LocalFavoritesTable, LocalFavorite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalFavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _starredAtMeta = const VerificationMeta(
    'starredAt',
  );
  @override
  late final GeneratedColumn<DateTime> starredAt = GeneratedColumn<DateTime>(
    'starred_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [entityType, entityId, starredAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_favorites';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalFavorite> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('starred_at')) {
      context.handle(
        _starredAtMeta,
        starredAt.isAcceptableOrUnknown(data['starred_at']!, _starredAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityType, entityId};
  @override
  LocalFavorite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalFavorite(
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      starredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}starred_at'],
      ),
    );
  }

  @override
  $LocalFavoritesTable createAlias(String alias) {
    return $LocalFavoritesTable(attachedDatabase, alias);
  }
}

class LocalFavorite extends DataClass implements Insertable<LocalFavorite> {
  final String entityType;
  final String entityId;
  final DateTime? starredAt;
  const LocalFavorite({
    required this.entityType,
    required this.entityId,
    this.starredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    if (!nullToAbsent || starredAt != null) {
      map['starred_at'] = Variable<DateTime>(starredAt);
    }
    return map;
  }

  LocalFavoritesCompanion toCompanion(bool nullToAbsent) {
    return LocalFavoritesCompanion(
      entityType: Value(entityType),
      entityId: Value(entityId),
      starredAt: starredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(starredAt),
    );
  }

  factory LocalFavorite.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalFavorite(
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      starredAt: serializer.fromJson<DateTime?>(json['starredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'starredAt': serializer.toJson<DateTime?>(starredAt),
    };
  }

  LocalFavorite copyWith({
    String? entityType,
    String? entityId,
    Value<DateTime?> starredAt = const Value.absent(),
  }) => LocalFavorite(
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    starredAt: starredAt.present ? starredAt.value : this.starredAt,
  );
  LocalFavorite copyWithCompanion(LocalFavoritesCompanion data) {
    return LocalFavorite(
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      starredAt: data.starredAt.present ? data.starredAt.value : this.starredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalFavorite(')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('starredAt: $starredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entityType, entityId, starredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalFavorite &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.starredAt == this.starredAt);
}

class LocalFavoritesCompanion extends UpdateCompanion<LocalFavorite> {
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<DateTime?> starredAt;
  final Value<int> rowid;
  const LocalFavoritesCompanion({
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.starredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalFavoritesCompanion.insert({
    required String entityType,
    required String entityId,
    this.starredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : entityType = Value(entityType),
       entityId = Value(entityId);
  static Insertable<LocalFavorite> custom({
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<DateTime>? starredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (starredAt != null) 'starred_at': starredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalFavoritesCompanion copyWith({
    Value<String>? entityType,
    Value<String>? entityId,
    Value<DateTime?>? starredAt,
    Value<int>? rowid,
  }) {
    return LocalFavoritesCompanion(
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      starredAt: starredAt ?? this.starredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (starredAt.present) {
      map['starred_at'] = Variable<DateTime>(starredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalFavoritesCompanion(')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('starredAt: $starredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalInternetRadioStationsTable extends LocalInternetRadioStations
    with
        TableInfo<$LocalInternetRadioStationsTable, LocalInternetRadioStation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalInternetRadioStationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _streamUrlMeta = const VerificationMeta(
    'streamUrl',
  );
  @override
  late final GeneratedColumn<String> streamUrl = GeneratedColumn<String>(
    'stream_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _homePageUrlMeta = const VerificationMeta(
    'homePageUrl',
  );
  @override
  late final GeneratedColumn<String> homePageUrl = GeneratedColumn<String>(
    'home_page_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    streamUrl,
    homePageUrl,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_internet_radio_stations';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalInternetRadioStation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('stream_url')) {
      context.handle(
        _streamUrlMeta,
        streamUrl.isAcceptableOrUnknown(data['stream_url']!, _streamUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_streamUrlMeta);
    }
    if (data.containsKey('home_page_url')) {
      context.handle(
        _homePageUrlMeta,
        homePageUrl.isAcceptableOrUnknown(
          data['home_page_url']!,
          _homePageUrlMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalInternetRadioStation map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalInternetRadioStation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      streamUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stream_url'],
      )!,
      homePageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}home_page_url'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalInternetRadioStationsTable createAlias(String alias) {
    return $LocalInternetRadioStationsTable(attachedDatabase, alias);
  }
}

class LocalInternetRadioStation extends DataClass
    implements Insertable<LocalInternetRadioStation> {
  final String id;
  final String name;
  final String streamUrl;
  final String? homePageUrl;
  final DateTime updatedAt;
  const LocalInternetRadioStation({
    required this.id,
    required this.name,
    required this.streamUrl,
    this.homePageUrl,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['stream_url'] = Variable<String>(streamUrl);
    if (!nullToAbsent || homePageUrl != null) {
      map['home_page_url'] = Variable<String>(homePageUrl);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalInternetRadioStationsCompanion toCompanion(bool nullToAbsent) {
    return LocalInternetRadioStationsCompanion(
      id: Value(id),
      name: Value(name),
      streamUrl: Value(streamUrl),
      homePageUrl: homePageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(homePageUrl),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalInternetRadioStation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalInternetRadioStation(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      streamUrl: serializer.fromJson<String>(json['streamUrl']),
      homePageUrl: serializer.fromJson<String?>(json['homePageUrl']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'streamUrl': serializer.toJson<String>(streamUrl),
      'homePageUrl': serializer.toJson<String?>(homePageUrl),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalInternetRadioStation copyWith({
    String? id,
    String? name,
    String? streamUrl,
    Value<String?> homePageUrl = const Value.absent(),
    DateTime? updatedAt,
  }) => LocalInternetRadioStation(
    id: id ?? this.id,
    name: name ?? this.name,
    streamUrl: streamUrl ?? this.streamUrl,
    homePageUrl: homePageUrl.present ? homePageUrl.value : this.homePageUrl,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalInternetRadioStation copyWithCompanion(
    LocalInternetRadioStationsCompanion data,
  ) {
    return LocalInternetRadioStation(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      streamUrl: data.streamUrl.present ? data.streamUrl.value : this.streamUrl,
      homePageUrl: data.homePageUrl.present
          ? data.homePageUrl.value
          : this.homePageUrl,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalInternetRadioStation(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('streamUrl: $streamUrl, ')
          ..write('homePageUrl: $homePageUrl, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, streamUrl, homePageUrl, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalInternetRadioStation &&
          other.id == this.id &&
          other.name == this.name &&
          other.streamUrl == this.streamUrl &&
          other.homePageUrl == this.homePageUrl &&
          other.updatedAt == this.updatedAt);
}

class LocalInternetRadioStationsCompanion
    extends UpdateCompanion<LocalInternetRadioStation> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> streamUrl;
  final Value<String?> homePageUrl;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalInternetRadioStationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.streamUrl = const Value.absent(),
    this.homePageUrl = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalInternetRadioStationsCompanion.insert({
    required String id,
    required String name,
    required String streamUrl,
    this.homePageUrl = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       streamUrl = Value(streamUrl),
       updatedAt = Value(updatedAt);
  static Insertable<LocalInternetRadioStation> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? streamUrl,
    Expression<String>? homePageUrl,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (streamUrl != null) 'stream_url': streamUrl,
      if (homePageUrl != null) 'home_page_url': homePageUrl,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalInternetRadioStationsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? streamUrl,
    Value<String?>? homePageUrl,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalInternetRadioStationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      streamUrl: streamUrl ?? this.streamUrl,
      homePageUrl: homePageUrl ?? this.homePageUrl,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (streamUrl.present) {
      map['stream_url'] = Variable<String>(streamUrl.value);
    }
    if (homePageUrl.present) {
      map['home_page_url'] = Variable<String>(homePageUrl.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalInternetRadioStationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('streamUrl: $streamUrl, ')
          ..write('homePageUrl: $homePageUrl, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStatesTable extends SyncStates
    with TableInfo<$SyncStatesTable, SyncState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cursorMeta = const VerificationMeta('cursor');
  @override
  late final GeneratedColumn<String> cursor = GeneratedColumn<String>(
    'cursor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSuccessfulAtMeta = const VerificationMeta(
    'lastSuccessfulAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSuccessfulAt =
      GeneratedColumn<DateTime>(
        'last_successful_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    scope,
    cursor,
    lastSuccessfulAt,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('cursor')) {
      context.handle(
        _cursorMeta,
        cursor.isAcceptableOrUnknown(data['cursor']!, _cursorMeta),
      );
    }
    if (data.containsKey('last_successful_at')) {
      context.handle(
        _lastSuccessfulAtMeta,
        lastSuccessfulAt.isAcceptableOrUnknown(
          data['last_successful_at']!,
          _lastSuccessfulAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {scope};
  @override
  SyncState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncState(
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      cursor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cursor'],
      ),
      lastSuccessfulAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_successful_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $SyncStatesTable createAlias(String alias) {
    return $SyncStatesTable(attachedDatabase, alias);
  }
}

class SyncState extends DataClass implements Insertable<SyncState> {
  final String scope;
  final String? cursor;
  final DateTime? lastSuccessfulAt;
  final String? lastError;
  const SyncState({
    required this.scope,
    this.cursor,
    this.lastSuccessfulAt,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['scope'] = Variable<String>(scope);
    if (!nullToAbsent || cursor != null) {
      map['cursor'] = Variable<String>(cursor);
    }
    if (!nullToAbsent || lastSuccessfulAt != null) {
      map['last_successful_at'] = Variable<DateTime>(lastSuccessfulAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncStatesCompanion toCompanion(bool nullToAbsent) {
    return SyncStatesCompanion(
      scope: Value(scope),
      cursor: cursor == null && nullToAbsent
          ? const Value.absent()
          : Value(cursor),
      lastSuccessfulAt: lastSuccessfulAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSuccessfulAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SyncState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncState(
      scope: serializer.fromJson<String>(json['scope']),
      cursor: serializer.fromJson<String?>(json['cursor']),
      lastSuccessfulAt: serializer.fromJson<DateTime?>(
        json['lastSuccessfulAt'],
      ),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'scope': serializer.toJson<String>(scope),
      'cursor': serializer.toJson<String?>(cursor),
      'lastSuccessfulAt': serializer.toJson<DateTime?>(lastSuccessfulAt),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SyncState copyWith({
    String? scope,
    Value<String?> cursor = const Value.absent(),
    Value<DateTime?> lastSuccessfulAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
  }) => SyncState(
    scope: scope ?? this.scope,
    cursor: cursor.present ? cursor.value : this.cursor,
    lastSuccessfulAt: lastSuccessfulAt.present
        ? lastSuccessfulAt.value
        : this.lastSuccessfulAt,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  SyncState copyWithCompanion(SyncStatesCompanion data) {
    return SyncState(
      scope: data.scope.present ? data.scope.value : this.scope,
      cursor: data.cursor.present ? data.cursor.value : this.cursor,
      lastSuccessfulAt: data.lastSuccessfulAt.present
          ? data.lastSuccessfulAt.value
          : this.lastSuccessfulAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncState(')
          ..write('scope: $scope, ')
          ..write('cursor: $cursor, ')
          ..write('lastSuccessfulAt: $lastSuccessfulAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(scope, cursor, lastSuccessfulAt, lastError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncState &&
          other.scope == this.scope &&
          other.cursor == this.cursor &&
          other.lastSuccessfulAt == this.lastSuccessfulAt &&
          other.lastError == this.lastError);
}

class SyncStatesCompanion extends UpdateCompanion<SyncState> {
  final Value<String> scope;
  final Value<String?> cursor;
  final Value<DateTime?> lastSuccessfulAt;
  final Value<String?> lastError;
  final Value<int> rowid;
  const SyncStatesCompanion({
    this.scope = const Value.absent(),
    this.cursor = const Value.absent(),
    this.lastSuccessfulAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStatesCompanion.insert({
    required String scope,
    this.cursor = const Value.absent(),
    this.lastSuccessfulAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : scope = Value(scope);
  static Insertable<SyncState> custom({
    Expression<String>? scope,
    Expression<String>? cursor,
    Expression<DateTime>? lastSuccessfulAt,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (scope != null) 'scope': scope,
      if (cursor != null) 'cursor': cursor,
      if (lastSuccessfulAt != null) 'last_successful_at': lastSuccessfulAt,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStatesCompanion copyWith({
    Value<String>? scope,
    Value<String?>? cursor,
    Value<DateTime?>? lastSuccessfulAt,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return SyncStatesCompanion(
      scope: scope ?? this.scope,
      cursor: cursor ?? this.cursor,
      lastSuccessfulAt: lastSuccessfulAt ?? this.lastSuccessfulAt,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (cursor.present) {
      map['cursor'] = Variable<String>(cursor.value);
    }
    if (lastSuccessfulAt.present) {
      map['last_successful_at'] = Variable<DateTime>(lastSuccessfulAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStatesCompanion(')
          ..write('scope: $scope, ')
          ..write('cursor: $cursor, ')
          ..write('lastSuccessfulAt: $lastSuccessfulAt, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingMutationsTable extends PendingMutations
    with TableInfo<$PendingMutationsTable, PendingMutation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingMutationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    entityId,
    payloadJson,
    createdAt,
    attemptCount,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_mutations';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingMutation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingMutation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingMutation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $PendingMutationsTable createAlias(String alias) {
    return $PendingMutationsTable(attachedDatabase, alias);
  }
}

class PendingMutation extends DataClass implements Insertable<PendingMutation> {
  final int id;
  final String kind;
  final String entityId;
  final String payloadJson;
  final DateTime createdAt;
  final int attemptCount;
  final String? lastError;
  const PendingMutation({
    required this.id,
    required this.kind,
    required this.entityId,
    required this.payloadJson,
    required this.createdAt,
    required this.attemptCount,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kind'] = Variable<String>(kind);
    map['entity_id'] = Variable<String>(entityId);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  PendingMutationsCompanion toCompanion(bool nullToAbsent) {
    return PendingMutationsCompanion(
      id: Value(id),
      kind: Value(kind),
      entityId: Value(entityId),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      attemptCount: Value(attemptCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory PendingMutation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingMutation(
      id: serializer.fromJson<int>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      entityId: serializer.fromJson<String>(json['entityId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(kind),
      'entityId': serializer.toJson<String>(entityId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  PendingMutation copyWith({
    int? id,
    String? kind,
    String? entityId,
    String? payloadJson,
    DateTime? createdAt,
    int? attemptCount,
    Value<String?> lastError = const Value.absent(),
  }) => PendingMutation(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    entityId: entityId ?? this.entityId,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    attemptCount: attemptCount ?? this.attemptCount,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  PendingMutation copyWithCompanion(PendingMutationsCompanion data) {
    return PendingMutation(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingMutation(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('entityId: $entityId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    entityId,
    payloadJson,
    createdAt,
    attemptCount,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingMutation &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.entityId == this.entityId &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.attemptCount == this.attemptCount &&
          other.lastError == this.lastError);
}

class PendingMutationsCompanion extends UpdateCompanion<PendingMutation> {
  final Value<int> id;
  final Value<String> kind;
  final Value<String> entityId;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<int> attemptCount;
  final Value<String?> lastError;
  const PendingMutationsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.entityId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  PendingMutationsCompanion.insert({
    this.id = const Value.absent(),
    required String kind,
    required String entityId,
    required String payloadJson,
    required DateTime createdAt,
    this.attemptCount = const Value.absent(),
    this.lastError = const Value.absent(),
  }) : kind = Value(kind),
       entityId = Value(entityId),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<PendingMutation> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<String>? entityId,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<int>? attemptCount,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (entityId != null) 'entity_id': entityId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (lastError != null) 'last_error': lastError,
    });
  }

  PendingMutationsCompanion copyWith({
    Value<int>? id,
    Value<String>? kind,
    Value<String>? entityId,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
    Value<int>? attemptCount,
    Value<String?>? lastError,
  }) {
    return PendingMutationsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      entityId: entityId ?? this.entityId,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      attemptCount: attemptCount ?? this.attemptCount,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingMutationsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('entityId: $entityId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

class $LocalPlayEventsTable extends LocalPlayEvents
    with TableInfo<$LocalPlayEventsTable, LocalPlayEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalPlayEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playbackIdMeta = const VerificationMeta(
    'playbackId',
  );
  @override
  late final GeneratedColumn<String> playbackId = GeneratedColumn<String>(
    'playback_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMillisecondsMeta =
      const VerificationMeta('durationMilliseconds');
  @override
  late final GeneratedColumn<int> durationMilliseconds = GeneratedColumn<int>(
    'duration_milliseconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _scrobbledAtMeta = const VerificationMeta(
    'scrobbledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scrobbledAt = GeneratedColumn<DateTime>(
    'scrobbled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _skippedMeta = const VerificationMeta(
    'skipped',
  );
  @override
  late final GeneratedColumn<bool> skipped = GeneratedColumn<bool>(
    'skipped',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("skipped" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    playbackId,
    songId,
    startedAt,
    durationMilliseconds,
    scrobbledAt,
    completedAt,
    endedAt,
    skipped,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_play_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalPlayEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('playback_id')) {
      context.handle(
        _playbackIdMeta,
        playbackId.isAcceptableOrUnknown(data['playback_id']!, _playbackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playbackIdMeta);
    }
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('duration_milliseconds')) {
      context.handle(
        _durationMillisecondsMeta,
        durationMilliseconds.isAcceptableOrUnknown(
          data['duration_milliseconds']!,
          _durationMillisecondsMeta,
        ),
      );
    }
    if (data.containsKey('scrobbled_at')) {
      context.handle(
        _scrobbledAtMeta,
        scrobbledAt.isAcceptableOrUnknown(
          data['scrobbled_at']!,
          _scrobbledAtMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('skipped')) {
      context.handle(
        _skippedMeta,
        skipped.isAcceptableOrUnknown(data['skipped']!, _skippedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playbackId};
  @override
  LocalPlayEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalPlayEvent(
      playbackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playback_id'],
      )!,
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      durationMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_milliseconds'],
      )!,
      scrobbledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scrobbled_at'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      skipped: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}skipped'],
      )!,
    );
  }

  @override
  $LocalPlayEventsTable createAlias(String alias) {
    return $LocalPlayEventsTable(attachedDatabase, alias);
  }
}

class LocalPlayEvent extends DataClass implements Insertable<LocalPlayEvent> {
  final String playbackId;
  final String songId;
  final DateTime startedAt;
  final int durationMilliseconds;
  final DateTime? scrobbledAt;
  final DateTime? completedAt;
  final DateTime? endedAt;
  final bool skipped;
  const LocalPlayEvent({
    required this.playbackId,
    required this.songId,
    required this.startedAt,
    required this.durationMilliseconds,
    this.scrobbledAt,
    this.completedAt,
    this.endedAt,
    required this.skipped,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playback_id'] = Variable<String>(playbackId);
    map['song_id'] = Variable<String>(songId);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['duration_milliseconds'] = Variable<int>(durationMilliseconds);
    if (!nullToAbsent || scrobbledAt != null) {
      map['scrobbled_at'] = Variable<DateTime>(scrobbledAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['skipped'] = Variable<bool>(skipped);
    return map;
  }

  LocalPlayEventsCompanion toCompanion(bool nullToAbsent) {
    return LocalPlayEventsCompanion(
      playbackId: Value(playbackId),
      songId: Value(songId),
      startedAt: Value(startedAt),
      durationMilliseconds: Value(durationMilliseconds),
      scrobbledAt: scrobbledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(scrobbledAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      skipped: Value(skipped),
    );
  }

  factory LocalPlayEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalPlayEvent(
      playbackId: serializer.fromJson<String>(json['playbackId']),
      songId: serializer.fromJson<String>(json['songId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      durationMilliseconds: serializer.fromJson<int>(
        json['durationMilliseconds'],
      ),
      scrobbledAt: serializer.fromJson<DateTime?>(json['scrobbledAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      skipped: serializer.fromJson<bool>(json['skipped']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playbackId': serializer.toJson<String>(playbackId),
      'songId': serializer.toJson<String>(songId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'durationMilliseconds': serializer.toJson<int>(durationMilliseconds),
      'scrobbledAt': serializer.toJson<DateTime?>(scrobbledAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'skipped': serializer.toJson<bool>(skipped),
    };
  }

  LocalPlayEvent copyWith({
    String? playbackId,
    String? songId,
    DateTime? startedAt,
    int? durationMilliseconds,
    Value<DateTime?> scrobbledAt = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
    Value<DateTime?> endedAt = const Value.absent(),
    bool? skipped,
  }) => LocalPlayEvent(
    playbackId: playbackId ?? this.playbackId,
    songId: songId ?? this.songId,
    startedAt: startedAt ?? this.startedAt,
    durationMilliseconds: durationMilliseconds ?? this.durationMilliseconds,
    scrobbledAt: scrobbledAt.present ? scrobbledAt.value : this.scrobbledAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    skipped: skipped ?? this.skipped,
  );
  LocalPlayEvent copyWithCompanion(LocalPlayEventsCompanion data) {
    return LocalPlayEvent(
      playbackId: data.playbackId.present
          ? data.playbackId.value
          : this.playbackId,
      songId: data.songId.present ? data.songId.value : this.songId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      durationMilliseconds: data.durationMilliseconds.present
          ? data.durationMilliseconds.value
          : this.durationMilliseconds,
      scrobbledAt: data.scrobbledAt.present
          ? data.scrobbledAt.value
          : this.scrobbledAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      skipped: data.skipped.present ? data.skipped.value : this.skipped,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalPlayEvent(')
          ..write('playbackId: $playbackId, ')
          ..write('songId: $songId, ')
          ..write('startedAt: $startedAt, ')
          ..write('durationMilliseconds: $durationMilliseconds, ')
          ..write('scrobbledAt: $scrobbledAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('skipped: $skipped')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    playbackId,
    songId,
    startedAt,
    durationMilliseconds,
    scrobbledAt,
    completedAt,
    endedAt,
    skipped,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalPlayEvent &&
          other.playbackId == this.playbackId &&
          other.songId == this.songId &&
          other.startedAt == this.startedAt &&
          other.durationMilliseconds == this.durationMilliseconds &&
          other.scrobbledAt == this.scrobbledAt &&
          other.completedAt == this.completedAt &&
          other.endedAt == this.endedAt &&
          other.skipped == this.skipped);
}

class LocalPlayEventsCompanion extends UpdateCompanion<LocalPlayEvent> {
  final Value<String> playbackId;
  final Value<String> songId;
  final Value<DateTime> startedAt;
  final Value<int> durationMilliseconds;
  final Value<DateTime?> scrobbledAt;
  final Value<DateTime?> completedAt;
  final Value<DateTime?> endedAt;
  final Value<bool> skipped;
  final Value<int> rowid;
  const LocalPlayEventsCompanion({
    this.playbackId = const Value.absent(),
    this.songId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.durationMilliseconds = const Value.absent(),
    this.scrobbledAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.skipped = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalPlayEventsCompanion.insert({
    required String playbackId,
    required String songId,
    required DateTime startedAt,
    this.durationMilliseconds = const Value.absent(),
    this.scrobbledAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.skipped = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : playbackId = Value(playbackId),
       songId = Value(songId),
       startedAt = Value(startedAt);
  static Insertable<LocalPlayEvent> custom({
    Expression<String>? playbackId,
    Expression<String>? songId,
    Expression<DateTime>? startedAt,
    Expression<int>? durationMilliseconds,
    Expression<DateTime>? scrobbledAt,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? endedAt,
    Expression<bool>? skipped,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playbackId != null) 'playback_id': playbackId,
      if (songId != null) 'song_id': songId,
      if (startedAt != null) 'started_at': startedAt,
      if (durationMilliseconds != null)
        'duration_milliseconds': durationMilliseconds,
      if (scrobbledAt != null) 'scrobbled_at': scrobbledAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (skipped != null) 'skipped': skipped,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalPlayEventsCompanion copyWith({
    Value<String>? playbackId,
    Value<String>? songId,
    Value<DateTime>? startedAt,
    Value<int>? durationMilliseconds,
    Value<DateTime?>? scrobbledAt,
    Value<DateTime?>? completedAt,
    Value<DateTime?>? endedAt,
    Value<bool>? skipped,
    Value<int>? rowid,
  }) {
    return LocalPlayEventsCompanion(
      playbackId: playbackId ?? this.playbackId,
      songId: songId ?? this.songId,
      startedAt: startedAt ?? this.startedAt,
      durationMilliseconds: durationMilliseconds ?? this.durationMilliseconds,
      scrobbledAt: scrobbledAt ?? this.scrobbledAt,
      completedAt: completedAt ?? this.completedAt,
      endedAt: endedAt ?? this.endedAt,
      skipped: skipped ?? this.skipped,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playbackId.present) {
      map['playback_id'] = Variable<String>(playbackId.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (durationMilliseconds.present) {
      map['duration_milliseconds'] = Variable<int>(durationMilliseconds.value);
    }
    if (scrobbledAt.present) {
      map['scrobbled_at'] = Variable<DateTime>(scrobbledAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (skipped.present) {
      map['skipped'] = Variable<bool>(skipped.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalPlayEventsCompanion(')
          ..write('playbackId: $playbackId, ')
          ..write('songId: $songId, ')
          ..write('startedAt: $startedAt, ')
          ..write('durationMilliseconds: $durationMilliseconds, ')
          ..write('scrobbledAt: $scrobbledAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('skipped: $skipped, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalSongActivitiesTable extends LocalSongActivities
    with TableInfo<$LocalSongActivitiesTable, LocalSongActivity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSongActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPlayCountMeta = const VerificationMeta(
    'localPlayCount',
  );
  @override
  late final GeneratedColumn<int> localPlayCount = GeneratedColumn<int>(
    'local_play_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _unacknowledgedPlayCountMeta =
      const VerificationMeta('unacknowledgedPlayCount');
  @override
  late final GeneratedColumn<int> unacknowledgedPlayCount =
      GeneratedColumn<int>(
        'unacknowledged_play_count',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _serverPlayCountSeenMeta =
      const VerificationMeta('serverPlayCountSeen');
  @override
  late final GeneratedColumn<int> serverPlayCountSeen = GeneratedColumn<int>(
    'server_play_count_seen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _skipCountMeta = const VerificationMeta(
    'skipCount',
  );
  @override
  late final GeneratedColumn<int> skipCount = GeneratedColumn<int>(
    'skip_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastStartedAtMeta = const VerificationMeta(
    'lastStartedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastStartedAt =
      GeneratedColumn<DateTime>(
        'last_started_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastPlayedAtMeta = const VerificationMeta(
    'lastPlayedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPlayedAt = GeneratedColumn<DateTime>(
    'last_played_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastCompletedAtMeta = const VerificationMeta(
    'lastCompletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastCompletedAt =
      GeneratedColumn<DateTime>(
        'last_completed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    songId,
    localPlayCount,
    unacknowledgedPlayCount,
    serverPlayCountSeen,
    skipCount,
    lastStartedAt,
    lastPlayedAt,
    lastCompletedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_song_activities';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSongActivity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('local_play_count')) {
      context.handle(
        _localPlayCountMeta,
        localPlayCount.isAcceptableOrUnknown(
          data['local_play_count']!,
          _localPlayCountMeta,
        ),
      );
    }
    if (data.containsKey('unacknowledged_play_count')) {
      context.handle(
        _unacknowledgedPlayCountMeta,
        unacknowledgedPlayCount.isAcceptableOrUnknown(
          data['unacknowledged_play_count']!,
          _unacknowledgedPlayCountMeta,
        ),
      );
    }
    if (data.containsKey('server_play_count_seen')) {
      context.handle(
        _serverPlayCountSeenMeta,
        serverPlayCountSeen.isAcceptableOrUnknown(
          data['server_play_count_seen']!,
          _serverPlayCountSeenMeta,
        ),
      );
    }
    if (data.containsKey('skip_count')) {
      context.handle(
        _skipCountMeta,
        skipCount.isAcceptableOrUnknown(data['skip_count']!, _skipCountMeta),
      );
    }
    if (data.containsKey('last_started_at')) {
      context.handle(
        _lastStartedAtMeta,
        lastStartedAt.isAcceptableOrUnknown(
          data['last_started_at']!,
          _lastStartedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_played_at')) {
      context.handle(
        _lastPlayedAtMeta,
        lastPlayedAt.isAcceptableOrUnknown(
          data['last_played_at']!,
          _lastPlayedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_completed_at')) {
      context.handle(
        _lastCompletedAtMeta,
        lastCompletedAt.isAcceptableOrUnknown(
          data['last_completed_at']!,
          _lastCompletedAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {songId};
  @override
  LocalSongActivity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSongActivity(
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      localPlayCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_play_count'],
      )!,
      unacknowledgedPlayCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unacknowledged_play_count'],
      )!,
      serverPlayCountSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_play_count_seen'],
      )!,
      skipCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}skip_count'],
      )!,
      lastStartedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_started_at'],
      ),
      lastPlayedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_played_at'],
      ),
      lastCompletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_completed_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalSongActivitiesTable createAlias(String alias) {
    return $LocalSongActivitiesTable(attachedDatabase, alias);
  }
}

class LocalSongActivity extends DataClass
    implements Insertable<LocalSongActivity> {
  final String songId;
  final int localPlayCount;
  final int unacknowledgedPlayCount;
  final int serverPlayCountSeen;
  final int skipCount;
  final DateTime? lastStartedAt;
  final DateTime? lastPlayedAt;
  final DateTime? lastCompletedAt;
  final DateTime updatedAt;
  const LocalSongActivity({
    required this.songId,
    required this.localPlayCount,
    required this.unacknowledgedPlayCount,
    required this.serverPlayCountSeen,
    required this.skipCount,
    this.lastStartedAt,
    this.lastPlayedAt,
    this.lastCompletedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['song_id'] = Variable<String>(songId);
    map['local_play_count'] = Variable<int>(localPlayCount);
    map['unacknowledged_play_count'] = Variable<int>(unacknowledgedPlayCount);
    map['server_play_count_seen'] = Variable<int>(serverPlayCountSeen);
    map['skip_count'] = Variable<int>(skipCount);
    if (!nullToAbsent || lastStartedAt != null) {
      map['last_started_at'] = Variable<DateTime>(lastStartedAt);
    }
    if (!nullToAbsent || lastPlayedAt != null) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt);
    }
    if (!nullToAbsent || lastCompletedAt != null) {
      map['last_completed_at'] = Variable<DateTime>(lastCompletedAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalSongActivitiesCompanion toCompanion(bool nullToAbsent) {
    return LocalSongActivitiesCompanion(
      songId: Value(songId),
      localPlayCount: Value(localPlayCount),
      unacknowledgedPlayCount: Value(unacknowledgedPlayCount),
      serverPlayCountSeen: Value(serverPlayCountSeen),
      skipCount: Value(skipCount),
      lastStartedAt: lastStartedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastStartedAt),
      lastPlayedAt: lastPlayedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayedAt),
      lastCompletedAt: lastCompletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCompletedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalSongActivity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSongActivity(
      songId: serializer.fromJson<String>(json['songId']),
      localPlayCount: serializer.fromJson<int>(json['localPlayCount']),
      unacknowledgedPlayCount: serializer.fromJson<int>(
        json['unacknowledgedPlayCount'],
      ),
      serverPlayCountSeen: serializer.fromJson<int>(
        json['serverPlayCountSeen'],
      ),
      skipCount: serializer.fromJson<int>(json['skipCount']),
      lastStartedAt: serializer.fromJson<DateTime?>(json['lastStartedAt']),
      lastPlayedAt: serializer.fromJson<DateTime?>(json['lastPlayedAt']),
      lastCompletedAt: serializer.fromJson<DateTime?>(json['lastCompletedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'songId': serializer.toJson<String>(songId),
      'localPlayCount': serializer.toJson<int>(localPlayCount),
      'unacknowledgedPlayCount': serializer.toJson<int>(
        unacknowledgedPlayCount,
      ),
      'serverPlayCountSeen': serializer.toJson<int>(serverPlayCountSeen),
      'skipCount': serializer.toJson<int>(skipCount),
      'lastStartedAt': serializer.toJson<DateTime?>(lastStartedAt),
      'lastPlayedAt': serializer.toJson<DateTime?>(lastPlayedAt),
      'lastCompletedAt': serializer.toJson<DateTime?>(lastCompletedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalSongActivity copyWith({
    String? songId,
    int? localPlayCount,
    int? unacknowledgedPlayCount,
    int? serverPlayCountSeen,
    int? skipCount,
    Value<DateTime?> lastStartedAt = const Value.absent(),
    Value<DateTime?> lastPlayedAt = const Value.absent(),
    Value<DateTime?> lastCompletedAt = const Value.absent(),
    DateTime? updatedAt,
  }) => LocalSongActivity(
    songId: songId ?? this.songId,
    localPlayCount: localPlayCount ?? this.localPlayCount,
    unacknowledgedPlayCount:
        unacknowledgedPlayCount ?? this.unacknowledgedPlayCount,
    serverPlayCountSeen: serverPlayCountSeen ?? this.serverPlayCountSeen,
    skipCount: skipCount ?? this.skipCount,
    lastStartedAt: lastStartedAt.present
        ? lastStartedAt.value
        : this.lastStartedAt,
    lastPlayedAt: lastPlayedAt.present ? lastPlayedAt.value : this.lastPlayedAt,
    lastCompletedAt: lastCompletedAt.present
        ? lastCompletedAt.value
        : this.lastCompletedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalSongActivity copyWithCompanion(LocalSongActivitiesCompanion data) {
    return LocalSongActivity(
      songId: data.songId.present ? data.songId.value : this.songId,
      localPlayCount: data.localPlayCount.present
          ? data.localPlayCount.value
          : this.localPlayCount,
      unacknowledgedPlayCount: data.unacknowledgedPlayCount.present
          ? data.unacknowledgedPlayCount.value
          : this.unacknowledgedPlayCount,
      serverPlayCountSeen: data.serverPlayCountSeen.present
          ? data.serverPlayCountSeen.value
          : this.serverPlayCountSeen,
      skipCount: data.skipCount.present ? data.skipCount.value : this.skipCount,
      lastStartedAt: data.lastStartedAt.present
          ? data.lastStartedAt.value
          : this.lastStartedAt,
      lastPlayedAt: data.lastPlayedAt.present
          ? data.lastPlayedAt.value
          : this.lastPlayedAt,
      lastCompletedAt: data.lastCompletedAt.present
          ? data.lastCompletedAt.value
          : this.lastCompletedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSongActivity(')
          ..write('songId: $songId, ')
          ..write('localPlayCount: $localPlayCount, ')
          ..write('unacknowledgedPlayCount: $unacknowledgedPlayCount, ')
          ..write('serverPlayCountSeen: $serverPlayCountSeen, ')
          ..write('skipCount: $skipCount, ')
          ..write('lastStartedAt: $lastStartedAt, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('lastCompletedAt: $lastCompletedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    songId,
    localPlayCount,
    unacknowledgedPlayCount,
    serverPlayCountSeen,
    skipCount,
    lastStartedAt,
    lastPlayedAt,
    lastCompletedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSongActivity &&
          other.songId == this.songId &&
          other.localPlayCount == this.localPlayCount &&
          other.unacknowledgedPlayCount == this.unacknowledgedPlayCount &&
          other.serverPlayCountSeen == this.serverPlayCountSeen &&
          other.skipCount == this.skipCount &&
          other.lastStartedAt == this.lastStartedAt &&
          other.lastPlayedAt == this.lastPlayedAt &&
          other.lastCompletedAt == this.lastCompletedAt &&
          other.updatedAt == this.updatedAt);
}

class LocalSongActivitiesCompanion extends UpdateCompanion<LocalSongActivity> {
  final Value<String> songId;
  final Value<int> localPlayCount;
  final Value<int> unacknowledgedPlayCount;
  final Value<int> serverPlayCountSeen;
  final Value<int> skipCount;
  final Value<DateTime?> lastStartedAt;
  final Value<DateTime?> lastPlayedAt;
  final Value<DateTime?> lastCompletedAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalSongActivitiesCompanion({
    this.songId = const Value.absent(),
    this.localPlayCount = const Value.absent(),
    this.unacknowledgedPlayCount = const Value.absent(),
    this.serverPlayCountSeen = const Value.absent(),
    this.skipCount = const Value.absent(),
    this.lastStartedAt = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.lastCompletedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSongActivitiesCompanion.insert({
    required String songId,
    this.localPlayCount = const Value.absent(),
    this.unacknowledgedPlayCount = const Value.absent(),
    this.serverPlayCountSeen = const Value.absent(),
    this.skipCount = const Value.absent(),
    this.lastStartedAt = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.lastCompletedAt = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : songId = Value(songId),
       updatedAt = Value(updatedAt);
  static Insertable<LocalSongActivity> custom({
    Expression<String>? songId,
    Expression<int>? localPlayCount,
    Expression<int>? unacknowledgedPlayCount,
    Expression<int>? serverPlayCountSeen,
    Expression<int>? skipCount,
    Expression<DateTime>? lastStartedAt,
    Expression<DateTime>? lastPlayedAt,
    Expression<DateTime>? lastCompletedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (songId != null) 'song_id': songId,
      if (localPlayCount != null) 'local_play_count': localPlayCount,
      if (unacknowledgedPlayCount != null)
        'unacknowledged_play_count': unacknowledgedPlayCount,
      if (serverPlayCountSeen != null)
        'server_play_count_seen': serverPlayCountSeen,
      if (skipCount != null) 'skip_count': skipCount,
      if (lastStartedAt != null) 'last_started_at': lastStartedAt,
      if (lastPlayedAt != null) 'last_played_at': lastPlayedAt,
      if (lastCompletedAt != null) 'last_completed_at': lastCompletedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSongActivitiesCompanion copyWith({
    Value<String>? songId,
    Value<int>? localPlayCount,
    Value<int>? unacknowledgedPlayCount,
    Value<int>? serverPlayCountSeen,
    Value<int>? skipCount,
    Value<DateTime?>? lastStartedAt,
    Value<DateTime?>? lastPlayedAt,
    Value<DateTime?>? lastCompletedAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalSongActivitiesCompanion(
      songId: songId ?? this.songId,
      localPlayCount: localPlayCount ?? this.localPlayCount,
      unacknowledgedPlayCount:
          unacknowledgedPlayCount ?? this.unacknowledgedPlayCount,
      serverPlayCountSeen: serverPlayCountSeen ?? this.serverPlayCountSeen,
      skipCount: skipCount ?? this.skipCount,
      lastStartedAt: lastStartedAt ?? this.lastStartedAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (localPlayCount.present) {
      map['local_play_count'] = Variable<int>(localPlayCount.value);
    }
    if (unacknowledgedPlayCount.present) {
      map['unacknowledged_play_count'] = Variable<int>(
        unacknowledgedPlayCount.value,
      );
    }
    if (serverPlayCountSeen.present) {
      map['server_play_count_seen'] = Variable<int>(serverPlayCountSeen.value);
    }
    if (skipCount.present) {
      map['skip_count'] = Variable<int>(skipCount.value);
    }
    if (lastStartedAt.present) {
      map['last_started_at'] = Variable<DateTime>(lastStartedAt.value);
    }
    if (lastPlayedAt.present) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt.value);
    }
    if (lastCompletedAt.present) {
      map['last_completed_at'] = Variable<DateTime>(lastCompletedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSongActivitiesCompanion(')
          ..write('songId: $songId, ')
          ..write('localPlayCount: $localPlayCount, ')
          ..write('unacknowledgedPlayCount: $unacknowledgedPlayCount, ')
          ..write('serverPlayCountSeen: $serverPlayCountSeen, ')
          ..write('skipCount: $skipCount, ')
          ..write('lastStartedAt: $lastStartedAt, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('lastCompletedAt: $lastCompletedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalQueueSessionsTable extends LocalQueueSessions
    with TableInfo<$LocalQueueSessionsTable, LocalQueueSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalQueueSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentEntryIdMeta = const VerificationMeta(
    'currentEntryId',
  );
  @override
  late final GeneratedColumn<String> currentEntryId = GeneratedColumn<String>(
    'current_entry_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _autoPlayEnabledMeta = const VerificationMeta(
    'autoPlayEnabled',
  );
  @override
  late final GeneratedColumn<bool> autoPlayEnabled = GeneratedColumn<bool>(
    'auto_play_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_play_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _positionMillisecondsMeta =
      const VerificationMeta('positionMilliseconds');
  @override
  late final GeneratedColumn<int> positionMilliseconds = GeneratedColumn<int>(
    'position_milliseconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    currentEntryId,
    autoPlayEnabled,
    positionMilliseconds,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_queue_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalQueueSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('current_entry_id')) {
      context.handle(
        _currentEntryIdMeta,
        currentEntryId.isAcceptableOrUnknown(
          data['current_entry_id']!,
          _currentEntryIdMeta,
        ),
      );
    }
    if (data.containsKey('auto_play_enabled')) {
      context.handle(
        _autoPlayEnabledMeta,
        autoPlayEnabled.isAcceptableOrUnknown(
          data['auto_play_enabled']!,
          _autoPlayEnabledMeta,
        ),
      );
    }
    if (data.containsKey('position_milliseconds')) {
      context.handle(
        _positionMillisecondsMeta,
        positionMilliseconds.isAcceptableOrUnknown(
          data['position_milliseconds']!,
          _positionMillisecondsMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalQueueSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalQueueSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      currentEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_entry_id'],
      ),
      autoPlayEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_play_enabled'],
      )!,
      positionMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_milliseconds'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalQueueSessionsTable createAlias(String alias) {
    return $LocalQueueSessionsTable(attachedDatabase, alias);
  }
}

class LocalQueueSession extends DataClass
    implements Insertable<LocalQueueSession> {
  final String id;
  final String? currentEntryId;
  final bool autoPlayEnabled;
  final int positionMilliseconds;
  final DateTime updatedAt;
  const LocalQueueSession({
    required this.id,
    this.currentEntryId,
    required this.autoPlayEnabled,
    required this.positionMilliseconds,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || currentEntryId != null) {
      map['current_entry_id'] = Variable<String>(currentEntryId);
    }
    map['auto_play_enabled'] = Variable<bool>(autoPlayEnabled);
    map['position_milliseconds'] = Variable<int>(positionMilliseconds);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalQueueSessionsCompanion toCompanion(bool nullToAbsent) {
    return LocalQueueSessionsCompanion(
      id: Value(id),
      currentEntryId: currentEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentEntryId),
      autoPlayEnabled: Value(autoPlayEnabled),
      positionMilliseconds: Value(positionMilliseconds),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalQueueSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalQueueSession(
      id: serializer.fromJson<String>(json['id']),
      currentEntryId: serializer.fromJson<String?>(json['currentEntryId']),
      autoPlayEnabled: serializer.fromJson<bool>(json['autoPlayEnabled']),
      positionMilliseconds: serializer.fromJson<int>(
        json['positionMilliseconds'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'currentEntryId': serializer.toJson<String?>(currentEntryId),
      'autoPlayEnabled': serializer.toJson<bool>(autoPlayEnabled),
      'positionMilliseconds': serializer.toJson<int>(positionMilliseconds),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalQueueSession copyWith({
    String? id,
    Value<String?> currentEntryId = const Value.absent(),
    bool? autoPlayEnabled,
    int? positionMilliseconds,
    DateTime? updatedAt,
  }) => LocalQueueSession(
    id: id ?? this.id,
    currentEntryId: currentEntryId.present
        ? currentEntryId.value
        : this.currentEntryId,
    autoPlayEnabled: autoPlayEnabled ?? this.autoPlayEnabled,
    positionMilliseconds: positionMilliseconds ?? this.positionMilliseconds,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalQueueSession copyWithCompanion(LocalQueueSessionsCompanion data) {
    return LocalQueueSession(
      id: data.id.present ? data.id.value : this.id,
      currentEntryId: data.currentEntryId.present
          ? data.currentEntryId.value
          : this.currentEntryId,
      autoPlayEnabled: data.autoPlayEnabled.present
          ? data.autoPlayEnabled.value
          : this.autoPlayEnabled,
      positionMilliseconds: data.positionMilliseconds.present
          ? data.positionMilliseconds.value
          : this.positionMilliseconds,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalQueueSession(')
          ..write('id: $id, ')
          ..write('currentEntryId: $currentEntryId, ')
          ..write('autoPlayEnabled: $autoPlayEnabled, ')
          ..write('positionMilliseconds: $positionMilliseconds, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    currentEntryId,
    autoPlayEnabled,
    positionMilliseconds,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalQueueSession &&
          other.id == this.id &&
          other.currentEntryId == this.currentEntryId &&
          other.autoPlayEnabled == this.autoPlayEnabled &&
          other.positionMilliseconds == this.positionMilliseconds &&
          other.updatedAt == this.updatedAt);
}

class LocalQueueSessionsCompanion extends UpdateCompanion<LocalQueueSession> {
  final Value<String> id;
  final Value<String?> currentEntryId;
  final Value<bool> autoPlayEnabled;
  final Value<int> positionMilliseconds;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalQueueSessionsCompanion({
    this.id = const Value.absent(),
    this.currentEntryId = const Value.absent(),
    this.autoPlayEnabled = const Value.absent(),
    this.positionMilliseconds = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalQueueSessionsCompanion.insert({
    required String id,
    this.currentEntryId = const Value.absent(),
    this.autoPlayEnabled = const Value.absent(),
    this.positionMilliseconds = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt);
  static Insertable<LocalQueueSession> custom({
    Expression<String>? id,
    Expression<String>? currentEntryId,
    Expression<bool>? autoPlayEnabled,
    Expression<int>? positionMilliseconds,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (currentEntryId != null) 'current_entry_id': currentEntryId,
      if (autoPlayEnabled != null) 'auto_play_enabled': autoPlayEnabled,
      if (positionMilliseconds != null)
        'position_milliseconds': positionMilliseconds,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalQueueSessionsCompanion copyWith({
    Value<String>? id,
    Value<String?>? currentEntryId,
    Value<bool>? autoPlayEnabled,
    Value<int>? positionMilliseconds,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalQueueSessionsCompanion(
      id: id ?? this.id,
      currentEntryId: currentEntryId ?? this.currentEntryId,
      autoPlayEnabled: autoPlayEnabled ?? this.autoPlayEnabled,
      positionMilliseconds: positionMilliseconds ?? this.positionMilliseconds,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (currentEntryId.present) {
      map['current_entry_id'] = Variable<String>(currentEntryId.value);
    }
    if (autoPlayEnabled.present) {
      map['auto_play_enabled'] = Variable<bool>(autoPlayEnabled.value);
    }
    if (positionMilliseconds.present) {
      map['position_milliseconds'] = Variable<int>(positionMilliseconds.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalQueueSessionsCompanion(')
          ..write('id: $id, ')
          ..write('currentEntryId: $currentEntryId, ')
          ..write('autoPlayEnabled: $autoPlayEnabled, ')
          ..write('positionMilliseconds: $positionMilliseconds, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalQueueEntriesTable extends LocalQueueEntries
    with TableInfo<$LocalQueueEntriesTable, LocalQueueEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalQueueEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [sessionId, entryId, songId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_queue_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalQueueEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId, entryId};
  @override
  LocalQueueEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalQueueEntry(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_id'],
      )!,
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $LocalQueueEntriesTable createAlias(String alias) {
    return $LocalQueueEntriesTable(attachedDatabase, alias);
  }
}

class LocalQueueEntry extends DataClass implements Insertable<LocalQueueEntry> {
  final String sessionId;
  final String entryId;
  final String songId;
  final int position;
  const LocalQueueEntry({
    required this.sessionId,
    required this.entryId,
    required this.songId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['entry_id'] = Variable<String>(entryId);
    map['song_id'] = Variable<String>(songId);
    map['position'] = Variable<int>(position);
    return map;
  }

  LocalQueueEntriesCompanion toCompanion(bool nullToAbsent) {
    return LocalQueueEntriesCompanion(
      sessionId: Value(sessionId),
      entryId: Value(entryId),
      songId: Value(songId),
      position: Value(position),
    );
  }

  factory LocalQueueEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalQueueEntry(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      entryId: serializer.fromJson<String>(json['entryId']),
      songId: serializer.fromJson<String>(json['songId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'entryId': serializer.toJson<String>(entryId),
      'songId': serializer.toJson<String>(songId),
      'position': serializer.toJson<int>(position),
    };
  }

  LocalQueueEntry copyWith({
    String? sessionId,
    String? entryId,
    String? songId,
    int? position,
  }) => LocalQueueEntry(
    sessionId: sessionId ?? this.sessionId,
    entryId: entryId ?? this.entryId,
    songId: songId ?? this.songId,
    position: position ?? this.position,
  );
  LocalQueueEntry copyWithCompanion(LocalQueueEntriesCompanion data) {
    return LocalQueueEntry(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      songId: data.songId.present ? data.songId.value : this.songId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalQueueEntry(')
          ..write('sessionId: $sessionId, ')
          ..write('entryId: $entryId, ')
          ..write('songId: $songId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sessionId, entryId, songId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalQueueEntry &&
          other.sessionId == this.sessionId &&
          other.entryId == this.entryId &&
          other.songId == this.songId &&
          other.position == this.position);
}

class LocalQueueEntriesCompanion extends UpdateCompanion<LocalQueueEntry> {
  final Value<String> sessionId;
  final Value<String> entryId;
  final Value<String> songId;
  final Value<int> position;
  final Value<int> rowid;
  const LocalQueueEntriesCompanion({
    this.sessionId = const Value.absent(),
    this.entryId = const Value.absent(),
    this.songId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalQueueEntriesCompanion.insert({
    required String sessionId,
    required String entryId,
    required String songId,
    required int position,
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       entryId = Value(entryId),
       songId = Value(songId),
       position = Value(position);
  static Insertable<LocalQueueEntry> custom({
    Expression<String>? sessionId,
    Expression<String>? entryId,
    Expression<String>? songId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (entryId != null) 'entry_id': entryId,
      if (songId != null) 'song_id': songId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalQueueEntriesCompanion copyWith({
    Value<String>? sessionId,
    Value<String>? entryId,
    Value<String>? songId,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return LocalQueueEntriesCompanion(
      sessionId: sessionId ?? this.sessionId,
      entryId: entryId ?? this.entryId,
      songId: songId ?? this.songId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalQueueEntriesCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('entryId: $entryId, ')
          ..write('songId: $songId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavedQueueSnapshotsTable extends SavedQueueSnapshots
    with TableInfo<$SavedQueueSnapshotsTable, SavedQueueSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedQueueSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentIndexMeta = const VerificationMeta(
    'currentIndex',
  );
  @override
  late final GeneratedColumn<int> currentIndex = GeneratedColumn<int>(
    'current_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _autoPlayEnabledMeta = const VerificationMeta(
    'autoPlayEnabled',
  );
  @override
  late final GeneratedColumn<bool> autoPlayEnabled = GeneratedColumn<bool>(
    'auto_play_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_play_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _positionMillisecondsMeta =
      const VerificationMeta('positionMilliseconds');
  @override
  late final GeneratedColumn<int> positionMilliseconds = GeneratedColumn<int>(
    'position_milliseconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    currentIndex,
    autoPlayEnabled,
    positionMilliseconds,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_queue_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedQueueSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('current_index')) {
      context.handle(
        _currentIndexMeta,
        currentIndex.isAcceptableOrUnknown(
          data['current_index']!,
          _currentIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentIndexMeta);
    }
    if (data.containsKey('auto_play_enabled')) {
      context.handle(
        _autoPlayEnabledMeta,
        autoPlayEnabled.isAcceptableOrUnknown(
          data['auto_play_enabled']!,
          _autoPlayEnabledMeta,
        ),
      );
    }
    if (data.containsKey('position_milliseconds')) {
      context.handle(
        _positionMillisecondsMeta,
        positionMilliseconds.isAcceptableOrUnknown(
          data['position_milliseconds']!,
          _positionMillisecondsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedQueueSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedQueueSnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      currentIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_index'],
      )!,
      autoPlayEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_play_enabled'],
      )!,
      positionMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_milliseconds'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SavedQueueSnapshotsTable createAlias(String alias) {
    return $SavedQueueSnapshotsTable(attachedDatabase, alias);
  }
}

class SavedQueueSnapshot extends DataClass
    implements Insertable<SavedQueueSnapshot> {
  final String id;
  final String name;
  final int currentIndex;
  final bool autoPlayEnabled;
  final int positionMilliseconds;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SavedQueueSnapshot({
    required this.id,
    required this.name,
    required this.currentIndex,
    required this.autoPlayEnabled,
    required this.positionMilliseconds,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['current_index'] = Variable<int>(currentIndex);
    map['auto_play_enabled'] = Variable<bool>(autoPlayEnabled);
    map['position_milliseconds'] = Variable<int>(positionMilliseconds);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SavedQueueSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return SavedQueueSnapshotsCompanion(
      id: Value(id),
      name: Value(name),
      currentIndex: Value(currentIndex),
      autoPlayEnabled: Value(autoPlayEnabled),
      positionMilliseconds: Value(positionMilliseconds),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SavedQueueSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedQueueSnapshot(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      currentIndex: serializer.fromJson<int>(json['currentIndex']),
      autoPlayEnabled: serializer.fromJson<bool>(json['autoPlayEnabled']),
      positionMilliseconds: serializer.fromJson<int>(
        json['positionMilliseconds'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'currentIndex': serializer.toJson<int>(currentIndex),
      'autoPlayEnabled': serializer.toJson<bool>(autoPlayEnabled),
      'positionMilliseconds': serializer.toJson<int>(positionMilliseconds),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SavedQueueSnapshot copyWith({
    String? id,
    String? name,
    int? currentIndex,
    bool? autoPlayEnabled,
    int? positionMilliseconds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SavedQueueSnapshot(
    id: id ?? this.id,
    name: name ?? this.name,
    currentIndex: currentIndex ?? this.currentIndex,
    autoPlayEnabled: autoPlayEnabled ?? this.autoPlayEnabled,
    positionMilliseconds: positionMilliseconds ?? this.positionMilliseconds,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SavedQueueSnapshot copyWithCompanion(SavedQueueSnapshotsCompanion data) {
    return SavedQueueSnapshot(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      currentIndex: data.currentIndex.present
          ? data.currentIndex.value
          : this.currentIndex,
      autoPlayEnabled: data.autoPlayEnabled.present
          ? data.autoPlayEnabled.value
          : this.autoPlayEnabled,
      positionMilliseconds: data.positionMilliseconds.present
          ? data.positionMilliseconds.value
          : this.positionMilliseconds,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedQueueSnapshot(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('currentIndex: $currentIndex, ')
          ..write('autoPlayEnabled: $autoPlayEnabled, ')
          ..write('positionMilliseconds: $positionMilliseconds, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    currentIndex,
    autoPlayEnabled,
    positionMilliseconds,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedQueueSnapshot &&
          other.id == this.id &&
          other.name == this.name &&
          other.currentIndex == this.currentIndex &&
          other.autoPlayEnabled == this.autoPlayEnabled &&
          other.positionMilliseconds == this.positionMilliseconds &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SavedQueueSnapshotsCompanion extends UpdateCompanion<SavedQueueSnapshot> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> currentIndex;
  final Value<bool> autoPlayEnabled;
  final Value<int> positionMilliseconds;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SavedQueueSnapshotsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.currentIndex = const Value.absent(),
    this.autoPlayEnabled = const Value.absent(),
    this.positionMilliseconds = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedQueueSnapshotsCompanion.insert({
    required String id,
    required String name,
    required int currentIndex,
    this.autoPlayEnabled = const Value.absent(),
    this.positionMilliseconds = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       currentIndex = Value(currentIndex),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SavedQueueSnapshot> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? currentIndex,
    Expression<bool>? autoPlayEnabled,
    Expression<int>? positionMilliseconds,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (currentIndex != null) 'current_index': currentIndex,
      if (autoPlayEnabled != null) 'auto_play_enabled': autoPlayEnabled,
      if (positionMilliseconds != null)
        'position_milliseconds': positionMilliseconds,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedQueueSnapshotsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? currentIndex,
    Value<bool>? autoPlayEnabled,
    Value<int>? positionMilliseconds,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SavedQueueSnapshotsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      currentIndex: currentIndex ?? this.currentIndex,
      autoPlayEnabled: autoPlayEnabled ?? this.autoPlayEnabled,
      positionMilliseconds: positionMilliseconds ?? this.positionMilliseconds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (currentIndex.present) {
      map['current_index'] = Variable<int>(currentIndex.value);
    }
    if (autoPlayEnabled.present) {
      map['auto_play_enabled'] = Variable<bool>(autoPlayEnabled.value);
    }
    if (positionMilliseconds.present) {
      map['position_milliseconds'] = Variable<int>(positionMilliseconds.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedQueueSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('currentIndex: $currentIndex, ')
          ..write('autoPlayEnabled: $autoPlayEnabled, ')
          ..write('positionMilliseconds: $positionMilliseconds, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavedQueueSnapshotEntriesTable extends SavedQueueSnapshotEntries
    with TableInfo<$SavedQueueSnapshotEntriesTable, SavedQueueSnapshotEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedQueueSnapshotEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _snapshotIdMeta = const VerificationMeta(
    'snapshotId',
  );
  @override
  late final GeneratedColumn<String> snapshotId = GeneratedColumn<String>(
    'snapshot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [snapshotId, songId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_queue_snapshot_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedQueueSnapshotEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('snapshot_id')) {
      context.handle(
        _snapshotIdMeta,
        snapshotId.isAcceptableOrUnknown(data['snapshot_id']!, _snapshotIdMeta),
      );
    } else if (isInserting) {
      context.missing(_snapshotIdMeta);
    }
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {snapshotId, position};
  @override
  SavedQueueSnapshotEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedQueueSnapshotEntry(
      snapshotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snapshot_id'],
      )!,
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $SavedQueueSnapshotEntriesTable createAlias(String alias) {
    return $SavedQueueSnapshotEntriesTable(attachedDatabase, alias);
  }
}

class SavedQueueSnapshotEntry extends DataClass
    implements Insertable<SavedQueueSnapshotEntry> {
  final String snapshotId;
  final String songId;
  final int position;
  const SavedQueueSnapshotEntry({
    required this.snapshotId,
    required this.songId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['snapshot_id'] = Variable<String>(snapshotId);
    map['song_id'] = Variable<String>(songId);
    map['position'] = Variable<int>(position);
    return map;
  }

  SavedQueueSnapshotEntriesCompanion toCompanion(bool nullToAbsent) {
    return SavedQueueSnapshotEntriesCompanion(
      snapshotId: Value(snapshotId),
      songId: Value(songId),
      position: Value(position),
    );
  }

  factory SavedQueueSnapshotEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedQueueSnapshotEntry(
      snapshotId: serializer.fromJson<String>(json['snapshotId']),
      songId: serializer.fromJson<String>(json['songId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'snapshotId': serializer.toJson<String>(snapshotId),
      'songId': serializer.toJson<String>(songId),
      'position': serializer.toJson<int>(position),
    };
  }

  SavedQueueSnapshotEntry copyWith({
    String? snapshotId,
    String? songId,
    int? position,
  }) => SavedQueueSnapshotEntry(
    snapshotId: snapshotId ?? this.snapshotId,
    songId: songId ?? this.songId,
    position: position ?? this.position,
  );
  SavedQueueSnapshotEntry copyWithCompanion(
    SavedQueueSnapshotEntriesCompanion data,
  ) {
    return SavedQueueSnapshotEntry(
      snapshotId: data.snapshotId.present
          ? data.snapshotId.value
          : this.snapshotId,
      songId: data.songId.present ? data.songId.value : this.songId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedQueueSnapshotEntry(')
          ..write('snapshotId: $snapshotId, ')
          ..write('songId: $songId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(snapshotId, songId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedQueueSnapshotEntry &&
          other.snapshotId == this.snapshotId &&
          other.songId == this.songId &&
          other.position == this.position);
}

class SavedQueueSnapshotEntriesCompanion
    extends UpdateCompanion<SavedQueueSnapshotEntry> {
  final Value<String> snapshotId;
  final Value<String> songId;
  final Value<int> position;
  final Value<int> rowid;
  const SavedQueueSnapshotEntriesCompanion({
    this.snapshotId = const Value.absent(),
    this.songId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedQueueSnapshotEntriesCompanion.insert({
    required String snapshotId,
    required String songId,
    required int position,
    this.rowid = const Value.absent(),
  }) : snapshotId = Value(snapshotId),
       songId = Value(songId),
       position = Value(position);
  static Insertable<SavedQueueSnapshotEntry> custom({
    Expression<String>? snapshotId,
    Expression<String>? songId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (snapshotId != null) 'snapshot_id': snapshotId,
      if (songId != null) 'song_id': songId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedQueueSnapshotEntriesCompanion copyWith({
    Value<String>? snapshotId,
    Value<String>? songId,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return SavedQueueSnapshotEntriesCompanion(
      snapshotId: snapshotId ?? this.snapshotId,
      songId: songId ?? this.songId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (snapshotId.present) {
      map['snapshot_id'] = Variable<String>(snapshotId.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedQueueSnapshotEntriesCompanion(')
          ..write('snapshotId: $snapshotId, ')
          ..write('songId: $songId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalLyricsTable extends LocalLyrics
    with TableInfo<$LocalLyricsTable, LocalLyric> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalLyricsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lrcMeta = const VerificationMeta('lrc');
  @override
  late final GeneratedColumn<String> lrc = GeneratedColumn<String>(
    'lrc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [songId, lrc, fetchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_lyrics';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalLyric> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('lrc')) {
      context.handle(
        _lrcMeta,
        lrc.isAcceptableOrUnknown(data['lrc']!, _lrcMeta),
      );
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {songId};
  @override
  LocalLyric map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalLyric(
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      lrc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lrc'],
      ),
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $LocalLyricsTable createAlias(String alias) {
    return $LocalLyricsTable(attachedDatabase, alias);
  }
}

class LocalLyric extends DataClass implements Insertable<LocalLyric> {
  final String songId;
  final String? lrc;
  final DateTime fetchedAt;
  const LocalLyric({required this.songId, this.lrc, required this.fetchedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['song_id'] = Variable<String>(songId);
    if (!nullToAbsent || lrc != null) {
      map['lrc'] = Variable<String>(lrc);
    }
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  LocalLyricsCompanion toCompanion(bool nullToAbsent) {
    return LocalLyricsCompanion(
      songId: Value(songId),
      lrc: lrc == null && nullToAbsent ? const Value.absent() : Value(lrc),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory LocalLyric.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalLyric(
      songId: serializer.fromJson<String>(json['songId']),
      lrc: serializer.fromJson<String?>(json['lrc']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'songId': serializer.toJson<String>(songId),
      'lrc': serializer.toJson<String?>(lrc),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  LocalLyric copyWith({
    String? songId,
    Value<String?> lrc = const Value.absent(),
    DateTime? fetchedAt,
  }) => LocalLyric(
    songId: songId ?? this.songId,
    lrc: lrc.present ? lrc.value : this.lrc,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  LocalLyric copyWithCompanion(LocalLyricsCompanion data) {
    return LocalLyric(
      songId: data.songId.present ? data.songId.value : this.songId,
      lrc: data.lrc.present ? data.lrc.value : this.lrc,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalLyric(')
          ..write('songId: $songId, ')
          ..write('lrc: $lrc, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(songId, lrc, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalLyric &&
          other.songId == this.songId &&
          other.lrc == this.lrc &&
          other.fetchedAt == this.fetchedAt);
}

class LocalLyricsCompanion extends UpdateCompanion<LocalLyric> {
  final Value<String> songId;
  final Value<String?> lrc;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const LocalLyricsCompanion({
    this.songId = const Value.absent(),
    this.lrc = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalLyricsCompanion.insert({
    required String songId,
    this.lrc = const Value.absent(),
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : songId = Value(songId),
       fetchedAt = Value(fetchedAt);
  static Insertable<LocalLyric> custom({
    Expression<String>? songId,
    Expression<String>? lrc,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (songId != null) 'song_id': songId,
      if (lrc != null) 'lrc': lrc,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalLyricsCompanion copyWith({
    Value<String>? songId,
    Value<String?>? lrc,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return LocalLyricsCompanion(
      songId: songId ?? this.songId,
      lrc: lrc ?? this.lrc,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (lrc.present) {
      map['lrc'] = Variable<String>(lrc.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalLyricsCompanion(')
          ..write('songId: $songId, ')
          ..write('lrc: $lrc, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalArtistsTable localArtists = $LocalArtistsTable(this);
  late final $LocalAlbumsTable localAlbums = $LocalAlbumsTable(this);
  late final $StagedArtistsTable stagedArtists = $StagedArtistsTable(this);
  late final $StagedAlbumsTable stagedAlbums = $StagedAlbumsTable(this);
  late final $LocalSongsTable localSongs = $LocalSongsTable(this);
  late final $StagedSongsTable stagedSongs = $StagedSongsTable(this);
  late final $LocalPlaylistsTable localPlaylists = $LocalPlaylistsTable(this);
  late final $StagedPlaylistsTable stagedPlaylists = $StagedPlaylistsTable(
    this,
  );
  late final $LocalPlaylistEntriesTable localPlaylistEntries =
      $LocalPlaylistEntriesTable(this);
  late final $StagedPlaylistEntriesTable stagedPlaylistEntries =
      $StagedPlaylistEntriesTable(this);
  late final $LocalFavoritesTable localFavorites = $LocalFavoritesTable(this);
  late final $LocalInternetRadioStationsTable localInternetRadioStations =
      $LocalInternetRadioStationsTable(this);
  late final $SyncStatesTable syncStates = $SyncStatesTable(this);
  late final $PendingMutationsTable pendingMutations = $PendingMutationsTable(
    this,
  );
  late final $LocalPlayEventsTable localPlayEvents = $LocalPlayEventsTable(
    this,
  );
  late final $LocalSongActivitiesTable localSongActivities =
      $LocalSongActivitiesTable(this);
  late final $LocalQueueSessionsTable localQueueSessions =
      $LocalQueueSessionsTable(this);
  late final $LocalQueueEntriesTable localQueueEntries =
      $LocalQueueEntriesTable(this);
  late final $SavedQueueSnapshotsTable savedQueueSnapshots =
      $SavedQueueSnapshotsTable(this);
  late final $SavedQueueSnapshotEntriesTable savedQueueSnapshotEntries =
      $SavedQueueSnapshotEntriesTable(this);
  late final $LocalLyricsTable localLyrics = $LocalLyricsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localArtists,
    localAlbums,
    stagedArtists,
    stagedAlbums,
    localSongs,
    stagedSongs,
    localPlaylists,
    stagedPlaylists,
    localPlaylistEntries,
    stagedPlaylistEntries,
    localFavorites,
    localInternetRadioStations,
    syncStates,
    pendingMutations,
    localPlayEvents,
    localSongActivities,
    localQueueSessions,
    localQueueEntries,
    savedQueueSnapshots,
    savedQueueSnapshotEntries,
    localLyrics,
  ];
}

typedef $$LocalArtistsTableCreateCompanionBuilder =
    LocalArtistsCompanion Function({
      required String id,
      required String name,
      Value<String?> sortName,
      Value<String?> coverArt,
      Value<int> albumCount,
      Value<bool> starred,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$LocalArtistsTableUpdateCompanionBuilder =
    LocalArtistsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> sortName,
      Value<String?> coverArt,
      Value<int> albumCount,
      Value<bool> starred,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$LocalArtistsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalArtistsTable> {
  $$LocalArtistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sortName => $composableBuilder(
    column: $table.sortName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverArt => $composableBuilder(
    column: $table.coverArt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get albumCount => $composableBuilder(
    column: $table.albumCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get starred => $composableBuilder(
    column: $table.starred,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalArtistsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalArtistsTable> {
  $$LocalArtistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sortName => $composableBuilder(
    column: $table.sortName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverArt => $composableBuilder(
    column: $table.coverArt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get albumCount => $composableBuilder(
    column: $table.albumCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get starred => $composableBuilder(
    column: $table.starred,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalArtistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalArtistsTable> {
  $$LocalArtistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sortName =>
      $composableBuilder(column: $table.sortName, builder: (column) => column);

  GeneratedColumn<String> get coverArt =>
      $composableBuilder(column: $table.coverArt, builder: (column) => column);

  GeneratedColumn<int> get albumCount => $composableBuilder(
    column: $table.albumCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get starred =>
      $composableBuilder(column: $table.starred, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalArtistsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalArtistsTable,
          LocalArtist,
          $$LocalArtistsTableFilterComposer,
          $$LocalArtistsTableOrderingComposer,
          $$LocalArtistsTableAnnotationComposer,
          $$LocalArtistsTableCreateCompanionBuilder,
          $$LocalArtistsTableUpdateCompanionBuilder,
          (
            LocalArtist,
            BaseReferences<_$AppDatabase, $LocalArtistsTable, LocalArtist>,
          ),
          LocalArtist,
          PrefetchHooks Function()
        > {
  $$LocalArtistsTableTableManager(_$AppDatabase db, $LocalArtistsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalArtistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalArtistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalArtistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> sortName = const Value.absent(),
                Value<String?> coverArt = const Value.absent(),
                Value<int> albumCount = const Value.absent(),
                Value<bool> starred = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalArtistsCompanion(
                id: id,
                name: name,
                sortName: sortName,
                coverArt: coverArt,
                albumCount: albumCount,
                starred: starred,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> sortName = const Value.absent(),
                Value<String?> coverArt = const Value.absent(),
                Value<int> albumCount = const Value.absent(),
                Value<bool> starred = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalArtistsCompanion.insert(
                id: id,
                name: name,
                sortName: sortName,
                coverArt: coverArt,
                albumCount: albumCount,
                starred: starred,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalArtistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalArtistsTable,
      LocalArtist,
      $$LocalArtistsTableFilterComposer,
      $$LocalArtistsTableOrderingComposer,
      $$LocalArtistsTableAnnotationComposer,
      $$LocalArtistsTableCreateCompanionBuilder,
      $$LocalArtistsTableUpdateCompanionBuilder,
      (
        LocalArtist,
        BaseReferences<_$AppDatabase, $LocalArtistsTable, LocalArtist>,
      ),
      LocalArtist,
      PrefetchHooks Function()
    >;
typedef $$LocalAlbumsTableCreateCompanionBuilder =
    LocalAlbumsCompanion Function({
      required String id,
      required String name,
      Value<String?> artistId,
      required String artist,
      Value<String> canonicalArtist,
      Value<int> year,
      Value<int> songCount,
      Value<int> duration,
      Value<int> playCount,
      Value<String?> coverArt,
      Value<bool> starred,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$LocalAlbumsTableUpdateCompanionBuilder =
    LocalAlbumsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> artistId,
      Value<String> artist,
      Value<String> canonicalArtist,
      Value<int> year,
      Value<int> songCount,
      Value<int> duration,
      Value<int> playCount,
      Value<String?> coverArt,
      Value<bool> starred,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$LocalAlbumsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAlbumsTable> {
  $$LocalAlbumsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistId => $composableBuilder(
    column: $table.artistId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get canonicalArtist => $composableBuilder(
    column: $table.canonicalArtist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get songCount => $composableBuilder(
    column: $table.songCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverArt => $composableBuilder(
    column: $table.coverArt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get starred => $composableBuilder(
    column: $table.starred,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAlbumsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAlbumsTable> {
  $$LocalAlbumsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistId => $composableBuilder(
    column: $table.artistId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get canonicalArtist => $composableBuilder(
    column: $table.canonicalArtist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get songCount => $composableBuilder(
    column: $table.songCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverArt => $composableBuilder(
    column: $table.coverArt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get starred => $composableBuilder(
    column: $table.starred,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAlbumsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAlbumsTable> {
  $$LocalAlbumsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get artistId =>
      $composableBuilder(column: $table.artistId, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get canonicalArtist => $composableBuilder(
    column: $table.canonicalArtist,
    builder: (column) => column,
  );

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get songCount =>
      $composableBuilder(column: $table.songCount, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<int> get playCount =>
      $composableBuilder(column: $table.playCount, builder: (column) => column);

  GeneratedColumn<String> get coverArt =>
      $composableBuilder(column: $table.coverArt, builder: (column) => column);

  GeneratedColumn<bool> get starred =>
      $composableBuilder(column: $table.starred, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalAlbumsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAlbumsTable,
          LocalAlbum,
          $$LocalAlbumsTableFilterComposer,
          $$LocalAlbumsTableOrderingComposer,
          $$LocalAlbumsTableAnnotationComposer,
          $$LocalAlbumsTableCreateCompanionBuilder,
          $$LocalAlbumsTableUpdateCompanionBuilder,
          (
            LocalAlbum,
            BaseReferences<_$AppDatabase, $LocalAlbumsTable, LocalAlbum>,
          ),
          LocalAlbum,
          PrefetchHooks Function()
        > {
  $$LocalAlbumsTableTableManager(_$AppDatabase db, $LocalAlbumsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAlbumsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAlbumsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAlbumsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> artistId = const Value.absent(),
                Value<String> artist = const Value.absent(),
                Value<String> canonicalArtist = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<int> songCount = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<String?> coverArt = const Value.absent(),
                Value<bool> starred = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAlbumsCompanion(
                id: id,
                name: name,
                artistId: artistId,
                artist: artist,
                canonicalArtist: canonicalArtist,
                year: year,
                songCount: songCount,
                duration: duration,
                playCount: playCount,
                coverArt: coverArt,
                starred: starred,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> artistId = const Value.absent(),
                required String artist,
                Value<String> canonicalArtist = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<int> songCount = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<String?> coverArt = const Value.absent(),
                Value<bool> starred = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAlbumsCompanion.insert(
                id: id,
                name: name,
                artistId: artistId,
                artist: artist,
                canonicalArtist: canonicalArtist,
                year: year,
                songCount: songCount,
                duration: duration,
                playCount: playCount,
                coverArt: coverArt,
                starred: starred,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAlbumsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAlbumsTable,
      LocalAlbum,
      $$LocalAlbumsTableFilterComposer,
      $$LocalAlbumsTableOrderingComposer,
      $$LocalAlbumsTableAnnotationComposer,
      $$LocalAlbumsTableCreateCompanionBuilder,
      $$LocalAlbumsTableUpdateCompanionBuilder,
      (
        LocalAlbum,
        BaseReferences<_$AppDatabase, $LocalAlbumsTable, LocalAlbum>,
      ),
      LocalAlbum,
      PrefetchHooks Function()
    >;
typedef $$StagedArtistsTableCreateCompanionBuilder =
    StagedArtistsCompanion Function({
      required String id,
      required String name,
      Value<String?> sortName,
      Value<String?> coverArt,
      Value<int> albumCount,
      Value<bool> starred,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$StagedArtistsTableUpdateCompanionBuilder =
    StagedArtistsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> sortName,
      Value<String?> coverArt,
      Value<int> albumCount,
      Value<bool> starred,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$StagedArtistsTableFilterComposer
    extends Composer<_$AppDatabase, $StagedArtistsTable> {
  $$StagedArtistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sortName => $composableBuilder(
    column: $table.sortName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverArt => $composableBuilder(
    column: $table.coverArt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get albumCount => $composableBuilder(
    column: $table.albumCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get starred => $composableBuilder(
    column: $table.starred,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StagedArtistsTableOrderingComposer
    extends Composer<_$AppDatabase, $StagedArtistsTable> {
  $$StagedArtistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sortName => $composableBuilder(
    column: $table.sortName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverArt => $composableBuilder(
    column: $table.coverArt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get albumCount => $composableBuilder(
    column: $table.albumCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get starred => $composableBuilder(
    column: $table.starred,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StagedArtistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StagedArtistsTable> {
  $$StagedArtistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sortName =>
      $composableBuilder(column: $table.sortName, builder: (column) => column);

  GeneratedColumn<String> get coverArt =>
      $composableBuilder(column: $table.coverArt, builder: (column) => column);

  GeneratedColumn<int> get albumCount => $composableBuilder(
    column: $table.albumCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get starred =>
      $composableBuilder(column: $table.starred, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$StagedArtistsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StagedArtistsTable,
          StagedArtist,
          $$StagedArtistsTableFilterComposer,
          $$StagedArtistsTableOrderingComposer,
          $$StagedArtistsTableAnnotationComposer,
          $$StagedArtistsTableCreateCompanionBuilder,
          $$StagedArtistsTableUpdateCompanionBuilder,
          (
            StagedArtist,
            BaseReferences<_$AppDatabase, $StagedArtistsTable, StagedArtist>,
          ),
          StagedArtist,
          PrefetchHooks Function()
        > {
  $$StagedArtistsTableTableManager(_$AppDatabase db, $StagedArtistsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StagedArtistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StagedArtistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StagedArtistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> sortName = const Value.absent(),
                Value<String?> coverArt = const Value.absent(),
                Value<int> albumCount = const Value.absent(),
                Value<bool> starred = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StagedArtistsCompanion(
                id: id,
                name: name,
                sortName: sortName,
                coverArt: coverArt,
                albumCount: albumCount,
                starred: starred,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> sortName = const Value.absent(),
                Value<String?> coverArt = const Value.absent(),
                Value<int> albumCount = const Value.absent(),
                Value<bool> starred = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StagedArtistsCompanion.insert(
                id: id,
                name: name,
                sortName: sortName,
                coverArt: coverArt,
                albumCount: albumCount,
                starred: starred,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StagedArtistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StagedArtistsTable,
      StagedArtist,
      $$StagedArtistsTableFilterComposer,
      $$StagedArtistsTableOrderingComposer,
      $$StagedArtistsTableAnnotationComposer,
      $$StagedArtistsTableCreateCompanionBuilder,
      $$StagedArtistsTableUpdateCompanionBuilder,
      (
        StagedArtist,
        BaseReferences<_$AppDatabase, $StagedArtistsTable, StagedArtist>,
      ),
      StagedArtist,
      PrefetchHooks Function()
    >;
typedef $$StagedAlbumsTableCreateCompanionBuilder =
    StagedAlbumsCompanion Function({
      required String id,
      required String name,
      Value<String?> artistId,
      required String artist,
      Value<String> canonicalArtist,
      Value<int> year,
      Value<int> songCount,
      Value<int> duration,
      Value<int> playCount,
      Value<String?> coverArt,
      Value<bool> starred,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$StagedAlbumsTableUpdateCompanionBuilder =
    StagedAlbumsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> artistId,
      Value<String> artist,
      Value<String> canonicalArtist,
      Value<int> year,
      Value<int> songCount,
      Value<int> duration,
      Value<int> playCount,
      Value<String?> coverArt,
      Value<bool> starred,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$StagedAlbumsTableFilterComposer
    extends Composer<_$AppDatabase, $StagedAlbumsTable> {
  $$StagedAlbumsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistId => $composableBuilder(
    column: $table.artistId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get canonicalArtist => $composableBuilder(
    column: $table.canonicalArtist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get songCount => $composableBuilder(
    column: $table.songCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverArt => $composableBuilder(
    column: $table.coverArt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get starred => $composableBuilder(
    column: $table.starred,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StagedAlbumsTableOrderingComposer
    extends Composer<_$AppDatabase, $StagedAlbumsTable> {
  $$StagedAlbumsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistId => $composableBuilder(
    column: $table.artistId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get canonicalArtist => $composableBuilder(
    column: $table.canonicalArtist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get songCount => $composableBuilder(
    column: $table.songCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverArt => $composableBuilder(
    column: $table.coverArt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get starred => $composableBuilder(
    column: $table.starred,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StagedAlbumsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StagedAlbumsTable> {
  $$StagedAlbumsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get artistId =>
      $composableBuilder(column: $table.artistId, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get canonicalArtist => $composableBuilder(
    column: $table.canonicalArtist,
    builder: (column) => column,
  );

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get songCount =>
      $composableBuilder(column: $table.songCount, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<int> get playCount =>
      $composableBuilder(column: $table.playCount, builder: (column) => column);

  GeneratedColumn<String> get coverArt =>
      $composableBuilder(column: $table.coverArt, builder: (column) => column);

  GeneratedColumn<bool> get starred =>
      $composableBuilder(column: $table.starred, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$StagedAlbumsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StagedAlbumsTable,
          StagedAlbum,
          $$StagedAlbumsTableFilterComposer,
          $$StagedAlbumsTableOrderingComposer,
          $$StagedAlbumsTableAnnotationComposer,
          $$StagedAlbumsTableCreateCompanionBuilder,
          $$StagedAlbumsTableUpdateCompanionBuilder,
          (
            StagedAlbum,
            BaseReferences<_$AppDatabase, $StagedAlbumsTable, StagedAlbum>,
          ),
          StagedAlbum,
          PrefetchHooks Function()
        > {
  $$StagedAlbumsTableTableManager(_$AppDatabase db, $StagedAlbumsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StagedAlbumsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StagedAlbumsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StagedAlbumsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> artistId = const Value.absent(),
                Value<String> artist = const Value.absent(),
                Value<String> canonicalArtist = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<int> songCount = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<String?> coverArt = const Value.absent(),
                Value<bool> starred = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StagedAlbumsCompanion(
                id: id,
                name: name,
                artistId: artistId,
                artist: artist,
                canonicalArtist: canonicalArtist,
                year: year,
                songCount: songCount,
                duration: duration,
                playCount: playCount,
                coverArt: coverArt,
                starred: starred,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> artistId = const Value.absent(),
                required String artist,
                Value<String> canonicalArtist = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<int> songCount = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<String?> coverArt = const Value.absent(),
                Value<bool> starred = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StagedAlbumsCompanion.insert(
                id: id,
                name: name,
                artistId: artistId,
                artist: artist,
                canonicalArtist: canonicalArtist,
                year: year,
                songCount: songCount,
                duration: duration,
                playCount: playCount,
                coverArt: coverArt,
                starred: starred,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StagedAlbumsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StagedAlbumsTable,
      StagedAlbum,
      $$StagedAlbumsTableFilterComposer,
      $$StagedAlbumsTableOrderingComposer,
      $$StagedAlbumsTableAnnotationComposer,
      $$StagedAlbumsTableCreateCompanionBuilder,
      $$StagedAlbumsTableUpdateCompanionBuilder,
      (
        StagedAlbum,
        BaseReferences<_$AppDatabase, $StagedAlbumsTable, StagedAlbum>,
      ),
      StagedAlbum,
      PrefetchHooks Function()
    >;
typedef $$LocalSongsTableCreateCompanionBuilder =
    LocalSongsCompanion Function({
      required String id,
      required String title,
      Value<String?> albumId,
      required String album,
      Value<String?> artistId,
      required String artist,
      Value<String> canonicalArtist,
      Value<int> track,
      Value<int> disc,
      Value<int> year,
      Value<String?> genre,
      Value<int> duration,
      Value<int?> bitRate,
      Value<int?> bitDepth,
      Value<int?> samplingRate,
      Value<String?> suffix,
      Value<String?> contentType,
      Value<int?> fileSize,
      Value<String?> coverArt,
      Value<int> playCount,
      Value<bool> starred,
      Value<DateTime?> starredAt,
      Value<DateTime?> createdAt,
      Value<DateTime?> lastPlayedAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$LocalSongsTableUpdateCompanionBuilder =
    LocalSongsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> albumId,
      Value<String> album,
      Value<String?> artistId,
      Value<String> artist,
      Value<String> canonicalArtist,
      Value<int> track,
      Value<int> disc,
      Value<int> year,
      Value<String?> genre,
      Value<int> duration,
      Value<int?> bitRate,
      Value<int?> bitDepth,
      Value<int?> samplingRate,
      Value<String?> suffix,
      Value<String?> contentType,
      Value<int?> fileSize,
      Value<String?> coverArt,
      Value<int> playCount,
      Value<bool> starred,
      Value<DateTime?> starredAt,
      Value<DateTime?> createdAt,
      Value<DateTime?> lastPlayedAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$LocalSongsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSongsTable> {
  $$LocalSongsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get albumId => $composableBuilder(
    column: $table.albumId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistId => $composableBuilder(
    column: $table.artistId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get canonicalArtist => $composableBuilder(
    column: $table.canonicalArtist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get track => $composableBuilder(
    column: $table.track,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get disc => $composableBuilder(
    column: $table.disc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bitRate => $composableBuilder(
    column: $table.bitRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bitDepth => $composableBuilder(
    column: $table.bitDepth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get samplingRate => $composableBuilder(
    column: $table.samplingRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get suffix => $composableBuilder(
    column: $table.suffix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverArt => $composableBuilder(
    column: $table.coverArt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get starred => $composableBuilder(
    column: $table.starred,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get starredAt => $composableBuilder(
    column: $table.starredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalSongsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSongsTable> {
  $$LocalSongsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get albumId => $composableBuilder(
    column: $table.albumId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistId => $composableBuilder(
    column: $table.artistId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get canonicalArtist => $composableBuilder(
    column: $table.canonicalArtist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get track => $composableBuilder(
    column: $table.track,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get disc => $composableBuilder(
    column: $table.disc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bitRate => $composableBuilder(
    column: $table.bitRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bitDepth => $composableBuilder(
    column: $table.bitDepth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get samplingRate => $composableBuilder(
    column: $table.samplingRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get suffix => $composableBuilder(
    column: $table.suffix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverArt => $composableBuilder(
    column: $table.coverArt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get starred => $composableBuilder(
    column: $table.starred,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get starredAt => $composableBuilder(
    column: $table.starredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalSongsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSongsTable> {
  $$LocalSongsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get albumId =>
      $composableBuilder(column: $table.albumId, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<String> get artistId =>
      $composableBuilder(column: $table.artistId, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get canonicalArtist => $composableBuilder(
    column: $table.canonicalArtist,
    builder: (column) => column,
  );

  GeneratedColumn<int> get track =>
      $composableBuilder(column: $table.track, builder: (column) => column);

  GeneratedColumn<int> get disc =>
      $composableBuilder(column: $table.disc, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<int> get bitRate =>
      $composableBuilder(column: $table.bitRate, builder: (column) => column);

  GeneratedColumn<int> get bitDepth =>
      $composableBuilder(column: $table.bitDepth, builder: (column) => column);

  GeneratedColumn<int> get samplingRate => $composableBuilder(
    column: $table.samplingRate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get suffix =>
      $composableBuilder(column: $table.suffix, builder: (column) => column);

  GeneratedColumn<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<String> get coverArt =>
      $composableBuilder(column: $table.coverArt, builder: (column) => column);

  GeneratedColumn<int> get playCount =>
      $composableBuilder(column: $table.playCount, builder: (column) => column);

  GeneratedColumn<bool> get starred =>
      $composableBuilder(column: $table.starred, builder: (column) => column);

  GeneratedColumn<DateTime> get starredAt =>
      $composableBuilder(column: $table.starredAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalSongsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSongsTable,
          LocalSong,
          $$LocalSongsTableFilterComposer,
          $$LocalSongsTableOrderingComposer,
          $$LocalSongsTableAnnotationComposer,
          $$LocalSongsTableCreateCompanionBuilder,
          $$LocalSongsTableUpdateCompanionBuilder,
          (
            LocalSong,
            BaseReferences<_$AppDatabase, $LocalSongsTable, LocalSong>,
          ),
          LocalSong,
          PrefetchHooks Function()
        > {
  $$LocalSongsTableTableManager(_$AppDatabase db, $LocalSongsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSongsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSongsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalSongsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> albumId = const Value.absent(),
                Value<String> album = const Value.absent(),
                Value<String?> artistId = const Value.absent(),
                Value<String> artist = const Value.absent(),
                Value<String> canonicalArtist = const Value.absent(),
                Value<int> track = const Value.absent(),
                Value<int> disc = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<int?> bitRate = const Value.absent(),
                Value<int?> bitDepth = const Value.absent(),
                Value<int?> samplingRate = const Value.absent(),
                Value<String?> suffix = const Value.absent(),
                Value<String?> contentType = const Value.absent(),
                Value<int?> fileSize = const Value.absent(),
                Value<String?> coverArt = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<bool> starred = const Value.absent(),
                Value<DateTime?> starredAt = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> lastPlayedAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSongsCompanion(
                id: id,
                title: title,
                albumId: albumId,
                album: album,
                artistId: artistId,
                artist: artist,
                canonicalArtist: canonicalArtist,
                track: track,
                disc: disc,
                year: year,
                genre: genre,
                duration: duration,
                bitRate: bitRate,
                bitDepth: bitDepth,
                samplingRate: samplingRate,
                suffix: suffix,
                contentType: contentType,
                fileSize: fileSize,
                coverArt: coverArt,
                playCount: playCount,
                starred: starred,
                starredAt: starredAt,
                createdAt: createdAt,
                lastPlayedAt: lastPlayedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> albumId = const Value.absent(),
                required String album,
                Value<String?> artistId = const Value.absent(),
                required String artist,
                Value<String> canonicalArtist = const Value.absent(),
                Value<int> track = const Value.absent(),
                Value<int> disc = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<int?> bitRate = const Value.absent(),
                Value<int?> bitDepth = const Value.absent(),
                Value<int?> samplingRate = const Value.absent(),
                Value<String?> suffix = const Value.absent(),
                Value<String?> contentType = const Value.absent(),
                Value<int?> fileSize = const Value.absent(),
                Value<String?> coverArt = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<bool> starred = const Value.absent(),
                Value<DateTime?> starredAt = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> lastPlayedAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSongsCompanion.insert(
                id: id,
                title: title,
                albumId: albumId,
                album: album,
                artistId: artistId,
                artist: artist,
                canonicalArtist: canonicalArtist,
                track: track,
                disc: disc,
                year: year,
                genre: genre,
                duration: duration,
                bitRate: bitRate,
                bitDepth: bitDepth,
                samplingRate: samplingRate,
                suffix: suffix,
                contentType: contentType,
                fileSize: fileSize,
                coverArt: coverArt,
                playCount: playCount,
                starred: starred,
                starredAt: starredAt,
                createdAt: createdAt,
                lastPlayedAt: lastPlayedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalSongsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSongsTable,
      LocalSong,
      $$LocalSongsTableFilterComposer,
      $$LocalSongsTableOrderingComposer,
      $$LocalSongsTableAnnotationComposer,
      $$LocalSongsTableCreateCompanionBuilder,
      $$LocalSongsTableUpdateCompanionBuilder,
      (LocalSong, BaseReferences<_$AppDatabase, $LocalSongsTable, LocalSong>),
      LocalSong,
      PrefetchHooks Function()
    >;
typedef $$StagedSongsTableCreateCompanionBuilder =
    StagedSongsCompanion Function({
      required String id,
      required String title,
      Value<String?> albumId,
      required String album,
      Value<String?> artistId,
      required String artist,
      Value<String> canonicalArtist,
      Value<int> track,
      Value<int> disc,
      Value<int> year,
      Value<String?> genre,
      Value<int> duration,
      Value<int?> bitRate,
      Value<int?> bitDepth,
      Value<int?> samplingRate,
      Value<String?> suffix,
      Value<String?> contentType,
      Value<int?> fileSize,
      Value<String?> coverArt,
      Value<int> playCount,
      Value<bool> starred,
      Value<DateTime?> starredAt,
      Value<DateTime?> createdAt,
      Value<DateTime?> lastPlayedAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$StagedSongsTableUpdateCompanionBuilder =
    StagedSongsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> albumId,
      Value<String> album,
      Value<String?> artistId,
      Value<String> artist,
      Value<String> canonicalArtist,
      Value<int> track,
      Value<int> disc,
      Value<int> year,
      Value<String?> genre,
      Value<int> duration,
      Value<int?> bitRate,
      Value<int?> bitDepth,
      Value<int?> samplingRate,
      Value<String?> suffix,
      Value<String?> contentType,
      Value<int?> fileSize,
      Value<String?> coverArt,
      Value<int> playCount,
      Value<bool> starred,
      Value<DateTime?> starredAt,
      Value<DateTime?> createdAt,
      Value<DateTime?> lastPlayedAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$StagedSongsTableFilterComposer
    extends Composer<_$AppDatabase, $StagedSongsTable> {
  $$StagedSongsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get albumId => $composableBuilder(
    column: $table.albumId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistId => $composableBuilder(
    column: $table.artistId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get canonicalArtist => $composableBuilder(
    column: $table.canonicalArtist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get track => $composableBuilder(
    column: $table.track,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get disc => $composableBuilder(
    column: $table.disc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bitRate => $composableBuilder(
    column: $table.bitRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bitDepth => $composableBuilder(
    column: $table.bitDepth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get samplingRate => $composableBuilder(
    column: $table.samplingRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get suffix => $composableBuilder(
    column: $table.suffix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverArt => $composableBuilder(
    column: $table.coverArt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get starred => $composableBuilder(
    column: $table.starred,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get starredAt => $composableBuilder(
    column: $table.starredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StagedSongsTableOrderingComposer
    extends Composer<_$AppDatabase, $StagedSongsTable> {
  $$StagedSongsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get albumId => $composableBuilder(
    column: $table.albumId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistId => $composableBuilder(
    column: $table.artistId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get canonicalArtist => $composableBuilder(
    column: $table.canonicalArtist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get track => $composableBuilder(
    column: $table.track,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get disc => $composableBuilder(
    column: $table.disc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bitRate => $composableBuilder(
    column: $table.bitRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bitDepth => $composableBuilder(
    column: $table.bitDepth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get samplingRate => $composableBuilder(
    column: $table.samplingRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get suffix => $composableBuilder(
    column: $table.suffix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverArt => $composableBuilder(
    column: $table.coverArt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get starred => $composableBuilder(
    column: $table.starred,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get starredAt => $composableBuilder(
    column: $table.starredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StagedSongsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StagedSongsTable> {
  $$StagedSongsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get albumId =>
      $composableBuilder(column: $table.albumId, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<String> get artistId =>
      $composableBuilder(column: $table.artistId, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get canonicalArtist => $composableBuilder(
    column: $table.canonicalArtist,
    builder: (column) => column,
  );

  GeneratedColumn<int> get track =>
      $composableBuilder(column: $table.track, builder: (column) => column);

  GeneratedColumn<int> get disc =>
      $composableBuilder(column: $table.disc, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<int> get bitRate =>
      $composableBuilder(column: $table.bitRate, builder: (column) => column);

  GeneratedColumn<int> get bitDepth =>
      $composableBuilder(column: $table.bitDepth, builder: (column) => column);

  GeneratedColumn<int> get samplingRate => $composableBuilder(
    column: $table.samplingRate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get suffix =>
      $composableBuilder(column: $table.suffix, builder: (column) => column);

  GeneratedColumn<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<String> get coverArt =>
      $composableBuilder(column: $table.coverArt, builder: (column) => column);

  GeneratedColumn<int> get playCount =>
      $composableBuilder(column: $table.playCount, builder: (column) => column);

  GeneratedColumn<bool> get starred =>
      $composableBuilder(column: $table.starred, builder: (column) => column);

  GeneratedColumn<DateTime> get starredAt =>
      $composableBuilder(column: $table.starredAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$StagedSongsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StagedSongsTable,
          StagedSong,
          $$StagedSongsTableFilterComposer,
          $$StagedSongsTableOrderingComposer,
          $$StagedSongsTableAnnotationComposer,
          $$StagedSongsTableCreateCompanionBuilder,
          $$StagedSongsTableUpdateCompanionBuilder,
          (
            StagedSong,
            BaseReferences<_$AppDatabase, $StagedSongsTable, StagedSong>,
          ),
          StagedSong,
          PrefetchHooks Function()
        > {
  $$StagedSongsTableTableManager(_$AppDatabase db, $StagedSongsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StagedSongsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StagedSongsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StagedSongsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> albumId = const Value.absent(),
                Value<String> album = const Value.absent(),
                Value<String?> artistId = const Value.absent(),
                Value<String> artist = const Value.absent(),
                Value<String> canonicalArtist = const Value.absent(),
                Value<int> track = const Value.absent(),
                Value<int> disc = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<int?> bitRate = const Value.absent(),
                Value<int?> bitDepth = const Value.absent(),
                Value<int?> samplingRate = const Value.absent(),
                Value<String?> suffix = const Value.absent(),
                Value<String?> contentType = const Value.absent(),
                Value<int?> fileSize = const Value.absent(),
                Value<String?> coverArt = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<bool> starred = const Value.absent(),
                Value<DateTime?> starredAt = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> lastPlayedAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StagedSongsCompanion(
                id: id,
                title: title,
                albumId: albumId,
                album: album,
                artistId: artistId,
                artist: artist,
                canonicalArtist: canonicalArtist,
                track: track,
                disc: disc,
                year: year,
                genre: genre,
                duration: duration,
                bitRate: bitRate,
                bitDepth: bitDepth,
                samplingRate: samplingRate,
                suffix: suffix,
                contentType: contentType,
                fileSize: fileSize,
                coverArt: coverArt,
                playCount: playCount,
                starred: starred,
                starredAt: starredAt,
                createdAt: createdAt,
                lastPlayedAt: lastPlayedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> albumId = const Value.absent(),
                required String album,
                Value<String?> artistId = const Value.absent(),
                required String artist,
                Value<String> canonicalArtist = const Value.absent(),
                Value<int> track = const Value.absent(),
                Value<int> disc = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<int?> bitRate = const Value.absent(),
                Value<int?> bitDepth = const Value.absent(),
                Value<int?> samplingRate = const Value.absent(),
                Value<String?> suffix = const Value.absent(),
                Value<String?> contentType = const Value.absent(),
                Value<int?> fileSize = const Value.absent(),
                Value<String?> coverArt = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<bool> starred = const Value.absent(),
                Value<DateTime?> starredAt = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> lastPlayedAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StagedSongsCompanion.insert(
                id: id,
                title: title,
                albumId: albumId,
                album: album,
                artistId: artistId,
                artist: artist,
                canonicalArtist: canonicalArtist,
                track: track,
                disc: disc,
                year: year,
                genre: genre,
                duration: duration,
                bitRate: bitRate,
                bitDepth: bitDepth,
                samplingRate: samplingRate,
                suffix: suffix,
                contentType: contentType,
                fileSize: fileSize,
                coverArt: coverArt,
                playCount: playCount,
                starred: starred,
                starredAt: starredAt,
                createdAt: createdAt,
                lastPlayedAt: lastPlayedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StagedSongsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StagedSongsTable,
      StagedSong,
      $$StagedSongsTableFilterComposer,
      $$StagedSongsTableOrderingComposer,
      $$StagedSongsTableAnnotationComposer,
      $$StagedSongsTableCreateCompanionBuilder,
      $$StagedSongsTableUpdateCompanionBuilder,
      (
        StagedSong,
        BaseReferences<_$AppDatabase, $StagedSongsTable, StagedSong>,
      ),
      StagedSong,
      PrefetchHooks Function()
    >;
typedef $$LocalPlaylistsTableCreateCompanionBuilder =
    LocalPlaylistsCompanion Function({
      required String id,
      required String name,
      Value<String?> coverArt,
      Value<int> songCount,
      Value<int> duration,
      Value<bool> serverReadOnly,
      Value<String> owner,
      Value<bool> isPublic,
      Value<bool> isGenerated,
      Value<DateTime?> changedAt,
      Value<int> rowid,
    });
typedef $$LocalPlaylistsTableUpdateCompanionBuilder =
    LocalPlaylistsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> coverArt,
      Value<int> songCount,
      Value<int> duration,
      Value<bool> serverReadOnly,
      Value<String> owner,
      Value<bool> isPublic,
      Value<bool> isGenerated,
      Value<DateTime?> changedAt,
      Value<int> rowid,
    });

class $$LocalPlaylistsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalPlaylistsTable> {
  $$LocalPlaylistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverArt => $composableBuilder(
    column: $table.coverArt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get songCount => $composableBuilder(
    column: $table.songCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get serverReadOnly => $composableBuilder(
    column: $table.serverReadOnly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPublic => $composableBuilder(
    column: $table.isPublic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isGenerated => $composableBuilder(
    column: $table.isGenerated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalPlaylistsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalPlaylistsTable> {
  $$LocalPlaylistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverArt => $composableBuilder(
    column: $table.coverArt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get songCount => $composableBuilder(
    column: $table.songCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get serverReadOnly => $composableBuilder(
    column: $table.serverReadOnly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPublic => $composableBuilder(
    column: $table.isPublic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isGenerated => $composableBuilder(
    column: $table.isGenerated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalPlaylistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalPlaylistsTable> {
  $$LocalPlaylistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get coverArt =>
      $composableBuilder(column: $table.coverArt, builder: (column) => column);

  GeneratedColumn<int> get songCount =>
      $composableBuilder(column: $table.songCount, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<bool> get serverReadOnly => $composableBuilder(
    column: $table.serverReadOnly,
    builder: (column) => column,
  );

  GeneratedColumn<String> get owner =>
      $composableBuilder(column: $table.owner, builder: (column) => column);

  GeneratedColumn<bool> get isPublic =>
      $composableBuilder(column: $table.isPublic, builder: (column) => column);

  GeneratedColumn<bool> get isGenerated => $composableBuilder(
    column: $table.isGenerated,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get changedAt =>
      $composableBuilder(column: $table.changedAt, builder: (column) => column);
}

class $$LocalPlaylistsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalPlaylistsTable,
          LocalPlaylist,
          $$LocalPlaylistsTableFilterComposer,
          $$LocalPlaylistsTableOrderingComposer,
          $$LocalPlaylistsTableAnnotationComposer,
          $$LocalPlaylistsTableCreateCompanionBuilder,
          $$LocalPlaylistsTableUpdateCompanionBuilder,
          (
            LocalPlaylist,
            BaseReferences<_$AppDatabase, $LocalPlaylistsTable, LocalPlaylist>,
          ),
          LocalPlaylist,
          PrefetchHooks Function()
        > {
  $$LocalPlaylistsTableTableManager(
    _$AppDatabase db,
    $LocalPlaylistsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalPlaylistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalPlaylistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalPlaylistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> coverArt = const Value.absent(),
                Value<int> songCount = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<bool> serverReadOnly = const Value.absent(),
                Value<String> owner = const Value.absent(),
                Value<bool> isPublic = const Value.absent(),
                Value<bool> isGenerated = const Value.absent(),
                Value<DateTime?> changedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPlaylistsCompanion(
                id: id,
                name: name,
                coverArt: coverArt,
                songCount: songCount,
                duration: duration,
                serverReadOnly: serverReadOnly,
                owner: owner,
                isPublic: isPublic,
                isGenerated: isGenerated,
                changedAt: changedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> coverArt = const Value.absent(),
                Value<int> songCount = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<bool> serverReadOnly = const Value.absent(),
                Value<String> owner = const Value.absent(),
                Value<bool> isPublic = const Value.absent(),
                Value<bool> isGenerated = const Value.absent(),
                Value<DateTime?> changedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPlaylistsCompanion.insert(
                id: id,
                name: name,
                coverArt: coverArt,
                songCount: songCount,
                duration: duration,
                serverReadOnly: serverReadOnly,
                owner: owner,
                isPublic: isPublic,
                isGenerated: isGenerated,
                changedAt: changedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalPlaylistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalPlaylistsTable,
      LocalPlaylist,
      $$LocalPlaylistsTableFilterComposer,
      $$LocalPlaylistsTableOrderingComposer,
      $$LocalPlaylistsTableAnnotationComposer,
      $$LocalPlaylistsTableCreateCompanionBuilder,
      $$LocalPlaylistsTableUpdateCompanionBuilder,
      (
        LocalPlaylist,
        BaseReferences<_$AppDatabase, $LocalPlaylistsTable, LocalPlaylist>,
      ),
      LocalPlaylist,
      PrefetchHooks Function()
    >;
typedef $$StagedPlaylistsTableCreateCompanionBuilder =
    StagedPlaylistsCompanion Function({
      required String id,
      required String name,
      Value<String?> coverArt,
      Value<int> songCount,
      Value<int> duration,
      Value<bool> serverReadOnly,
      Value<String> owner,
      Value<bool> isPublic,
      Value<bool> isGenerated,
      Value<DateTime?> changedAt,
      Value<int> rowid,
    });
typedef $$StagedPlaylistsTableUpdateCompanionBuilder =
    StagedPlaylistsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> coverArt,
      Value<int> songCount,
      Value<int> duration,
      Value<bool> serverReadOnly,
      Value<String> owner,
      Value<bool> isPublic,
      Value<bool> isGenerated,
      Value<DateTime?> changedAt,
      Value<int> rowid,
    });

class $$StagedPlaylistsTableFilterComposer
    extends Composer<_$AppDatabase, $StagedPlaylistsTable> {
  $$StagedPlaylistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverArt => $composableBuilder(
    column: $table.coverArt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get songCount => $composableBuilder(
    column: $table.songCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get serverReadOnly => $composableBuilder(
    column: $table.serverReadOnly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPublic => $composableBuilder(
    column: $table.isPublic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isGenerated => $composableBuilder(
    column: $table.isGenerated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StagedPlaylistsTableOrderingComposer
    extends Composer<_$AppDatabase, $StagedPlaylistsTable> {
  $$StagedPlaylistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverArt => $composableBuilder(
    column: $table.coverArt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get songCount => $composableBuilder(
    column: $table.songCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get serverReadOnly => $composableBuilder(
    column: $table.serverReadOnly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPublic => $composableBuilder(
    column: $table.isPublic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isGenerated => $composableBuilder(
    column: $table.isGenerated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StagedPlaylistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StagedPlaylistsTable> {
  $$StagedPlaylistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get coverArt =>
      $composableBuilder(column: $table.coverArt, builder: (column) => column);

  GeneratedColumn<int> get songCount =>
      $composableBuilder(column: $table.songCount, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<bool> get serverReadOnly => $composableBuilder(
    column: $table.serverReadOnly,
    builder: (column) => column,
  );

  GeneratedColumn<String> get owner =>
      $composableBuilder(column: $table.owner, builder: (column) => column);

  GeneratedColumn<bool> get isPublic =>
      $composableBuilder(column: $table.isPublic, builder: (column) => column);

  GeneratedColumn<bool> get isGenerated => $composableBuilder(
    column: $table.isGenerated,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get changedAt =>
      $composableBuilder(column: $table.changedAt, builder: (column) => column);
}

class $$StagedPlaylistsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StagedPlaylistsTable,
          StagedPlaylist,
          $$StagedPlaylistsTableFilterComposer,
          $$StagedPlaylistsTableOrderingComposer,
          $$StagedPlaylistsTableAnnotationComposer,
          $$StagedPlaylistsTableCreateCompanionBuilder,
          $$StagedPlaylistsTableUpdateCompanionBuilder,
          (
            StagedPlaylist,
            BaseReferences<
              _$AppDatabase,
              $StagedPlaylistsTable,
              StagedPlaylist
            >,
          ),
          StagedPlaylist,
          PrefetchHooks Function()
        > {
  $$StagedPlaylistsTableTableManager(
    _$AppDatabase db,
    $StagedPlaylistsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StagedPlaylistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StagedPlaylistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StagedPlaylistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> coverArt = const Value.absent(),
                Value<int> songCount = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<bool> serverReadOnly = const Value.absent(),
                Value<String> owner = const Value.absent(),
                Value<bool> isPublic = const Value.absent(),
                Value<bool> isGenerated = const Value.absent(),
                Value<DateTime?> changedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StagedPlaylistsCompanion(
                id: id,
                name: name,
                coverArt: coverArt,
                songCount: songCount,
                duration: duration,
                serverReadOnly: serverReadOnly,
                owner: owner,
                isPublic: isPublic,
                isGenerated: isGenerated,
                changedAt: changedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> coverArt = const Value.absent(),
                Value<int> songCount = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<bool> serverReadOnly = const Value.absent(),
                Value<String> owner = const Value.absent(),
                Value<bool> isPublic = const Value.absent(),
                Value<bool> isGenerated = const Value.absent(),
                Value<DateTime?> changedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StagedPlaylistsCompanion.insert(
                id: id,
                name: name,
                coverArt: coverArt,
                songCount: songCount,
                duration: duration,
                serverReadOnly: serverReadOnly,
                owner: owner,
                isPublic: isPublic,
                isGenerated: isGenerated,
                changedAt: changedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StagedPlaylistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StagedPlaylistsTable,
      StagedPlaylist,
      $$StagedPlaylistsTableFilterComposer,
      $$StagedPlaylistsTableOrderingComposer,
      $$StagedPlaylistsTableAnnotationComposer,
      $$StagedPlaylistsTableCreateCompanionBuilder,
      $$StagedPlaylistsTableUpdateCompanionBuilder,
      (
        StagedPlaylist,
        BaseReferences<_$AppDatabase, $StagedPlaylistsTable, StagedPlaylist>,
      ),
      StagedPlaylist,
      PrefetchHooks Function()
    >;
typedef $$LocalPlaylistEntriesTableCreateCompanionBuilder =
    LocalPlaylistEntriesCompanion Function({
      required String playlistId,
      required String songId,
      required int position,
      Value<int> rowid,
    });
typedef $$LocalPlaylistEntriesTableUpdateCompanionBuilder =
    LocalPlaylistEntriesCompanion Function({
      Value<String> playlistId,
      Value<String> songId,
      Value<int> position,
      Value<int> rowid,
    });

class $$LocalPlaylistEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalPlaylistEntriesTable> {
  $$LocalPlaylistEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get playlistId => $composableBuilder(
    column: $table.playlistId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalPlaylistEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalPlaylistEntriesTable> {
  $$LocalPlaylistEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get playlistId => $composableBuilder(
    column: $table.playlistId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalPlaylistEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalPlaylistEntriesTable> {
  $$LocalPlaylistEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get playlistId => $composableBuilder(
    column: $table.playlistId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get songId =>
      $composableBuilder(column: $table.songId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$LocalPlaylistEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalPlaylistEntriesTable,
          LocalPlaylistEntry,
          $$LocalPlaylistEntriesTableFilterComposer,
          $$LocalPlaylistEntriesTableOrderingComposer,
          $$LocalPlaylistEntriesTableAnnotationComposer,
          $$LocalPlaylistEntriesTableCreateCompanionBuilder,
          $$LocalPlaylistEntriesTableUpdateCompanionBuilder,
          (
            LocalPlaylistEntry,
            BaseReferences<
              _$AppDatabase,
              $LocalPlaylistEntriesTable,
              LocalPlaylistEntry
            >,
          ),
          LocalPlaylistEntry,
          PrefetchHooks Function()
        > {
  $$LocalPlaylistEntriesTableTableManager(
    _$AppDatabase db,
    $LocalPlaylistEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalPlaylistEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalPlaylistEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalPlaylistEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> playlistId = const Value.absent(),
                Value<String> songId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPlaylistEntriesCompanion(
                playlistId: playlistId,
                songId: songId,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String playlistId,
                required String songId,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => LocalPlaylistEntriesCompanion.insert(
                playlistId: playlistId,
                songId: songId,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalPlaylistEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalPlaylistEntriesTable,
      LocalPlaylistEntry,
      $$LocalPlaylistEntriesTableFilterComposer,
      $$LocalPlaylistEntriesTableOrderingComposer,
      $$LocalPlaylistEntriesTableAnnotationComposer,
      $$LocalPlaylistEntriesTableCreateCompanionBuilder,
      $$LocalPlaylistEntriesTableUpdateCompanionBuilder,
      (
        LocalPlaylistEntry,
        BaseReferences<
          _$AppDatabase,
          $LocalPlaylistEntriesTable,
          LocalPlaylistEntry
        >,
      ),
      LocalPlaylistEntry,
      PrefetchHooks Function()
    >;
typedef $$StagedPlaylistEntriesTableCreateCompanionBuilder =
    StagedPlaylistEntriesCompanion Function({
      required String playlistId,
      required String songId,
      required int position,
      Value<int> rowid,
    });
typedef $$StagedPlaylistEntriesTableUpdateCompanionBuilder =
    StagedPlaylistEntriesCompanion Function({
      Value<String> playlistId,
      Value<String> songId,
      Value<int> position,
      Value<int> rowid,
    });

class $$StagedPlaylistEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $StagedPlaylistEntriesTable> {
  $$StagedPlaylistEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get playlistId => $composableBuilder(
    column: $table.playlistId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StagedPlaylistEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $StagedPlaylistEntriesTable> {
  $$StagedPlaylistEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get playlistId => $composableBuilder(
    column: $table.playlistId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StagedPlaylistEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StagedPlaylistEntriesTable> {
  $$StagedPlaylistEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get playlistId => $composableBuilder(
    column: $table.playlistId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get songId =>
      $composableBuilder(column: $table.songId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$StagedPlaylistEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StagedPlaylistEntriesTable,
          StagedPlaylistEntry,
          $$StagedPlaylistEntriesTableFilterComposer,
          $$StagedPlaylistEntriesTableOrderingComposer,
          $$StagedPlaylistEntriesTableAnnotationComposer,
          $$StagedPlaylistEntriesTableCreateCompanionBuilder,
          $$StagedPlaylistEntriesTableUpdateCompanionBuilder,
          (
            StagedPlaylistEntry,
            BaseReferences<
              _$AppDatabase,
              $StagedPlaylistEntriesTable,
              StagedPlaylistEntry
            >,
          ),
          StagedPlaylistEntry,
          PrefetchHooks Function()
        > {
  $$StagedPlaylistEntriesTableTableManager(
    _$AppDatabase db,
    $StagedPlaylistEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StagedPlaylistEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$StagedPlaylistEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$StagedPlaylistEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> playlistId = const Value.absent(),
                Value<String> songId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StagedPlaylistEntriesCompanion(
                playlistId: playlistId,
                songId: songId,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String playlistId,
                required String songId,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => StagedPlaylistEntriesCompanion.insert(
                playlistId: playlistId,
                songId: songId,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StagedPlaylistEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StagedPlaylistEntriesTable,
      StagedPlaylistEntry,
      $$StagedPlaylistEntriesTableFilterComposer,
      $$StagedPlaylistEntriesTableOrderingComposer,
      $$StagedPlaylistEntriesTableAnnotationComposer,
      $$StagedPlaylistEntriesTableCreateCompanionBuilder,
      $$StagedPlaylistEntriesTableUpdateCompanionBuilder,
      (
        StagedPlaylistEntry,
        BaseReferences<
          _$AppDatabase,
          $StagedPlaylistEntriesTable,
          StagedPlaylistEntry
        >,
      ),
      StagedPlaylistEntry,
      PrefetchHooks Function()
    >;
typedef $$LocalFavoritesTableCreateCompanionBuilder =
    LocalFavoritesCompanion Function({
      required String entityType,
      required String entityId,
      Value<DateTime?> starredAt,
      Value<int> rowid,
    });
typedef $$LocalFavoritesTableUpdateCompanionBuilder =
    LocalFavoritesCompanion Function({
      Value<String> entityType,
      Value<String> entityId,
      Value<DateTime?> starredAt,
      Value<int> rowid,
    });

class $$LocalFavoritesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalFavoritesTable> {
  $$LocalFavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get starredAt => $composableBuilder(
    column: $table.starredAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalFavoritesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalFavoritesTable> {
  $$LocalFavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get starredAt => $composableBuilder(
    column: $table.starredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalFavoritesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalFavoritesTable> {
  $$LocalFavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<DateTime> get starredAt =>
      $composableBuilder(column: $table.starredAt, builder: (column) => column);
}

class $$LocalFavoritesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalFavoritesTable,
          LocalFavorite,
          $$LocalFavoritesTableFilterComposer,
          $$LocalFavoritesTableOrderingComposer,
          $$LocalFavoritesTableAnnotationComposer,
          $$LocalFavoritesTableCreateCompanionBuilder,
          $$LocalFavoritesTableUpdateCompanionBuilder,
          (
            LocalFavorite,
            BaseReferences<_$AppDatabase, $LocalFavoritesTable, LocalFavorite>,
          ),
          LocalFavorite,
          PrefetchHooks Function()
        > {
  $$LocalFavoritesTableTableManager(
    _$AppDatabase db,
    $LocalFavoritesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalFavoritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalFavoritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalFavoritesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<DateTime?> starredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalFavoritesCompanion(
                entityType: entityType,
                entityId: entityId,
                starredAt: starredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entityType,
                required String entityId,
                Value<DateTime?> starredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalFavoritesCompanion.insert(
                entityType: entityType,
                entityId: entityId,
                starredAt: starredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalFavoritesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalFavoritesTable,
      LocalFavorite,
      $$LocalFavoritesTableFilterComposer,
      $$LocalFavoritesTableOrderingComposer,
      $$LocalFavoritesTableAnnotationComposer,
      $$LocalFavoritesTableCreateCompanionBuilder,
      $$LocalFavoritesTableUpdateCompanionBuilder,
      (
        LocalFavorite,
        BaseReferences<_$AppDatabase, $LocalFavoritesTable, LocalFavorite>,
      ),
      LocalFavorite,
      PrefetchHooks Function()
    >;
typedef $$LocalInternetRadioStationsTableCreateCompanionBuilder =
    LocalInternetRadioStationsCompanion Function({
      required String id,
      required String name,
      required String streamUrl,
      Value<String?> homePageUrl,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalInternetRadioStationsTableUpdateCompanionBuilder =
    LocalInternetRadioStationsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> streamUrl,
      Value<String?> homePageUrl,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalInternetRadioStationsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalInternetRadioStationsTable> {
  $$LocalInternetRadioStationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get streamUrl => $composableBuilder(
    column: $table.streamUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get homePageUrl => $composableBuilder(
    column: $table.homePageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalInternetRadioStationsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalInternetRadioStationsTable> {
  $$LocalInternetRadioStationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get streamUrl => $composableBuilder(
    column: $table.streamUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get homePageUrl => $composableBuilder(
    column: $table.homePageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalInternetRadioStationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalInternetRadioStationsTable> {
  $$LocalInternetRadioStationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get streamUrl =>
      $composableBuilder(column: $table.streamUrl, builder: (column) => column);

  GeneratedColumn<String> get homePageUrl => $composableBuilder(
    column: $table.homePageUrl,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalInternetRadioStationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalInternetRadioStationsTable,
          LocalInternetRadioStation,
          $$LocalInternetRadioStationsTableFilterComposer,
          $$LocalInternetRadioStationsTableOrderingComposer,
          $$LocalInternetRadioStationsTableAnnotationComposer,
          $$LocalInternetRadioStationsTableCreateCompanionBuilder,
          $$LocalInternetRadioStationsTableUpdateCompanionBuilder,
          (
            LocalInternetRadioStation,
            BaseReferences<
              _$AppDatabase,
              $LocalInternetRadioStationsTable,
              LocalInternetRadioStation
            >,
          ),
          LocalInternetRadioStation,
          PrefetchHooks Function()
        > {
  $$LocalInternetRadioStationsTableTableManager(
    _$AppDatabase db,
    $LocalInternetRadioStationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalInternetRadioStationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalInternetRadioStationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalInternetRadioStationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> streamUrl = const Value.absent(),
                Value<String?> homePageUrl = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalInternetRadioStationsCompanion(
                id: id,
                name: name,
                streamUrl: streamUrl,
                homePageUrl: homePageUrl,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String streamUrl,
                Value<String?> homePageUrl = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalInternetRadioStationsCompanion.insert(
                id: id,
                name: name,
                streamUrl: streamUrl,
                homePageUrl: homePageUrl,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalInternetRadioStationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalInternetRadioStationsTable,
      LocalInternetRadioStation,
      $$LocalInternetRadioStationsTableFilterComposer,
      $$LocalInternetRadioStationsTableOrderingComposer,
      $$LocalInternetRadioStationsTableAnnotationComposer,
      $$LocalInternetRadioStationsTableCreateCompanionBuilder,
      $$LocalInternetRadioStationsTableUpdateCompanionBuilder,
      (
        LocalInternetRadioStation,
        BaseReferences<
          _$AppDatabase,
          $LocalInternetRadioStationsTable,
          LocalInternetRadioStation
        >,
      ),
      LocalInternetRadioStation,
      PrefetchHooks Function()
    >;
typedef $$SyncStatesTableCreateCompanionBuilder =
    SyncStatesCompanion Function({
      required String scope,
      Value<String?> cursor,
      Value<DateTime?> lastSuccessfulAt,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$SyncStatesTableUpdateCompanionBuilder =
    SyncStatesCompanion Function({
      Value<String> scope,
      Value<String?> cursor,
      Value<DateTime?> lastSuccessfulAt,
      Value<String?> lastError,
      Value<int> rowid,
    });

class $$SyncStatesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSuccessfulAt => $composableBuilder(
    column: $table.lastSuccessfulAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSuccessfulAt => $composableBuilder(
    column: $table.lastSuccessfulAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<String> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSuccessfulAt => $composableBuilder(
    column: $table.lastSuccessfulAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStatesTable,
          SyncState,
          $$SyncStatesTableFilterComposer,
          $$SyncStatesTableOrderingComposer,
          $$SyncStatesTableAnnotationComposer,
          $$SyncStatesTableCreateCompanionBuilder,
          $$SyncStatesTableUpdateCompanionBuilder,
          (
            SyncState,
            BaseReferences<_$AppDatabase, $SyncStatesTable, SyncState>,
          ),
          SyncState,
          PrefetchHooks Function()
        > {
  $$SyncStatesTableTableManager(_$AppDatabase db, $SyncStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> scope = const Value.absent(),
                Value<String?> cursor = const Value.absent(),
                Value<DateTime?> lastSuccessfulAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStatesCompanion(
                scope: scope,
                cursor: cursor,
                lastSuccessfulAt: lastSuccessfulAt,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String scope,
                Value<String?> cursor = const Value.absent(),
                Value<DateTime?> lastSuccessfulAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStatesCompanion.insert(
                scope: scope,
                cursor: cursor,
                lastSuccessfulAt: lastSuccessfulAt,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStatesTable,
      SyncState,
      $$SyncStatesTableFilterComposer,
      $$SyncStatesTableOrderingComposer,
      $$SyncStatesTableAnnotationComposer,
      $$SyncStatesTableCreateCompanionBuilder,
      $$SyncStatesTableUpdateCompanionBuilder,
      (SyncState, BaseReferences<_$AppDatabase, $SyncStatesTable, SyncState>),
      SyncState,
      PrefetchHooks Function()
    >;
typedef $$PendingMutationsTableCreateCompanionBuilder =
    PendingMutationsCompanion Function({
      Value<int> id,
      required String kind,
      required String entityId,
      required String payloadJson,
      required DateTime createdAt,
      Value<int> attemptCount,
      Value<String?> lastError,
    });
typedef $$PendingMutationsTableUpdateCompanionBuilder =
    PendingMutationsCompanion Function({
      Value<int> id,
      Value<String> kind,
      Value<String> entityId,
      Value<String> payloadJson,
      Value<DateTime> createdAt,
      Value<int> attemptCount,
      Value<String?> lastError,
    });

class $$PendingMutationsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingMutationsTable> {
  $$PendingMutationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingMutationsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingMutationsTable> {
  $$PendingMutationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingMutationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingMutationsTable> {
  $$PendingMutationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$PendingMutationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingMutationsTable,
          PendingMutation,
          $$PendingMutationsTableFilterComposer,
          $$PendingMutationsTableOrderingComposer,
          $$PendingMutationsTableAnnotationComposer,
          $$PendingMutationsTableCreateCompanionBuilder,
          $$PendingMutationsTableUpdateCompanionBuilder,
          (
            PendingMutation,
            BaseReferences<
              _$AppDatabase,
              $PendingMutationsTable,
              PendingMutation
            >,
          ),
          PendingMutation,
          PrefetchHooks Function()
        > {
  $$PendingMutationsTableTableManager(
    _$AppDatabase db,
    $PendingMutationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingMutationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingMutationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingMutationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => PendingMutationsCompanion(
                id: id,
                kind: kind,
                entityId: entityId,
                payloadJson: payloadJson,
                createdAt: createdAt,
                attemptCount: attemptCount,
                lastError: lastError,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String kind,
                required String entityId,
                required String payloadJson,
                required DateTime createdAt,
                Value<int> attemptCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => PendingMutationsCompanion.insert(
                id: id,
                kind: kind,
                entityId: entityId,
                payloadJson: payloadJson,
                createdAt: createdAt,
                attemptCount: attemptCount,
                lastError: lastError,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingMutationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingMutationsTable,
      PendingMutation,
      $$PendingMutationsTableFilterComposer,
      $$PendingMutationsTableOrderingComposer,
      $$PendingMutationsTableAnnotationComposer,
      $$PendingMutationsTableCreateCompanionBuilder,
      $$PendingMutationsTableUpdateCompanionBuilder,
      (
        PendingMutation,
        BaseReferences<_$AppDatabase, $PendingMutationsTable, PendingMutation>,
      ),
      PendingMutation,
      PrefetchHooks Function()
    >;
typedef $$LocalPlayEventsTableCreateCompanionBuilder =
    LocalPlayEventsCompanion Function({
      required String playbackId,
      required String songId,
      required DateTime startedAt,
      Value<int> durationMilliseconds,
      Value<DateTime?> scrobbledAt,
      Value<DateTime?> completedAt,
      Value<DateTime?> endedAt,
      Value<bool> skipped,
      Value<int> rowid,
    });
typedef $$LocalPlayEventsTableUpdateCompanionBuilder =
    LocalPlayEventsCompanion Function({
      Value<String> playbackId,
      Value<String> songId,
      Value<DateTime> startedAt,
      Value<int> durationMilliseconds,
      Value<DateTime?> scrobbledAt,
      Value<DateTime?> completedAt,
      Value<DateTime?> endedAt,
      Value<bool> skipped,
      Value<int> rowid,
    });

class $$LocalPlayEventsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalPlayEventsTable> {
  $$LocalPlayEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get playbackId => $composableBuilder(
    column: $table.playbackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMilliseconds => $composableBuilder(
    column: $table.durationMilliseconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scrobbledAt => $composableBuilder(
    column: $table.scrobbledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get skipped => $composableBuilder(
    column: $table.skipped,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalPlayEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalPlayEventsTable> {
  $$LocalPlayEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get playbackId => $composableBuilder(
    column: $table.playbackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMilliseconds => $composableBuilder(
    column: $table.durationMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scrobbledAt => $composableBuilder(
    column: $table.scrobbledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get skipped => $composableBuilder(
    column: $table.skipped,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalPlayEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalPlayEventsTable> {
  $$LocalPlayEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get playbackId => $composableBuilder(
    column: $table.playbackId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get songId =>
      $composableBuilder(column: $table.songId, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get durationMilliseconds => $composableBuilder(
    column: $table.durationMilliseconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get scrobbledAt => $composableBuilder(
    column: $table.scrobbledAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<bool> get skipped =>
      $composableBuilder(column: $table.skipped, builder: (column) => column);
}

class $$LocalPlayEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalPlayEventsTable,
          LocalPlayEvent,
          $$LocalPlayEventsTableFilterComposer,
          $$LocalPlayEventsTableOrderingComposer,
          $$LocalPlayEventsTableAnnotationComposer,
          $$LocalPlayEventsTableCreateCompanionBuilder,
          $$LocalPlayEventsTableUpdateCompanionBuilder,
          (
            LocalPlayEvent,
            BaseReferences<
              _$AppDatabase,
              $LocalPlayEventsTable,
              LocalPlayEvent
            >,
          ),
          LocalPlayEvent,
          PrefetchHooks Function()
        > {
  $$LocalPlayEventsTableTableManager(
    _$AppDatabase db,
    $LocalPlayEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalPlayEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalPlayEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalPlayEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> playbackId = const Value.absent(),
                Value<String> songId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<int> durationMilliseconds = const Value.absent(),
                Value<DateTime?> scrobbledAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<bool> skipped = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPlayEventsCompanion(
                playbackId: playbackId,
                songId: songId,
                startedAt: startedAt,
                durationMilliseconds: durationMilliseconds,
                scrobbledAt: scrobbledAt,
                completedAt: completedAt,
                endedAt: endedAt,
                skipped: skipped,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String playbackId,
                required String songId,
                required DateTime startedAt,
                Value<int> durationMilliseconds = const Value.absent(),
                Value<DateTime?> scrobbledAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<bool> skipped = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPlayEventsCompanion.insert(
                playbackId: playbackId,
                songId: songId,
                startedAt: startedAt,
                durationMilliseconds: durationMilliseconds,
                scrobbledAt: scrobbledAt,
                completedAt: completedAt,
                endedAt: endedAt,
                skipped: skipped,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalPlayEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalPlayEventsTable,
      LocalPlayEvent,
      $$LocalPlayEventsTableFilterComposer,
      $$LocalPlayEventsTableOrderingComposer,
      $$LocalPlayEventsTableAnnotationComposer,
      $$LocalPlayEventsTableCreateCompanionBuilder,
      $$LocalPlayEventsTableUpdateCompanionBuilder,
      (
        LocalPlayEvent,
        BaseReferences<_$AppDatabase, $LocalPlayEventsTable, LocalPlayEvent>,
      ),
      LocalPlayEvent,
      PrefetchHooks Function()
    >;
typedef $$LocalSongActivitiesTableCreateCompanionBuilder =
    LocalSongActivitiesCompanion Function({
      required String songId,
      Value<int> localPlayCount,
      Value<int> unacknowledgedPlayCount,
      Value<int> serverPlayCountSeen,
      Value<int> skipCount,
      Value<DateTime?> lastStartedAt,
      Value<DateTime?> lastPlayedAt,
      Value<DateTime?> lastCompletedAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalSongActivitiesTableUpdateCompanionBuilder =
    LocalSongActivitiesCompanion Function({
      Value<String> songId,
      Value<int> localPlayCount,
      Value<int> unacknowledgedPlayCount,
      Value<int> serverPlayCountSeen,
      Value<int> skipCount,
      Value<DateTime?> lastStartedAt,
      Value<DateTime?> lastPlayedAt,
      Value<DateTime?> lastCompletedAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalSongActivitiesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSongActivitiesTable> {
  $$LocalSongActivitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localPlayCount => $composableBuilder(
    column: $table.localPlayCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unacknowledgedPlayCount => $composableBuilder(
    column: $table.unacknowledgedPlayCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverPlayCountSeen => $composableBuilder(
    column: $table.serverPlayCountSeen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get skipCount => $composableBuilder(
    column: $table.skipCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastStartedAt => $composableBuilder(
    column: $table.lastStartedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastCompletedAt => $composableBuilder(
    column: $table.lastCompletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalSongActivitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSongActivitiesTable> {
  $$LocalSongActivitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localPlayCount => $composableBuilder(
    column: $table.localPlayCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unacknowledgedPlayCount => $composableBuilder(
    column: $table.unacknowledgedPlayCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverPlayCountSeen => $composableBuilder(
    column: $table.serverPlayCountSeen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skipCount => $composableBuilder(
    column: $table.skipCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastStartedAt => $composableBuilder(
    column: $table.lastStartedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastCompletedAt => $composableBuilder(
    column: $table.lastCompletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalSongActivitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSongActivitiesTable> {
  $$LocalSongActivitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get songId =>
      $composableBuilder(column: $table.songId, builder: (column) => column);

  GeneratedColumn<int> get localPlayCount => $composableBuilder(
    column: $table.localPlayCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unacknowledgedPlayCount => $composableBuilder(
    column: $table.unacknowledgedPlayCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverPlayCountSeen => $composableBuilder(
    column: $table.serverPlayCountSeen,
    builder: (column) => column,
  );

  GeneratedColumn<int> get skipCount =>
      $composableBuilder(column: $table.skipCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastStartedAt => $composableBuilder(
    column: $table.lastStartedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastCompletedAt => $composableBuilder(
    column: $table.lastCompletedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalSongActivitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSongActivitiesTable,
          LocalSongActivity,
          $$LocalSongActivitiesTableFilterComposer,
          $$LocalSongActivitiesTableOrderingComposer,
          $$LocalSongActivitiesTableAnnotationComposer,
          $$LocalSongActivitiesTableCreateCompanionBuilder,
          $$LocalSongActivitiesTableUpdateCompanionBuilder,
          (
            LocalSongActivity,
            BaseReferences<
              _$AppDatabase,
              $LocalSongActivitiesTable,
              LocalSongActivity
            >,
          ),
          LocalSongActivity,
          PrefetchHooks Function()
        > {
  $$LocalSongActivitiesTableTableManager(
    _$AppDatabase db,
    $LocalSongActivitiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSongActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSongActivitiesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalSongActivitiesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> songId = const Value.absent(),
                Value<int> localPlayCount = const Value.absent(),
                Value<int> unacknowledgedPlayCount = const Value.absent(),
                Value<int> serverPlayCountSeen = const Value.absent(),
                Value<int> skipCount = const Value.absent(),
                Value<DateTime?> lastStartedAt = const Value.absent(),
                Value<DateTime?> lastPlayedAt = const Value.absent(),
                Value<DateTime?> lastCompletedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSongActivitiesCompanion(
                songId: songId,
                localPlayCount: localPlayCount,
                unacknowledgedPlayCount: unacknowledgedPlayCount,
                serverPlayCountSeen: serverPlayCountSeen,
                skipCount: skipCount,
                lastStartedAt: lastStartedAt,
                lastPlayedAt: lastPlayedAt,
                lastCompletedAt: lastCompletedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String songId,
                Value<int> localPlayCount = const Value.absent(),
                Value<int> unacknowledgedPlayCount = const Value.absent(),
                Value<int> serverPlayCountSeen = const Value.absent(),
                Value<int> skipCount = const Value.absent(),
                Value<DateTime?> lastStartedAt = const Value.absent(),
                Value<DateTime?> lastPlayedAt = const Value.absent(),
                Value<DateTime?> lastCompletedAt = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalSongActivitiesCompanion.insert(
                songId: songId,
                localPlayCount: localPlayCount,
                unacknowledgedPlayCount: unacknowledgedPlayCount,
                serverPlayCountSeen: serverPlayCountSeen,
                skipCount: skipCount,
                lastStartedAt: lastStartedAt,
                lastPlayedAt: lastPlayedAt,
                lastCompletedAt: lastCompletedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalSongActivitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSongActivitiesTable,
      LocalSongActivity,
      $$LocalSongActivitiesTableFilterComposer,
      $$LocalSongActivitiesTableOrderingComposer,
      $$LocalSongActivitiesTableAnnotationComposer,
      $$LocalSongActivitiesTableCreateCompanionBuilder,
      $$LocalSongActivitiesTableUpdateCompanionBuilder,
      (
        LocalSongActivity,
        BaseReferences<
          _$AppDatabase,
          $LocalSongActivitiesTable,
          LocalSongActivity
        >,
      ),
      LocalSongActivity,
      PrefetchHooks Function()
    >;
typedef $$LocalQueueSessionsTableCreateCompanionBuilder =
    LocalQueueSessionsCompanion Function({
      required String id,
      Value<String?> currentEntryId,
      Value<bool> autoPlayEnabled,
      Value<int> positionMilliseconds,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalQueueSessionsTableUpdateCompanionBuilder =
    LocalQueueSessionsCompanion Function({
      Value<String> id,
      Value<String?> currentEntryId,
      Value<bool> autoPlayEnabled,
      Value<int> positionMilliseconds,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalQueueSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalQueueSessionsTable> {
  $$LocalQueueSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentEntryId => $composableBuilder(
    column: $table.currentEntryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoPlayEnabled => $composableBuilder(
    column: $table.autoPlayEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMilliseconds => $composableBuilder(
    column: $table.positionMilliseconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalQueueSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalQueueSessionsTable> {
  $$LocalQueueSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentEntryId => $composableBuilder(
    column: $table.currentEntryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoPlayEnabled => $composableBuilder(
    column: $table.autoPlayEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMilliseconds => $composableBuilder(
    column: $table.positionMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalQueueSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalQueueSessionsTable> {
  $$LocalQueueSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get currentEntryId => $composableBuilder(
    column: $table.currentEntryId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get autoPlayEnabled => $composableBuilder(
    column: $table.autoPlayEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get positionMilliseconds => $composableBuilder(
    column: $table.positionMilliseconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalQueueSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalQueueSessionsTable,
          LocalQueueSession,
          $$LocalQueueSessionsTableFilterComposer,
          $$LocalQueueSessionsTableOrderingComposer,
          $$LocalQueueSessionsTableAnnotationComposer,
          $$LocalQueueSessionsTableCreateCompanionBuilder,
          $$LocalQueueSessionsTableUpdateCompanionBuilder,
          (
            LocalQueueSession,
            BaseReferences<
              _$AppDatabase,
              $LocalQueueSessionsTable,
              LocalQueueSession
            >,
          ),
          LocalQueueSession,
          PrefetchHooks Function()
        > {
  $$LocalQueueSessionsTableTableManager(
    _$AppDatabase db,
    $LocalQueueSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalQueueSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalQueueSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalQueueSessionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> currentEntryId = const Value.absent(),
                Value<bool> autoPlayEnabled = const Value.absent(),
                Value<int> positionMilliseconds = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalQueueSessionsCompanion(
                id: id,
                currentEntryId: currentEntryId,
                autoPlayEnabled: autoPlayEnabled,
                positionMilliseconds: positionMilliseconds,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> currentEntryId = const Value.absent(),
                Value<bool> autoPlayEnabled = const Value.absent(),
                Value<int> positionMilliseconds = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalQueueSessionsCompanion.insert(
                id: id,
                currentEntryId: currentEntryId,
                autoPlayEnabled: autoPlayEnabled,
                positionMilliseconds: positionMilliseconds,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalQueueSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalQueueSessionsTable,
      LocalQueueSession,
      $$LocalQueueSessionsTableFilterComposer,
      $$LocalQueueSessionsTableOrderingComposer,
      $$LocalQueueSessionsTableAnnotationComposer,
      $$LocalQueueSessionsTableCreateCompanionBuilder,
      $$LocalQueueSessionsTableUpdateCompanionBuilder,
      (
        LocalQueueSession,
        BaseReferences<
          _$AppDatabase,
          $LocalQueueSessionsTable,
          LocalQueueSession
        >,
      ),
      LocalQueueSession,
      PrefetchHooks Function()
    >;
typedef $$LocalQueueEntriesTableCreateCompanionBuilder =
    LocalQueueEntriesCompanion Function({
      required String sessionId,
      required String entryId,
      required String songId,
      required int position,
      Value<int> rowid,
    });
typedef $$LocalQueueEntriesTableUpdateCompanionBuilder =
    LocalQueueEntriesCompanion Function({
      Value<String> sessionId,
      Value<String> entryId,
      Value<String> songId,
      Value<int> position,
      Value<int> rowid,
    });

class $$LocalQueueEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalQueueEntriesTable> {
  $$LocalQueueEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalQueueEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalQueueEntriesTable> {
  $$LocalQueueEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalQueueEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalQueueEntriesTable> {
  $$LocalQueueEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get entryId =>
      $composableBuilder(column: $table.entryId, builder: (column) => column);

  GeneratedColumn<String> get songId =>
      $composableBuilder(column: $table.songId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$LocalQueueEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalQueueEntriesTable,
          LocalQueueEntry,
          $$LocalQueueEntriesTableFilterComposer,
          $$LocalQueueEntriesTableOrderingComposer,
          $$LocalQueueEntriesTableAnnotationComposer,
          $$LocalQueueEntriesTableCreateCompanionBuilder,
          $$LocalQueueEntriesTableUpdateCompanionBuilder,
          (
            LocalQueueEntry,
            BaseReferences<
              _$AppDatabase,
              $LocalQueueEntriesTable,
              LocalQueueEntry
            >,
          ),
          LocalQueueEntry,
          PrefetchHooks Function()
        > {
  $$LocalQueueEntriesTableTableManager(
    _$AppDatabase db,
    $LocalQueueEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalQueueEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalQueueEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalQueueEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<String> entryId = const Value.absent(),
                Value<String> songId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalQueueEntriesCompanion(
                sessionId: sessionId,
                entryId: entryId,
                songId: songId,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                required String entryId,
                required String songId,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => LocalQueueEntriesCompanion.insert(
                sessionId: sessionId,
                entryId: entryId,
                songId: songId,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalQueueEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalQueueEntriesTable,
      LocalQueueEntry,
      $$LocalQueueEntriesTableFilterComposer,
      $$LocalQueueEntriesTableOrderingComposer,
      $$LocalQueueEntriesTableAnnotationComposer,
      $$LocalQueueEntriesTableCreateCompanionBuilder,
      $$LocalQueueEntriesTableUpdateCompanionBuilder,
      (
        LocalQueueEntry,
        BaseReferences<_$AppDatabase, $LocalQueueEntriesTable, LocalQueueEntry>,
      ),
      LocalQueueEntry,
      PrefetchHooks Function()
    >;
typedef $$SavedQueueSnapshotsTableCreateCompanionBuilder =
    SavedQueueSnapshotsCompanion Function({
      required String id,
      required String name,
      required int currentIndex,
      Value<bool> autoPlayEnabled,
      Value<int> positionMilliseconds,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SavedQueueSnapshotsTableUpdateCompanionBuilder =
    SavedQueueSnapshotsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> currentIndex,
      Value<bool> autoPlayEnabled,
      Value<int> positionMilliseconds,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SavedQueueSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $SavedQueueSnapshotsTable> {
  $$SavedQueueSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoPlayEnabled => $composableBuilder(
    column: $table.autoPlayEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMilliseconds => $composableBuilder(
    column: $table.positionMilliseconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavedQueueSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedQueueSnapshotsTable> {
  $$SavedQueueSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoPlayEnabled => $composableBuilder(
    column: $table.autoPlayEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMilliseconds => $composableBuilder(
    column: $table.positionMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavedQueueSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedQueueSnapshotsTable> {
  $$SavedQueueSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get autoPlayEnabled => $composableBuilder(
    column: $table.autoPlayEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get positionMilliseconds => $composableBuilder(
    column: $table.positionMilliseconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SavedQueueSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedQueueSnapshotsTable,
          SavedQueueSnapshot,
          $$SavedQueueSnapshotsTableFilterComposer,
          $$SavedQueueSnapshotsTableOrderingComposer,
          $$SavedQueueSnapshotsTableAnnotationComposer,
          $$SavedQueueSnapshotsTableCreateCompanionBuilder,
          $$SavedQueueSnapshotsTableUpdateCompanionBuilder,
          (
            SavedQueueSnapshot,
            BaseReferences<
              _$AppDatabase,
              $SavedQueueSnapshotsTable,
              SavedQueueSnapshot
            >,
          ),
          SavedQueueSnapshot,
          PrefetchHooks Function()
        > {
  $$SavedQueueSnapshotsTableTableManager(
    _$AppDatabase db,
    $SavedQueueSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedQueueSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedQueueSnapshotsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SavedQueueSnapshotsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> currentIndex = const Value.absent(),
                Value<bool> autoPlayEnabled = const Value.absent(),
                Value<int> positionMilliseconds = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedQueueSnapshotsCompanion(
                id: id,
                name: name,
                currentIndex: currentIndex,
                autoPlayEnabled: autoPlayEnabled,
                positionMilliseconds: positionMilliseconds,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int currentIndex,
                Value<bool> autoPlayEnabled = const Value.absent(),
                Value<int> positionMilliseconds = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SavedQueueSnapshotsCompanion.insert(
                id: id,
                name: name,
                currentIndex: currentIndex,
                autoPlayEnabled: autoPlayEnabled,
                positionMilliseconds: positionMilliseconds,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavedQueueSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedQueueSnapshotsTable,
      SavedQueueSnapshot,
      $$SavedQueueSnapshotsTableFilterComposer,
      $$SavedQueueSnapshotsTableOrderingComposer,
      $$SavedQueueSnapshotsTableAnnotationComposer,
      $$SavedQueueSnapshotsTableCreateCompanionBuilder,
      $$SavedQueueSnapshotsTableUpdateCompanionBuilder,
      (
        SavedQueueSnapshot,
        BaseReferences<
          _$AppDatabase,
          $SavedQueueSnapshotsTable,
          SavedQueueSnapshot
        >,
      ),
      SavedQueueSnapshot,
      PrefetchHooks Function()
    >;
typedef $$SavedQueueSnapshotEntriesTableCreateCompanionBuilder =
    SavedQueueSnapshotEntriesCompanion Function({
      required String snapshotId,
      required String songId,
      required int position,
      Value<int> rowid,
    });
typedef $$SavedQueueSnapshotEntriesTableUpdateCompanionBuilder =
    SavedQueueSnapshotEntriesCompanion Function({
      Value<String> snapshotId,
      Value<String> songId,
      Value<int> position,
      Value<int> rowid,
    });

class $$SavedQueueSnapshotEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SavedQueueSnapshotEntriesTable> {
  $$SavedQueueSnapshotEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get snapshotId => $composableBuilder(
    column: $table.snapshotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavedQueueSnapshotEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedQueueSnapshotEntriesTable> {
  $$SavedQueueSnapshotEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get snapshotId => $composableBuilder(
    column: $table.snapshotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavedQueueSnapshotEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedQueueSnapshotEntriesTable> {
  $$SavedQueueSnapshotEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get snapshotId => $composableBuilder(
    column: $table.snapshotId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get songId =>
      $composableBuilder(column: $table.songId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$SavedQueueSnapshotEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedQueueSnapshotEntriesTable,
          SavedQueueSnapshotEntry,
          $$SavedQueueSnapshotEntriesTableFilterComposer,
          $$SavedQueueSnapshotEntriesTableOrderingComposer,
          $$SavedQueueSnapshotEntriesTableAnnotationComposer,
          $$SavedQueueSnapshotEntriesTableCreateCompanionBuilder,
          $$SavedQueueSnapshotEntriesTableUpdateCompanionBuilder,
          (
            SavedQueueSnapshotEntry,
            BaseReferences<
              _$AppDatabase,
              $SavedQueueSnapshotEntriesTable,
              SavedQueueSnapshotEntry
            >,
          ),
          SavedQueueSnapshotEntry,
          PrefetchHooks Function()
        > {
  $$SavedQueueSnapshotEntriesTableTableManager(
    _$AppDatabase db,
    $SavedQueueSnapshotEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedQueueSnapshotEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SavedQueueSnapshotEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SavedQueueSnapshotEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> snapshotId = const Value.absent(),
                Value<String> songId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedQueueSnapshotEntriesCompanion(
                snapshotId: snapshotId,
                songId: songId,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String snapshotId,
                required String songId,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => SavedQueueSnapshotEntriesCompanion.insert(
                snapshotId: snapshotId,
                songId: songId,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavedQueueSnapshotEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedQueueSnapshotEntriesTable,
      SavedQueueSnapshotEntry,
      $$SavedQueueSnapshotEntriesTableFilterComposer,
      $$SavedQueueSnapshotEntriesTableOrderingComposer,
      $$SavedQueueSnapshotEntriesTableAnnotationComposer,
      $$SavedQueueSnapshotEntriesTableCreateCompanionBuilder,
      $$SavedQueueSnapshotEntriesTableUpdateCompanionBuilder,
      (
        SavedQueueSnapshotEntry,
        BaseReferences<
          _$AppDatabase,
          $SavedQueueSnapshotEntriesTable,
          SavedQueueSnapshotEntry
        >,
      ),
      SavedQueueSnapshotEntry,
      PrefetchHooks Function()
    >;
typedef $$LocalLyricsTableCreateCompanionBuilder =
    LocalLyricsCompanion Function({
      required String songId,
      Value<String?> lrc,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$LocalLyricsTableUpdateCompanionBuilder =
    LocalLyricsCompanion Function({
      Value<String> songId,
      Value<String?> lrc,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$LocalLyricsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalLyricsTable> {
  $$LocalLyricsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lrc => $composableBuilder(
    column: $table.lrc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalLyricsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalLyricsTable> {
  $$LocalLyricsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lrc => $composableBuilder(
    column: $table.lrc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalLyricsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalLyricsTable> {
  $$LocalLyricsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get songId =>
      $composableBuilder(column: $table.songId, builder: (column) => column);

  GeneratedColumn<String> get lrc =>
      $composableBuilder(column: $table.lrc, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$LocalLyricsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalLyricsTable,
          LocalLyric,
          $$LocalLyricsTableFilterComposer,
          $$LocalLyricsTableOrderingComposer,
          $$LocalLyricsTableAnnotationComposer,
          $$LocalLyricsTableCreateCompanionBuilder,
          $$LocalLyricsTableUpdateCompanionBuilder,
          (
            LocalLyric,
            BaseReferences<_$AppDatabase, $LocalLyricsTable, LocalLyric>,
          ),
          LocalLyric,
          PrefetchHooks Function()
        > {
  $$LocalLyricsTableTableManager(_$AppDatabase db, $LocalLyricsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalLyricsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalLyricsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalLyricsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> songId = const Value.absent(),
                Value<String?> lrc = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalLyricsCompanion(
                songId: songId,
                lrc: lrc,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String songId,
                Value<String?> lrc = const Value.absent(),
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalLyricsCompanion.insert(
                songId: songId,
                lrc: lrc,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalLyricsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalLyricsTable,
      LocalLyric,
      $$LocalLyricsTableFilterComposer,
      $$LocalLyricsTableOrderingComposer,
      $$LocalLyricsTableAnnotationComposer,
      $$LocalLyricsTableCreateCompanionBuilder,
      $$LocalLyricsTableUpdateCompanionBuilder,
      (
        LocalLyric,
        BaseReferences<_$AppDatabase, $LocalLyricsTable, LocalLyric>,
      ),
      LocalLyric,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalArtistsTableTableManager get localArtists =>
      $$LocalArtistsTableTableManager(_db, _db.localArtists);
  $$LocalAlbumsTableTableManager get localAlbums =>
      $$LocalAlbumsTableTableManager(_db, _db.localAlbums);
  $$StagedArtistsTableTableManager get stagedArtists =>
      $$StagedArtistsTableTableManager(_db, _db.stagedArtists);
  $$StagedAlbumsTableTableManager get stagedAlbums =>
      $$StagedAlbumsTableTableManager(_db, _db.stagedAlbums);
  $$LocalSongsTableTableManager get localSongs =>
      $$LocalSongsTableTableManager(_db, _db.localSongs);
  $$StagedSongsTableTableManager get stagedSongs =>
      $$StagedSongsTableTableManager(_db, _db.stagedSongs);
  $$LocalPlaylistsTableTableManager get localPlaylists =>
      $$LocalPlaylistsTableTableManager(_db, _db.localPlaylists);
  $$StagedPlaylistsTableTableManager get stagedPlaylists =>
      $$StagedPlaylistsTableTableManager(_db, _db.stagedPlaylists);
  $$LocalPlaylistEntriesTableTableManager get localPlaylistEntries =>
      $$LocalPlaylistEntriesTableTableManager(_db, _db.localPlaylistEntries);
  $$StagedPlaylistEntriesTableTableManager get stagedPlaylistEntries =>
      $$StagedPlaylistEntriesTableTableManager(_db, _db.stagedPlaylistEntries);
  $$LocalFavoritesTableTableManager get localFavorites =>
      $$LocalFavoritesTableTableManager(_db, _db.localFavorites);
  $$LocalInternetRadioStationsTableTableManager
  get localInternetRadioStations =>
      $$LocalInternetRadioStationsTableTableManager(
        _db,
        _db.localInternetRadioStations,
      );
  $$SyncStatesTableTableManager get syncStates =>
      $$SyncStatesTableTableManager(_db, _db.syncStates);
  $$PendingMutationsTableTableManager get pendingMutations =>
      $$PendingMutationsTableTableManager(_db, _db.pendingMutations);
  $$LocalPlayEventsTableTableManager get localPlayEvents =>
      $$LocalPlayEventsTableTableManager(_db, _db.localPlayEvents);
  $$LocalSongActivitiesTableTableManager get localSongActivities =>
      $$LocalSongActivitiesTableTableManager(_db, _db.localSongActivities);
  $$LocalQueueSessionsTableTableManager get localQueueSessions =>
      $$LocalQueueSessionsTableTableManager(_db, _db.localQueueSessions);
  $$LocalQueueEntriesTableTableManager get localQueueEntries =>
      $$LocalQueueEntriesTableTableManager(_db, _db.localQueueEntries);
  $$SavedQueueSnapshotsTableTableManager get savedQueueSnapshots =>
      $$SavedQueueSnapshotsTableTableManager(_db, _db.savedQueueSnapshots);
  $$SavedQueueSnapshotEntriesTableTableManager get savedQueueSnapshotEntries =>
      $$SavedQueueSnapshotEntriesTableTableManager(
        _db,
        _db.savedQueueSnapshotEntries,
      );
  $$LocalLyricsTableTableManager get localLyrics =>
      $$LocalLyricsTableTableManager(_db, _db.localLyrics);
}
