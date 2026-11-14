import '../../api/subsonic_api.dart';
import '../../domain/lyrics/lyrics_service.dart';

class SubsonicLyricsGateway implements LyricsGateway {
  const SubsonicLyricsGateway(this.api);

  final SubsonicApi api;

  @override
  Future<String?> fetch(String songId) => api.getLyricsLrc(songId);
}
