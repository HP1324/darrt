import 'package:flutter/material.dart';
enum ThemeColors{
  deepTeal,
  lavendarBlush,
  peach,
  mauve
}
extension ThemeColorsExtension on ThemeColors{
  Color get color {
    switch(this){
      case ThemeColors.deepTeal:
        return Color(0xFF00574B);
      case ThemeColors.lavendarBlush:
        return Color(0xFFBA68C8);
      case ThemeColors.peach:
        return Color(0xFFFFCBA4);
      case ThemeColors.mauve:
        return Color(0xFF9B7E8E);
    }
  }
}
class ThemeViewModel extends ChangeNotifier{

}