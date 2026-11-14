/// Policy for how much of the queue the native player prepares before the
/// first sound.
///
/// A tap used to hand the player the whole lookahead window (up to 26 remote
/// streams) and wait for every source to open. The listener heard silence for
/// seconds while the server logged dozens of stream requests. The cold start
/// now prepares only the tapped entry so playback can begin,
/// and the rest of the window is appended while the song is already running.
library;

/// Earlier tracks are loaded on demand when the listener selects them.
const int initialWindowBefore = 0;

/// Lookahead is appended after the selected source is ready.
const int initialWindowAfter = 0;

class WindowSlice {
  const WindowSlice(this.start, this.end);

  final int start;
  final int end;

  int get length => end - start;
}

/// Slice of [length] entries to prepare before playback starts.
WindowSlice initialWindowSlice(
  int length,
  int currentIndex, {
  int before = initialWindowBefore,
  int after = initialWindowAfter,
}) {
  if (length <= 0) return const WindowSlice(0, 0);
  final index = currentIndex.clamp(0, length - 1);
  final start = (index - before).clamp(0, length);
  final end = (index + after + 1).clamp(start, length);
  return WindowSlice(start, end);
}

/// Whether the native queue can be edited in place instead of rebuilt.
///
/// A rebuild re-opens every source, so it is only justified when the entry
/// that is currently playing is no longer part of the new window.
bool canReuseNativeWindow({
  required List<String> previousEntryIds,
  required List<String> desiredEntryIds,
  required String? currentEntryId,
}) =>
    currentEntryId != null &&
    previousEntryIds.contains(currentEntryId) &&
    desiredEntryIds.contains(currentEntryId);
