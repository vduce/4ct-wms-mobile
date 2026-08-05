import 'package:flutter/material.dart';

import '../../../../app/theme/airport_feedback_design_tokens.dart';
import '../../../../l10n/app_localizations_context.dart';
import '../../../../shared/widgets/app_lottie_message_dialog.dart';

class FeedbackThanksPanel extends StatelessWidget {
  const FeedbackThanksPanel({
    required this.positive,
    required this.onDone,
    super.key,
  });

  final bool positive;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppLottieMessageDialog(
      animationAsset: AirportFeedbackAssets.successAnimation,
      title: l10n.feedbackThanksTitle,
      message: positive
          ? l10n.feedbackThanksPositiveSubtitle
          : l10n.feedbackThanksNegativeSubtitle,
      actionLabel: l10n.doneButton,
      onAction: onDone,
      fallbackIcon: positive ? Icons.verified_rounded : Icons.handshake_rounded,
    );
  }
}
