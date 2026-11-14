import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class V2PlaybackPreferences extends ChangeNotifier {
  static const _dataSaverKey = 'data_saver_enabled';
  static const dataSaverMaximumBitRate = 192;

  bool dataSaverEnabled = false;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    dataSaverEnabled = preferences.getBool(_dataSaverKey) ?? false;
    notifyListeners();
  }

  Future<void> setDataSaverEnabled(bool enabled) async {
    if (dataSaverEnabled == enabled) return;
    dataSaverEnabled = enabled;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_dataSaverKey, enabled);
  }
}
