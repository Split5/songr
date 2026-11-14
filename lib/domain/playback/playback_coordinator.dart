import 'dart:async';

import 'auto_play_profile.dart';
import 'logical_queue.dart';

enum QueueWindowUpdateReason { replace, jump, advance, edit, autoPlay }

class NativeQueueWindow {
  const NativeQueueWindow({required this.entries, required this.currentIndex});

  final List<LogicalQueueEntry> entries;
  final int currentIndex;
}

/// Adapter implemented by the just_audio layer. It receives only a bounded
/// source window and never owns the app's logical queue.
abstract interface class NativePlaybackPort {
  Future<void> reconcileQueueWindow(
    NativeQueueWindow window, {
    required QueueWindowUpdateReason reason,
  });

  /// Starts playback.
  ///
  /// Some audio engines keep this future pending for the entire playback
  /// lifetime. The coordinator therefore dispatches it without serializing on
  /// its completion.
  Future<void> play();
  Future<void> pause();

  /// Completes when the most recent window is fully materialized.
  ///
  /// A cold start hands the player a small buffer so the first sound is not
  /// waiting for the whole lookahead; the remaining entries are appended in
  /// the background and this future reports when that has finished. The queue
  /// sheet uses it to wait for a complete list.
  Future<void> get windowReady;
}

abstract interface class AutoPlayCandidateProvider {
  Future<List<String>> candidates({
    required String seedSongId,
    required Set<String> excludedSongIds,
    required int limit,
    required AutoPlayProfile profile,
  });
}

AutoPlayProfile _defaultAutoPlayProfile() => const AutoPlayProfile();

/// Sole owner of V2 queue mutations.
///
/// Every public command is serialized. The logical queue changes only after
/// the native adapter accepts the matching bounded window, which prevents UI,
/// AutoPlay and platform callbacks from racing each other.
class PlaybackCoordinator {
  PlaybackCoordinator({
    required this.nativePort,
    this.autoPlayCandidates,
    this.autoPlayProfile = _defaultAutoPlayProfile,
    this.nativeWindowBefore = 5,
    this.nativeWindowAfter = 20,
  });

  final NativePlaybackPort nativePort;
  final AutoPlayCandidateProvider? autoPlayCandidates;
  final AutoPlayProfile Function() autoPlayProfile;
  final int nativeWindowBefore;
  final int nativeWindowAfter;

  final StreamController<LogicalQueue> _queueChanges =
      StreamController.broadcast();
  Future<void> _commandTail = Future.value();
  LogicalQueue _queue = const LogicalQueue.empty();
  NativeQueueWindow _nativeWindow = const NativeQueueWindow(
    entries: [],
    currentIndex: -1,
  );
  bool _autoPlayEnabled = true;
  int _nextAutoPlayEntry = 0;

  /// Every explicit queue replacement bumps this. A replacement that a newer
  /// tap has already superseded must not publish itself or start playing, or
  /// the previous song would briefly take over the player after a quick second
  /// tap.
  int _replaceEpoch = 0;

  LogicalQueue get queue => _queue;
  Stream<LogicalQueue> get queueChanges => _queueChanges.stream;

  /// Completes when the queue's lookahead has been handed to the player.
  Future<void> get queueReady => nativePort.windowReady;
  bool get autoPlayEnabled => _autoPlayEnabled;

  Future<void> replaceQueue(
    List<LogicalQueueEntry> entries, {
    required String startEntryId,
    bool playImmediately = true,
  }) {
    final epoch = ++_replaceEpoch;
    return _serialize(() async {
      if (epoch != _replaceEpoch) return;
      final next = LogicalQueue.start(entries, startEntryId);
      await _reconcile(next, QueueWindowUpdateReason.replace);
      if (epoch != _replaceEpoch) return;
      _publish(next);
      if (playImmediately) await _dispatchPlay();
    });
  }

  /// Starts a radio-style queue with [seed] first, then hydrates it with an
  /// initial batch from the configured similarity provider. Navidrome answers
  /// `getSimilarSongs2` through its AudioMuse plugin when that agent is
  /// enabled; the client itself only ever talks to Navidrome.
  ///
  /// Playback starts before the network result arrives. A late response is
  /// discarded if another queue has replaced this seed in the meantime.
  Future<void> startAutoPlayMix(
    LogicalQueueEntry seed, {
    int? initialCandidateCount,
  }) async {
    await replaceQueue([seed], startEntryId: seed.id);
    final provider = autoPlayCandidates;
    final profile = autoPlayProfile();
    final candidateCount =
        initialCandidateCount ?? profile.initialCandidateCount;
    if (provider == null || candidateCount <= 0) return;

    final candidates = await provider.candidates(
      seedSongId: seed.songId,
      excludedSongIds: {seed.songId},
      limit: candidateCount,
      profile: profile,
    );
    if (candidates.isEmpty) return;

    await _serialize(() async {
      // A different tap may have replaced the queue while the server worked.
      if (_queue.entries.isEmpty || _queue.entries.first.id != seed.id) return;
      final additions = candidates
          .map(
            (songId) => LogicalQueueEntry(
              id: 'autoplay-${_nextAutoPlayEntry++}-$songId',
              songId: songId,
            ),
          )
          .toList(growable: false);
      final next = _queue.appendNewSongs(additions, maxCount: candidateCount);
      if (identical(next, _queue)) return;
      await _reconcile(next, QueueWindowUpdateReason.autoPlay);
      _publish(next);
    });
  }

  /// Selects an existing queue occurrence without recreating or truncating the
  /// logical queue.
  Future<void> jumpTo(String entryId, {String? expectedCurrentEntryId}) =>
      _serialize(() async {
        if (expectedCurrentEntryId != null &&
            _queue.current?.id != expectedCurrentEntryId) {
          return;
        }
        final next = _queue.jumpTo(entryId);
        if (identical(next, _queue)) return;
        await _reconcile(next, QueueWindowUpdateReason.jump);
        _publish(next);
        await _dispatchPlay();
      });

  /// Platform callback after the native player advanced naturally. The source
  /// window shifts only when five materialized entries remain and more logical
  /// entries exist; the logical queue itself is never recreated.
  Future<void> handleNativeCurrentEntry(String entryId) => _serialize(() async {
    final next = _queue.jumpTo(entryId);
    if (identical(next, _queue)) return;

    final nativeIndex = _nativeWindow.entries.indexWhere(
      (item) => item.id == entryId,
    );
    final nativeRemaining = nativeIndex < 0
        ? 0
        : _nativeWindow.entries.length - nativeIndex - 1;
    final logicalRemaining = next.entries.length - next.currentIndex - 1;
    if (logicalRemaining > nativeRemaining && nativeRemaining <= 5) {
      await _reconcile(next, QueueWindowUpdateReason.advance);
    }
    _publish(next);
  });

  Future<void> moveBefore(String entryId, String? beforeEntryId) => _serialize(
    () async {
      final oldIndex = _queue.entries.indexWhere((item) => item.id == entryId);
      if (oldIndex < 0) return;

      var target = beforeEntryId == null
          ? _queue.entries.length - 1
          : _queue.entries.indexWhere((item) => item.id == beforeEntryId);
      if (target < 0 || entryId == beforeEntryId) return;
      if (oldIndex < target && beforeEntryId != null) target--;

      final next = _queue.move(entryId, target);
      if (identical(next, _queue)) return;

      // A drag has to land in the frame the finger lets go. Reconciling the
      // native window first took long enough for the row to drop back into its
      // old slot and jump again a moment later, which read as a flicker.
      final previous = _queue;
      _publish(next);
      try {
        await _reconcile(next, QueueWindowUpdateReason.edit);
      } catch (_) {
        // Nothing reached the player, so the list must not keep the new order.
        _publish(previous);
        rethrow;
      }
    },
  );

  Future<void> remove(String entryId) => _serialize(() async {
    final next = _queue.remove(entryId);
    if (identical(next, _queue)) return;
    await _reconcile(next, QueueWindowUpdateReason.edit);
    _publish(next);
  });

  Future<void> append(List<LogicalQueueEntry> entries) => _serialize(() async {
    final next = _queue.append(entries);
    if (identical(next, _queue)) return;
    await _reconcile(next, QueueWindowUpdateReason.edit);
    _publish(next);
  });

  Future<void> insertNext(List<LogicalQueueEntry> entries) =>
      _serialize(() async {
        final next = _queue.insertAfterCurrent(entries);
        if (identical(next, _queue)) return;
        await _reconcile(next, QueueWindowUpdateReason.edit);
        _publish(next);
      });

  Future<void> replaceUpcoming(List<LogicalQueueEntry> entries) =>
      _serialize(() async {
        final next = _queue.replaceAfterCurrent(entries);
        if (identical(next, _queue)) return;
        await _reconcile(next, QueueWindowUpdateReason.edit);
        _publish(next);
      });

  Future<void> reorder(List<LogicalQueueEntry> entries) => _serialize(() async {
    final next = _queue.reorderKeepingCurrent(entries);
    if (identical(next, _queue)) return;
    await _reconcile(next, QueueWindowUpdateReason.edit);
    _publish(next);
  });

  Future<void> clear() => _serialize(() async {
    if (_queue.entries.isEmpty) return;
    const next = LogicalQueue.empty();
    await _reconcile(next, QueueWindowUpdateReason.replace);
    _publish(next);
  });

  Future<void> setAutoPlay(bool enabled) => _serialize(() async {
    _autoPlayEnabled = enabled;
  });

  /// Returns the existing next queue item, or extends the queue at its tail
  /// with one AutoPlay batch. The current item never changes here, so callers
  /// can finish scrobbling the current playback before they jump.
  Future<LogicalQueueEntry?> prepareNextEntry({
    String? expectedCurrentEntryId,
  }) => _serialize(() async {
    final current = _queue.current;
    if (current == null) return null;
    if (expectedCurrentEntryId != null &&
        current.id != expectedCurrentEntryId) {
      return null;
    }
    final nextIndex = _queue.currentIndex + 1;
    if (nextIndex < _queue.entries.length) return _queue.entries[nextIndex];
    return (await _appendAutoPlayBatch()).first;
  });

  /// Called only when the last logical item has completed. Each successful
  /// call appends at most five unseen songs and preserves the entire prefix.
  Future<int> handleQueueExhausted() => _serialize(() async {
    if (_queue.current == null ||
        _queue.currentIndex < _queue.entries.length - 1) {
      return 0;
    }
    return (await _appendAutoPlayBatch()).added;
  });

  Future<({int added, LogicalQueueEntry? first})> _appendAutoPlayBatch() async {
    final provider = autoPlayCandidates;
    final current = _queue.current;
    if (!_autoPlayEnabled || provider == null || current == null) {
      return (added: 0, first: null);
    }

    final candidates = await provider.candidates(
      seedSongId: current.songId,
      excludedSongIds: _queue.entries.map((item) => item.songId).toSet(),
      limit: 20,
      profile: autoPlayProfile(),
    );
    final additions = candidates
        .map(
          (songId) => LogicalQueueEntry(
            id: 'autoplay-${_nextAutoPlayEntry++}-$songId',
            songId: songId,
          ),
        )
        .toList(growable: false);
    final previousLength = _queue.entries.length;
    final next = _queue.appendNewSongs(additions, maxCount: 5);
    final added = next.entries.length - previousLength;
    if (added == 0) return (added: 0, first: null);

    await _reconcile(next, QueueWindowUpdateReason.autoPlay);
    _publish(next);
    return (added: added, first: next.entries[previousLength]);
  }

  Future<void> play() => _serialize(_dispatchPlay);
  Future<void> pause() => _serialize(nativePort.pause);

  Future<void> dispose() async {
    await _commandTail;
    await _queueChanges.close();
  }

  Future<void> _reconcile(LogicalQueue queue, QueueWindowUpdateReason reason) {
    final bounded = queue.nativeWindow(
      before: nativeWindowBefore,
      after: nativeWindowAfter,
    );
    final window = NativeQueueWindow(
      entries: bounded.entries,
      currentIndex: bounded.currentIndex,
    );
    return nativePort
        .reconcileQueueWindow(window, reason: reason)
        .then((_) => _nativeWindow = window);
  }

  void _publish(LogicalQueue next) {
    _queue = next;
    _queueChanges.add(next);
  }

  /// Dispatches play without awaiting the audio engine's playback-lifetime
  /// future. In just_audio that future completes only after pause, stop or
  /// completion; awaiting it inside [_serialize] would deadlock Pause behind
  /// Play.
  Future<void> _dispatchPlay() async {
    final errorZone = Zone.current;
    final playbackLifetime = nativePort.play();
    unawaited(
      playbackLifetime.catchError((Object error, StackTrace stackTrace) {
        errorZone.handleUncaughtError(error, stackTrace);
      }),
    );
  }

  Future<T> _serialize<T>(Future<T> Function() command) {
    final result = Completer<T>();
    _commandTail = _commandTail.then((_) async {
      try {
        result.complete(await command());
      } catch (error, stackTrace) {
        result.completeError(error, stackTrace);
      }
    });
    return result.future;
  }
}
