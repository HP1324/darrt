import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:minimaltodo/global_utils.dart';
import 'package:minimaltodo/theme_colors.dart';

class ThemeViewModel extends ChangeNotifier{
  // FlexSchemeColor selectedScheme =  FlexSchemeColor.from(primary: ThemeColors.deepTeal.color);
  final _box = GetStorage();
  static const String _themeColorKey = 'themeColor';
  static const String _isDarkModeKey = 'isDarkMode';
  bool _isDarkMode = false;
  late ThemeColors _selectedColor;

  ThemeViewModel() {
    final storedColorIndex = _box.read(_themeColorKey);
    _selectedColor = storedColorIndex != null ? ThemeColors.values[storedColorIndex] : ThemeColors.deepTeal;
    _isDarkMode = _box.read(_isDarkModeKey) ?? false;
  }
  ThemeColors get selectedColor => _selectedColor;
  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  FlexSchemeColor get selectedScheme => FlexSchemeColor.from(
    primary: _selectedColor.color,
  );
  Future<void> toggleDarkMode(bool newValue) async {
    try {
      await _box.write(_isDarkModeKey, newValue);
      _isDarkMode = newValue;
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