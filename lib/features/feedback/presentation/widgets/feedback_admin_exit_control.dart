import 'package:flutter/material.dart';

import '../../../../app/theme/airport_feedback_design_tokens.dart';
import '../../../../l10n/app_localizations_context.dart';
import '../../../../shared/widgets/app_gradient_button.dart';

class FeedbackAdminExitControl extends StatelessWidget {
  const FeedbackAdminExitControl({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark
        ? AirportFeedbackColors.darkSecondaryText
        : AirportFeedbackColors.lightSecondaryText;

    return Semantics(
      label: l10n.feedbackAdminExitControlLabel,
      button: true,
      onTap: onPressed,
      child: Material(
        color: Colors.transparent,
        child: InkResponse(
          onTap: onPressed,
          radius: 22,
          child: SizedBox.square(
            dimension: 44,
            child: Center(
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: foreground.withValues(alpha: isDark ? 0.08 : 0.06),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: foreground.withValues(alpha: isDark ? 0.14 : 0.1),
                  ),
                ),
                child: ExcludeSemantics(
                  child: Icon(
                    Icons.admin_panel_settings_outlined,
                    size: 15,
                    color: foreground.withValues(alpha: isDark ? 0.34 : 0.28),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<bool> showFeedbackAdminExitDialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => const _FeedbackAdminExitDialog(),
      ) ??
      false;
}

class _FeedbackAdminExitDialog extends StatelessWidget {
  const _FeedbackAdminExitDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark
        ? AirportFeedbackColors.darkSurface
        : AirportFeedbackColors.lightSurface;
    final primaryText = isDark
        ? AirportFeedbackColors.darkPrimaryText
        : AirportFeedbackColors.lightPrimaryText;
    final secondaryText = isDark
        ? AirportFeedbackColors.darkSecondaryText
        : AirportFeedbackColors.lightSecondaryText;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 410),
        child: Material(
          color: surface,
          elevation: isDark ? 0 : 10,
          shadowColor: AirportFeedbackColors.primaryPurple.withValues(
            alpha: 0.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: isDark
                  ? AirportFeedbackColors.issueCardBorderDark
                  : AirportFeedbackColors.issueCardBorderLight,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AirportFeedbackColors.primaryPurple.withValues(
                        alpha: 0.11,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_outlined,
                      size: 28,
                      color: AirportFeedbackColors.primaryPurple,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l10n.feedbackAdminExitTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.feedbackAdminExitMessage,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: secondaryText,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: AppGradientButton(
                      height: 50,
                      radius: 14,
                      onPressed: () => Navigator.of(context).pop(true),
                      icon: const Icon(Icons.logout_rounded, size: 19),
                      label: Text(l10n.feedbackAdminExitButton),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(l10n.feedbackAdminStayButton),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
