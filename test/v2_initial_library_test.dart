import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/app/v2/v2_runtime.dart';
import 'package:navimusic/data/local/app_database.dart';
import 'package:navimusic/domain/sync/catalog_sync_service.dart';
import 'package:navimusic/domain/sync/delta_sync_service.dart';
import 'package:navimusic/domain/sync/library_sync_service.dart';

void main() {
  late AppDatabase database;
  setUp(() => database = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => database.close());

  test('a new account requires a full library import', () async {
    expect(await requiresInitialLibrarySync(database), isTrue);
  });

  test('a successful delta does not replace the first full import', () async {
    await database.recordSyncSuccess(DeltaSyncService.scope, DateTime.now());
    expect(await requiresInitialLibrarySync(database), isTrue);
  });

  test(
    'an interrupted import must retry until every scope completed',
    () async {
      for (final scope in [
        LibrarySyncService.songsScope,
        CatalogSyncService.artistsScope,
        CatalogSyncService.albumsScope,
      ]) {
        await database.recordSyncSuccess(scope, DateTime.now());
        expect(await requiresInitialLibrarySync(database), isTrue);
      }
      await database.recordSyncSuccess(
        CatalogSyncService.playlistsScope,
        DateTime.now(),
      );
      expect(await requiresInitialLibrarySync(database), isFalse);
    },
  );
}
