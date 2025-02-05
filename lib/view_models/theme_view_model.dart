// theme_view_model.dart
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:minimaltodo/helpers/mini_utils.dart';
import 'package:minimaltodo/theme_colors.dart';

enum ThemePreference { system, light, dark }

class ThemeViewModel extends ChangeNotifier {
  final _box = GetStorage();
  static const String _themeColorKey = 'themeColor';
  static const String _themePreferenceKey = 'themePreference';

  late ThemeColors _selectedColor;
  late ThemePreference _themePreference;

  ThemeViewModel() {
    final storedColorIndex = _box.read(_themeColorKey);
    _selectedColor = storedColorIndex != null
        ? ThemeColors.values[storedColorIndex]
        : ThemeColors.cerulean;

    final storedPreference = _box.read(_themePreferenceKey);
    _themePreference = storedPreference != null
        ? ThemePreference.values[storedPreference]
        : ThemePreference.system;
  }

  ThemeColors get selectedColor => _selectedColor;
  ThemePreference get themePreference => _themePreference;

  bool get isDarkMode {
    switch (_themePreference) {
      case ThemePreference.system:
      // This will be used in the UI to determine the switch state
        return false;
      case ThemePreference.light:
        return false;
      case ThemePreference.dark:
        return true;
    }
  }

  ThemeMode get themeMode {
    switch (_themePreference) {
      case ThemePreference.system:
        return ThemeMode.system;
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
    }
  }

  FlexSchemeColor get selectedScheme => FlexSchemeColor.from(
    primary: _selectedColor.color,
  );

  Future<void> setThemePreference(ThemePreference preference) async {
    try {
      await _box.write(_themePreferenceKey, preference.index);
      _themePreference = preference;
      notifyListeners();
    } catch (e) {
      logger.d('Failed to save theme preference: $e');
    }
  }

  Future<void> setThemeColor(ThemeColors color) async {
    _selectedColor = color;
    await _box.write(_themeColorKey, color.index);
    notifyListeners();
  }
}