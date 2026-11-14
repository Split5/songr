import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../diagnostics/app_metrics.dart';
import '../../models/models.dart';
import 'logical_queue.dart';
import 'native_window_policy.dart';
import 'playback_coordinator.dart';
import 'playback_media_resolver.dart';
import 'queue_edit_planner.dart';

/// Incremental just_audio adapter for the bounded native queue window.
///
/// Queue edits are transformed with native insert/remove/move operations, so
/// reordering Up Next does not reload or seek the currently playing source.
///
/// A cold start prepares only the tapped entry. Every
/// source is a remote Subsonic stream, so handing over the whole lookahead
/// window made the tap wait for dozens of connections before the first sound.
/// The rest of the window is appended while the song is already playing and
/// [windowReady] reports when the lookahead is complete.
class JustAudioNativePort implements NativePlaybackPort {
  JustAudioNativePort({
    required this.resolver,
    AudioPlayer? player,
    this.cacheDirectory,
  }) : player = player ?? AudioPlayer();

  /// Lookahead is appended in small batches with a short pause between them.
  /// One burst of twenty inserts competes with the song that is already
  /// playing for the UI thread; batching keeps the fill-in invisible.
  static const int _appendBatchSize = 4;
  static const Duration _appendBatchPause = Duration(milliseconds: 12);

  /// A platform append that never completes must not wedge playback. Every
  /// reconcile waits for the fill-in, so a stalled insert would otherwise
  /// block the whole command chain until the app restarts.
  static const Duration _appendTimeout = Duration(seconds: 10);

  final PlaybackMediaResolver resolver;
  final AudioPlayer player;

  /// Where remote entries are cached while they download.
  ///
  /// A streamed FLAC cannot be seeked reliably by AVPlayer: it re-reads the
  /// file and reports a pretend position.
  // ignore: experimental_member_use
  /// [LockCachingAudioSource] puts
  /// just_audio's cached proxy in front of the stream instead — the player
  /// then seeks in byte ranges served locally, and once the download completes
  /// the same source resolves to the file itself.
  final Directory? cacheDirectory;

  /// Download progress per entry for the sources above (1.0 = fully cached).
  final Map<String, double> _cacheProgress = {};
  final Set<String> _cacheWatched = {};
  List<LogicalQueueEntry> _entries = const [];
  final Map<String, ResolvedPlaybackMedia> _mediaByEntry = {};

  /// Offset of [_entries] inside the window it was reconciled from.
  int _entriesOffset = 0;

  /// True once every entry of the last requested window is in [_entries].
  bool _windowComplete = true;

  Future<void>? _pendingAppend;
  int _windowGeneration = 0;

  /// Window whose lookahead is held back until playback is audible.
  ///
  /// A cold start prepares only the tapped entry. Handing the rest of the
  /// window to the player at the same moment opened up to twenty streams while
  /// the first one was still starting, which measured three times slower to
  /// the first byte. The fill is released by the playback controller once the
  /// song has actually been playing.
  List<LogicalQueueEntry>? _deferredLookahead;

  List<LogicalQueueEntry> get entries => List.unmodifiable(_entries);

  ResolvedPlaybackMedia? get currentMedia {
    final index = player.currentIndex;
    if (index == null || index < 0 || index >= _entries.length) return null;
    return _mediaByEntry[_entries[index].id];
  }

  ResolvedPlaybackMedia? mediaForEntry(String entryId) =>
      _mediaByEntry[entryId];

  /// Completes when the current lookahead has been handed to the player.
  /// The UI uses it to hold the queue sheet until the list is real.
  @override
  Future<void> get windowReady => _pendingAppend ?? Future<void>.value();

  /// Applies [patch] to every cached media entry that carries song [id] (the
  /// same song can sit in the queue twice). Used to keep [currentMedia] in
  /// step with metadata edits such as starring without re-resolving audio.
  void updateSong(String id, Song Function(Song song) patch) {
    for (final entry in _mediaByEntry.entries.toList()) {
      if (entry.value.song.id != id) continue;
      _mediaByEntry[entry.key] = ResolvedPlaybackMedia(
        song: patch(entry.value.song),
        uri: entry.value.uri,
        scrobbleSongId: entry.value.scrobbleSongId,
      );
    }
  }

  Stream<String?> get currentEntryIdStream => player.sequenceStateStream.map(
    (state) => state.currentSource?.tag as String?,
  );

  @override
  Future<void> reconcileQueueWindow(
    NativeQueueWindow window, {
    required QueueWindowUpdateReason reason,
  }) async {
    if (window.entries.isEmpty) {
      _deferredLookahead = null;
      _cancelPendingAppend();
      await player.stop();
      if (_entries.isNotEmpty) {
        await player.clearAudioSources();
      }
      _entries = const [];
      _entriesOffset = 0;
      _windowComplete = true;
      _mediaByEntry.clear();
      return;
    }

    final pending = _pendingAppend;
    if (pending != null) {
      // A new tap supersedes the old lookahead. Finish only the insertion
      // already in progress before replacing the native sources.
      if (reason == QueueWindowUpdateReason.replace) _cancelPendingAppend();
      await pending;
    }

    final desired = window.entries;
    final currentEntryId = _currentEntryId();
    // A newer window supersedes a lookahead that was still waiting to be
    // released; the paths below decide what to materialise now.
    _deferredLookahead = null;

    if (_entries.isEmpty || reason == QueueWindowUpdateReason.replace) {
      await _coldStart(desired, window.currentIndex);
      return;
    }

    if (_windowComplete && _entriesOffset == 0) {
      await _editInPlace(desired, window.currentIndex, reason, currentEntryId);
      return;
    }

    // A lookahead that is still filling, or a window that dropped its head to
    // start quickly, can only grow at the tail without re-opening the stream
    // that is already playing. Anything else needs a fresh cold start.
    if (currentEntryId != null &&
        desired.any((entry) => entry.id == currentEntryId) &&
        (reason != QueueWindowUpdateReason.jump ||
            _entries.any(
              (entry) => entry.id == desired[window.currentIndex].id,
            )) &&
        _extendTail(desired)) {
      if (reason == QueueWindowUpdateReason.jump) {
        final nativeIndex = window.currentIndex - _entriesOffset;
        if (nativeIndex >= 0 && nativeIndex < _entries.length) {
          await player.seek(Duration.zero, index: nativeIndex);
        }
      }
      return;
    }

    // A window opened from the middle of the queue keeps a non-zero offset, so
    // the whole-window edit path above cannot run. Such an edit used to fall
    // through to [_coldStart], which re-opened the stream that was playing and
    // restarted the song — the "Play next restarts the current song" bug. Keep
    // the played entry selected and edit only the materialised region.
    if (reason != QueueWindowUpdateReason.jump &&
        currentEntryId != null &&
        desired[window.currentIndex].id == currentEntryId &&
        await _editMaterialisedRegionInPlace(desired, currentEntryId)) {
      return;
    }

    await _coldStart(desired, window.currentIndex);
  }

  /// Applies an edit to the region the native player already holds, anchored by
  /// the entries it has materialised, without re-opening the source that is
  /// playing. Anything the desired window has after that region is appended by
  /// the usual background fill.
  ///
  /// The head anchor is required: entries before it are outside the window and
  /// would desynchronise the native list. The tail anchor is the last
  /// materialised entry that is still part of the window — an insertion pushes
  /// the window's tail out, and requiring the very last entry would send every
  /// long queue back to a full rebuild.
  ///
  /// Returns false when the materialised entries no longer line up with the
  /// desired window; only a rebuild is correct then.
  Future<bool> _editMaterialisedRegionInPlace(
    List<LogicalQueueEntry> desired,
    String currentEntryId,
  ) async {
    if (_entries.isEmpty) return false;
    final start = desired.indexWhere((entry) => entry.id == _entries.first.id);
    if (start < 0) return false;
    var end = -1;
    for (var index = _entries.length - 1; index >= 0; index--) {
      final position = desired.indexWhere(
        (entry) => entry.id == _entries[index].id,
      );
      if (position >= start) {
        end = position;
        break;
      }
    }
    if (end < start) return false;
    final region = desired.sublist(start, end + 1);
    if (!region.any((entry) => entry.id == currentEntryId)) return false;

    await _resolveMissing(region);
    for (final edit in planNativeQueueEdits(_entries, region)) {
      switch (edit) {
        case RemoveNativeQueueEntry(:final index):
          await player.removeAudioSourceAt(index);
        case MoveNativeQueueEntry(:final from, :final to):
          await player.moveAudioSource(from, to);
        case InsertNativeQueueEntry(:final index, :final entry):
          await player.insertAudioSource(index, _source(entry));
      }
    }

    _entries = List.of(region);
    _entriesOffset = start;
    _windowComplete = start + region.length >= desired.length;
    if (_windowComplete) {
      _pruneResolved(desired);
    } else {
      _fillLookahead(desired);
    }
    return true;
  }

  /// Prepares the current entry and starts the
  /// lookahead in the background.
  Future<void> _coldStart(
    List<LogicalQueueEntry> desired,
    int currentIndex,
  ) async {
    final slice = initialWindowSlice(desired.length, currentIndex);
    final initial = desired.sublist(slice.start, slice.end);
    await _resolveMissing(initial);
    final stopwatch = Stopwatch()..start();
    try {
      await player.setAudioSources([
        for (final entry in initial) _source(entry),
      ], initialIndex: currentIndex - slice.start);
      AppMetrics.duration('playback_prepare', stopwatch.elapsed);
    } catch (_) {
      AppMetrics.duration(
        'playback_prepare',
        stopwatch.elapsed,
        success: false,
      );
      rethrow;
    }
    _entries = List.of(initial);
    _entriesOffset = slice.start;
    _windowComplete = initial.length == desired.length;
    _pruneResolved(_entries);
    // The lookahead is deliberately not handed to the player here: playback
    // starts first, then [releaseLookahead] fills the window once the listener
    // actually hears the song.
    _deferredLookahead = _windowComplete ? null : desired;
  }

  /// True while a freshly started queue still holds its lookahead back.
  bool get hasDeferredLookahead => _deferredLookahead != null;

  /// Hands the held-back lookahead to the player.
  ///
  /// [limit] materialises only that many upcoming entries, so the first wave
  /// after playback starts stays small and the rest can follow once the song
  /// is clearly running.
  Future<void> releaseLookahead({int? limit}) async {
    final desired = _deferredLookahead;
    if (desired == null) return;
    _deferredLookahead = null;
    _fillLookahead(desired, maxEntries: limit);
  }

  /// Applies the window with native insert/remove/move operations. The entry
  /// that is playing stays untouched, so browsing never re-opens its stream.
  Future<void> _editInPlace(
    List<LogicalQueueEntry> desired,
    int currentIndex,
    QueueWindowUpdateReason reason,
    String? currentEntryId,
  ) async {
    await _resolveMissing(desired);
    for (final edit in planNativeQueueEdits(_entries, desired)) {
      switch (edit) {
        case RemoveNativeQueueEntry(:final index):
          await player.removeAudioSourceAt(index);
        case MoveNativeQueueEntry(:final from, :final to):
          await player.moveAudioSource(from, to);
        case InsertNativeQueueEntry(:final index, :final entry):
          await player.insertAudioSource(index, _source(entry));
      }
    }

    _entries = List.of(desired);
    _entriesOffset = 0;
    _windowComplete = true;
    _pruneResolved(desired);
    final desiredCurrentId = desired[currentIndex].id;
    if (reason == QueueWindowUpdateReason.jump ||
        currentEntryId != desiredCurrentId) {
      await player.seek(Duration.zero, index: currentIndex);
    }
  }

  /// Appends whatever the current window has after the last materialized
  /// entry. The playing source is never touched.
  ///
  /// Returns false when the materialized list no longer lines up with
  /// [desired]; the caller then has to rebuild the window.
  bool _extendTail(List<LogicalQueueEntry> desired) {
    if (_entries.isEmpty) return false;
    final lastIndex = desired.indexWhere(
      (entry) => entry.id == _entries.last.id,
    );
    if (lastIndex < 0) return false;
    final offset = lastIndex - (_entries.length - 1);
    if (offset < 0) return false;
    for (var index = 0; index < _entries.length; index++) {
      if (desired[offset + index].id != _entries[index].id) return false;
    }
    _entriesOffset = offset;
    _windowComplete = offset + _entries.length >= desired.length;
    if (_windowComplete) {
      _pruneResolved(desired);
      return true;
    }
    _fillLookahead(desired);
    return true;
  }

  void _fillLookahead(List<LogicalQueueEntry> desired, {int? maxEntries}) {
    final generation = ++_windowGeneration;
    _pendingAppend = _appendRemaining(
      desired,
      generation,
      maxEntries: maxEntries,
    );
  }

  void _cancelPendingAppend() {
    _windowGeneration++;
    _pendingAppend = null;
  }

  /// Appends the rest of the window once playback is running. Never throws: a
  /// failed lookahead must not interrupt the song; the next reconcile repairs
  /// what is missing.
  Future<void> _appendRemaining(
    List<LogicalQueueEntry> desired,
    int generation, {
    int? maxEntries,
  }) async {
    try {
      var sincePause = 0;
      var appended = 0;
      while (_entriesOffset + _entries.length < desired.length) {
        if (generation != _windowGeneration) return;
        if (maxEntries != null && appended >= maxEntries) {
          // Hold the rest until the next release.
          _deferredLookahead = desired;
          _windowComplete = false;
          _pruneResolved(desired);
          return;
        }
        final entry = desired[_entriesOffset + _entries.length];
        _mediaByEntry[entry.id] ??= await resolver.resolve(entry.songId);
        if (generation != _windowGeneration) return;
        await player
            .insertAudioSource(_entries.length, _source(entry))
            .timeout(_appendTimeout);
        if (generation != _windowGeneration) return;
        _entries = [..._entries, entry];
        appended++;
        if (++sincePause >= _appendBatchSize) {
          sincePause = 0;
          await Future<void>.delayed(_appendBatchPause);
        }
      }
      if (generation != _windowGeneration) return;
      _windowComplete = true;
      _pruneResolved(desired);
    } catch (_) {
      // Keep playing; the next reconcile resumes the fill-in.
    } finally {
      if (generation == _windowGeneration) _pendingAppend = null;
    }
  }

  Future<void> _resolveMissing(List<LogicalQueueEntry> entries) async {
    for (final entry in entries) {
      _mediaByEntry[entry.id] ??= await resolver.resolve(entry.songId);
    }
  }

  AudioSource _source(LogicalQueueEntry entry) {
    final media = _mediaByEntry[entry.id]!;
    final uri = media.uri;
    final directory = cacheDirectory;
    if (uri.isScheme('file') || directory == null) {
      return AudioSource.uri(uri, tag: entry.id);
    }
    final digest = sha256.convert(utf8.encode(media.song.id)).toString();
    final suffix = media.song.suffix.toLowerCase();
    final name = suffix.isEmpty ? digest : '$digest.$suffix';
    // ignore: experimental_member_use
    final source = LockCachingAudioSource(
      uri,
      cacheFile: File('${directory.path}/$name'),
      tag: entry.id,
    );
    if (_cacheWatched.add(entry.id)) {
      _cacheProgress[entry.id] = 0;
      source.downloadProgressStream
          .listen((progress) {
            _cacheProgress[entry.id] = progress;
          })
          .onError((Object _) {});
    }
    return source;
  }

  /// 1.0 once the entry is fully on disk, 0.0 while it downloads, null when
  /// the entry is not a stream at all (a downloaded song plays from its file).
  double? cacheProgressFor(String entryId) => _cacheProgress[entryId];

  /// Test seam for [cacheProgressFor].
  @visibleForTesting
  void debugSetCacheProgress(String entryId, double progress) =>
      _cacheProgress[entryId] = progress;

  /// Waits until [entryId] is fully cached, giving up after [timeout] so a
  /// stalled download can never wedge the player.
  ///
  /// A seek into an entry that is still downloading leaves AVPlayer stuck in
  /// `buffering` at the target: the byte range it asks for is not there yet.
  /// Waiting for the cache first turns that into an exact seek.
  Future<bool> waitForCached(
    String entryId, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    if (!_cacheProgress.containsKey(entryId)) return false;
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      if ((_cacheProgress[entryId] ?? 0) >= 1) return true;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    return (_cacheProgress[entryId] ?? 0) >= 1;
  }

  String? _currentEntryId() {
    final index = player.currentIndex;
    return index == null || index < 0 || index >= _entries.length
        ? null
        : _entries[index].id;
  }

  void _pruneResolved(List<LogicalQueueEntry> desired) {
    final ids = desired.map((entry) => entry.id).toSet();
    _mediaByEntry.removeWhere((id, _) => !ids.contains(id));
  }

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  Future<void> playExternal({required Uri uri, required String tag}) async {
    _deferredLookahead = null;
    _cancelPendingAppend();
    _entries = const [];
    _entriesOffset = 0;
    _windowComplete = true;
    _mediaByEntry.clear();
    final stopwatch = Stopwatch()..start();
    try {
      await player.setAudioSource(AudioSource.uri(uri, tag: tag));
      AppMetrics.duration('radio_prepare', stopwatch.elapsed);
    } catch (_) {
      AppMetrics.duration('radio_prepare', stopwatch.elapsed, success: false);
      rethrow;
    }
    final errorZone = Zone.current;
    unawaited(
      player.play().catchError((Object error, StackTrace stackTrace) {
        errorZone.handleUncaughtError(error, stackTrace);
      }),
    );
  }

  Future<void> dispose() => player.dispose();
}
