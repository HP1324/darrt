import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Colors
  static const primary = Color(0xFF6B4EFF);  // Deep Purple
  static const primaryLight = Color(0xFF8F7AFF); // Light Purple
  static const primaryDark = Color(0xFF4B36CB); // Dark Purple

  // Secondary Colors
  static const secondary = Color(0xFFFF4ECD); // Pink
  static const secondaryLight = Color(0xFFFF7ADB); // Light Pink
  static const secondaryDark = Color(0xFFCB36A3); // Dark Pink

  // Background Shades
  static const background50 = Color(0xFFF8F7FF);  // Lightest Purple Tint
  static const background100 = Color(0xFFF0EEFF);
  static const background200 = Color(0xFFE3DEFF);
  static const background300 = Color(0xFFD6CEFF);
  static const background400 = Color(0xFFC9BEFF);
  static const background500 = Color(0xFFBCAEFF);
  static const background600 = Color(0xFFAF9EFF);
  static const background700 = Color(0xFFA28EFF);
  static const background800 = Color(0xFF957EFF);
  static const background900 = Color(0xFF886EFF);

  // Utility Colors
  static const surface = Color(0xFFFFFFFF);
  static const error = Color(0xFFFF4E4E);
  static const success = Color(0xFF4ECB71);
  static const warning = Color(0xFFFFB74E);
  static const linethrough = Color(0xFF9E9E9E);

  static const popupItemStyle = TextStyle(
    color: primary,
    fontWeight: FontWeight.bold
  );

  // Date Picker Theme
  static final _datePickerTheme = DatePickerThemeData(
    backgroundColor: background50,
    surfaceTintColor: primary,
    headerBackgroundColor: primary,
    headerForegroundColor: Colors.white,
    weekdayStyle: const TextStyle(color: primary),
    dayForegroundColor: WidgetStateColor.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return primary;
    }),
    dayBackgroundColor: WidgetStateColor.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return primary;
      }
      return background100;
    }),
    todayForegroundColor: WidgetStateColor.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return secondary;
    }),
    todayBackgroundColor: WidgetStateColor.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return primary;
      }
      return secondaryLight.withAlpha(50);
    }),
  );

  // Time Picker Theme
  static final _timePickerTheme = TimePickerThemeData(
    backgroundColor: background50,
    hourMinuteShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    dayPeriodShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    dayPeriodColor: WidgetStateColor.resolveWith((states) =>
        states.contains(WidgetState.selected)
            ? primary
            : background100),
    dayPeriodTextColor: WidgetStateColor.resolveWith((states) =>
        states.contains(WidgetState.selected)
            ? Colors.white
            : primary),
    hourMinuteColor: WidgetStateColor.resolveWith((states) =>
        states.contains(WidgetState.selected)
            ? primary
            : background100),
    hourMinuteTextColor: WidgetStateColor.resolveWith((states) =>
        states.contains(WidgetState.selected)
            ? Colors.white
            : primary),
    dialBackgroundColor: background100,
    dialHandColor: primary,
    dialTextColor: WidgetStateColor.resolveWith((states) =>
        states.contains(WidgetState.selected)
            ? Colors.white
            : primary),
    entryModeIconColor: primary,
  );

  static ThemeData lightMode = ThemeData(
    fontFamily: GoogleFonts.gabarito().fontFamily,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: surface,
      error: error,
    ),
    appBarTheme: _appBarTheme,
    scaffoldBackgroundColor: background50,
    navigationBarTheme: _navigationBarTheme,
    datePickerTheme: _datePickerTheme,
    timePickerTheme: _timePickerTheme,
    floatingActionButtonTheme: _floatingActionButtonTheme,
    dialogTheme: _dialogTheme,
    cardTheme: _cardTheme,
    popupMenuTheme: _popupMenuTheme,
    checkboxTheme: _checkboxTheme,
    listTileTheme: _listTileTheme,
    dropdownMenuTheme: _dropdownMenuTheme,
    textTheme: _textTheme,
    switchTheme: _switchTheme,
  );

  static final _textTheme = TextTheme(
    titleLarge: const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    bodyLarge: TextStyle(
      color: primary.withAlpha(222),
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      color: primary.withAlpha(222),
      fontSize: 14,
    ),
  );

  static final _appBarTheme = AppBarTheme(
    iconTheme: const IconThemeData(color: Colors.white),
    titleTextStyle: const TextStyle(
      fontSize: 25,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
    actionsIconTheme: const IconThemeData(color: Colors.white),
    backgroundColor: primary,
    elevation: 0,
  );

  static final _navigationBarTheme = NavigationBarThemeData(
    elevation: 0,
    backgroundColor: primary,
    indicatorColor: Colors.white,
    labelTextStyle: const WidgetStatePropertyAll(TextStyle(color:Colors.white,fontSize: 14)),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(color: primary);
      }
      return IconThemeData(color:Colors.white);
    }),
  );

  static final _floatingActionButtonTheme = const FloatingActionButtonThemeData(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    elevation: 4,
  );

  static final _dialogTheme = DialogTheme(
    backgroundColor: surface,
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  );

  static final _cardTheme = CardTheme(
    color: surface,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );

  static final _popupMenuTheme = PopupMenuThemeData(
    color: surface,
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: const TextStyle(color: primary, fontWeight: FontWeight.w500),
  );

  static final _checkboxTheme = CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return primary;
      }
      return Colors.transparent;
    }),
    checkColor: const WidgetStatePropertyAll(Colors.white),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    side: BorderSide(color: primary.withAlpha(150)),
  );

  static final _listTileTheme = ListTileThemeData(
    selectedTileColor: primary.withAlpha(50),
    selectedColor: primary,
    iconColor: primary,
    textColor: primary.withAlpha(222),
  );

  static final _dropdownMenuTheme = DropdownMenuThemeData(
    textStyle: TextStyle(color: primary.withAlpha(222)),
    menuStyle: MenuStyle(
      backgroundColor: WidgetStatePropertyAll(surface),
      elevation: const WidgetStatePropertyAll(8),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  static final _switchTheme = SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return Colors.grey.shade400;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return primary;
      }
      return Colors.grey.shade300;
    }),
    trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
  );
}
