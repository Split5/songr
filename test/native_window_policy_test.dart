import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/domain/playback/native_window_policy.dart';

void main() {
  group('initialWindowSlice', () {
    test('prepares only the tapped entry before playback', () {
      final slice = initialWindowSlice(26, 12);

      expect(slice.start, 12);
      expect(slice.end, 13);
      expect(slice.length, 1);
    });

    test('clamps at the start of the window', () {
      final slice = initialWindowSlice(26, 0);

      expect(slice.start, 0);
      expect(slice.end, 1);
    });

    test('clamps at the end of the window', () {
      final slice = initialWindowSlice(4, 3);

      expect(slice.start, 3);
      expect(slice.end, 4);
    });

    test('a single entry is its own window', () {
      final slice = initialWindowSlice(1, 0);

      expect(slice.start, 0);
      expect(slice.end, 1);
    });

    test('an empty window produces an empty slice', () {
      expect(initialWindowSlice(0, 0).length, 0);
    });
  });

  group('canReuseNativeWindow', () {
    test('reuse while the playing entry stays in both windows', () {
      expect(
        canReuseNativeWindow(
          previousEntryIds: const ['a', 'b', 'c'],
          desiredEntryIds: const ['b', 'c', 'd'],
          currentEntryId: 'b',
        ),
        isTrue,
      );
    });

    test('a rebuild is required when the playing entry is gone', () {
      expect(
        canReuseNativeWindow(
          previousEntryIds: const ['a', 'b'],
          desiredEntryIds: const ['c', 'd'],
          currentEntryId: 'a',
        ),
        isFalse,
      );
    });

    test('nothing playing means nothing to preserve', () {
      expect(
        canReuseNativeWindow(
          previousEntryIds: const ['a'],
          desiredEntryIds: const ['a'],
          currentEntryId: null,
        ),
        isFalse,
      );
    });
  });
}
