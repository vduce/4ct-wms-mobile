import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/data/session_controller.dart';
import '../features/notifications/data/notification_service.dart';
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
    final branding = ref.watch(tenantControllerProvider).branding;
    final locale = ref.watch(localeControllerProvider);
    final preferredThemeMode = ref.watch(themeModeControllerProvider);

    // Keep the OneSignal external user id aligned with the app session.
    ref.listen(sessionControllerProvider, (previous, next) {
      final service = ref.read(oneSignalServiceProvider);
      if (next.isAuthenticated && previous?.isAuthenticated != true) {
        unawaited(service.login(next.session?.userId ?? ''));
      } else if (!next.isAuthenticated && previous?.isAuthenticated == true) {
        unawaited(service.logout());
      }
    });

    return MaterialApp.router(
      title: branding.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(branding),
      darkTheme: AppTheme.dark(branding),
      themeMode: preferredThemeMode ?? branding.themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
