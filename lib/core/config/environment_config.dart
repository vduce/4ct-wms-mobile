import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppFlavor { dev, qa, prod }

final environmentConfigProvider = Provider<EnvironmentConfig>(
  (_) => EnvironmentConfig.fromDartDefines(),
);

class EnvironmentConfig {
  const EnvironmentConfig({
    required this.flavor,
    required this.apiBaseUrl,
    required this.portalBaseUrl,
    required this.feedbackWebUrl,
    required this.feedbackVideoUrl,
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
      AppFlavor.dev => 'https://api.wms-dev.smartdigibuild.net/api/v1',
      AppFlavor.qa => 'https://qa-api.4ctwms.com/api/v1',
      AppFlavor.prod => 'https://api.wms-prod.smartdigibuild.net/api/v1',
    };
    final defaultPortalBaseUrl = switch (flavor) {
      AppFlavor.dev => 'https://wms-dev.smartdigibuild.net',
      AppFlavor.qa => 'https://qa.4ctwms.com',
      AppFlavor.prod => 'https://mial.smartdigibuild.net',
    };
    final portalBaseUrl =
        const String.fromEnvironment('PORTAL_BASE_URL').isNotEmpty
        ? const String.fromEnvironment('PORTAL_BASE_URL')
        : defaultPortalBaseUrl;
    final defaultFeedbackWebUrl = portalBaseUrl;

    return EnvironmentConfig(
      flavor: flavor,
      apiBaseUrl: const String.fromEnvironment('API_BASE_URL').isNotEmpty
          ? const String.fromEnvironment('API_BASE_URL')
          : defaultBaseUrl,
      portalBaseUrl: portalBaseUrl,
      feedbackWebUrl:
          const String.fromEnvironment('FEEDBACK_WEB_URL').isNotEmpty
          ? const String.fromEnvironment('FEEDBACK_WEB_URL')
          : defaultFeedbackWebUrl,
      feedbackVideoUrl: const String.fromEnvironment(
        'FEEDBACK_VIDEO_URL',
        defaultValue:
            'https://stgfcwashroomnewprod01.blob.core.windows.net/app-artifacts-prod/assets/mumbai-passenger-feedback-animation-final.mp4',
      ),
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
  final String portalBaseUrl;
  final String feedbackWebUrl;
  final String feedbackVideoUrl;
  final String tenantSlug;
  final String oneSignalAppId;
  final bool enableNetworkLogging;

  String get appName => switch (flavor) {
    AppFlavor.dev => '4CT Washroom Ops Dev',
    AppFlavor.qa => '4CT Washroom Ops QA',
    AppFlavor.prod => '4CT Washroom Ops',
  };
}
