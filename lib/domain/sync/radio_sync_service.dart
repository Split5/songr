import 'package:drift/drift.dart';

import '../../api/subsonic_api.dart';
import '../../data/local/app_database.dart';

class RadioSyncService {
  const RadioSyncService({required this.api, required this.database});

  final SubsonicApi api;
  final AppDatabase database;

  Future<int> refresh() async {
    final stations = await api.getInternetRadioStations();
    final now = DateTime.now();
    await database.replaceInternetRadioStations(
      stations.map(
        (station) => LocalInternetRadioStationsCompanion.insert(
          id: station.id,
          name: station.name,
          streamUrl: station.streamUrl,
          homePageUrl: Value(station.homePageUrl),
          updatedAt: now,
        ),
      ),
    );
    return stations.length;
  }
}
