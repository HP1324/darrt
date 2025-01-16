import 'package:flutter/material.dart';

enum ThemeColors {
  deepTeal,
  lavendarBlush,
  peach,
  mauve,
  coral,
  mint,
  skyBlue,
  salmon,
  lilac,
  sage,
  goldenrod,
  aqua,
  rose,
  tangerine,
  periwinkle,
  apricot,
  dustyBlue,
  seafoam,
  plum,
  sandstone,
  terracotta,
  celadon,
  orchid,
  azure,
  mango,
  cornflower,
  juniper,
  rosewood,
  cerulean,
  mahogany,
  moss,
  mulberry,
  slate,
  rust,
  sapphire,
  sienna,
  turquoise,
  burgundy,
  emerald,
  amethyst,
  copper,
  indigo,
  jade,
  topaz,
  crimson
}

extension ThemeColorsExtension on ThemeColors {
  Color get color {
    switch (this) {
      case ThemeColors.deepTeal:
        return Color(0xFF00574B);
      case ThemeColors.lavendarBlush:
        return Color(0xFFBA68C8);
      case ThemeColors.peach:
        return Color(0xFFFFCBA4);
      case ThemeColors.mauve:
        return Color(0xFF9B7E8E);
      case ThemeColors.coral:
        return Color(0xFFFF7F50);
      case ThemeColors.mint:
        return Color(0xFF98FF98);
      case ThemeColors.skyBlue:
        return Color(0xFF87CEEB);
      case ThemeColors.salmon:
        return Color(0xFFFA8072);
      case ThemeColors.lilac:
        return Color(0xFFC8A2C8);
      case ThemeColors.sage:
        return Color(0xFFBCB88A);
      case ThemeColors.goldenrod:
        return Color(0xFFDAA520);
      case ThemeColors.aqua:
        return Color(0xFF7FDBFF);
      case ThemeColors.rose:
        return Color(0xFFFFB5C5);
      case ThemeColors.tangerine:
        return Color(0xFFFFA07A);
      case ThemeColors.periwinkle:
        return Color(0xFFCCCCFF);
      case ThemeColors.apricot:
        return Color(0xFFFFB347);
      case ThemeColors.dustyBlue:
        return Color(0xFF6699CC);
      case ThemeColors.seafoam:
        return Color(0xFF98FF98);
      case ThemeColors.plum:
        return Color(0xFF8B4513);
      case ThemeColors.sandstone:
        return Color(0xFFF4A460);
      case ThemeColors.terracotta:
        return Color(0xFFE2725B);
      case ThemeColors.celadon:
        return Color(0xFFACE1AF);
      case ThemeColors.orchid:
        return Color(0xFFDA70D6);
      case ThemeColors.azure:
        return Color(0xFF007FFF);
      case ThemeColors.mango:
        return Color(0xFFFFBE4F);
      case ThemeColors.cornflower:
        return Color(0xFF6495ED);
      case ThemeColors.juniper:
        return Color(0xFF689F38);
      case ThemeColors.rosewood:
        return Color(0xFF65000B);
      case ThemeColors.cerulean:
        return Color(0xFF007BA7);
      case ThemeColors.mahogany:
        return Color(0xFF8B0000);
      case ThemeColors.moss:
        return Color(0xFF8FBC8F);
      case ThemeColors.mulberry:
        return Color(0xFFC54B8C);
      case ThemeColors.slate:
        return Color(0xFF708090);
      case ThemeColors.rust:
        return Color(0xFFB7410E);
      case ThemeColors.sapphire:
        return Color(0xFF0F52BA);
      case ThemeColors.sienna:
        return Color(0xFF882D17);
      case ThemeColors.turquoise:
        return Color(0xFF40E0D0);
      case ThemeColors.burgundy:
        return Color(0xFF800020);
      case ThemeColors.emerald:
        return Color(0xFF50C878);
      case ThemeColors.amethyst:
        return Color(0xFF9966CC);
      case ThemeColors.copper:
        return Color(0xFFB87333);
      case ThemeColors.indigo:
        return Color(0xFF4B0082);
      case ThemeColors.jade:
        return Color(0xFF00A86B);
      case ThemeColors.topaz:
        return Color(0xFFFFC87C);
      case ThemeColors.crimson:
        return Color(0xFFDC143C);
    }
  }
}