import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/app/v2/v2_server_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => null);
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'failed secret migration preserves the password for the next launch',
    () async {
      SharedPreferences.setMockInitialValues({
        'server_url': 'https://music.example.com',
        'server_user': 'simon',
        'server_pass': 'secret',
      });
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'write') throw PlatformException(code: 'locked');
            return null;
          });
      final settings = V2ServerSettings();
      final restarted = V2ServerSettings();
      addTearDown(settings.dispose);
      addTearDown(restarted.dispose);
      await settings.load();
      await restarted.load();
      expect(restarted.isConfigured, isTrue);
      expect(restarted.password, 'secret');
    },
  );

  test('load() purges the legacy direct-AudioMuse url and token', () async {
    SharedPreferences.setMockInitialValues({
      'server_url': 'https://music.example.com',
      'server_user': 'simon',
      'server_pass': 'secret',
      V2ServerSettings.legacyAudioMuseUrlKey: 'https://audiomuse.example.com',
      V2ServerSettings.legacyAudioMuseTokenKey: 'old-bearer-token',
    });
    final settings = V2ServerSettings();
    addTearDown(settings.dispose);

    await settings.load();

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.containsKey(V2ServerSettings.legacyAudioMuseUrlKey),
      isFalse,
    );
    expect(
      preferences.containsKey(V2ServerSettings.legacyAudioMuseTokenKey),
      isFalse,
    );
    expect(preferences.containsKey('server_pass'), isFalse);
    // Navidrome values survive in memory, but the legacy plaintext copy moves
    // out of SharedPreferences before the app continues.
    expect(settings.url, 'https://music.example.com');
    expect(settings.username, 'simon');
    expect(settings.password, 'secret');
    expect(settings.isConfigured, isTrue);
    expect(settings.loaded, isTrue);
  });

  test(
    'load() is a no-op for the legacy keys when nothing is stored',
    () async {
      SharedPreferences.setMockInitialValues({});
      final settings = V2ServerSettings();
      addTearDown(settings.dispose);

      await settings.load();

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getKeys(), isEmpty);
      expect(settings.isConfigured, isFalse);
    },
  );
}
