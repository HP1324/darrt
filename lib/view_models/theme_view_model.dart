// theme_view_model.dart
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:minimaltodo/helpers/mini_box.dart';
import 'package:minimaltodo/helpers/mini_consts.dart';
import 'package:minimaltodo/helpers/mini_enums.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';

class ThemeViewModel extends ChangeNotifier {


  late ThemeColors _selectedColor;
  late ThemePreference _themePreference;

  ThemeViewModel() {
    final storedColorIndex = MiniBox.read(mThemeColor);
    _selectedColor = storedColorIndex != null
        ? ThemeColors.values[storedColorIndex]
        : ThemeColors.cerulean;

    final storedPreference = MiniBox.read(mThemePreference);
    _themePreference = storedPreference != null
        ? ThemePreference.values[storedPreference]
        : ThemePreference.system;
  }

  ThemeColors get selectedColor => _selectedColor;
  ThemePreference get themePreference => _themePreference;

  bool get isDarkMode {
    switch (_themePreference) {
      case ThemePreference.system:
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
      await MiniBox.write(mThemePreference, preference.index);
      _themePreference = preference;
      notifyListeners();
    } catch (e) {
      MiniLogger.debug('Failed to save theme preference: $e');
    }
  }

  Future<void> setThemeColor(ThemeColors color) async {
    _selectedColor = color;
    await MiniBox.write(mThemeColor, color.index);
    notifyListeners();
  }
}