/// Data models for the Subsonic/Navidrome API.
///
/// Field choices follow API_CAPABILITIES.md: `title`, `artist`, `album`,
/// `albumId`, `artistId`, `duration`, `coverArt`, `playCount` are reliable;
/// V2 also retains technical fields (`track`, `discNumber`, bit depth, sample
/// rate, size and MIME type) required for database-backed sorting and quality
/// filters. Missing server values remain zero/null and degrade gracefully.
library;

/// The main artist of a collaboration string. Tags separate collaborators
/// with "," or ";" ("Justin Bieber,Kehlani", "Alan Walker; Sorana") —
/// the first name is the main artist. Used to group all collaborations
/// under one artist entry. Note: "&" is NOT a separator (band names like
/// "Norlie & KKV" contain it).
String primaryArtistName(String artist) =>
    artist.split(RegExp(r'[,;]')).first.trim();

class Song {
  final String id;
  final String title;
  final String artist;
  final String artistId;
  final String album;
  final String albumId;
  final String? coverArt;
  final int duration; // seconds
  final int playCount;
  final int year;
  final int bitRate; // kbps
  final int bitDepth;
  final int samplingRate; // Hz
  final int fileSize; // bytes
  final int track;
  final int disc;
  final String suffix; // file extension, e.g. m4a / flac
  final String? contentType;
  final String? comment; // contains the YouTube source URL
  final DateTime? created; // when the file was added to the server
  final DateTime? lastPlayed; // Navidrome's latest completed play timestamp
  final String? genre; // ID3 genre tag, e.g. "Alternative Metal" — see above
  bool starred;

  /// When the song was starred (Subsonic's `starred` timestamp) — powers
  /// "Favorites: newest first".
  DateTime? starredAt;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.artistId,
    required this.album,
    required this.albumId,
    this.coverArt,
    this.duration = 0,
    this.playCount = 0,
    this.year = 0,
    this.bitRate = 0,
    this.bitDepth = 0,
    this.samplingRate = 0,
    this.fileSize = 0,
    this.track = 0,
    this.disc = 0,
    this.suffix = '',
    this.contentType,
    this.comment,
    this.created,
    this.lastPlayed,
    this.genre,
    this.starred = false,
    this.starredAt,
  });

  factory Song.fromJson(Map<String, dynamic> json) => Song(
    id: json['id'] as String,
    title: (json['title'] ?? '') as String,
    artist: (json['artist'] ?? '') as String,
    artistId: (json['artistId'] ?? '') as String,
    album: (json['album'] ?? '') as String,
    albumId: (json['albumId'] ?? '') as String,
    coverArt: json['coverArt'] as String?,
    duration: (json['duration'] ?? 0) as int,
    playCount: (json['playCount'] ?? 0) as int,
    year: (json['year'] ?? 0) as int,
    bitRate: (json['bitRate'] ?? 0) as int,
    bitDepth: (json['bitDepth'] ?? 0) as int,
    samplingRate: (json['samplingRate'] ?? 0) as int,
    fileSize: (json['size'] ?? json['fileSize'] ?? 0) as int,
    track: (json['track'] ?? 0) as int,
    disc: (json['discNumber'] ?? json['disc'] ?? 0) as int,
    suffix: (json['suffix'] ?? '') as String,
    contentType: json['contentType'] as String?,
    comment: json['comment'] as String?,
    created: json['created'] != null
        ? DateTime.tryParse(json['created'] as String)
        : null,
    lastPlayed: json['played'] is String
        ? DateTime.tryParse(json['played'] as String)
        : (json['lastPlayed'] is String
              ? DateTime.tryParse(json['lastPlayed'] as String)
              : null),
    genre: json['genre'] as String?,
    // Subsonic sends `starred` as an ISO timestamp; our offline
    // snapshot stores a bool plus a separate starredAt field.
    starred: json['starred'] != null && json['starred'] != false,
    starredAt: json['starredAt'] != null
        ? DateTime.tryParse(json['starredAt'] as String)
        : (json['starred'] is String
              ? DateTime.tryParse(json['starred'] as String)
              : null),
  );

  /// Round-trips through [Song.fromJson] — used for the offline library
  /// cache (see LibraryProvider), not the live API.
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'artist': artist,
    'artistId': artistId,
    'album': album,
    'albumId': albumId,
    'coverArt': coverArt,
    'duration': duration,
    'playCount': playCount,
    'year': year,
    'bitRate': bitRate,
    'bitDepth': bitDepth,
    'samplingRate': samplingRate,
    'size': fileSize,
    'track': track,
    'discNumber': disc,
    'suffix': suffix,
    'contentType': contentType,
    'comment': comment,
    'created': created?.toIso8601String(),
    'played': lastPlayed?.toIso8601String(),
    'genre': genre,
    if (starred) 'starred': true,
    if (starredAt != null) 'starredAt': starredAt!.toIso8601String(),
  };
}

class Album {
  final String id;
  final String name;
  final String artist;
  final String artistId;
  final String? coverArt;
  final int songCount;
  final int duration;
  final int playCount;
  final int year;
  final DateTime? created;
  bool starred;

  Album({
    required this.id,
    required this.name,
    required this.artist,
    required this.artistId,
    this.coverArt,
    this.songCount = 0,
    this.duration = 0,
    this.playCount = 0,
    this.year = 0,
    this.created,
    this.starred = false,
  });

  factory Album.fromJson(Map<String, dynamic> json) => Album(
    id: json['id'] as String,
    name: (json['name'] ?? json['title'] ?? json['album'] ?? '') as String,
    artist: (json['artist'] ?? '') as String,
    artistId: (json['artistId'] ?? '') as String,
    coverArt: json['coverArt'] as String?,
    songCount: (json['songCount'] ?? 0) as int,
    duration: (json['duration'] ?? 0) as int,
    playCount: (json['playCount'] ?? 0) as int,
    year: (json['year'] ?? 0) as int,
    created: json['created'] is String
        ? DateTime.tryParse(json['created'] as String)
        : null,
    starred: json['starred'] != null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'artist': artist,
    'artistId': artistId,
    'coverArt': coverArt,
    'songCount': songCount,
    'duration': duration,
    'playCount': playCount,
    'year': year,
    'created': created?.toIso8601String(),
    if (starred) 'starred': true,
  };
}

class ArtistSummary {
  final String id;
  final String name;
  final String? coverArt;
  final int albumCount;
  bool starred;

  ArtistSummary({
    required this.id,
    required this.name,
    this.coverArt,
    this.albumCount = 0,
    this.starred = false,
  });

  factory ArtistSummary.fromJson(Map<String, dynamic> json) => ArtistSummary(
    id: json['id'] as String,
    name: (json['name'] ?? '') as String,
    coverArt: json['coverArt'] as String?,
    albumCount: (json['albumCount'] ?? 0) as int,
    starred: json['starred'] != null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'coverArt': coverArt,
    'albumCount': albumCount,
    if (starred) 'starred': true,
  };
}

class Playlist {
  final String id;
  final String name;
  final int songCount;
  final int duration;
  final String? coverArt;
  final String owner;

  /// True for auto-generated/managed "smart" playlists — e.g. Navidrome's
  /// own rule-based Smart Playlists (NSP) or a server-side analysis plugin;
  /// Navidrome marks these read-only and refreshes them on its own
  /// schedule, unlike a user's own playlists. There's no API field that
  /// says which system generated a given one, only this flag.
  final bool readonly;

  /// True when the playlist is shared/public. Empirically on this server
  /// the user's OWN playlists are private (the field is absent → false)
  /// while plugin-generated playlists (the AudioMuse-AI Navidrome plugin's
  /// `*_automatic` clusters) are created public.
  final bool isPublic;
  final DateTime? changed;

  Playlist({
    required this.id,
    required this.name,
    this.songCount = 0,
    this.duration = 0,
    this.coverArt,
    this.owner = '',
    this.readonly = false,
    this.isPublic = false,
    this.changed,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
    id: json['id'] as String,
    name: (json['name'] ?? '') as String,
    songCount: (json['songCount'] ?? 0) as int,
    duration: (json['duration'] ?? 0) as int,
    coverArt: json['coverArt'] as String?,
    owner: (json['owner'] ?? '') as String,
    readonly: (json['readonly'] ?? false) as bool,
    isPublic: (json['public'] ?? false) as bool,
    changed: json['changed'] is String
        ? DateTime.tryParse(json['changed'] as String)
        : null,
  );
}

class SearchResult {
  final List<Song> songs;
  final List<Album> albums;
  final List<ArtistSummary> artists;

  SearchResult({
    this.songs = const [],
    this.albums = const [],
    this.artists = const [],
  });
}

class InternetRadioStation {
  const InternetRadioStation({
    required this.id,
    required this.name,
    required this.streamUrl,
    this.homePageUrl,
  });

  final String id;
  final String name;
  final String streamUrl;
  final String? homePageUrl;

  factory InternetRadioStation.fromJson(Map<String, dynamic> json) =>
      InternetRadioStation(
        id: json['id'] as String,
        name: (json['name'] ?? '') as String,
        streamUrl: (json['streamUrl'] ?? '') as String,
        homePageUrl: json['homePageUrl'] as String?,
      );
}
