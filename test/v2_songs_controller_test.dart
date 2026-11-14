import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/domain/library/song_filter.dart';
import 'package:navimusic/domain/library/song_library_repository.dart';
import 'package:navimusic/features/library/songs/songs_controller.dart';
import 'package:navimusic/models/models.dart';

void main() {
  test('loads exact count and then appends database pages', () async {
    final repository = _FakeSongRepository(_songs(145));
    final controller = SongsController(repository: repository, pageSize: 60);
    addTearDown(controller.dispose);

    await controller.initialize();
    expect(controller.state.totalCount, 145);
    expect(controller.state.songs, hasLength(60));
    expect(controller.state.hasMore, isTrue);

    await controller.loadMore();
    await controller.loadMore();
    expect(controller.state.songs, hasLength(145));
    expect(controller.state.hasMore, isFalse);
    expect(repository.offsets, [0, 60, 120]);
  });

  test(
    'a stale slow filter response cannot overwrite the latest filter',
    () async {
      final repository = _ControlledRepository();
      final controller = SongsController(repository: repository, pageSize: 20);
      addTearDown(controller.dispose);

      final oldRequest = controller.applyFilter(const SongFilter(query: 'old'));
      final newRequest = controller.applyFilter(const SongFilter(query: 'new'));
      repository.complete('new', [_song('new-result')]);
      await newRequest;
      repository.complete('old', [_song('old-result')]);
      await oldRequest;

      expect(controller.state.filter.query, 'new');
      expect(controller.state.songs.single.id, 'new-result');
    },
  );

  test('search input is debounced into one database request', () async {
    final repository = _FakeSongRepository(_songs(10));
    final controller = SongsController(
      repository: repository,
      searchDebounce: const Duration(milliseconds: 10),
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    controller.setQuery('a');
    controller.setQuery('ab');
    controller.setQuery('abc');
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(repository.queries, ['', 'abc']);
    expect(controller.state.filter.query, 'abc');
  });

  test('load-more error preserves the visible page and is retryable', () async {
    final repository = _FakeSongRepository(_songs(80));
    final controller = SongsController(repository: repository, pageSize: 60);
    addTearDown(controller.dispose);
    await controller.initialize();
    repository.failNextPage = true;

    await controller.loadMore();
    expect(controller.state.songs, hasLength(60));
    expect(controller.state.error, isA<StateError>());
    expect(controller.state.hasMore, isTrue);

    await controller.loadMore();
    expect(controller.state.songs, hasLength(80));
    expect(controller.state.error, isNull);
  });

  test(
    'a slow random sort can be cancelled without replacing the page',
    () async {
      final repository = _SequentialRepository();
      final controller = SongsController(repository: repository, pageSize: 20);
      addTearDown(controller.dispose);

      final initial = controller.initialize();
      repository.pages[0].complete([_song('visible')]);
      await initial;

      final random = controller.applyFilter(
        const SongFilter(sort: SongSort.random, randomSeed: 1),
      );
      expect(controller.state.initialLoading, isTrue);

      controller.cancelLoading();
      expect(controller.state.initialLoading, isFalse);
      expect(controller.state.filter.sort, SongSort.title);
      expect(controller.state.songs.single.id, 'visible');

      repository.pages[1].complete([_song('discarded')]);
      await random;
      expect(controller.state.songs.single.id, 'visible');
    },
  );
}

class _FakeSongRepository implements SongLibraryRepository {
  _FakeSongRepository(this.source);

  final List<Song> source;
  final List<int> offsets = [];
  final List<String> queries = [];
  bool failNextPage = false;

  @override
  Future<int> count(SongFilter filter) async => source.length;

  @override
  Future<List<Song>> page({
    required SongFilter filter,
    required int limit,
    required int offset,
  }) async {
    offsets.add(offset);
    queries.add(filter.query);
    if (failNextPage) {
      failNextPage = false;
      throw StateError('page failed');
    }
    return source.skip(offset).take(limit).toList();
  }
}

class _ControlledRepository implements SongLibraryRepository {
  final Map<String, Completer<List<Song>>> _pages = {};

  @override
  Future<int> count(SongFilter filter) async => 1;

  @override
  Future<List<Song>> page({
    required SongFilter filter,
    required int limit,
    required int offset,
  }) => (_pages[filter.query] ??= Completer()).future;

  void complete(String query, List<Song> songs) =>
      _pages[query]!.complete(songs);
}

class _SequentialRepository implements SongLibraryRepository {
  final List<Completer<List<Song>>> pages = [];

  @override
  Future<int> count(SongFilter filter) async => 1;

  @override
  Future<List<Song>> page({
    required SongFilter filter,
    required int limit,
    required int offset,
  }) {
    final page = Completer<List<Song>>();
    pages.add(page);
    return page.future;
  }
}

List<Song> _songs(int count) => [for (var i = 0; i < count; i++) _song('$i')];

Song _song(String id) => Song(
  id: id,
  title: 'Song $id',
  artist: 'Artist ${int.tryParse(id) ?? 0}',
  artistId: 'artist-$id',
  album: 'Album $id',
  albumId: 'album-$id',
);
