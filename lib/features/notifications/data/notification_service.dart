import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../../core/config/environment_config.dart';
import '../../../core/logging/app_logger.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(
    ref.watch(environmentConfigProvider),
    ref.watch(appLoggerProvider),
  );
});

class NotificationService {
  const NotificationService(this._config, this._logger);

  final EnvironmentConfig _config;
  final AppLogger _logger;

  Future<void> initialize() async {
    if (_config.oneSignalAppId.isEmpty) {
      _logger.warning('OneSignal App ID is not configured for this flavor.');
      return;
    }

    OneSignal.initialize(_config.oneSignalAppId);
    await OneSignal.Notifications.requestPermission(true);

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      _logger.info('Foreground notification: ${event.notification.title}');
      event.notification.display();
    });

    OneSignal.Notifications.addClickListener((event) {
      _logger.info('Notification opened: ${event.notification.additionalData}');
      // TODO: parse deep link payloads and route through go_router.
    });
  }
}
