import '../../api/subsonic_api.dart';
import '../../domain/playback/scrobble_tracker.dart';

class SubsonicScrobbleSink implements ScrobbleSink {
  const SubsonicScrobbleSink(this.api);

  final SubsonicApi api;

  @override
  Future<void> announceStart(String songId) =>
      api.scrobble(songId, submission: false);

  @override
  Future<void> submitPlay(String songId) =>
      api.scrobble(songId, submission: true);
}
