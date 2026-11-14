import 'app/v2/v2_bootstrap.dart';

/// Kept as a delegate so `tool/build_ios_v2.sh` (`-t lib/main_v2.dart`)
/// keeps working; `lib/main.dart` boots the very same app.
Future<void> main() => bootstrapV2();
