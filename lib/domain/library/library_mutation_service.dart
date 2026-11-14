import 'dart:async';

import '../../api/subsonic_api.dart';
import '../../data/local/app_database.dart';
import '../../models/models.dart';
import '../../state/download_provider.dart';

class LibraryMutationService {
  LibraryMutationService({
    required this.api,
    required this.database,
    required this.downloads,
  });

  final SubsonicApi api;
  final AppDatabase database;
  final DownloadProvider downloads;
  final Map<String, Future<void>> _songMutationTails = {};
  final Map<String, Future<void>> _playlistMutationTails = {};

  Future<bool> toggleFavorite(
    Song song, {
    Future<void> Function()? onLocalChange,
  }) => _serializeMutation(
    _songMutationTails,
    song.id,
    () => _toggleFavoriteUnlocked(song, onLocalChange: onLocalChange),
  );

  Future<bool> _toggleFavoriteUnlocked(
    Song song, {
    Future<void> Function()? onLocalChange,
  }) async {
    final next = !song.starred;
    final previousStarred = song.starred;
    final previousStarredAt = song.starredAt;
    song.starred = next;
    song.starredAt = next ? DateTime.now() : null;
    await database.setSongStarred(
      song.id,
      starred: next,
      starredAt: song.starredAt,
    );
    await onLocalChange?.call();
    try {
      if (next) {
        await api.star(id: song.id);
      } else {
        await api.unstar(id: song.id);
      }
    } on SubsonicException catch (error) {
      if (const {40, 41, 42, 43, 44, 401, 403}.contains(error.code)) {
        song.starred = previousStarred;
        song.starredAt = previousStarredAt;
        await database.setSongStarred(
          song.id,
          starred: previousStarred,
          starredAt: previousStarredAt,
        );
        await onLocalChange?.call();
        rethrow;
      }
      await database.queueFavoriteMutation(songId: song.id, starred: next);
    } catch (_) {
      await database.queueFavoriteMutation(songId: song.id, starred: next);
    }
    if (downloads.favoritesOfflineEnabled) {
      if (next) {
        unawaited(
          downloads.downloadSong(
            song,
            api,
            favoritesDownloadReason,
            background: true,
          ),
        );
      } else {
        await downloads.removeReason(song.id, favoritesDownloadReason);
        unawaited(
          downloads.waitForPendingDownloads.then(
            (_) => downloads.removeReason(song.id, favoritesDownloadReason),
          ),
        );
      }
    }
    return next;
  }

  Future<void> addToPlaylist(Song song, Playlist playlist) =>
      _serializeMutation(
        _playlistMutationTails,
        playlist.id,
        () => api.updatePlaylist(playlist.id, addSongIds: [song.id]),
      );

  Future<void> removeFromPlaylist({
    required Playlist playlist,
    required String songId,
    required int occurrence,
  }) => _serializeMutation(
    _playlistMutationTails,
    playlist.id,
    () => _removeFromPlaylistUnlocked(
      playlist: playlist,
      songId: songId,
      occurrence: occurrence,
    ),
  );

  Future<void> _removeFromPlaylistUnlocked({
    required Playlist playlist,
    required String songId,
    required int occurrence,
  }) async {
    final current = await api.getPlaylist(playlist.id);
    final index = playlistOccurrenceIndex(current, songId, occurrence);
    if (index < 0) {
      throw StateError('Song $songId is no longer in playlist ${playlist.id}');
    }
    await api.updatePlaylist(playlist.id, removeIndexes: [index]);
  }

  Future<void> replayPendingFavorites() async {
    for (final mutation in await database.pendingFavoriteMutations()) {
      await _serializeMutation(_songMutationTails, mutation.songId, () async {
        if (mutation.starred) {
          await api.star(id: mutation.songId);
        } else {
          await api.unstar(id: mutation.songId);
        }
        await database.deletePendingMutation(mutation.id);
      });
    }
  }

  Future<void> deletePlaylist(Playlist playlist) => _serializeMutation(
    _playlistMutationTails,
    playlist.id,
    () => api.deletePlaylist(playlist.id),
  );

  Future<void> renamePlaylist(Playlist playlist, String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'must not be empty');
    }
    return _serializeMutation(
      _playlistMutationTails,
      playlist.id,
      () => api.updatePlaylist(playlist.id, name: trimmed),
    );
  }

  /// Creates an empty playlist and returns its id.
  Future<String> createPlaylist(String name) =>
      api.createPlaylist(name.trim(), const []);

  /// Creates a playlist holding [songs] in order and returns its id.
  Future<String> createPlaylistWithSongs(String name, Iterable<Song> songs) =>
      api.createPlaylist(
        name.trim(),
        songs.map((song) => song.id).toList(growable: false),
      );

  Future<T> _serializeMutation<T>(
    Map<String, Future<void>> tails,
    String key,
    Future<T> Function() operation,
  ) {
    final previous = tails[key] ?? Future.value();
    final result = Completer<T>();
    late final Future<void> tracked;
    tracked = previous.then((_) async {
      try {
        result.complete(await operation());
      } catch (error, stackTrace) {
        result.completeError(error, stackTrace);
      }
    });
    tails[key] = tracked;
    tracked.whenComplete(() {
      if (identical(tails[key], tracked)) tails.remove(key);
    });
    return result.future;
  }
}

int playlistOccurrenceIndex(List<Song> songs, String songId, int occurrence) {
  if (occurrence < 0) return -1;
  var found = 0;
  for (var index = 0; index < songs.length; index++) {
    if (songs[index].id != songId) continue;
    if (found == occurrence) return index;
    found++;
  }
  return -1;
}
