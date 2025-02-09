import 'package:flutter/material.dart';

enum TaskType { all, single, recurring }
enum ThemePreference { system, light, dark }


enum ThemeColors {
  amethyst,
  cerulean,
  deepTeal,
  dustyBlue,
  terracotta,
  slate,
  mauve,
  celadon,
  rust,
  lilac,
}
extension ThemeColorsExtension on ThemeColors {
  Color get color {
    switch (this) {
      case ThemeColors.cerulean:
        return const Color(0xFF007BA7);      // Rich blue
      case ThemeColors.deepTeal:
        return const Color(0xFF00574B);      // Muted green-gray
      case ThemeColors.dustyBlue:
        return const Color(0xFF6699CC);      // Soft muted blue
      case ThemeColors.terracotta:
        return const Color(0xFFE2725B);      // Earthy red-orange
      case ThemeColors.slate:
        return const Color(0xFF708090);      // Neutral blue-gray
      case ThemeColors.amethyst:
        return const Color(0xFF9966CC);      // Medium purple
      case ThemeColors.mauve:
        return const Color(0xFF9B7E8E);      // Dusty purple-gray
      case ThemeColors.celadon:
        return const Color(0xFFACE1AF);      // Soft sage green
      case ThemeColors.rust:
        return const Color(0xFFB7410E);      // Warm earthy red
      case ThemeColors.lilac:
        return const Color(0xFFC8A2C8);      // Muted purple
    }
  }
}

enum MiniPageTransitionType {
  jumpFromRight,
  popFromCenter,
  popFromTap,
  fadeIn,
  slideFromBottom,
}