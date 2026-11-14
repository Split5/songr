import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/domain/lyrics/lrc_document.dart';
import 'package:navimusic/domain/lyrics/lyrics_service.dart';

void main() {
  test('LRC parser keeps timing and finds the active line', () {
    final document = LrcDocument.parse('''
[ar:Artist]
[00:01.50]First
[00:03.250]Second
[00:05]Third
''');

    expect(document.isSynced, isTrue);
    expect(document.lines.map((line) => line.text), [
      'First',
      'Second',
      'Third',
    ]);
    expect(document.lines[0].start, const Duration(milliseconds: 1500));
    expect(document.lines[1].start, const Duration(milliseconds: 3250));
    expect(document.activeLine(const Duration(seconds: 2)), 0);
    expect(document.activeLine(const Duration(seconds: 4)), 1);
  });

  test('an LRC offset tag shifts every line and is not shown as text', () {
    final document = LrcDocument.parse('''
[offset:+500]
[00:01.00]First
[00:03.00]Second
''');

    expect(document.lines.map((line) => line.text), ['First', 'Second']);
    expect(document.lines[0].start, const Duration(milliseconds: 1500));
    expect(document.lines[1].start, const Duration(milliseconds: 3500));
  });

  test('a negative LRC offset pulls lines earlier but never before zero', () {
    final document = LrcDocument.parse('''
[offset:-800]
[00:00.50]Intro
[00:03.00]Verse
''');

    expect(document.lines[0].start, Duration.zero);
    expect(document.lines[1].start, const Duration(milliseconds: 2200));
  });

  test('an unsynced file with an offset tag stays unsynced', () {
    final document = LrcDocument.parse('''
[offset:500]
Just words
''');

    expect(document.isSynced, isFalse);
    expect(document.lines.single.text, 'Just words');
  });

  test('lyrics service serves the cache without a network request', () async {
    final cache = _MemoryLyricsCache(
      CachedLyrics(lrc: '[00:01]Cached', fetchedAt: DateTime.now()),
    );
    final gateway = _FakeLyricsGateway('[00:01]Network');
    final service = LyricsService(cache: cache, gateway: gateway);

    expect(await service.load('song'), '[00:01]Cached');
    expect(gateway.calls, 0);
  });

  test('lyrics service caches the first network result', () async {
    final cache = _MemoryLyricsCache(null);
    final gateway = _FakeLyricsGateway('[00:01]Fresh');
    final service = LyricsService(cache: cache, gateway: gateway);

    expect(await service.load('song'), '[00:01]Fresh');
    expect(cache.value?.lrc, '[00:01]Fresh');
    expect(gateway.calls, 1);
  });

  test(
    'lyrics service does not cache request failures as missing lyrics',
    () async {
      final cache = _MemoryLyricsCache(null);
      final gateway = _FailingLyricsGateway();
      final service = LyricsService(cache: cache, gateway: gateway);

      await expectLater(service.load('song'), throwsStateError);
      expect(cache.value, isNull);
      expect(gateway.calls, 1);
    },
  );

  test('downloaded lyrics work offline before the database cache', () async {
    final directory = await Directory.systemTemp.createTemp('lyrics-');
    addTearDown(() => directory.delete(recursive: true));
    final sidecar = File('${directory.path}/song.lrc');
    await sidecar.writeAsString('[00:01]Downloaded');
    final gateway = _FailingLyricsGateway();
    final service = LyricsService(
      cache: _MemoryLyricsCache(null),
      gateway: gateway,
    );

    expect(
      await service.load('song', localPath: sidecar.path),
      '[00:01]Downloaded',
    );
    expect(gateway.calls, 0);
  });

  test('stale positive lyrics are refreshed from the server', () async {
    final cache = _MemoryLyricsCache(
      CachedLyrics(
        lrc: '[00:01]Old',
        fetchedAt: DateTime.now().subtract(const Duration(days: 31)),
      ),
    );
    final gateway = _FakeLyricsGateway('[00:01]New');
    final service = LyricsService(cache: cache, gateway: gateway);

    expect(await service.load('song'), '[00:01]New');
    expect(gateway.calls, 1);
    expect(cache.value?.lrc, '[00:01]New');
  });
}

class _MemoryLyricsCache implements LyricsCache {
  _MemoryLyricsCache(this.value);

  CachedLyrics? value;

  @override
  Future<CachedLyrics?> read(String songId) async => value;

  @override
  Future<void> write(String songId, String? lrc) async {
    value = CachedLyrics(lrc: lrc, fetchedAt: DateTime.now());
  }
}

class _FakeLyricsGateway implements LyricsGateway {
  _FakeLyricsGateway(this.value);

  final String? value;
  int calls = 0;

  @override
  Future<String?> fetch(String songId) async {
    calls++;
    return value;
  }
}

class _FailingLyricsGateway implements LyricsGateway {
  int calls = 0;

  @override
  Future<String?> fetch(String songId) async {
    calls++;
    throw StateError('offline');
  }
}
