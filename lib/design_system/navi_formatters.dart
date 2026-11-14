/// Shared text formatting for the design system and feature screens.
library;

/// Formats a song length in whole seconds as `m:ss` (for example `3:07`).
/// Lengths of an hour or more keep counting minutes (`63:05`) so a row's
/// trailing text stays one compact token.
String formatDuration(int seconds) {
  final safe = seconds < 0 ? 0 : seconds;
  final minutes = safe ~/ 60;
  final remainder = safe % 60;
  return '$minutes:${remainder.toString().padLeft(2, '0')}';
}
