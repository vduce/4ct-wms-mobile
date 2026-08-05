import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/localization/locale_controller.dart';
import '../../../../app/theme/airport_feedback_design_tokens.dart';
import '../../../../app/theme/theme_mode_controller.dart';
import '../../../../l10n/app_localizations_context.dart';
import 'feedback_metrics.dart';

class FeedbackTabletMetricColumn extends StatelessWidget {
  const FeedbackTabletMetricColumn({
    required this.items,
    required this.compact,
    required this.gap,
    super.key,
  });

  final List<FeedbackScreensaverMetricItem> items;
  final bool compact;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          Expanded(
            child: FeedbackMetricStatusCard(
              item: items[index],
              compact: compact,
              horizontal: false,
            ),
          ),
          if (index < items.length - 1) SizedBox(height: gap),
        ],
      ],
    );
  }
}

class FeedbackBrandHeader extends StatelessWidget {
  const FeedbackBrandHeader({
    required this.semanticsLabel,
    required this.compact,
    super.key,
  });

  final String semanticsLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final phone = MediaQuery.sizeOf(context).width < 520;
    final logoHeight = phone ? 34.0 : (compact ? 34.0 : 48.0);
    final logoWidth = phone ? 150.0 : (compact ? 194.0 : 258.0);

    return Semantics(
      label: semanticsLabel,
      child: Row(
        children: [
          _AdaniWordmark(compact: compact),
          Container(
            width: 1,
            height: phone ? 24 : (compact ? 27 : 36),
            margin: EdgeInsets.symmetric(
              horizontal: phone ? 8 : (compact ? 12 : 18),
            ),
            color:
                (isDark ? Colors.white : AirportFeedbackColors.lightPrimaryText)
                    .withValues(alpha: 0.35),
          ),
          Flexible(
            child: SizedBox(
              height: logoHeight,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SvgPicture.asset(
                  AirportFeedbackAssets.mialLogo,
                  width: logoWidth,
                  height: logoHeight,
                  fit: BoxFit.contain,
                  colorFilter: isDark
                      ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdaniWordmark extends StatelessWidget {
  const _AdaniWordmark({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final phone = MediaQuery.sizeOf(context).width < 520;

    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          AirportFeedbackColors.primaryBlue,
          AirportFeedbackColors.primaryPurple,
          AirportFeedbackColors.primaryPink,
        ],
      ).createShader(bounds),
      child: Text(
        'adani',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Colors.white,
          fontSize: phone ? 22 : (compact ? 25 : 32),
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class FeedbackLanguagePill extends ConsumerWidget {
  const FeedbackLanguagePill({required this.compact, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark
        ? Colors.white
        : AirportFeedbackColors.lightPrimaryText;
    final phone = MediaQuery.sizeOf(context).width < 520;
    final languageCode = Localizations.localeOf(context).languageCode;

    return PopupMenuButton<Locale>(
      tooltip: l10n.languageSelectorTooltip,
      onSelected: (locale) =>
          ref.read(localeControllerProvider.notifier).setLocale(locale),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: const Locale('en'),
          child: Text(l10n.languageEnglish),
        ),
        PopupMenuItem(
          value: const Locale('hi'),
          child: Text(l10n.languageHindi),
        ),
      ],
      child: Container(
        constraints: const BoxConstraints(minHeight: 40),
        padding: EdgeInsets.symmetric(
          horizontal: phone ? 8 : (compact ? 12 : 15),
          vertical: phone ? 7 : (compact ? 9 : 11),
        ),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF071B31).withValues(alpha: 0.86)
              : Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isDark ? const Color(0xFF253C5C) : const Color(0xFFE6E8EF),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.language_rounded,
              color: foreground,
              size: phone ? 13 : (compact ? 16 : 18),
            ),
            SizedBox(width: phone ? 4 : 6),
            Text(
              languageCode == 'hi'
                  ? l10n.feedbackLanguageHindi
                  : l10n.feedbackLanguageEnglish,
              style: TextStyle(
                color: foreground,
                fontSize: phone ? 10 : (compact ? 12 : 13),
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(width: phone ? 2 : 2),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: foreground,
              size: phone ? 13 : (compact ? 16 : 18),
            ),
          ],
        ),
      ),
    );
  }
}

class FeedbackHomeHeaderActions extends StatelessWidget {
  const FeedbackHomeHeaderActions({
    required this.compact,
    required this.temperatureCelsius,
    super.key,
  });

  final bool compact;
  final num? temperatureCelsius;

  @override
  Widget build(BuildContext context) {
    final phone = MediaQuery.sizeOf(context).width < 520;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TemperaturePill(
          compact: compact,
          temperatureCelsius: temperatureCelsius,
        ),
        SizedBox(width: phone ? 5 : 8),
        FeedbackLanguagePill(compact: compact),
        SizedBox(width: phone ? 5 : 8),
        _ThemeModeButton(compact: compact),
      ],
    );
  }
}

class _ThemeModeButton extends ConsumerWidget {
  const _ThemeModeButton({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final phone = MediaQuery.sizeOf(context).width < 520;
    final foreground = isDark
        ? Colors.white
        : AirportFeedbackColors.lightPrimaryText;
    final tooltip = isDark
        ? l10n.switchToLightModeTooltip
        : l10n.switchToDarkModeTooltip;
    const tapTargetSize = 40.0;
    final visualSize = phone ? 36.0 : (compact ? 40.0 : 42.0);

    return IconButton(
      tooltip: tooltip,
      constraints: const BoxConstraints.tightFor(
        width: tapTargetSize,
        height: tapTargetSize,
      ),
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      padding: EdgeInsets.zero,
      color: foreground,
      onPressed: () => ref
          .read(themeModeControllerProvider.notifier)
          .setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark),
      icon: SizedBox.square(
        key: const ValueKey('feedback-theme-toggle-visual'),
        dimension: visualSize,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF071B31).withValues(alpha: 0.86)
                : Colors.white.withValues(alpha: 0.94),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? const Color(0xFF253C5C) : const Color(0xFFE6E8EF),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            size: phone ? 16 : (compact ? 17 : 18),
          ),
        ),
      ),
    );
  }
}

class _TemperaturePill extends StatelessWidget {
  const _TemperaturePill({
    required this.compact,
    required this.temperatureCelsius,
  });

  final bool compact;
  final num? temperatureCelsius;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark
        ? Colors.white
        : AirportFeedbackColors.lightPrimaryText;
    final phone = MediaQuery.sizeOf(context).width < 520;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: phone ? 7 : (compact ? 10 : 13),
        vertical: phone ? 7 : (compact ? 9 : 11),
      ),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF071B31).withValues(alpha: 0.86)
            : Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark ? const Color(0xFF253C5C) : const Color(0xFFE6E8EF),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wb_sunny_outlined,
            color: foreground,
            size: phone ? 13 : (compact ? 16 : 18),
          ),
          SizedBox(width: phone ? 3 : 6),
          Text(
            _formatTemperatureLabel(
              temperatureCelsius,
              fallback: l10n.feedbackTemperatureUnavailable,
            ),
            style: TextStyle(
              color: foreground,
              fontSize: phone ? 10 : (compact ? 12 : 13),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatTemperatureLabel(num? value, {required String fallback}) {
  if (value == null) return fallback;
  return '${value.round()}°C';
}
