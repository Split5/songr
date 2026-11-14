class AppMetrics {
  AppMetrics._();

  static final Map<String, _DurationMetric> _durations = {};
  static final Map<String, int> _counters = {};

  static void count(String name, [int amount = 1]) {
    _counters[name] = (_counters[name] ?? 0) + amount;
  }

  static void duration(String name, Duration value, {bool success = true}) {
    final metric = _durations.putIfAbsent(name, _DurationMetric.new);
    metric.count++;
    metric.totalMicros += value.inMicroseconds;
    metric.lastMicros = value.inMicroseconds;
    metric.minMicros = metric.minMicros == null
        ? value.inMicroseconds
        : (value.inMicroseconds < metric.minMicros!
              ? value.inMicroseconds
              : metric.minMicros!);
    metric.maxMicros = metric.maxMicros == null
        ? value.inMicroseconds
        : (value.inMicroseconds > metric.maxMicros!
              ? value.inMicroseconds
              : metric.maxMicros!);
    count(success ? '${name}_success' : '${name}_failure');
  }

  static List<String> reportLines() {
    final names = {..._durations.keys, ..._counters.keys}.toList()..sort();
    return [
      'Local session metrics',
      for (final name in names)
        if (_durations[name] case final metric?)
          '$name: count=${metric.count}, '
              'avg=${metric.averageMilliseconds.toStringAsFixed(1)} ms, '
              'min=${metric.minMicros! ~/ 1000} ms, '
              'max=${metric.maxMicros! ~/ 1000} ms, '
              'last=${metric.lastMicros! ~/ 1000} ms'
        else
          '$name: ${_counters[name]}',
    ];
  }

  static void resetForTesting() {
    _durations.clear();
    _counters.clear();
  }
}

class _DurationMetric {
  int count = 0;
  int totalMicros = 0;
  int? minMicros;
  int? maxMicros;
  int? lastMicros;

  double get averageMilliseconds => count == 0 ? 0 : totalMicros / count / 1000;
}
