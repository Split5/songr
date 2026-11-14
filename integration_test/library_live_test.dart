import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:navimusic/api/subsonic_api.dart';
import 'package:navimusic/data/local/app_database.dart';
import 'package:navimusic/data/local/drift_catalog_repository.dart';
import 'package:navimusic/domain/sync/catalog_sync_service.dart';
import 'package:navimusic/features/library/catalog_controllers.dart';
import 'package:navimusic/models/models.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('artists load from a real Navidrome library', (tester) async {
    final api = SubsonicApi(
      baseUrl: 'https://demo.navidrome.org',
      username: 'demo',
      password: 'demo',
    );
    final database = AppDatabase();
    final catalog = DriftCatalogRepository(database);
    final controller = PagedCatalogController<ArtistSummary>(
      countLoader: (query) => catalog.artistCount(query: query),
      pageLoader: (query, limit, offset) =>
          catalog.artistsPage(query: query, limit: limit, offset: offset),
    );
    addTearDown(() async {
      controller.dispose();
      await database.close();
      api.dispose();
    });

    final report = await CatalogSyncService(
      database: database,
      gateway: SubsonicCatalogGateway(api),
    ).syncAll(pageSize: 64);
    await controller.refresh();

    expect(report.artistCount, greaterThan(0));
    expect(controller.state.error, isNull);
    expect(controller.state.items, isNotEmpty);
  }, timeout: const Timeout(Duration(minutes: 3)));
}
