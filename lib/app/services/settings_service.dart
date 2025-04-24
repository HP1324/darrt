import 'package:flutter/services.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';

class SettingsService {
  static const platform = MethodChannel('com.hp.minimaltodo/battery_settings');

  static Future<void> openBatterySettings() async {
    try {
      await platform.invokeMethod('openBatterySettings');
    } on PlatformException catch (e) {
      MiniLogger.e('Failed to open battery settings: ${e.message}');
    }
  }
}