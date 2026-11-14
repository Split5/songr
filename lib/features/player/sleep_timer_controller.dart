import 'dart:async';

import 'package:flutter/foundation.dart';

class SleepTimerController extends ChangeNotifier {
  SleepTimerController(this._onElapsed);

  final Future<void> Function() _onElapsed;
  DateTime? _deadline;
  Timer? _deadlineTimer;
  Timer? _ticker;
  bool _disposed = false;

  DateTime? get deadline => _deadline;
  bool get active => _deadline != null;

  Duration? get remaining {
    final deadline = _deadline;
    if (deadline == null) return null;
    final milliseconds = deadline.difference(DateTime.now()).inMilliseconds;
    if (milliseconds <= 0) return Duration.zero;
    return Duration(seconds: (milliseconds + 999) ~/ 1000);
  }

  void start(Duration duration) {
    if (duration <= Duration.zero) {
      cancel();
      return;
    }
    _cancelTimers();
    _deadline = DateTime.now().add(duration);
    _deadlineTimer = Timer(duration, _expire);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  void cancel() {
    if (_deadline == null) return;
    _deadline = null;
    _cancelTimers();
    notifyListeners();
  }

  /// Position callbacks continue while background audio is active. This gives
  /// the timer a second deadline check if iOS delayed the Dart timer itself.
  void checkDeadline() {
    final deadline = _deadline;
    if (deadline != null && !DateTime.now().isBefore(deadline)) _expire();
  }

  void _tick() {
    checkDeadline();
    if (_deadline != null && !_disposed) notifyListeners();
  }

  void _expire() {
    if (_deadline == null) return;
    _deadline = null;
    _cancelTimers();
    if (!_disposed) notifyListeners();
    unawaited(_onElapsed().catchError((_) {}));
  }

  void _cancelTimers() {
    _deadlineTimer?.cancel();
    _deadlineTimer = null;
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelTimers();
    super.dispose();
  }
}
