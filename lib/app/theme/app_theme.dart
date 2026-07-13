import 'package:flutter/material.dart';

import '../../features/tenant/domain/tenant_models.dart';
import 'airport_feedback_design_tokens.dart';

abstract final class AppTheme {
  static ThemeData light(TenantBranding branding) {
    return _theme(_lightScheme());
  }

  static ThemeData dark(TenantBranding branding) {
    return _theme(_darkScheme());
  }

  static ThemeData _theme(ColorScheme colors) {
    final isDark = colors.brightness == Brightness.dark;
    final textTheme = _interTextTheme(
      ThemeData(brightness: colors.brightness).textTheme,
    );
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: colors,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      scaffoldBackgroundColor: isDark
          ? AirportFeedbackColors.darkBackground
          : AirportFeedbackColors.lightBackground,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: isDark ? 0 : 5,
        margin: EdgeInsets.zero,
        shadowColor: colors.shadow.withValues(alpha: isDark ? 0.18 : 0.14),
        surfaceTintColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: colors.outlineVariant.withValues(
              alpha: isDark ? 0.45 : 0.55,
            ),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: isDark
              ? AirportFeedbackColors.darkPrimaryCyan
              : AirportFeedbackColors.primaryPurple,
          foregroundColor: Colors.white,
          disabledBackgroundColor: colors.outlineVariant.withValues(alpha: 0.5),
          disabledForegroundColor: colors.onSurface.withValues(alpha: 0.45),
          minimumSize: const Size.fromHeight(48),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark
              ? AirportFeedbackColors.darkPrimaryCyan
              : AirportFeedbackColors.primaryPurple,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark
              ? AirportFeedbackColors.darkPrimaryCyan
              : AirportFeedbackColors.primaryPurple,
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(
            color: isDark
                ? AirportFeedbackColors.darkPrimaryCyan.withValues(alpha: 0.74)
                : AirportFeedbackColors.primaryPurple,
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark
              ? AirportFeedbackColors.darkPrimaryCyan
              : AirportFeedbackColors.primaryPurple,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? AirportFeedbackColors.darkSurface.withValues(alpha: 0.84)
            : Colors.white.withValues(alpha: 0.78),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        hintStyle: TextStyle(
          color: colors.onSurfaceVariant.withValues(alpha: 0.72),
        ),
        labelStyle: TextStyle(color: colors.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.62),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 1.6),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: isDark
            ? AirportFeedbackColors.progressActiveDark
            : AirportFeedbackColors.progressActiveLight,
        linearTrackColor: isDark
            ? AirportFeedbackColors.progressInactiveDark
            : AirportFeedbackColors.progressInactiveLight,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark
            ? AirportFeedbackColors.darkSurface
            : AirportFeedbackColors.lightPrimaryText,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static TextTheme _interTextTheme(TextTheme baseTextTheme) {
    return baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w800,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w800,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w800,
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w500,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static ColorScheme _lightScheme() {
    return ColorScheme.fromSeed(
      seedColor: AirportFeedbackColors.primaryPurple,
      secondary: AirportFeedbackColors.primaryBlue,
    ).copyWith(
      primary: AirportFeedbackColors.primaryPurple,
      onPrimary: Colors.white,
      secondary: AirportFeedbackColors.primaryBlue,
      onSecondary: Colors.white,
      tertiary: AirportFeedbackColors.primaryPink,
      surface: AirportFeedbackColors.lightSurface,
      onSurface: AirportFeedbackColors.lightPrimaryText,
      surfaceContainerHighest: const Color(0xFFF7F3FF),
      onSurfaceVariant: AirportFeedbackColors.lightSecondaryText,
      outline: const Color(0xFFD7DCEA),
      outlineVariant: const Color(0xFFE3E7EF),
      error: AirportFeedbackColors.error,
    );
  }

  static ColorScheme _darkScheme() {
    return ColorScheme.fromSeed(
      seedColor: AirportFeedbackColors.darkPrimaryCyan,
      secondary: AirportFeedbackColors.darkPrimaryTeal,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AirportFeedbackColors.darkPrimaryCyan,
      onPrimary: AirportFeedbackColors.darkBackground,
      secondary: AirportFeedbackColors.darkPrimaryTeal,
      onSecondary: AirportFeedbackColors.darkBackground,
      tertiary: AirportFeedbackColors.primaryPurple,
      surface: AirportFeedbackColors.darkSurface,
      onSurface: AirportFeedbackColors.darkPrimaryText,
      surfaceContainerHighest: AirportFeedbackColors.darkSurfaceAlt,
      onSurfaceVariant: AirportFeedbackColors.darkSecondaryText,
      outline: const Color(0xFF245162),
      outlineVariant: const Color(0xFF31505A),
      error: AirportFeedbackColors.error,
    );
  }
}
