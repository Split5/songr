import 'dart:io';

class CachedLyrics {
  const CachedLyrics({required this.lrc, required this.fetchedAt});

  final String? lrc;
  final DateTime fetchedAt;
}

abstract interface class LyricsCache {
  Future<CachedLyrics?> read(String songId);
  Future<void> write(String songId, String? lrc);
}

abstract interface class LyricsGateway {
  Future<String?> fetch(String songId);
}

/// Offline-first lyrics access. A downloaded sidecar wins, then a durable
/// database cache, then the server.
class LyricsService {
  const LyricsService({required this.cache, required this.gateway});

  static const negativeCacheLifetime = Duration(days: 7);
  static const positiveCacheLifetime = Duration(days: 30);

  final LyricsCache cache;
  final LyricsGateway gateway;

  Future<String?> load(
    String songId, {
    String? localPath,
    bool refresh = false,
  }) async {
    if (localPath != null && !refresh) {
      try {
        final file = File(localPath);
        if (await file.exists()) {
          final value = (await file.readAsString()).trim();
          if (value.isNotEmpty) return value;
        }
      } catch (_) {}
    }
    final cached = await cache.read(songId);
    final freshPositive =
        cached != null &&
        cached.lrc != null &&
        DateTime.now().difference(cached.fetchedAt) < positiveCacheLifetime;
    final freshNegative =
        cached != null &&
        cached.lrc == null &&
        DateTime.now().difference(cached.fetchedAt) < negativeCacheLifetime;
    if (!refresh && cached != null && (freshPositive || freshNegative)) {
      return cached.lrc;
    }
    try {
      final value = await gateway.fetch(songId);
      await cache.write(songId, value);
      return value;
    } catch (_) {
      // A stale cache is still more useful than an offline error.
      if (cached != null) return cached.lrc;
      rethrow;
    }
  }
}
