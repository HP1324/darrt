import 'package:darrt/app/theme/theme_enums.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart' show ThemeMode, ThemeData;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'theme_state.freezed.dart';

@freezed
abstract class ThemeState with _$ThemeState {
  const factory ThemeState(
      {required ThemeColors color, required ThemePreference preference}) = _ThemeState;

  const ThemeState._();

  ThemeMode get themeMode {
    switch (preference) {
      case ThemePreference.system:
        return ThemeMode.system;
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
    }
  }


  FlexSchemeColor get selectedScheme => FlexSchemeColor.from(
    primary: color.color,
  );

  ThemeData get lightTheme => FlexColorScheme.light(colors: selectedScheme, fontFamily: 'Gabarito').toTheme;

  ThemeData get darkTheme => FlexColorScheme.dark(
    fontFamily: 'Gabarito',
    colors: selectedScheme.toDark(27),
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    appBarStyle: FlexAppBarStyle.background,
    darkIsTrueBlack: false,
  ).toTheme;
}
