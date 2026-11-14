import 'dart:async';

import 'playback_history_repository.dart';

abstract interface class ScrobbleSink {
  Future<void> announceStart(String songId);
  Future<void> submitPlay(String songId);
}

/// Tracks one playback occurrence at a time and submits it exactly once after
/// the earlier of 50% played or four minutes.
///
/// [playbackId] identifies an occurrence, not merely a song. Repeating the same
/// song therefore creates a new playback id and may legitimately scrobble it
/// again. All callbacks are serialized so concurrent position streams cannot
/// double-submit.
class ScrobbleTracker {
  ScrobbleTracker({
    required this.sink,
    this.history,
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now;

  final ScrobbleSink sink;
  final PlaybackHistoryRecorder? history;
  final DateTime Function() clock;

  Future<void> _eventTail = Future.value();
  String? _playbackId;
  String? _songId;
  Duration _duration = Duration.zero;
  bool _submitted = false;

  String? get activePlaybackId => _playbackId;
  bool get submitted => _submitted;

  Future<void> start({
    required String playbackId,
    required String songId,
    required Duration duration,
  }) => _serialize(() async {
    if (_playbackId == playbackId && _songId == songId) return;
    await history?.beginPlayback(
      playbackId: playbackId,
      songId: songId,
      startedAt: clock(),
      duration: duration,
    );
    _playbackId = playbackId;
    _songId = songId;
    _duration = duration.isNegative ? Duration.zero : duration;
    _submitted = false;
    await sink.announceStart(songId);
  });

  Future<void> position({
    required String playbackId,
    required Duration position,
  }) => _serialize(() async {
    if (playbackId != _playbackId || _submitted) return;
    final threshold = _submissionThreshold(_duration);
    if (threshold == null || position < threshold) return;
    await _submitActive();
  });

  /// Completion is authoritative even when the platform skipped the final
  /// position event while the app was backgrounded.
  Future<void> completed({required String playbackId}) => _serialize(() async {
    if (playbackId != _playbackId || _duration <= Duration.zero) {
      return;
    }
    await history?.completePlayback(playbackId: playbackId, at: clock());
    if (!_submitted) await _submitActive();
  });

  Future<void> clear({required String playbackId, bool skipped = false}) =>
      _serialize(() async {
        if (playbackId != _playbackId) return;
        await history?.endPlayback(
          playbackId: playbackId,
          at: clock(),
          skipped: skipped,
        );
        _playbackId = null;
        _songId = null;
        _duration = Duration.zero;
        _submitted = false;
      });

  Future<void> dispose() => _eventTail;

  Future<void> _submitActive() async {
    final songId = _songId;
    final playbackId = _playbackId;
    if (songId == null || playbackId == null) return;
    final firstAttempt =
        await history?.markPlayed(playbackId: playbackId, at: clock()) ?? true;
    // Subsonic has no idempotency key. Once an attempt has been recorded, do
    // not send an ambiguous second request after a lost response.
    _submitted = true;
    if (!firstAttempt) return;
    await sink.submitPlay(songId);
  }

  Duration? _submissionThreshold(Duration duration) {
    if (duration <= Duration.zero) return null;
    final halfway = Duration(milliseconds: duration.inMilliseconds ~/ 2);
    const fourMinutes = Duration(minutes: 4);
    return halfway < fourMinutes ? halfway : fourMinutes;
  }

  Future<T> _serialize<T>(Future<T> Function() event) {
    final result = Completer<T>();
    _eventTail = _eventTail.then((_) async {
      try {
        result.complete(await event());
      } catch (error, stackTrace) {
        result.completeError(error, stackTrace);
      }
    });
    return result.future;
  }
}
