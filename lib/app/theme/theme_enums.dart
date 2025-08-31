import 'package:flutter/material.dart' show Color;

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
  whatsappGreen,
  indigo,
  burgundy,
  steel,
  coral,
  sage,
  plum,
  amber,
  navy,
  crimson,
  jade,
  bronze,
  ochre,
  sienna,
  black;

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
        return const Color(0xFFC8A2C8);
      case ThemeColors.whatsappGreen:
        return const Color(0xFF29b370);
      case ThemeColors.indigo:
        return const Color(0xFF4F46E5);  // Deep forest green
      case ThemeColors.burgundy:
        return const Color(0xFF8B1538);      // Deep wine red
      case ThemeColors.steel:
        return const Color(0xFF64748B);      // Modern steel blue-gray
      case ThemeColors.coral:
        return const Color(0xFFFF6B6B);      // Vibrant yet balanced coral
      case ThemeColors.sage:
        return const Color(0xFF87A96B);      // Muted sage green
      case ThemeColors.plum:
        return const Color(0xFF8B5A83);      // Sophisticated plum
      case ThemeColors.amber:
        return const Color(0xFFD97706);      // Warm amber orange
      case ThemeColors.navy:
        return const Color(0xFF1E3A8A);      // Classic navy blue
      case ThemeColors.crimson:
        return const Color(0xFFDC2626);      // Bold crimson red
      case ThemeColors.jade:
        return const Color(0xFF059669);      // Fresh jade green
      case ThemeColors.bronze:
        return const Color(0xFF92400E);      // Rich bronze brown
      case ThemeColors.ochre:
        return const Color(0xFFCC8E35);      // Golden ochre yellow
      case ThemeColors.sienna:
        return const Color(0xFFA0522D);      // Warm sienna brown
      case ThemeColors.black:
        return const Color(0xFF000000);      // Black
    }
  }
}