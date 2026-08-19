import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/date/date_time.dart';
import '../features/auth/data/session_controller.dart';
import '../features/auth/domain/user_session.dart';
import '../features/notifications/data/notification_service.dart';
import '../features/notifications/data/push_preference_controller.dart';
import '../features/tenant/data/tenant_controller.dart';
import '../l10n/generated/app_localizations.dart';
import 'localization/locale_controller.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_mode_controller.dart';

class WashroomOpsApp extends ConsumerStatefulWidget {
  const WashroomOpsApp({super.key});

  @override
  ConsumerState<WashroomOpsApp> createState() => _WashroomOpsAppState();
}

class _WashroomOpsAppState extends ConsumerState<WashroomOpsApp> {
  @override
  void initState() {
    super.initState();
    // Fire-and-forget: the SDK buffers early clicks until the listener
    // registers, so initializing here is safe for cold-start taps too.
    unawaited(ref.read(oneSignalServiceProvider).initialize());
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final tenantState = ref.watch(tenantControllerProvider);
    final branding = tenantState.branding;
    final locale = ref.watch(localeControllerProvider);
    final preferredThemeMode = ref.watch(themeModeControllerProvider);

    // Keep OneSignal push state aligned with the session and the device
    // preference. Feedback-device (kiosk) roles are force-disabled inside
    // OneSignalService regardless of the stored preference.
    ref.listen(sessionControllerProvider, (previous, next) {
      _applyPushPreference(
        ref,
        next.session,
        ref.read(pushPreferenceControllerProvider),
      );
    });
    ref.listen(pushPreferenceControllerProvider, (previous, next) {
      _applyPushPreference(
        ref,
        ref.read(sessionControllerProvider).session,
        next,
      );
    });

    return AppDateTimeScope(
      formatter: AppDateTimeFormatter(tenantState.dateTimeSettings),
      child: MaterialApp.router(
        title: branding.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(branding),
        darkTheme: AppTheme.dark(branding),
        themeMode: preferredThemeMode ?? branding.themeMode,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
  }

  void _applyPushPreference(
    WidgetRef ref,
    UserSession? session,
    bool pushEnabled,
  ) {
    unawaited(
      ref
          .read(oneSignalServiceProvider)
          .applyPushPreference(session, pushEnabled),
    );
  }
}
