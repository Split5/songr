import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/app/v2/v2_runtime.dart';

void main() {
  test(
    'an unplayable restored queue is discarded without blocking startup',
    () async {
      var discarded = false;

      final restored = await restorePlaybackSessionSafely(
        restore: () async {
          throw StateError(
            'AVFoundationErrorDomain -11850 AVErrorServerIncorrectlyConfigured',
          );
        },
        discard: () async {
          discarded = true;
        },
      );

      expect(restored, isFalse);
      expect(discarded, isTrue);
    },
  );

  test('a valid restored queue is kept', () async {
    var discarded = false;

    final restored = await restorePlaybackSessionSafely(
      restore: () async => true,
      discard: () async {
        discarded = true;
      },
    );

    expect(restored, isTrue);
    expect(discarded, isFalse);
  });

  test('cleanup failure still does not block startup', () async {
    final restored = await restorePlaybackSessionSafely(
      restore: () async => throw StateError('unplayable queue'),
      discard: () async => throw StateError('cleanup failed'),
    );

    expect(restored, isFalse);
  });
}
