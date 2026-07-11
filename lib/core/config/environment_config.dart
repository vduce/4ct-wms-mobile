import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppFlavor { dev, qa, prod }

final environmentConfigProvider = Provider<EnvironmentConfig>(
  (_) => EnvironmentConfig.fromDartDefines(),
);

class EnvironmentConfig {
  const EnvironmentConfig({
    required this.flavor,
    required this.apiBaseUrl,
    required this.tenantSlug,
    required this.oneSignalAppId,
    required this.enableNetworkLogging,
  });

  factory EnvironmentConfig.fromDartDefines() {
    final flavorName = const String.fromEnvironment(
      'FLAVOR',
      defaultValue: 'dev',
    );
    final flavor = AppFlavor.values.firstWhere(
      (item) => item.name == flavorName,
      orElse: () => AppFlavor.dev,
    );

    final defaultBaseUrl = switch (flavor) {
      AppFlavor.dev => 'http://localhost:9000/api/v1',
      AppFlavor.qa => 'https://qa-api.4ctwms.com/api/v1',
      AppFlavor.prod => 'https://api.wms-dev.smartdigibuild.net/api/v1',
    };

    return EnvironmentConfig(
      flavor: flavor,
      apiBaseUrl: const String.fromEnvironment('API_BASE_URL').isNotEmpty
          ? const String.fromEnvironment('API_BASE_URL')
          : defaultBaseUrl,
      tenantSlug: const String.fromEnvironment('TENANT_SLUG'),
      oneSignalAppId: const String.fromEnvironment('ONESIGNAL_APP_ID'),
      enableNetworkLogging: const bool.fromEnvironment(
        'ENABLE_NETWORK_LOGGING',
        defaultValue: true,
      ),
    );
  }

  final AppFlavor flavor;
  final String apiBaseUrl;
  final String tenantSlug;
  final String oneSignalAppId;
  final bool enableNetworkLogging;

  String get appName => switch (flavor) {
    AppFlavor.dev => '4CT Washroom Ops Dev',
    AppFlavor.qa => '4CT Washroom Ops QA',
    AppFlavor.prod => '4CT Washroom Ops',
  };
}
