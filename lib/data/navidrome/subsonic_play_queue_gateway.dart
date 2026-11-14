import '../../api/subsonic_api.dart';
import '../../domain/playback/server_play_queue.dart';

class SubsonicPlayQueueGateway implements ServerPlayQueueGateway {
  const SubsonicPlayQueueGateway(this.api);

  final SubsonicApi api;

  @override
  Future<ServerPlayQueueSnapshot?> load() async {
    final queue = await api.getPlayQueue();
    if (queue == null) return null;
    return ServerPlayQueueSnapshot(
      songIds: queue.songs.map((song) => song.id).toList(growable: false),
      currentSongId: queue.currentSongId,
      position: queue.position,
      changedAt: queue.changedAt,
    );
  }

  @override
  Future<void> save({
    required List<String> songIds,
    required String? currentSongId,
    required Duration position,
  }) => api.savePlayQueue(
    songIds: songIds,
    currentSongId: currentSongId,
    position: position,
  );
}
