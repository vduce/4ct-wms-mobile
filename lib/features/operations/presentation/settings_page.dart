import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../app/localization/locale_controller.dart';
import '../../../app/theme/theme_mode_controller.dart';
import '../../../l10n/app_localizations_context.dart';
import '../../auth/data/session_controller.dart';
import '../../notifications/data/notification_inbox_controller.dart';
import '../../tenant/data/tenant_controller.dart';
import 'widgets/operations_drawer.dart';
import 'widgets/operations_sign_out_dialog.dart';
import 'widgets/settings_about_dialog.dart';
import 'widgets/settings_content.dart';
import 'widgets/supervisor_ui.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final session = ref.watch(sessionControllerProvider).session;
    final tenantState = ref.watch(tenantControllerProvider);
    final preferredLocale = ref.watch(localeControllerProvider);
    final preferredThemeMode = ref.watch(themeModeControllerProvider);
    final unreadCount = ref.watch(
      notificationInboxControllerProvider.select((state) => state.unreadCount),
    );
    final displayName = session?.username.isNotEmpty == true
        ? session!.username
        : l10n.defaultUserName;
    final languageCode =
        preferredLocale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final themeMode = preferredThemeMode ?? tenantState.branding.themeMode;

    return Scaffold(
      drawer: OperationsDrawer(
        appName: tenantState.branding.appName,
        logoUrl: tenantState.branding.logoUrl,
        displayName: displayName,
        role: session?.roleDisplayName ?? session?.role ?? '',
        unreadCount: unreadCount,
        selectedDestination: OperationsDrawerDestination.settings,
        onOpenHome: () => context.go('/operations/home'),
        onOpenHistory: () => context.go('/operations/ticket-history'),
        onOpenNotifications: () => context.go('/notifications'),
        onOpenDashboards: () => context.go('/operations/dashboard'),
        onOpenSettings: () => context.go('/operations/settings'),
        onSignOut: _confirmSignOut,
      ),
      appBar: AppBar(
        leadingWidth: 72,
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: l10n.openNavigationTooltip,
            onPressed: Scaffold.of(context).openDrawer,
            icon: const Icon(Icons.menu_rounded, size: 30),
          ),
        ),
        titleSpacing: 0,
        title: Text(
          l10n.settingsTitle,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      body: SupervisorScrollableBody(
        maxWidth: 940,
        children: [
          SettingsContent(
            languageCode: languageCode,
            themeMode: themeMode,
            onLanguageChanged: (languageCode) => ref
                .read(localeControllerProvider.notifier)
                .setLocale(Locale(languageCode)),
            onThemeChanged: (themeMode) => ref
                .read(themeModeControllerProvider.notifier)
                .setThemeMode(themeMode),
            onOpenNotifications: () => context.go('/notifications'),
            onOpenAbout: _showAbout,
            onSignOut: _confirmSignOut,
          ),
        ],
      ),
    );
  }

  Future<void> _showAbout() async {
    final l10n = context.l10n;
    final branding = ref.read(tenantControllerProvider).branding;
    PackageInfo? packageInfo;
    try {
      packageInfo = await PackageInfo.fromPlatform();
    } catch (_) {
      // The dialog remains available if native package metadata is unavailable.
    }
    if (!mounted) return;

    await showSettingsAboutDialog(
      context: context,
      appName: branding.appName,
      logoUrl: branding.logoUrl,
      version: _metadataValue(packageInfo?.version, l10n.notAvailableLabel),
      buildNumber: _metadataValue(
        packageInfo?.buildNumber,
        l10n.notAvailableLabel,
      ),
    );
  }

  String _metadataValue(String? value, String fallback) {
    return value == null || value.trim().isEmpty ? fallback : value;
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showOperationsSignOutDialog(context);
    if (!mounted || !confirmed) return;
    await ref.read(sessionControllerProvider.notifier).signOut();
  }
}
