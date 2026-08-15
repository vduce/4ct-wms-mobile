import 'package:flutter/material.dart';

import '../../../../app/theme/adani_design_tokens.dart';
import '../../../../l10n/app_localizations_context.dart';
import 'settings_preferences_panel.dart';
import 'supervisor_ui.dart';

class SettingsContent extends StatelessWidget {
  const SettingsContent({
    required this.languageCode,
    required this.themeMode,
    required this.onLanguageChanged,
    required this.onThemeChanged,
    required this.onOpenNotifications,
    required this.onOpenAbout,
    required this.onSignOut,
    super.key,
  });

  final String languageCode;
  final ThemeMode themeMode;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<ThemeMode> onThemeChanged;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenAbout;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SettingsHero(),
        const SizedBox(height: 22),
        _SectionHeading(
          title: l10n.preferencesSectionTitle,
          subtitle: l10n.preferencesSectionSubtitle,
        ),
        const SizedBox(height: 12),
        SettingsPreferencesPanel(
          languageCode: languageCode,
          themeMode: themeMode,
          onLanguageChanged: onLanguageChanged,
          onThemeChanged: onThemeChanged,
        ),
        const SizedBox(height: 24),
        _SectionHeading(
          title: l10n.appInformationSectionTitle,
          subtitle: l10n.appInformationSectionSubtitle,
        ),
        const SizedBox(height: 12),
        SupervisorSurface(
          padding: EdgeInsets.zero,
          radius: 20,
          child: Column(
            children: [
              _SettingsActionTile(
                icon: Icons.notifications_none_rounded,
                title: l10n.notificationsTitle,
                subtitle: l10n.notificationsSettingSubtitle,
                onTap: onOpenNotifications,
              ),
              const Divider(height: 1),
              _SettingsActionTile(
                icon: Icons.info_outline_rounded,
                title: l10n.aboutUsTitle,
                subtitle: l10n.aboutUsSubtitle,
                onTap: onOpenAbout,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _SectionHeading(
          title: l10n.accountSectionTitle,
          subtitle: l10n.accountSectionSubtitle,
        ),
        const SizedBox(height: 12),
        _SettingsActionTile(
          icon: Icons.logout_rounded,
          title: l10n.signOutTooltip,
          subtitle: l10n.signOutConfirmMessage,
          destructive: true,
          surface: true,
          onTap: onSignOut,
        ),
      ],
    );
  }
}

class _SettingsHero extends StatelessWidget {
  const _SettingsHero();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return SupervisorSurface(
      padding: EdgeInsets.zero,
      radius: 22,
      color: isDark ? AdaniColors.darkHero : AdaniColors.lightHero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 4,
            decoration: const BoxDecoration(gradient: AdaniGradients.action),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AdaniGradients.action,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.settingsHeroTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.settingsHeroSubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  const _SettingsActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
    this.surface = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;
  final bool surface;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final content = InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (destructive ? colors.error : colors.primary).withValues(
                  alpha: 0.09,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: destructive ? colors.error : colors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: destructive ? colors.error : colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.onSurfaceVariant.withValues(alpha: 0.55),
            ),
          ],
        ),
      ),
    );
    if (!surface) return content;
    return SupervisorSurface(
      padding: EdgeInsets.zero,
      radius: 18,
      child: content,
    );
  }
}
