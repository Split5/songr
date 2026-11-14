import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/data/local/app_database.dart';
import 'package:navimusic/data/local/drift_catalog_repository.dart';
import 'package:navimusic/data/local/drift_song_library_repository.dart';
import 'package:navimusic/domain/library/song_filter.dart';
import 'package:navimusic/domain/library/song_library_repository.dart';
import 'package:navimusic/design_system/navi_theme.dart';
import 'package:navimusic/features/favorites/favorites_controller.dart';
import 'package:navimusic/features/favorites/v2_favorites_screen.dart';
import 'package:navimusic/l10n/app_localizations.dart';
import 'package:navimusic/models/models.dart';

/// The favourites page must survive a background refresh: keeping the rows and
/// the scroll position instead of flashing a spinner and jumping to the top.
void main() {
  late AppDatabase database;
  late FavoritesController controller;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await database.batch((batch) {
      for (var index = 0; index < 40; index++) {
        batch.insert(
          database.localSongs,
          _song(
            'song-$index',
            'Song ${index.toString().padLeft(2, '0')}',
            starred: true,
            created: DateTime(2020, 1, 1).add(Duration(days: index)),
          ),
        );
      }
    });
    controller = FavoritesController(
      songLibrary: _SlowRepository(DriftSongLibraryRepository(database)),
      catalog: DriftCatalogRepository(database),
    );
  });

  tearDown(() async {
    controller.dispose();
    await database.close();
  });

  testWidgets('a refresh keeps the rows and the scroll position', (
    tester,
  ) async {
    await tester.pumpWidget(_app(controller));
    await _settle(tester);

    await tester.drag(_songsList, const Offset(0, -420));
    await _settle(tester);
    final before = _scrollOffset(tester);
    expect(before, greaterThan(100));

    final pending = controller.refresh();
    await tester.pump(); // the frame where the old code showed a spinner
    await tester.pump(const Duration(milliseconds: 10));

    expect(
      find.byType(CircularProgressIndicator),
      findsNothing,
      reason: 'a refresh must not replace the list with a spinner',
    );
    expect(find.text('Song 00'), findsNothing, reason: 'still scrolled down');

    await _pumpUntil(tester, pending);
    await _settle(tester);
    expect(_scrollOffset(tester), closeTo(before, 1));
  });

  testWidgets('a newly added favourite appears without losing the position', (
    tester,
  ) async {
    await tester.pumpWidget(_app(controller));
    await _settle(tester);

    await tester.drag(_songsList, const Offset(0, -420));
    await _settle(tester);
    final before = _scrollOffset(tester);

    // Starring a song writes the row locally, then the surface refreshes.
    await database
        .into(database.localSongs)
        .insert(
          _song(
            'fresh',
            'Fresh favourite',
            starred: true,
            created: DateTime(2026, 11, 10),
          ),
        );
    await _pumpUntil(tester, controller.refresh());
    await _settle(tester);

    expect(_scrollOffset(tester), closeTo(before, 1));
    // The new row sorts newest-first, so it sits at the very top.
    expect(controller.songs.songs.first.id, 'fresh');
  });

  test('refreshing never empties the list that is already on screen', () async {
    await controller.initialize();
    final loaded = controller.songs.songs.length;
    expect(loaded, greaterThan(0));

    final refresh = controller.refresh();
    expect(
      controller.songs.state.songs,
      isNotEmpty,
      reason: 'the visible rows must stay while the refresh runs',
    );
    await refresh;
    expect(controller.songs.songs.length, loaded);
  });
}

/// Drives a future that depends on timers: inside testWidgets the fake clock
/// only advances while frames are pumped, so awaiting it directly would hang.
Future<void> _pumpUntil(WidgetTester tester, Future<void> future) async {
  var done = false;
  Object? failure;
  future.then((_) => done = true, onError: (Object error) {
    failure = error;
    done = true;
  });
  for (var i = 0; i < 100 && !done; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  if (!done) throw StateError('future did not complete');
  if (failure != null) throw failure!;
}

/// Advances frames without waiting for animations to settle: the loading
/// spinner animates forever, so pumpAndSettle would never return.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Finder get _songsList => find.descendant(
  of: find.byType(RefreshIndicator),
  matching: find.byType(Scrollable),
);

double _scrollOffset(WidgetTester tester) => tester
    .state<ScrollableState>(_songsList.first)
    .position
    .pixels;

Widget _app(FavoritesController controller) => MaterialApp(
  locale: const Locale('sv'),
  theme: NaviTheme.dark(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: V2FavoritesScreen(
    controller: controller,
    onSongTap: (_) {},
    onSongMenu: (_) {},
    onAlbumTap: (_) {},
    onArtistTap: (_) {},
    onPlaySongs: (_, {required shuffle}) {},
    onPlayMix: (_) async {},
  ),
);

LocalSongsCompanion _song(
  String id,
  String title, {
  bool starred = false,
  required DateTime created,
}) => LocalSongsCompanion.insert(
  id: id,
  title: title,
  artist: 'Favorite artist',
  artistId: const Value('favorite-artist'),
  album: 'Favorite album',
  albumId: const Value('favorite-album'),
  duration: const Value(180),
  starred: Value(starred),
  createdAt: Value(created),
);

/// The real snapshot query is slow enough to show its loading frame; the
/// in-memory test database is not, so the delay is explicit.
class _SlowRepository implements SongLibraryRepository {
  _SlowRepository(this.inner);

  final SongLibraryRepository inner;
  static const _delay = Duration(milliseconds: 80);

  @override
  Future<int> count(SongFilter filter) async {
    await Future<void>.delayed(_delay);
    return inner.count(filter);
  }

  @override
  Future<List<Song>> page({
    required SongFilter filter,
    required int limit,
    required int offset,
  }) async {
    await Future<void>.delayed(_delay);
    return inner.page(filter: filter, limit: limit, offset: offset);
  }
}
