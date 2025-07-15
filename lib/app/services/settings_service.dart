import 'package:flutter/services.dart';
import 'package:darrt/helpers/mini_logger.dart';

class SettingsService {
  static const _batteryChannel = MethodChannel('com.hp.darrt/battery_settings');

  static Future<void> openBatterySettings() async {
    try {
      await _batteryChannel.invokeMethod('openBatterySettings');
    } on PlatformException catch (e) {
      MiniLogger.e('Failed to open battery settings: ${e.message}');
    }
  }


}