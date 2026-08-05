import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/tenant/data/tenant_controller.dart';
import '../l10n/generated/app_localizations.dart';
import 'localization/locale_controller.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_mode_controller.dart';

class WashroomOpsApp extends ConsumerWidget {
  const WashroomOpsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final branding = ref.watch(tenantControllerProvider).branding;
    final locale = ref.watch(localeControllerProvider);
    final preferredThemeMode = ref.watch(themeModeControllerProvider);

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
