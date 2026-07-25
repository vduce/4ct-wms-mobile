import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../features/tenant/domain/tenant_models.dart';
import 'adani_design_tokens.dart';

abstract final class AppTheme {
  static ThemeData light(TenantBranding branding) {
    return _theme(_lightScheme());
  }

  static ThemeData dark(TenantBranding branding) {
    return _theme(_darkScheme());
  }

  static ThemeData _theme(ColorScheme colors) {
    final isDark = colors.brightness == Brightness.dark;
    final textTheme = _poppinsTextTheme(
      ThemeData(brightness: colors.brightness).textTheme,
    );
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      colorScheme: colors,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      scaffoldBackgroundColor: isDark
          ? AdaniColors.darkBackground
          : AdaniColors.lightBackground,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 68,
        backgroundColor: isDark
            ? AdaniColors.darkBackground
            : AdaniColors.lightBackground,
        foregroundColor: colors.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        elevation: isDark ? 0 : 5,
        margin: EdgeInsets.zero,
        shadowColor: AdaniColors.purple.withValues(alpha: 0.13),
        surfaceTintColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colors.outlineVariant.withValues(alpha: isDark ? 0.9 : 1),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AdaniColors.purple,
          foregroundColor: Colors.white,
          disabledBackgroundColor: colors.outlineVariant.withValues(alpha: 0.5),
          disabledForegroundColor: colors.onSurface.withValues(alpha: 0.45),
          minimumSize: const Size.fromHeight(48),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AdaniColors.purple,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark
              ? const Color(0xFFD77BFA)
              : AdaniColors.purple,
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(
            color: isDark ? const Color(0xFF513B65) : const Color(0xFFE7D6EF),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark
              ? const Color(0xFFD77BFA)
              : AdaniColors.purpleBright,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? AdaniColors.darkSurface.withValues(alpha: 0.94)
            : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        hintStyle: TextStyle(
          color: colors.onSurfaceVariant.withValues(alpha: 0.72),
        ),
        labelStyle: TextStyle(color: colors.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.62),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.primary, width: 1.6),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: isDark ? const Color(0xFFD77BFA) : AdaniColors.purple,
        linearTrackColor: colors.outlineVariant,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark
            ? AdaniColors.darkSurface
            : AdaniColors.lightPrimaryText,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static TextTheme _poppinsTextTheme(TextTheme baseTextTheme) {
    return baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w800,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w800,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w800,
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w700,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w700,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w400,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w400,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w500,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static ColorScheme _lightScheme() {
    return ColorScheme.fromSeed(
      seedColor: AdaniColors.purple,
      secondary: AdaniColors.blue,
    ).copyWith(
      primary: AdaniColors.purple,
      onPrimary: Colors.white,
      secondary: AdaniColors.blue,
      onSecondary: Colors.white,
      tertiary: AdaniColors.pink,
      surface: AdaniColors.lightSurface,
      onSurface: AdaniColors.lightPrimaryText,
      surfaceContainerHighest: AdaniColors.lightHero,
      onSurfaceVariant: AdaniColors.lightSecondaryText,
      outline: const Color(0xFFD9C9E1),
      outlineVariant: AdaniColors.lightBorder,
      error: AdaniColors.error,
    );
  }

  static ColorScheme _darkScheme() {
    return ColorScheme.fromSeed(
      seedColor: const Color(0xFFD77BFA),
      secondary: AdaniColors.blue,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFFD77BFA),
      onPrimary: AdaniColors.darkBackground,
      secondary: AdaniColors.blue,
      onSecondary: Colors.white,
      tertiary: AdaniColors.pink,
      surface: AdaniColors.darkSurface,
      onSurface: AdaniColors.darkPrimaryText,
      surfaceContainerHighest: AdaniColors.darkHero,
      onSurfaceVariant: AdaniColors.darkSecondaryText,
      outline: const Color(0xFF5A416B),
      outlineVariant: AdaniColors.darkBorder,
      error: AdaniColors.error,
    );
  }
}
