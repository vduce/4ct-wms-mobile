import 'package:flutter/material.dart';

abstract final class AdaniColors {
  static const purple = Color(0xFF7004A0);
  static const purpleBright = Color(0xFFC000D5);
  static const blue = Color(0xFF2774D9);
  static const pink = Color(0xFFED0B62);

  static const lightBackground = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightHero = Color(0xFFF7F0FC);
  static const lightHeroAccent = Color(0xFFEED7F7);
  static const lightPrimaryText = Color(0xFF242021);
  static const lightSecondaryText = Color(0xFF666166);
  static const lightBorder = Color(0xFFEEE6F2);

  static const darkBackground = Color(0xFF150E1E);
  static const darkSurface = Color(0xFF251B34);
  static const darkHero = Color(0xFF291A3B);
  static const darkHeroAccent = Color(0xFF4A2E5D);
  static const darkPrimaryText = Color(0xFFF8F3FC);
  static const darkSecondaryText = Color(0xFFBEB3CF);
  static const darkBorder = Color(0xFF413050);

  static const success = Color(0xFF0AA463);
  static const warning = Color(0xFFDD8211);
  static const error = Color(0xFFEC4F58);
}

abstract final class AdaniGradients {
  static const action = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AdaniColors.blue, AdaniColors.purpleBright, AdaniColors.pink],
    stops: [0, 0.58, 1],
  );
}

abstract final class AdaniAssets {
  static const swirl = 'assets/branding/adani_swirl_placeholder.jpeg';
}
