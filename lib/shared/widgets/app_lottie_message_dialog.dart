import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../app/theme/airport_feedback_design_tokens.dart';
import 'app_gradient_button.dart';

Future<T?> showAppLottieMessageDialog<T>({
  required BuildContext context,
  required String animationAsset,
  required String title,
  required String message,
  String? actionLabel,
  VoidCallback? onAction,
  IconData fallbackIcon = Icons.check_circle_rounded,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) => AppLottieMessageDialog(
      animationAsset: animationAsset,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction ?? () => Navigator.of(dialogContext).pop(),
      fallbackIcon: fallbackIcon,
    ),
  );
}

class AppLottieMessageDialog extends StatelessWidget {
  const AppLottieMessageDialog({
    required this.animationAsset,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.fallbackIcon = Icons.check_circle_rounded,
    this.repeat = false,
    this.maxWidth = 560,
    super.key,
  });

  final String animationAsset;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData fallbackIcon;
  final bool repeat;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.sizeOf(context);
    final phone = screenSize.width < 520;
    final animationSize = math.min(
      phone ? 142.0 : 188.0,
      screenSize.shortestSide * 0.34,
    );
    final primaryText = isDark
        ? AirportFeedbackColors.darkPrimaryText
        : AirportFeedbackColors.lightPrimaryText;
    final secondaryText = isDark
        ? AirportFeedbackColors.darkSecondaryText
        : AirportFeedbackColors.lightSecondaryText;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: phone ? 22 : 32,
          vertical: phone ? 24 : 36,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Material(
            color: isDark
                ? AirportFeedbackColors.darkSurface.withValues(alpha: 0.96)
                : AirportFeedbackColors.lightSurface.withValues(alpha: 0.98),
            borderRadius: BorderRadius.circular(phone ? 24 : 30),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                phone ? 24 : 42,
                phone ? 26 : 40,
                phone ? 24 : 42,
                phone ? 24 : 36,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox.square(
                    dimension: animationSize,
                    child: Lottie.asset(
                      animationAsset,
                      repeat: repeat,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Icon(
                        fallbackIcon,
                        color: AirportFeedbackColors.success,
                        size: animationSize * 0.58,
                      ),
                    ),
                  ),
                  SizedBox(height: phone ? 16 : 22),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: primaryText,
                      fontSize: phone ? 24 : 30,
                      fontWeight: FontWeight.w900,
                      height: 1.12,
                    ),
                  ),
                  SizedBox(height: phone ? 8 : 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: secondaryText,
                      fontSize: phone ? 14 : 18,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  if (actionLabel != null && onAction != null) ...[
                    SizedBox(height: phone ? 22 : 30),
                    SizedBox(
                      width: phone ? double.infinity : 220,
                      child: AppGradientButton(
                        onPressed: onAction,
                        height: phone ? 50 : 54,
                        radius: 14,
                        label: Text(
                          actionLabel!,
                          style: TextStyle(
                            fontSize: phone ? 14 : 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
