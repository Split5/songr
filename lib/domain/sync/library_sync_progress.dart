enum LibrarySyncStage { waiting, songs, artists, albums, playlists, finishing }

class LibrarySyncProgress {
  const LibrarySyncProgress(this.stage, {this.processed = 0, this.total});

  final LibrarySyncStage stage;
  final int processed;
  final int? total;

  double? get fraction {
    final count = total;
    if (count == null || count <= 0) return null;
    return (processed / count).clamp(0.0, 1.0);
  }
}

typedef LibrarySyncProgressCallback =
    void Function(LibrarySyncProgress progress);
