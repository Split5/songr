import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Temporary on-device trace for the seek investigation.
///
/// Writes short lines to `Documents/seek-trace.log` so the exact player state
/// around a seek can be read back from the device. Best effort: tracing must
/// never affect playback.
abstract final class SeekTrace {
  static const _fileName = 'seek-trace.log';
  static Future<void> _tail = Future<void>.value();

  static void add(String message) {
    final line =
        '${DateTime.now().toIso8601String()}  ${message.replaceAll('\n', ' ')}';
    _tail = _tail.then((_) async {
      try {
        final dir = await getApplicationDocumentsDirectory();
        await File(
          '${dir.path}/$_fileName',
        ).writeAsString('$line\n', mode: FileMode.append);
      } catch (_) {
        // Nothing about tracing may disturb playback.
      }
    });
  }
}
