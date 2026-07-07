import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppFlavor { dev, qa, prod }

final environmentConfigProvider = Provider<EnvironmentConfig>(
  (_) => EnvironmentConfig.fromDartDefines(),
);

class EnvironmentConfig {
  const EnvironmentConfig({
    required this.flavor,
    required this.apiBaseUrl,
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
      AppFlavor.dev =>
        'https://fourcorners-washroom-bial-prod.azurewebsites.net/api',
      AppFlavor.qa =>
        'https://fourcorners-washroom-bial-prod.azurewebsites.net/api',
      AppFlavor.prod =>
        'https://fourcorners-washroom-bial-prod.azurewebsites.net/api',
    };

    return EnvironmentConfig(
      flavor: flavor,
      apiBaseUrl: const String.fromEnvironment('API_BASE_URL').isNotEmpty
          ? const String.fromEnvironment('API_BASE_URL')
          : defaultBaseUrl,
      oneSignalAppId: const String.fromEnvironment('ONESIGNAL_APP_ID'),
      enableNetworkLogging: const bool.fromEnvironment(
        'ENABLE_NETWORK_LOGGING',
        defaultValue: true,
      ),
    );
  }

  final AppFlavor flavor;
  final String apiBaseUrl;
  final String oneSignalAppId;
  final bool enableNetworkLogging;

  String get appName => switch (flavor) {
    AppFlavor.dev => '4CT Washroom Ops Dev',
    AppFlavor.qa => '4CT Washroom Ops QA',
    AppFlavor.prod => '4CT Washroom Ops',
  };
}
