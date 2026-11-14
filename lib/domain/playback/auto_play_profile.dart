import 'package:flutter/foundation.dart';

/// Stable, client-owned tuning contract for radio-style playback.
///
/// The UI deliberately targets this small product model instead of binding
/// itself to any server-side similarity parameters. Providers may map
/// supported fields to newer server capabilities and safely ignore
/// unsupported ones.
@immutable
class AutoPlayProfile {
  const AutoPlayProfile({
    this.exploration = 0.25,
    this.maxSongsPerArtist = 2,
    this.initialCandidateCount = 20,
  });

  /// 0 keeps the server's closest-first similarity order; 1 explores deeper
  /// in its candidate set while still using only sonically related results.
  final double exploration;

  /// Client-side diversity cap, independent of server implementation.
  final int maxSongsPerArtist;

  /// How many candidates are materialized when a lone-song radio starts.
  final int initialCandidateCount;
}
