class ServerPlayQueueSnapshot {
  const ServerPlayQueueSnapshot({
    required this.songIds,
    required this.currentSongId,
    required this.position,
    required this.changedAt,
  });

  final List<String> songIds;
  final String? currentSongId;
  final Duration position;
  final DateTime? changedAt;
}

abstract interface class ServerPlayQueueGateway {
  Future<ServerPlayQueueSnapshot?> load();

  Future<void> save({
    required List<String> songIds,
    required String? currentSongId,
    required Duration position,
  });
}
