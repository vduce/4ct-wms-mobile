import 'package:flutter/material.dart';

import '../../../../app/theme/airport_feedback_design_tokens.dart';
import 'feedback_header.dart';

class FeedbackStepHeader extends StatelessWidget {
  const FeedbackStepHeader({
    required this.activeStep,
    required this.compact,
    required this.onBack,
    this.showLanguage = false,
    super.key,
  });

  final int activeStep;
  final bool compact;
  final VoidCallback onBack;
  final bool showLanguage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoundIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onPressed: onBack,
          compact: compact,
        ),
        Expanded(
          child: Center(child: _ProgressSteps(activeStep: activeStep)),
        ),
        if (showLanguage)
          FeedbackLanguagePill(compact: compact)
        else
          SizedBox(width: compact ? 44 : 52),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onPressed,
    required this.compact,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark
        ? Colors.white
        : AirportFeedbackColors.lightPrimaryText;

    return Material(
      color: isDark ? const Color(0xFF071B31) : Colors.white,
      shape: CircleBorder(
        side: BorderSide(
          color: isDark ? const Color(0xFF253C5C) : const Color(0xFFE6E8EF),
        ),
      ),
      elevation: isDark ? 0 : 8,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox.square(
          dimension: compact ? 44 : 52,
          child: Icon(icon, color: foreground, size: compact ? 18 : 20),
        ),
      ),
    );
  }
}

class _ProgressSteps extends StatelessWidget {
  const _ProgressSteps({required this.activeStep});

  final int activeStep;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final phone = MediaQuery.sizeOf(context).width < 520;
    final active = isDark
        ? AirportFeedbackColors.progressActiveDark
        : AirportFeedbackColors.progressActiveLight;
    final inactive = isDark
        ? AirportFeedbackColors.progressInactiveDark
        : AirportFeedbackColors.progressInactiveLight;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < 4; index++) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: index == activeStep ? (phone ? 18 : 22) : (phone ? 9 : 12),
            height: phone ? 9 : 12,
            decoration: BoxDecoration(
              color: index <= activeStep ? active : inactive,
              borderRadius: BorderRadius.circular(999),
            ),
            child: index < activeStep
                ? Icon(
                    Icons.check_rounded,
                    size: phone ? 8 : 10,
                    color: Colors.white,
                  )
                : null,
          ),
          if (index < 3)
            Container(
              width: phone ? 30 : 44,
              height: phone ? 2.4 : 3,
              color: index < activeStep ? active : inactive,
            ),
        ],
      ],
    );
  }
}
