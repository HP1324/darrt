import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:minimaltodo/theme_colors.dart';

class ThemeViewModel extends ChangeNotifier{
  FlexSchemeColor selectedScheme =  FlexSchemeColor.from(primary: ThemeColors.deepTeal.color);
  final _storage = GetStorage();
  bool _isDarkMode = false;

  ThemeViewModel() {
    _isDarkMode = _storage.read('isDarkMode') ?? false;
  }

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleDark(bool newValue) async {
    try {
      await _storage.write('isDarkMode', newValue);
      _isDarkMode = newValue;
      notifyListeners();
    } catch (e) {
      // Handle storage errors
      print('Failed to save theme preference: $e');
    }
  }
}