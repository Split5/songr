import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/app/v2/v2_artwork_cache.dart';
import 'package:navimusic/app/v2/v2_connectivity.dart';

void main() {
  test('cover art cache key is stable and contains no auth token', () {
    final key = coverArtCacheKey(
      accountScope: 'https://music.test|listener',
      coverArt: 'al-42',
      size: 600,
    );

    expect(key, contains('al-42'));
    expect(key, isNot(contains('\u0000')));
    expect(key, isNot(contains('token')));
    expect(key, isNot(contains('salt')));
  });

  test('sync resumes only after a network loss becomes a connection', () {
    expect(
      shouldResumeSync(
        wasOnline: false,
        results: const [ConnectivityResult.wifi],
      ),
      isTrue,
    );
    expect(
      shouldResumeSync(
        wasOnline: true,
        results: const [ConnectivityResult.wifi],
      ),
      isFalse,
    );
    expect(
      shouldResumeSync(
        wasOnline: false,
        results: const [ConnectivityResult.none],
      ),
      isFalse,
    );
  });
}
