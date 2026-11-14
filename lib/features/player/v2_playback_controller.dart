import 'dart:async';
import 'dart:math';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../../domain/diagnostics/app_metrics.dart';
import '../../domain/playback/just_audio_native_port.dart';
import '../../domain/playback/logical_queue.dart';
import '../../domain/playback/playback_coordinator.dart';
import 'lyrics_playhead.dart';
import '../../domain/playback/playback_media_resolver.dart';
import '../../domain/playback/queue_session_repository.dart';
import '../../domain/playback/radio_stream_uri.dart';
import '../../domain/playback/scrobble_tracker.dart';
import '../../domain/playback/server_play_queue.dart';
import '../../models/models.dart';
import '../../state/download_provider.dart';
import 'sleep_timer_controller.dart';

enum V2RepeatMode { off, one, all }

class V2PlaybackController extends ChangeNotifier {
  V2PlaybackController({
    required this.nativePort,
    required this.coordinator,
    required this.scrobbleTracker,
    this.queueSessions,
    this.serverQueue,
    Random? random,
  }) : _random = random ?? Random.secure() {
    sleepTimer = SleepTimerController(coordinator.pause);
    _subscriptions.add(
      coordinator.queueChanges.listen((queue) {
        _queue = queue;
        // The tapped song is part of a live queue now; the start feedback has
        // done its job. A queue published by an earlier, superseded tap must
        // not take the feedback over — that is what made two quick taps
        // switch the mini player back and forth.
        if (_pendingSong != null &&
            (_pendingEntryId == null || queue.current?.id == _pendingEntryId)) {
          _pendingSong = null;
          _pendingEntryId = null;
          _startFeedbackTimeout?.cancel();
          _startFeedbackTimeout = null;
        }
        if (!_restoring) {
          _queueRevision++;
          _saveQueue();
          _scheduleServerQueueSave();
        }
        notifyListeners();
      }),
    );
    _subscriptions.add(
      nativePort.currentEntryIdStream.distinct().listen(_onCurrentEntry),
    );
    unawaited(_watchInterruptions());
    _subscriptions.add(
      nativePort.player.positionStream.listen((position) {
        _position = position;
        positionListenable.value = position;
        _releaseLookaheadIfDue(position);
        final playbackId = _playbackId;
        if (playbackId != null &&
            (position - _lastScrobblePosition).abs() >=
                const Duration(seconds: 1)) {
          _lastScrobblePosition = position;
          unawaited(
            scrobbleTracker.position(
              playbackId: playbackId,
              position: position,
            ),
          );
        }
        _persistPositionIfDue();
        sleepTimer.checkDeadline();
      }),
    );
    _subscriptions.add(
      nativePort.player.durationStream.listen((duration) {
        _duration = duration ?? Duration.zero;
        notifyListeners();
      }),
    );
    _subscriptions.add(
      nativePort.player.playerStateStream.listen((state) {
        _playing = state.playing;
        _processingState = state.processingState;
        notifyListeners();
        if (state.processingState == ProcessingState.completed) {
          unawaited(_handleCompleted());
        }
      }),
    );
    _subscriptions.add(
      nativePort.player.errorStream.listen((_) {
        AppMetrics.count('playback_errors');
      }),
    );
  }

  final JustAudioNativePort nativePort;
  final PlaybackCoordinator coordinator;
  final ScrobbleTracker scrobbleTracker;
  final QueueSessionRepository? queueSessions;
  final ServerPlayQueueGateway? serverQueue;

  /// Source of randomness for every shuffle in the app. Injectable so tests
  /// can pin the resulting order.
  final Random _random;
  late final SleepTimerController sleepTimer;
  final ValueNotifier<Duration> positionListenable = ValueNotifier(
    Duration.zero,
  );

  /// The id of the song at the queue playhead, or null while nothing is
  /// queued (for example during radio). Song rows listen to this instead of
  /// the whole controller so a track change repaints only their glyph.
  final ValueNotifier<String?> currentSongIdListenable = ValueNotifier(null);

  /// Mirrors [playing] for the same targeted rebuilds.
  final ValueNotifier<bool> playingListenable = ValueNotifier(false);

  /// True while the queue behind the song at the playhead is still being
  /// prepared: the lookahead is filling in, or a similarity mix is still being
  /// fetched. The player's queue action shows a progress ring while this is
  /// true and opens Up Next when it turns false, so a fast tap never shows a
  /// half-built list.
  final ValueNotifier<bool> queuePreparing = ValueNotifier(false);
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  LogicalQueue _queue = const LogicalQueue.empty();
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _playing = false;
  ProcessingState _processingState = ProcessingState.idle;
  String? _playbackId;
  InternetRadioStation? _station;
  final Map<String, Song> _songsById = {};

  /// Tapped song that is still being prepared. It feeds the mini player and the
  /// row highlight immediately, so a tap feels acknowledged before the first
  /// stream byte arrives.
  Song? _pendingSong;
  String? _pendingEntryId;
  Timer? _startFeedbackTimeout;
  int _playbackSerial = 0;
  bool _handlingCompletion = false;
  V2RepeatMode _repeatMode = V2RepeatMode.off;
  bool _restoring = false;
  bool _resourcesClosed = false;
  Future<void> _persistenceTail = Future.value();
  Future<void> _serverPersistenceTail = Future.value();
  Future<bool>? _serverReconcileInFlight;
  Timer? _serverQueueDebounce;
  int _queueRevision = 0;
  DateTime _lastPositionPersisted = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastServerPositionPersisted = DateTime.fromMillisecondsSinceEpoch(
    0,
  );
  Duration _lastScrobblePosition = Duration.zero;

  LogicalQueue get queue => _queue;

  /// True while the tapped song is being prepared by the player.
  bool get startingPlayback => _pendingSong != null;

  Song? get currentSong {
    if (_pendingSong case final pending?) return pending;
    final current = _queue.current;
    if (current != null) {
      final queued = _songsById[current.songId];
      if (queued != null) return queued;
    }
    return nativePort.currentMedia?.song;
  }

  ResolvedPlaybackMedia? get currentMedia => nativePort.currentMedia;

  InternetRadioStation? get currentStation => _station;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get playing => _playing;
  ProcessingState get processingState => _processingState;
  bool get autoPlayEnabled => coordinator.autoPlayEnabled;
  V2RepeatMode get repeatMode => _repeatMode;

  /// True when [songId] is the song at the queue playhead.
  bool isCurrent(String songId) => currentSongIdListenable.value == songId;

  Future<void>? _queuePreparation;

  /// Completes when the queue is fully prepared; already complete when idle.
  Future<void> get queueReady => _queuePreparation ?? Future<void>.value();

  /// Marks the queue as preparing until [work] and the native lookahead are
  /// both done. Playback starts as soon as the player has the tapped song, so
  /// this never delays the first sound.
  void _trackQueuePreparation(Future<void> Function() work) {
    if (_resourcesClosed) return;
    final run = () async {
      await work();
      await coordinator.queueReady;
    }();
    _queuePreparation = run;
    queuePreparing.value = true;
    notifyListeners();
    unawaited(
      run.catchError((Object _) {}).whenComplete(() {
        if (!identical(_queuePreparation, run)) return;
        _queuePreparation = null;
        if (_resourcesClosed) return;
        queuePreparing.value = false;
        notifyListeners();
      }),
    );
  }

  void _beginStartFeedback(Song song, {String? entryId}) {
    _startFeedbackTimeout?.cancel();
    _pendingSong = song;
    _pendingEntryId = entryId;
    // A stream that never opens must not leave the play control ringing.
    _startFeedbackTimeout = Timer(const Duration(seconds: 12), () {
      _startFeedbackTimeout = null;
      if (_pendingSong == null) return;
      _pendingSong = null;
      notifyListeners();
    });
    notifyListeners();
  }

  void _clearStartFeedback() {
    _startFeedbackTimeout?.cancel();
    _startFeedbackTimeout = null;
    final hadPending = _pendingSong != null;
    _pendingSong = null;
    _pendingEntryId = null;
    if (hadPending) notifyListeners();
  }

  /// Every state change goes through here, so the targeted listenables are
  /// always in step with the coarse [ChangeNotifier] notification.
  @override
  void notifyListeners() {
    if (!_resourcesClosed) {
      final currentEntry = _queue.current;
      final queuedSong = currentEntry == null
          ? null
          : _songsById[currentEntry.songId];
      currentSongIdListenable.value = _station != null
          ? null
          : _pendingSong?.id ??
                queuedSong?.id ??
                currentEntry?.songId ??
                currentSong?.id;
      playingListenable.value = _playing;
    }
    super.notifyListeners();
  }

  Future<bool> restoreSession() async {
    final repository = queueSessions;
    if (repository == null || _queue.entries.isNotEmpty) return false;
    final session = await repository.load();
    if (session == null) return false;
    _restoring = true;
    try {
      await coordinator.setAutoPlay(session.autoPlayEnabled);
      await coordinator.replaceQueue(
        session.entries,
        startEntryId: session.currentEntryId,
        playImmediately: false,
      );
      if (session.position > Duration.zero) {
        await nativePort.player.seek(session.position);
      }
      // Queue changes are broadcast asynchronously. Keep the restore guard in
      // place through the next microtask so restoration is not mistaken for a
      // user mutation and immediately written back to the server.
      await Future<void>.delayed(Duration.zero);
      return true;
    } finally {
      _restoring = false;
      _lastPositionPersisted = DateTime.now();
    }
  }

  /// Reconciles Navidrome's cross-client queue after the local queue has been
  /// restored. A delayed network response is ignored if the user has changed
  /// the queue or started playback in the meantime.
  Future<bool> reconcileServerQueue() {
    final active = _serverReconcileInFlight;
    if (active != null) return active;
    final tracked = _reconcileServerQueue().whenComplete(
      () => _serverReconcileInFlight = null,
    );
    _serverReconcileInFlight = tracked;
    return tracked;
  }

  Future<bool> _reconcileServerQueue() async {
    final gateway = serverQueue;
    if (gateway == null) return false;
    final revision = _queueRevision;
    final local = await queueSessions?.load();
    final remote = await gateway.load();
    if (remote == null ||
        remote.songIds.isEmpty ||
        revision != _queueRevision ||
        playing ||
        _station != null) {
      return false;
    }
    // This device already has a queue — restored from its own session or
    // playing right now. The server's copy is only a starting point for a
    // fresh session: adopting it here replaced the live queue with whatever
    // the server last saw, which could stop the song that was playing and
    // start a different one (it is also how returning to the app rebuilt the
    // player and showed 0:00). An identical queue is never newer either,
    // whatever its timestamp says.
    if (local != null || _queue.entries.isNotEmpty) return false;

    // Reaching here means this device has no saved session and no queue of
    // its own: the server queue is the only thing to resume.

    final serial =
        remote.changedAt?.microsecondsSinceEpoch ??
        DateTime.now().microsecondsSinceEpoch;
    final entries = [
      for (var index = 0; index < remote.songIds.length; index++)
        LogicalQueueEntry(
          id: 'server-$serial-$index-${remote.songIds[index]}',
          songId: remote.songIds[index],
        ),
    ];
    final currentSongId = remote.currentSongId;
    final currentIndex = currentSongId == null
        ? 0
        : entries.indexWhere((entry) => entry.songId == currentSongId);
    final start = entries[currentIndex < 0 ? 0 : currentIndex];
    _restoring = true;
    try {
      await coordinator.replaceQueue(
        entries,
        startEntryId: start.id,
        playImmediately: false,
      );
      if (remote.position > Duration.zero) {
        await nativePort.player.seek(remote.position);
      }
      await Future<void>.delayed(Duration.zero);
      final queue = coordinator.queue;
      _queue = queue;
      await queueSessions?.save(
        queue: queue,
        autoPlayEnabled: coordinator.autoPlayEnabled,
        position: remote.position,
      );
      return true;
    } finally {
      _restoring = false;
      _lastPositionPersisted = DateTime.now();
      _lastServerPositionPersisted = DateTime.now();
    }
  }

  /// Plays a collection. [startIndex] selects the tapped row for an in-order
  /// start; with [shuffle] the whole collection is randomised, exactly like
  /// Navidrome's own "Shuffle All", so it never begins on the first row.
  Future<void> playSongs(
    List<Song> songs, {
    int startIndex = 0,
    bool shuffle = false,
  }) async {
    if (songs.isEmpty) return;
    // Product invariant: selecting a lone song must never create a dead-end
    // one-item queue. Collections preserve their real order; a lone song
    // becomes a similarity-backed sonic mix (Navidrome getSimilarSongs2).
    if (songs.length == 1) {
      await playSonicMix(songs.single);
      return;
    }
    _station = null;
    _songsById.addEntries(songs.map((song) => MapEntry(song.id, song)));
    final boundedStart = startIndex.clamp(0, songs.length - 1);
    final ordered = shuffle ? _shuffled(songs) : List.of(songs);
    final actualStart = shuffle ? 0 : boundedStart;
    final entries = [
      for (var index = 0; index < ordered.length; index++)
        LogicalQueueEntry(
          id: 'queue-${DateTime.now().microsecondsSinceEpoch}-$index',
          songId: ordered[index].id,
        ),
    ];
    _beginStartFeedback(ordered[actualStart], entryId: entries[actualStart].id);
    final replace = coordinator.replaceQueue(
      entries,
      startEntryId: entries[actualStart].id,
    );
    _trackQueuePreparation(() => replace);
    try {
      await replace;
    } catch (error) {
      _clearStartFeedback();
      rethrow;
    }
  }

  /// Plays downloaded entries as a local queue. The synthetic queue id keeps
  /// equal server song ids from different accounts distinct while the exposed
  /// [Song] still carries its original server id for display and scrobbling.
  Future<void> playDownloaded(
    List<DownloadedEntry> entries, {
    int startIndex = 0,
    bool shuffle = false,
  }) async {
    final playable = entries.where((entry) => entry.song != null).toList();
    if (playable.isEmpty) return;
    _station = null;
    final boundedStart = startIndex.clamp(0, playable.length - 1);
    final ordered = shuffle
        ? _shuffled(playable)
        : List<DownloadedEntry>.of(playable);
    final actualStart = shuffle ? 0 : boundedStart;
    final serial = DateTime.now().microsecondsSinceEpoch;
    final queueEntries = <LogicalQueueEntry>[];
    for (var index = 0; index < ordered.length; index++) {
      final entry = ordered[index];
      final song = entry.song!;
      _songsById[entry.playbackKey] = song;
      queueEntries.add(
        LogicalQueueEntry(
          id: 'download-$serial-$index',
          songId: entry.playbackKey,
        ),
      );
    }
    _beginStartFeedback(
      ordered[actualStart].song!,
      entryId: queueEntries[actualStart].id,
    );
    final replace = coordinator.replaceQueue(
      queueEntries,
      startEntryId: queueEntries[actualStart].id,
    );
    _trackQueuePreparation(() => replace);
    try {
      await replace;
    } catch (error) {
      _clearStartFeedback();
      rethrow;
    }
  }

  /// Starts the selected Home song immediately, then lets Navidrome's
  /// similarity agent (`getSimilarSongs2`) build the rest of the queue.
  Future<void> playSonicMix(Song seed) async {
    _station = null;
    _songsById[seed.id] = seed;
    final entry = LogicalQueueEntry(
      id: 'sonic-${DateTime.now().microsecondsSinceEpoch}-${seed.id}',
      songId: seed.id,
    );
    _beginStartFeedback(seed, entryId: entry.id);
    final mix = coordinator.startAutoPlayMix(entry);
    _trackQueuePreparation(() => mix);
    try {
      await mix;
    } catch (error) {
      _clearStartFeedback();
      rethrow;
    }
  }

  Future<void> playStation(InternetRadioStation station) async {
    final uri = parseRadioStreamUri(station.streamUrl);
    if (uri == null) {
      throw const FormatException('Unsupported radio stream URL');
    }
    _clearStartFeedback();
    await _endCurrent(skipped: false);
    await coordinator.clear();
    _station = station;
    notifyListeners();
    await nativePort.playExternal(uri: uri, tag: 'radio:${station.id}');
  }

  Future<String> playNext(Song song) async {
    _station = null;
    _songsById[song.id] = song;
    final entry = LogicalQueueEntry(
      id: 'next-${DateTime.now().microsecondsSinceEpoch}-${song.id}',
      songId: song.id,
    );
    if (_queue.entries.isEmpty) {
      _beginStartFeedback(song, entryId: entry.id);
      try {
        await coordinator.replaceQueue([entry], startEntryId: entry.id);
      } catch (error) {
        _clearStartFeedback();
        rethrow;
      }
    } else {
      await coordinator.insertNext([entry]);
    }
    return entry.id;
  }

  Future<void> appendSongs(List<Song> songs) async {
    if (songs.isEmpty) return;
    _station = null;
    _songsById.addEntries(songs.map((song) => MapEntry(song.id, song)));
    final serial = DateTime.now().microsecondsSinceEpoch;
    final entries = [
      for (var index = 0; index < songs.length; index++)
        LogicalQueueEntry(
          id: 'append-$serial-$index-${songs[index].id}',
          songId: songs[index].id,
        ),
    ];
    if (_queue.entries.isEmpty) {
      await coordinator.replaceQueue(entries, startEntryId: entries.first.id);
    } else {
      await coordinator.append(entries);
    }
  }

  /// Replaces only the future part of the logical queue. The current entry,
  /// native playhead and already-played history remain untouched.
  Future<void> replaceUpcomingSongs(List<Song> songs) async {
    _songsById.addEntries(songs.map((song) => MapEntry(song.id, song)));
    final serial = DateTime.now().microsecondsSinceEpoch;
    final entries = [
      for (var index = 0; index < songs.length; index++)
        LogicalQueueEntry(
          id: 'tuned-$serial-$index-${songs[index].id}',
          songId: songs[index].id,
        ),
    ];
    await coordinator.replaceUpcoming(entries);
  }

  Future<List<Song>> queueSongs({bool upcomingOnly = false}) async {
    final start = upcomingOnly ? queue.currentIndex + 1 : 0;
    if (start < 0 || start >= queue.entries.length) return const [];
    final resolved = <Song>[];
    for (final entry in queue.entries.skip(start)) {
      final song = await songForEntry(entry);
      if (song != null) resolved.add(song);
    }
    return List.unmodifiable(resolved);
  }

  Future<void> shuffleUpNext() async {
    if (_queue.currentIndex < 0 ||
        _queue.currentIndex >= _queue.entries.length - 2) {
      return;
    }
    final prefix = _queue.entries.take(_queue.currentIndex + 1).toList();
    final tail = _queue.entries.skip(_queue.currentIndex + 1).toList()
      ..shuffle(_random);
    await coordinator.reorder([...prefix, ...tail]);
  }

  Future<void> cycleRepeat() async {
    _repeatMode = switch (_repeatMode) {
      V2RepeatMode.off => V2RepeatMode.all,
      V2RepeatMode.all => V2RepeatMode.one,
      V2RepeatMode.one => V2RepeatMode.off,
    };
    await nativePort.player.setLoopMode(
      _repeatMode == V2RepeatMode.one ? LoopMode.one : LoopMode.off,
    );
    notifyListeners();
  }

  Future<void> setRepeatMode(V2RepeatMode mode) async {
    if (_repeatMode == mode) return;
    _repeatMode = mode;
    await nativePort.player.setLoopMode(
      mode == V2RepeatMode.one ? LoopMode.one : LoopMode.off,
    );
    notifyListeners();
  }

  /// Reflects a favourite toggle made anywhere in the app on the cached
  /// song objects the player and queue read from, so the heart in the full
  /// player never lags behind a list row.
  void markSongStarred(String songId, bool starred) {
    Song patch(Song song) => song..starred = starred;
    final cached = _songsById[songId];
    if (cached != null) patch(cached);
    nativePort.updateSong(songId, patch);
    notifyListeners();
  }

  Future<Song?> songForEntry(LogicalQueueEntry entry) async {
    final cached = _songsById[entry.songId];
    if (cached != null) return cached;
    try {
      final resolved = await nativePort.resolver.resolve(entry.songId);
      _songsById[entry.songId] = resolved.song;
      return resolved.song;
    } catch (_) {
      return null;
    }
  }

  Future<void> togglePlayback() =>
      playing ? coordinator.pause() : coordinator.play();

  Future<void> jumpTo(String entryId) => coordinator.jumpTo(entryId);

  Future<void> next() async {
    final skipped = _playedFraction < 0.3;
    final next = await coordinator.prepareNextEntry();
    if (next == null) return;
    await _endCurrent(skipped: skipped);
    await coordinator.jumpTo(next.id);
  }

  Future<void> previous() async {
    if (_position > const Duration(seconds: 5)) {
      await nativePort.player.seek(Duration.zero);
      return;
    }
    final previousIndex = _queue.currentIndex - 1;
    if (previousIndex < 0) return;
    await _endCurrent(skipped: false);
    await coordinator.jumpTo(_queue.entries[previousIndex].id);
  }

  Future<void> seek(Duration position) => nativePort.player.seek(position);

  /// The player's position for the lyric view: its value at this instant and a
  /// roughly thirty-a-second stream of what follows.
  ///
  /// Both come from just_audio itself, which freezes the position while
  /// buffering and moves it on a seek. The lyrics therefore cannot drift from
  /// the audio the way an independent clock did.
  LyricsPlayhead createLyricsPlayhead() => LyricsPlayhead(
    now: () => nativePort.player.position,
    updates: nativePort.player.createPositionStream(
      minPeriod: const Duration(milliseconds: 32),
      maxPeriod: const Duration(milliseconds: 32),
    ),
  );

  Future<void> moveBefore(String entryId, String? beforeEntryId) =>
      coordinator.moveBefore(entryId, beforeEntryId);

  Future<void> remove(String entryId) => coordinator.remove(entryId);

  Future<void> setAutoPlay(bool enabled) async {
    await coordinator.setAutoPlay(enabled);
    _saveQueue();
    notifyListeners();
  }

  /// The next song is only prepared once the listener actually hears audio.
  ///
  /// Opening the whole lookahead while the tapped song was still starting put
  /// up to twenty stream requests on the same connection at once and measured
  /// three times slower to the first byte. The first wave (four upcoming songs)
  /// goes out after one second of playback, the rest of the window after five.
  static const Duration _lookaheadFirstWave = Duration(seconds: 1);
  static const Duration _lookaheadRest = Duration(seconds: 5);
  static const int _lookaheadFirstWaveSize = 4;

  /// Queue entry the lookahead staging belongs to; a new entry resets it.
  String? _lookaheadEntryId;
  int _lookaheadStage = 0;

  void _releaseLookaheadIfDue(Duration position) {
    final current = _queue.current;
    if (current != null && current.id != _lookaheadEntryId) {
      _lookaheadEntryId = current.id;
      _lookaheadStage = 0;
    }
    if (!nativePort.hasDeferredLookahead) return;
    if (position >= _lookaheadRest) {
      if (_lookaheadStage >= 2) return;
      _lookaheadStage = 2;
      unawaited(nativePort.releaseLookahead());
      return;
    }
    if (position >= _lookaheadFirstWave && _lookaheadStage < 1) {
      _lookaheadStage = 1;
      unawaited(nativePort.releaseLookahead(limit: _lookaheadFirstWaveSize));
    }
  }

  double get _playedFraction => duration.inMilliseconds <= 0
      ? 0
      : position.inMilliseconds / duration.inMilliseconds;

  /// Uniform random order for a collection. Pinning the selected row first
  /// made every shuffle start on the top of the list, which is not what
  /// Navidrome's "Shuffle All" does and not what the shuffle button promises.
  List<T> _shuffled<T>(List<T> songs) => List<T>.of(songs)..shuffle(_random);

  bool _resumeAfterInterruption = false;

  /// A phone call, Siri or a notification can take the audio session away.
  /// iOS does not always hand playback back by itself, and a stream that was
  /// interrupted can stay silent while the playhead keeps running, so the
  /// session is activated again and the current position re-requested.
  Future<void> _watchInterruptions() async {
    final session = await AudioSession.instance;
    _subscriptions.add(
      session.interruptionEventStream.listen((event) async {
        if (event.begin) {
          _resumeAfterInterruption = _playing;
          return;
        }
        if (!_resumeAfterInterruption) return;
        _resumeAfterInterruption = false;
        try {
          await session.setActive(true);
          await nativePort.player.seek(nativePort.player.position);
          await nativePort.player.play();
        } catch (_) {
          // Nothing more to do; the listener can still start a song again.
        }
      }),
    );
  }

  Future<void> _onCurrentEntry(String? entryId) async {
    if (entryId == null) return;
    if (entryId.startsWith('radio:')) {
      notifyListeners();
      return;
    }
    await coordinator.handleNativeCurrentEntry(entryId);
    final media = nativePort.mediaForEntry(entryId);
    if (media == null) return;
    final oldPlayback = _playbackId;
    if (oldPlayback != null) {
      await scrobbleTracker.clear(playbackId: oldPlayback);
    }
    final scrobbleSongId = media.scrobbleSongId;
    if (scrobbleSongId == null) {
      _playbackId = null;
      _lastScrobblePosition = Duration.zero;
      notifyListeners();
      return;
    }
    final playbackId = '$entryId-${_playbackSerial++}';
    _playbackId = playbackId;
    _lastScrobblePosition = Duration.zero;
    await scrobbleTracker.start(
      playbackId: playbackId,
      songId: scrobbleSongId,
      duration: Duration(seconds: media.song.duration),
    );
    notifyListeners();
  }

  Future<void> _handleCompleted() async {
    if (_handlingCompletion) return;
    _handlingCompletion = true;
    try {
      final completedEntryId = coordinator.queue.current?.id;
      if (completedEntryId == null) return;
      final playbackId = _playbackId;
      if (playbackId != null) {
        await scrobbleTracker.completed(playbackId: playbackId);
      }
      final queue = coordinator.queue;
      if (queue.current?.id != completedEntryId) return;
      if (_repeatMode == V2RepeatMode.all &&
          queue.currentIndex == queue.entries.length - 1) {
        await coordinator.jumpTo(
          queue.entries.first.id,
          expectedCurrentEntryId: completedEntryId,
        );
        return;
      }
      // The native source may finish before its background lookahead arrives.
      // Advance the logical queue, including AutoPlay, then prepare that song.
      final next = await coordinator.prepareNextEntry(
        expectedCurrentEntryId: completedEntryId,
      );
      if (next != null) {
        await coordinator.jumpTo(
          next.id,
          expectedCurrentEntryId: completedEntryId,
        );
      }
    } finally {
      _handlingCompletion = false;
    }
  }

  Future<void> _endCurrent({required bool skipped}) async {
    final playbackId = _playbackId;
    if (playbackId == null) return;
    await scrobbleTracker.clear(playbackId: playbackId, skipped: skipped);
    _playbackId = null;
  }

  void _saveQueue() {
    final repository = queueSessions;
    if (repository == null) return;
    final queue = _queue;
    final position = _position;
    final autoplay = coordinator.autoPlayEnabled;
    _persistenceTail = _persistenceTail
        .then((_) async {
          if (queue.entries.isEmpty) {
            await repository.clear();
          } else {
            await repository.save(
              queue: queue,
              autoPlayEnabled: autoplay,
              position: position,
            );
          }
        })
        .catchError((_) {});
  }

  void _persistPositionIfDue() {
    final repository = queueSessions;
    if (repository == null || _queue.entries.isEmpty || _restoring) return;
    final now = DateTime.now();
    if (now.difference(_lastPositionPersisted) < const Duration(seconds: 10)) {
      return;
    }
    _lastPositionPersisted = now;
    final position = _position;
    _persistenceTail = _persistenceTail
        .then((_) => repository.updatePosition(position))
        .catchError((_) {});
    if (now.difference(_lastServerPositionPersisted) >=
        const Duration(seconds: 15)) {
      _lastServerPositionPersisted = now;
      _scheduleServerQueueSave(delay: const Duration(milliseconds: 250));
    }
  }

  void _scheduleServerQueueSave({Duration delay = const Duration(seconds: 1)}) {
    if (serverQueue == null || _restoring || _station != null) return;
    _serverQueueDebounce?.cancel();
    _serverQueueDebounce = Timer(delay, () {
      _serverQueueDebounce = null;
      _serverPersistenceTail = _serverPersistenceTail
          .then((_) => _persistServerQueue())
          .catchError((_) {});
    });
  }

  Future<void> _persistServerQueue() async {
    final gateway = serverQueue;
    if (gateway == null || _station != null) return;
    final queue = _queue;
    await gateway.save(
      songIds: queue.entries
          .map((entry) => entry.songId)
          .toList(growable: false),
      currentSongId: queue.current?.songId,
      position: _position,
    );
  }

  Future<void> shutdown() async {
    if (_resourcesClosed) return;
    _resourcesClosed = true;
    _serverQueueDebounce?.cancel();
    _serverQueueDebounce = null;
    _startFeedbackTimeout?.cancel();
    _startFeedbackTimeout = null;
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    final repository = queueSessions;
    if (repository != null && _queue.entries.isNotEmpty) {
      await _persistenceTail;
      await repository.updatePosition(_position);
    }
    if (serverQueue != null && _station == null) {
      await _serverPersistenceTail;
      await _persistServerQueue()
          .timeout(const Duration(seconds: 3))
          .catchError((_) {});
    }
    sleepTimer.dispose();
    await scrobbleTracker.dispose();
    await coordinator.dispose();
    await nativePort.dispose();
    positionListenable.dispose();
    currentSongIdListenable.dispose();
    playingListenable.dispose();
    queuePreparing.dispose();
  }

  @override
  void dispose() {
    if (!_resourcesClosed) unawaited(shutdown());
    super.dispose();
  }
}
