import 'package:flutter/material.dart';

import '../../features/tenant/domain/tenant_models.dart';

abstract final class AppTheme {
  static ThemeData light(TenantBranding branding) {
    return _theme(
      ColorScheme.fromSeed(
        seedColor: branding.primaryColor,
        secondary: branding.secondaryColor,
      ),
    );
  }

  static ThemeData dark(TenantBranding branding) {
    return _theme(
      ColorScheme.fromSeed(
        seedColor: branding.primaryColor,
        secondary: branding.secondaryColor,
        brightness: Brightness.dark,
      ),
    );
  }

  static ThemeData _theme(ColorScheme colors) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Montserrat',
      colorScheme: colors,
      scaffoldBackgroundColor: colors.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: colors.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
