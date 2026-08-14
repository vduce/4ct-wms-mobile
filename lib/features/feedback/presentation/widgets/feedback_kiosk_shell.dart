import 'package:flutter/material.dart';

import '../../../../app/theme/airport_feedback_design_tokens.dart';
import '../../../../l10n/app_localizations_context.dart';
import '../../../../shared/widgets/app_gradient_button.dart';
import '../../../../shared/widgets/app_loading_dialog.dart';

class FeedbackKioskScaffold extends StatelessWidget {
  const FeedbackKioskScaffold({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  AirportFeedbackColors.darkBackground,
                  Color(0xFF001B34),
                  AirportFeedbackColors.darkBackground,
                ]
              : const [
                  AirportFeedbackColors.lightBackground,
                  Color(0xFFFFFFFF),
                ],
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}

class FeedbackLoadingShell extends StatelessWidget {
  const FeedbackLoadingShell({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ColoredBox(
      color: isDark
          ? AirportFeedbackColors.darkBackground
          : AirportFeedbackColors.lightBackground,
      child: const AppLoadingDialog(),
    );
  }
}

class FeedbackErrorShell extends StatelessWidget {
  const FeedbackErrorShell({
    required this.message,
    required this.onRetry,
    required this.onSignOut,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark
        ? AirportFeedbackColors.darkSurface
        : AirportFeedbackColors.lightSurface;
    final primaryText = isDark
        ? AirportFeedbackColors.darkPrimaryText
        : AirportFeedbackColors.lightPrimaryText;

    return ColoredBox(
      color: isDark
          ? AirportFeedbackColors.darkBackground
          : AirportFeedbackColors.lightBackground,
      child: Center(
        child: Container(
          width: 520,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 56),
              const SizedBox(height: 18),
              Text(
                l10n.feedbackDeviceNotReadyTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onSignOut,
                      child: Text(l10n.signOutTooltip),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppGradientButton(
                      onPressed: onRetry,
                      label: Text(l10n.retryButton),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeedbackAirportSkylineStrip extends StatelessWidget {
  const FeedbackAirportSkylineStrip({required this.isDark, super.key});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (!isDark) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: Container(),
      /*child: Image.asset(
        isDark
            ? AirportFeedbackAssets.darkAirportSkyline
            : AirportFeedbackAssets.lightAirportSkyline,
        fit: BoxFit.fill,
        alignment: Alignment.bottomCenter,
      ),*/
    );
  }
}
