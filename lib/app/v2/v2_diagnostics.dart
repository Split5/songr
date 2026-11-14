import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../domain/diagnostics/app_metrics.dart';
import '../../domain/diagnostics/diagnostic_text.dart';

/// Small in-memory ring buffer used by the opt-in in-app bug reporter.
abstract final class V2Diagnostics {
  static final ListQueue<String> _events = ListQueue<String>();
  static bool _installed = false;

  static void install() {
    if (_installed) return;
    _installed = true;

    final previousFlutterError = FlutterError.onError;
    FlutterError.onError = (details) {
      record(details.exceptionAsString());
      previousFlutterError?.call(details);
    };

    final previousPlatformError = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      record('$error');
      return previousPlatformError?.call(error, stackTrace) ?? false;
    };
  }

  static void record(String message) {
    final cleaned = _sanitize(message);
    if (cleaned.isEmpty) return;
    _events.add('${DateTime.now().toUtc().toIso8601String()}  $cleaned');
    while (_events.length > 80) {
      _events.removeFirst();
    }
  }

  static Future<String> buildReport({required String description}) async {
    PackageInfo? info;
    try {
      info = await PackageInfo.fromPlatform();
    } catch (_) {}

    final locale = PlatformDispatcher.instance.locale;
    return [
      'Söngr diagnostic report',
      'Generated: ${DateTime.now().toUtc().toIso8601String()}',
      'App: ${info?.version ?? '?'} (${info?.buildNumber ?? '?'})',
      'Platform: ${defaultTargetPlatform.name}',
      'Locale: ${locale.toLanguageTag()}',
      '',
      'Description',
      description.trim(),
      '',
      'Recent app events',
      if (_events.isEmpty) 'No runtime errors captured.' else ..._events,
      '',
      ...AppMetrics.reportLines(),
    ].join('\n');
  }

  static String sanitizeForLog(String value) => sanitizeDiagnosticText(value);

  static String _sanitize(String value) => sanitizeDiagnosticText(value);
}
