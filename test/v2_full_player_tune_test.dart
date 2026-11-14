import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/features/player/v2_full_player.dart';

void main() {
  test('queue tuning only offers the two plugin-backed actions', () {
    // The tune sheet in V2FullPlayer renders QueueTuneAction.values directly,
    // so this pins the sheet to what Navidrome's getSimilarSongs2 can serve.
    // "More energy" / "Calmer" needed a direct AudioMuse text search and are
    // gone together with that API.
    expect(QueueTuneAction.values, [
      QueueTuneAction.moreLikeThis,
      QueueTuneAction.lessLikeThis,
    ]);
    expect(QueueTuneAction.values.map((action) => action.name), [
      'moreLikeThis',
      'lessLikeThis',
    ]);
  });
}
