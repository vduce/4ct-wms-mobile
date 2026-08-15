import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations_context.dart';
import 'supervisor_ui.dart';

class SettingsPreferencesPanel extends StatelessWidget {
  const SettingsPreferencesPanel({
    required this.languageCode,
    required this.themeMode,
    required this.onLanguageChanged,
    required this.onThemeChanged,
    super.key,
  });

  final String languageCode;
  final ThemeMode themeMode;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final language = _PreferenceCard(
      icon: Icons.language_rounded,
      title: l10n.languageSettingTitle,
      subtitle: l10n.languageSettingSubtitle,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _SettingsChoice<String>(
            icon: Icons.translate_rounded,
            label: l10n.languageEnglish,
            value: 'en',
            selectedValue: languageCode,
            onSelected: onLanguageChanged,
          ),
          _SettingsChoice<String>(
            icon: Icons.translate_rounded,
            label: l10n.languageHindi,
            value: 'hi',
            selectedValue: languageCode,
            onSelected: onLanguageChanged,
          ),
        ],
      ),
    );
    final appearance = _PreferenceCard(
      icon: Icons.palette_outlined,
      title: l10n.appearanceSettingTitle,
      subtitle: l10n.appearanceSettingSubtitle,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _SettingsChoice<ThemeMode>(
            icon: Icons.brightness_auto_rounded,
            label: l10n.themeSystemLabel,
            value: ThemeMode.system,
            selectedValue: themeMode,
            onSelected: onThemeChanged,
          ),
          _SettingsChoice<ThemeMode>(
            icon: Icons.light_mode_outlined,
            label: l10n.themeLightLabel,
            value: ThemeMode.light,
            selectedValue: themeMode,
            onSelected: onThemeChanged,
          ),
          _SettingsChoice<ThemeMode>(
            icon: Icons.dark_mode_outlined,
            label: l10n.themeDarkLabel,
            value: ThemeMode.dark,
            selectedValue: themeMode,
            onSelected: onThemeChanged,
          ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 760) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: language),
              const SizedBox(width: 14),
              Expanded(child: appearance),
            ],
          );
        }
        return Column(
          children: [language, const SizedBox(height: 12), appearance],
        );
      },
    );
  }
}

class _PreferenceCard extends StatelessWidget {
  const _PreferenceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return SupervisorSurface(
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: colors.primary, size: 20),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SettingsChoice<T> extends StatelessWidget {
  const _SettingsChoice({
    required this.icon,
    required this.label,
    required this.value,
    required this.selectedValue,
    required this.onSelected,
  });

  final IconData icon;
  final String label;
  final T value;
  final T selectedValue;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selected = value == selectedValue;
    return Material(
      color: selected
          ? colors.primary.withValues(alpha: 0.1)
          : colors.surfaceContainerHighest.withValues(alpha: 0.48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected
              ? colors.primary.withValues(alpha: 0.42)
              : colors.outlineVariant,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onSelected(value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? Icons.check_circle_rounded : icon,
                size: 17,
                color: selected ? colors.primary : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: selected ? colors.primary : colors.onSurface,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
