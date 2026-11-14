/// Where the lyrics view reads the playhead from.
///
/// [now] is the player's position at the moment the view opens, [updates] keeps
/// it current while the view is visible. `just_audio` already extrapolates
/// between platform reports, freezes the value while buffering and jumps it on
/// a seek, so the lyric view follows the player instead of keeping a clock of
/// its own — a private clock kept running through a buffer stall and left the
/// text out of time after a seek.
class LyricsPlayhead {
  const LyricsPlayhead({required this.now, required this.updates});

  final Duration Function() now;
  final Stream<Duration> updates;
}
