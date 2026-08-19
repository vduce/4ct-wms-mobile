import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../../app/router/app_router.dart';
import '../../../core/config/environment_config.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/storage/session_keys.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/session_controller.dart';
import '../../auth/domain/user_session.dart';
import '../domain/notification_models.dart';
import 'notification_inbox_controller.dart';

final oneSignalServiceProvider = Provider<OneSignalService>((ref) {
  return OneSignalService(
    ref.watch(environmentConfigProvider),
    ref.watch(appLoggerProvider),
    ref,
  );
});

/// Shared OneSignal setup for Android and iOS. Initializes from
/// `EnvironmentConfig.oneSignalAppId`, requests permission, normalizes push
/// into [AppNotification] for the shared inbox, routes clicks via go_router
/// and keeps the backend push token + OneSignal user in sync with the session.
/// Rendering copy is delegated to `NotificationTemplateService`.
class OneSignalService {
  OneSignalService(this._config, this._logger, this._ref);

  final EnvironmentConfig _config;
  final AppLogger _logger;
  final Ref _ref;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    if (_config.oneSignalAppId.isEmpty) {
      _logger.warning('OneSignal App ID is not configured for this flavor.');
      return;
    }

    OneSignal.Debug.setLogLevel(
      _config.enableNetworkLogging ? OSLogLevel.verbose : OSLogLevel.error,
    );
    await OneSignal.initialize(_config.oneSignalAppId);
    _initialized = true;

    _registerForegroundListener();
    _registerClickListener();
    _registerSubscriptionObserver();
    _registerPermissionObserver();

    // Permission is requested lazily via [applyPushPreference] once the
    // session is known, so passenger-facing kiosk devices are never prompted.
  }

  void _registerForegroundListener() {
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      final notification = event.notification;
      _storeInInbox(notification);
      event.notification.display();
    });
  }

  void _registerClickListener() {
    OneSignal.Notifications.addClickListener((event) {
      final notification = event.notification;
      _storeInInbox(notification);
      _handleDeepLink(notification);
    });
  }

  void _registerSubscriptionObserver() {
    OneSignal.User.pushSubscription.addObserver((state) {
      final playerId = state.current.id ?? state.current.token;
      if (playerId != null && playerId.isNotEmpty) {
        unawaited(_onPushTokenChanged(playerId));
      }
    });
  }

  void _registerPermissionObserver() {
    OneSignal.Notifications.addPermissionObserver((permission) {
      _logger.info('OneSignal push permission changed: $permission');
    });
  }

  Future<void> _onPushTokenChanged(String token) async {
    await _ref.read(secureStorageProvider).write(SessionKeys.pushToken, token);
    final session = _ref.read(sessionControllerProvider).session;
    if (session != null) {
      await _syncPushToken(session, token);
    }
  }

  Future<void> _syncPushToken(UserSession session, String token) async {
    try {
      await _ref
          .read(authRepositoryProvider)
          .updatePushToken(userId: session.userId, token: token);
    } catch (error, stackTrace) {
      _logger.warning('Failed to sync push token.', error, stackTrace);
    }
  }

  /// Associates the OneSignal user with the authenticated user id.
  Future<void> login(String externalId) async {
    if (externalId.isEmpty) return;
    if (!_initialized) await initialize();
    if (!_initialized) return;
    try {
      await OneSignal.login(externalId);
      final playerId = await _ref
          .read(secureStorageProvider)
          .read(SessionKeys.pushToken);
      if (playerId != null && playerId.isNotEmpty) {
        final session = _ref.read(sessionControllerProvider).session;
        if (session != null) await _syncPushToken(session, playerId);
      }
      _logger.info('OneSignal user logged in: $externalId');
    } catch (error, stackTrace) {
      _logger.warning('OneSignal login failed.', error, stackTrace);
    }
  }

  /// Detaches the OneSignal user on sign out.
  Future<void> logout() async {
    if (!_initialized) return;
    try {
      await OneSignal.logout();
      _logger.info('OneSignal user logged out.');
    } catch (error, stackTrace) {
      _logger.warning('OneSignal logout failed.', error, stackTrace);
    }
  }

  /// Applies the effective push state for the current [session] and the
  /// device [pushEnabled] preference.
  ///
  /// Feedback-device (kiosk) roles are force-disabled regardless of the
  /// preference, so passenger-facing tablets never receive push. Regular
  /// users are logged in and opted in/out based on [pushEnabled]; opting in
  /// triggers the native permission prompt on first use.
  Future<void> applyPushPreference(
    UserSession? session,
    bool pushEnabled,
  ) async {
    if (!_initialized) await initialize();
    if (!_initialized) return;

    if (session == null) {
      await logout();
      return;
    }

    if (session.isFeedbackDevice) {
      try {
        await OneSignal.User.pushSubscription.optOut();
        await OneSignal.logout();
        _logger.info('OneSignal push disabled for feedback-device role.');
      } catch (error, stackTrace) {
        _logger.warning(
          'Failed to disable push for feedback device.',
          error,
          stackTrace,
        );
      }
      return;
    }

    await login(session.userId);
    try {
      if (pushEnabled) {
        await OneSignal.User.pushSubscription.optIn();
      } else {
        await OneSignal.User.pushSubscription.optOut();
      }
      _logger.info('OneSignal push preference applied: enabled=$pushEnabled');
    } catch (error, stackTrace) {
      _logger.warning('Failed to apply push preference.', error, stackTrace);
    }
  }

  void _storeInInbox(OSNotification notification) {
    final data = notification.additionalData ?? <String, dynamic>{};
    final appNotification = AppNotification.fromOneSignalPayload(
      Map<String, Object?>.from(data),
      id: notification.notificationId.isNotEmpty
          ? notification.notificationId
          : DateTime.now().millisecondsSinceEpoch.toString(),
      fallbackTitle: notification.title,
      fallbackBody: notification.body,
    );
    unawaited(
      _ref
          .read(notificationInboxControllerProvider.notifier)
          .add(appNotification),
    );
  }

  void _handleDeepLink(OSNotification notification) {
    final data = notification.additionalData ?? <String, dynamic>{};
    final deepLink =
        data['deepLink']?.toString() ??
        data['route']?.toString() ??
        data['screen']?.toString();
    if (deepLink == null || deepLink.isEmpty) return;

    try {
      _ref.read(appRouterProvider).go(deepLink);
    } catch (error, stackTrace) {
      _logger.warning('Invalid deep link from notification: $deepLink');
      _logger.warning('', error, stackTrace);
    }
  }
}
