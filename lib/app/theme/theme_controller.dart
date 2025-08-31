import 'package:darrt/app/services/mini_box.dart';
import 'package:darrt/app/theme/theme_enums.dart';
import 'package:darrt/app/theme/theme_state.dart';
import 'package:darrt/helpers/consts.dart';
import 'package:darrt/helpers/mini_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_controller.g.dart';

@riverpod
class ThemeController extends _$ThemeController{
  @override
  ThemeState build() {
    final storedColorIndex = MiniBox().read(mThemeColor) as int?;
    final storedPreference  = MiniBox().read(mThemePreference) as int?;

    final color = storedColorIndex != null
        ? ThemeColors.values[storedColorIndex]
        : ThemeColors.values[0];

    final pref = storedPreference != null
        ? ThemePreference.values[storedPreference]
        : ThemePreference.system;

    return ThemeState(color: color, preference: pref);
  }

  void setThemePreference(ThemePreference preference)  {
    try {
      MiniBox().write(mThemePreference, preference.index);
      state = state.copyWith(preference: preference);
    } catch (e) {
      MiniLogger.d('Failed to save theme preference: $e');
    }
  }

  void setThemeColor(ThemeColors color)  {
    MiniBox().write(mThemeColor, color.index);
    state = state.copyWith(color: color);
  }

}