import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/features/player/sleep_timer_controller.dart';

void main() {
  test(
    'sleep timer pauses once and clears itself without touching a queue',
    () async {
      var elapsed = 0;
      final completer = Completer<void>();
      final timer = SleepTimerController(() async {
        elapsed++;
        if (!completer.isCompleted) completer.complete();
      });
      addTearDown(timer.dispose);

      timer.start(const Duration(milliseconds: 20));
      expect(timer.active, isTrue);
      await completer.future.timeout(const Duration(seconds: 1));

      expect(elapsed, 1);
      expect(timer.active, isFalse);
      expect(timer.remaining, isNull);
    },
  );

  test('cancelling prevents the elapsed callback', () async {
    var elapsed = 0;
    final timer = SleepTimerController(() async => elapsed++);
    addTearDown(timer.dispose);

    timer.start(const Duration(milliseconds: 30));
    timer.cancel();
    await Future<void>.delayed(const Duration(milliseconds: 60));

    expect(elapsed, 0);
    expect(timer.active, isFalse);
  });
}
