// Release-device check using only the already saved main profile.
// Build with --target tool/main_profile_check.dart; results are saved in
// Documents/agent-verification.json. No credentials are logged or exported.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:path_provider/path_provider.dart';

import 'package:navimusic/app/v2/v2_runtime.dart';
import 'package:navimusic/app/v2/v2_server_settings.dart';
import 'package:navimusic/data/local/navidrome_playback_media_resolver.dart';
import 'package:navimusic/domain/library/song_filter.dart';
import 'package:navimusic/domain/playback/just_audio_native_port.dart';
import 'package:navimusic/domain/playback/logical_queue.dart';
import 'package:navimusic/domain/playback/playback_coordinator.dart';
import 'package:navimusic/domain/playback/playback_media_resolver.dart';
import 'package:navimusic/design_system/navi_theme.dart';
import 'package:navimusic/features/home/v2_home_screen.dart';
import 'package:navimusic/l10n/app_localizations.dart';

void _check(bool condition, String message) {
  if (!condition) throw StateError(message);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      home: Scaffold(body: Center(child: Text('Verifierar simon_b…'))),
    ),
  );
  FlutterNativeSplash.remove();
  final file = File(
    '${(await getApplicationDocumentsDirectory()).path}/agent-verification.json',
  );
  final report = <String, Object?>{'stage': 'started'};
  Future<void> save() => file.writeAsString(jsonEncode(report), flush: true);
  await save();
  final settings = V2ServerSettings();
  V2Runtime? runtime;
  try {
    await settings.load();
    _check(settings.username == 'simon_b', 'Saved profile must be simon_b');
    _check(settings.isConfigured, 'Saved main profile is not configured');
    await settings.api!.ping();
    report.addAll({'stage': 'authenticated', 'profile': settings.username});
    await save();
    runtime = await V2Runtime.create(settings);
    if (await runtime.songLibrary.count(const SongFilter()) < 1000) {
      report['stage'] = 'syncing';
      await save();
      _check(await runtime.syncEntireLibrary(), 'Main library sync failed');
    }
    final songCount = await runtime.songLibrary.count(const SongFilter());
    _check(songCount > 1000, 'Main library must contain over 1000 songs');
    report.addAll({'stage': 'home', 'songs': songCount});
    await save();
    await runtime.home.initialize();
    report['home_pull'] = await _checkHomePull(
      runtime,
      onUpdated: (result) async {
        report['home_pull'] = result;
        await save();
      },
    );
    report['stage'] = 'artists';
    await save();
    await runtime.artists.refresh();
    final artistCount = runtime.artists.state.totalCount;
    final firstPage = runtime.artists.state.items;
    await runtime.artists.loadMore();
    final artists = runtime.artists.state.items;
    _check(runtime.artists.state.error == null, 'Artist paging failed');
    _check(
      artists.map((a) => a.id).toSet().length == artists.length,
      'Duplicate artists across pages',
    );
    _check(artists.length > firstPage.length, 'Artist second page must load');
    final sample = firstPage.reduce(
      (a, b) => a.albumCount >= b.albumCount ? a : b,
    );
    final artistSongs = await runtime.catalog.songsForArtist(sample);
    final artistAlbums = await runtime.catalog.albumsForArtist(sample);
    await runtime.artists.refresh(query: sample.name);
    _check(
      runtime.artists.state.items.any((a) => a.id == sample.id),
      'Artist search must find the selected artist',
    );
    report.addAll({
      'artists': artistCount,
      'artist_pages_loaded': artists.length,
      'sample_artist_songs': artistSongs.length,
      'sample_artist_albums': artistAlbums.length,
      'stage': 'playback',
    });
    await save();
    final songs = await runtime.songLibrary.page(
      filter: const SongFilter(),
      limit: 60,
      offset: 0,
    );
    final resolver = NavidromePlaybackMediaResolver(
      database: runtime.database,
      api: settings.api!,
    );
    final timings = <Map<String, Object?>>[];
    final cache = await Directory(
      '${(await getTemporaryDirectory()).path}/startup-check-${DateTime.now().microsecondsSinceEpoch}',
    ).create();
    try {
      for (final song
          in songs
              .where((s) => s.fileSize > 0 && s.fileSize <= 25 * 1024 * 1024)
              .take(3)) {
        final lookup = Stopwatch()..start();
        final media = await resolver.resolve(song.id);
        final lookupMs = lookup.elapsedMilliseconds;
        final timer = Stopwatch()..start();
        final response = await settings.api!.openStream(song.id);
        _check(response.statusCode == 200, 'Stream request failed');
        final headersMs = timer.elapsedMilliseconds;
        int? firstByteMs;
        var bytes = 0;
        final suffix = RegExp(r'^[a-zA-Z0-9]{1,8}$').hasMatch(song.suffix)
            ? song.suffix
            : 'audio';
        final local = File('${cache.path}/${timings.length}.$suffix');
        final sink = local.openWrite();
        try {
          await for (final chunk in response.stream) {
            firstByteMs ??= timer.elapsedMilliseconds;
            bytes += chunk.length;
            _check(
              bytes <= 32 * 1024 * 1024,
              'Diagnostic download exceeded size limit',
            );
            sink.add(chunk);
          }
        } finally {
          await sink.close();
        }
        final downloadMs = timer.elapsedMilliseconds;
        final remoteTiming = await _measureStartup(media);
        final localTiming = await _measureStartup(
          ResolvedPlaybackMedia(song: media.song, uri: local.uri),
        );
        timings.add({
          'song_id': song.id,
          'lookup_ms': lookupMs,
          'headers_ms': headersMs,
          'first_byte_ms': firstByteMs,
          'download_ms': downloadMs,
          'bytes': bytes,
          'duration_ms': song.duration * 1000,
          'remote': remoteTiming,
          'local': localTiming,
        });
        report['startup_timings'] = timings;
        await save();
      }
      _check(
        timings.length == 3,
        'Need three real songs for the startup comparison',
      );
    } finally {
      await cache.delete(recursive: true);
    }
    report['stage'] = 'passed';
  } catch (error) {
    report['failed_stage'] = report['stage'];
    report['stage'] = 'failed';
    // API errors can contain authenticated URLs; only our own checks are safe.
    report['error'] = error is StateError
        ? error.message
        : error.runtimeType.toString();
  } finally {
    await save();
    await runtime?.dispose();
    settings.dispose();
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Kontroll: ${report['stage']}')),
        ),
      ),
    );
  }
}

class _FixedMedia implements PlaybackMediaResolver {
  _FixedMedia(this.media);
  final ResolvedPlaybackMedia media;
  @override
  Future<ResolvedPlaybackMedia> resolve(String songId) async => media;
}

Future<Map<String, int>> _measureStartup(ResolvedPlaybackMedia media) async {
  final port = JustAudioNativePort(resolver: _FixedMedia(media));
  final coordinator = PlaybackCoordinator(nativePort: port);
  try {
    final timer = Stopwatch()..start();
    await coordinator
        .replaceQueue([
          LogicalQueueEntry(id: 'measure', songId: media.song.id),
        ], startEntryId: 'measure')
        .timeout(const Duration(seconds: 15));
    final preparedMs = timer.elapsedMilliseconds;
    await port.player.positionStream
        .firstWhere((p) => p >= const Duration(milliseconds: 200))
        .timeout(const Duration(seconds: 30));
    return {
      'prepared_ms': preparedMs,
      'position_200_ms': timer.elapsedMilliseconds,
      'buffered_ms': port.player.bufferedPosition.inMilliseconds,
    };
  } finally {
    await port.player.stop();
    await coordinator.dispose();
    await port.dispose();
  }
}

Future<Map<String, Object?>> _checkHomePull(
  V2Runtime runtime, {
  required Future<void> Function(Map<String, Object?> result) onUpdated,
}) async {
  Future<bool>? serverRefresh;
  runApp(
    MaterialApp(
      theme: NaviTheme.dark(),
      locale: const Locale('sv'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: V2HomeScreen(
        controller: runtime.home,
        preferences: runtime.experience,
        onRefresh: () async {
          serverRefresh = runtime.refreshNow(rotateHomeLibrary: true);
          await serverRefresh;
        },
      ),
    ),
  );
  await WidgetsBinding.instance.endOfFrame;
  final before = runtime.home.state.quickPicks.map((p) => p.song.id).toList();
  _check(before.isNotEmpty, 'Quick Picks must be visible before the gesture');
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  final size = view.physicalSize / view.devicePixelRatio;
  final start = Offset(size.width / 2, size.height * .25);
  final end = Offset(size.width / 2, size.height * .85);
  final timer = Stopwatch()..start();
  GestureBinding.instance.handlePointerEvent(
    PointerDownEvent(pointer: 91, position: start, timeStamp: timer.elapsed),
  );
  for (var step = 1; step <= 20; step++) {
    GestureBinding.instance.handlePointerEvent(
      PointerMoveEvent(
        pointer: 91,
        position: Offset.lerp(start, end, step / 20)!,
        delta: (end - start) / 20,
        timeStamp: timer.elapsed,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 16));
  }
  GestureBinding.instance.handlePointerEvent(
    PointerUpEvent(pointer: 91, position: end, timeStamp: timer.elapsed),
  );
  List<String> after() =>
      runtime.home.state.quickPicks.map((p) => p.song.id).toList();
  while (serverRefresh == null || before.join(',') == after().join(',')) {
    _check(
      timer.elapsed < const Duration(seconds: 5),
      'Pull did not visibly renew Quick Picks within five seconds',
    );
    await Future<void>.delayed(const Duration(milliseconds: 25));
  }
  final result = <String, Object?>{
    'updated_ms': timer.elapsedMilliseconds,
    'before_ids': before,
    'after_ids': after(),
    'new_tracks': after().toSet().difference(before.toSet()).length,
  };
  await onUpdated(result);
  result['server_finished_within_2s'] = await serverRefresh!.timeout(
    const Duration(seconds: 2),
    onTimeout: () => false,
  );
  return result;
}
