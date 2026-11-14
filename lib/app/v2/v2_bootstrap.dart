import 'package:audio_session/audio_session.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';

import 'v2_app.dart';
import 'v2_diagnostics.dart';
import 'v2_server_settings.dart';

/// Starts the shipped (V2) app. Both `lib/main.dart` and `lib/main_v2.dart`
/// delegate here so every build target (Xcode's FLUTTER_TARGET, the
/// tool/build_ios_v2.sh script and plain `flutter run`) boots the same app.
Future<void> bootstrapV2() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  V2Diagnostics.install();
  // Keep the blank native splash up until Flutter can draw the app's single
  // small loading mark.
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  // Linux/Windows audio backend for just_audio (libmpv via media_kit).
  JustAudioMediaKit.ensureInitialized();
  // A playback session keeps the music running when a notification or another
  // app makes a sound; without it iOS can silence the app for good.
  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());
  final settings = V2ServerSettings();
  await settings.load();
  runApp(NaviMusicV2App(settings: settings));
}
