import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/app/v2/v2_diagnostics.dart';
import 'package:navimusic/domain/diagnostics/app_metrics.dart';

void main() {
  setUp(AppMetrics.resetForTesting);

  test('diagnostic report redacts server details and secrets', () async {
    V2Diagnostics.record(
      'Failed https://music.example.test/rest password=hunter2 '
      'for listener@example.com',
    );

    final report = await V2Diagnostics.buildReport(
      description: 'Playback stopped',
    );

    expect(report, contains('Playback stopped'));
    expect(report, contains('[url]'));
    expect(report, contains('[email]'));
    expect(report, isNot(contains('music.example.test')));
    expect(report, isNot(contains('hunter2')));
    expect(report, isNot(contains('listener@example.com')));
  });

  test('direct log sanitizer removes authenticated URLs', () {
    final sanitized = V2Diagnostics.sanitizeForLog(
      'failed https://music.test/rest/stream?id=1&t=token&s=salt token=abc',
    );

    expect(sanitized, contains('[url]'));
    expect(sanitized, contains('token=[redacted]'));
    expect(sanitized, isNot(contains('music.test')));
    expect(sanitized, isNot(contains('t=token')));
  });

  test('diagnostic report includes local timing and failure metrics', () async {
    AppMetrics.duration('playback_prepare', const Duration(milliseconds: 240));
    AppMetrics.duration(
      'catalog_sync',
      const Duration(milliseconds: 800),
      success: false,
    );

    final report = await V2Diagnostics.buildReport(description: 'Slow start');

    expect(report, contains('playback_prepare: count=1'));
    expect(report, contains('catalog_sync_failure: 1'));
    expect(report, contains('max=800 ms'));
  });
}
