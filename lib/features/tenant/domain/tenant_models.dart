import 'package:flutter/material.dart';

class TenantContext {
  const TenantContext({
    required this.tenantId,
    required this.airportId,
    this.terminalId,
    this.zoneId,
    this.washroomIds = const [],
  });

  final String tenantId;
  final String airportId;
  final String? terminalId;
  final String? zoneId;
  final List<String> washroomIds;
}

class TenantBranding {
  const TenantBranding({
    required this.appName,
    required this.primaryColor,
    required this.secondaryColor,
    required this.themeMode,
    this.logoUrl,
    this.labels = const {},
    this.featureFlags = const {},
  });

  factory TenantBranding.default4ct() => const TenantBranding(
    appName: '4CT Washroom Ops',
    primaryColor: Color(0xFF0126B2),
    secondaryColor: Color(0xFF2563EB),
    themeMode: ThemeMode.system,
  );

  factory TenantBranding.fromJson(Map<String, Object?> json) {
    return TenantBranding(
      appName: json['appName'] as String? ?? '4CT Washroom Ops',
      logoUrl: json['logoUrl'] as String?,
      primaryColor:
          _parseColor(json['primaryColor'] as String?) ??
          const Color(0xFF0126B2),
      secondaryColor:
          _parseColor(json['secondaryColor'] as String?) ??
          const Color(0xFF2563EB),
      themeMode: switch (json['themeMode']) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      labels: Map<String, String>.from(json['labels'] as Map? ?? {}),
      featureFlags: Map<String, bool>.from(json['featureFlags'] as Map? ?? {}),
    );
  }

  final String appName;
  final String? logoUrl;
  final Color primaryColor;
  final Color secondaryColor;
  final ThemeMode themeMode;
  final Map<String, String> labels;
  final Map<String, bool> featureFlags;

  Map<String, Object?> toJson() => {
    'appName': appName,
    'logoUrl': logoUrl,
    'primaryColor': _colorToHex(primaryColor),
    'secondaryColor': _colorToHex(secondaryColor),
    'themeMode': themeMode.name,
    'labels': labels,
    'featureFlags': featureFlags,
  };

  static Color? _parseColor(String? value) {
    if (value == null || value.isEmpty) return null;
    final normalized = value.replaceFirst('#', '');
    final withAlpha = normalized.length == 6 ? 'FF$normalized' : normalized;
    final parsed = int.tryParse(withAlpha, radix: 16);
    return parsed == null ? null : Color(parsed);
  }

  static String _colorToHex(Color color) {
    final value = color.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#${value.substring(2).toUpperCase()}';
  }
}

class TenantState {
  const TenantState({
    required this.branding,
    this.context,
    this.isLoading = false,
  });

  factory TenantState.initial() =>
      TenantState(branding: TenantBranding.default4ct());

  final TenantBranding branding;
  final TenantContext? context;
  final bool isLoading;

  TenantState copyWith({
    TenantBranding? branding,
    TenantContext? context,
    bool? isLoading,
  }) {
    return TenantState(
      branding: branding ?? this.branding,
      context: context ?? this.context,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
