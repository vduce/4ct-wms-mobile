import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../app/theme/airport_feedback_design_tokens.dart';

class AppLoadingDialog extends StatelessWidget {
  const AppLoadingDialog({
    this.animationAsset = AirportFeedbackAssets.rocketLaunchAnimation,
    this.alignment = Alignment.center,
    this.topPadding = 28,
    this.size,
    this.maxWidth = 220,
    super.key,
  });

  final String animationAsset;
  final AlignmentGeometry alignment;
  final double topPadding;
  final double? size;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.sizeOf(context);
    final compact = screenSize.width < 520 || screenSize.height < 620;
    final animationSize =
        size ?? math.min(compact ? 98.0 : 126.0, screenSize.shortestSide * 0.3);

    return Align(
      alignment: alignment,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            alignment == Alignment.topCenter ? topPadding : 0,
            16,
            0,
          ),
          child: Material(
            color: isDark
                ? AirportFeedbackColors.darkSurface.withValues(alpha: 0.96)
                : AirportFeedbackColors.lightSurface.withValues(alpha: 0.98),
            elevation: isDark ? 0 : 14,
            shadowColor: Colors.black.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(22),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 24 : 30,
                  vertical: compact ? 18 : 22,
                ),
                child: AppLoadingIndicator(
                  animationAsset: animationAsset,
                  size: animationSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({
    this.animationAsset = AirportFeedbackAssets.rocketLaunchAnimation,
    this.size = 96,
    super.key,
  });

  final String animationAsset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Lottie.asset(
        animationAsset,
        repeat: true,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const CircularProgressIndicator(),
      ),
    );
  }
}
