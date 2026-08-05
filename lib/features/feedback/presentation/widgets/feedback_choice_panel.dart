import 'package:flutter/material.dart';

import '../../../../app/theme/airport_feedback_design_tokens.dart';
import '../../../../l10n/app_localizations_context.dart';
import 'feedback_kiosk_shell.dart';
import 'feedback_step_header.dart';

class FeedbackChoicePanel extends StatelessWidget {
  const FeedbackChoicePanel({
    required this.submitting,
    required this.onBack,
    required this.onPositive,
    required this.onNegative,
    super.key,
  });

  final bool submitting;
  final VoidCallback onBack;
  final VoidCallback onPositive;
  final VoidCallback onNegative;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark
        ? AirportFeedbackColors.darkPrimaryText
        : AirportFeedbackColors.lightPrimaryText;
    final secondaryText = isDark
        ? AirportFeedbackColors.darkSecondaryText
        : AirportFeedbackColors.lightSecondaryText;

    return LayoutBuilder(
      builder: (context, constraints) {
        final phone = constraints.maxWidth < 520;
        final compact =
            phone || constraints.maxWidth < 720 || constraints.maxHeight < 620;
        final stacked = constraints.maxWidth < 340;
        final shortHeight = constraints.maxHeight < 600;
        final buttonHeight = phone
            ? (shortHeight ? 184.0 : 200.0)
            : stacked
            ? (shortHeight ? 360.0 : 430.0)
            : (shortHeight ? 250.0 : 340.0);
        final children = [
          Expanded(
            child: _FeedbackChoiceButton(
              title: l10n.feedbackChoiceSatisfiedTitle,
              subtitle: l10n.feedbackChoiceSatisfiedSubtitle,
              positive: true,
              onTap: submitting ? null : onPositive,
            ),
          ),
          SizedBox(
            width: stacked ? 0 : (phone ? 14 : 36),
            height: stacked ? 18 : 0,
          ),
          Expanded(
            child: _FeedbackChoiceButton(
              title: l10n.needsAttentionButton,
              subtitle: l10n.feedbackChoiceNeedsAttentionSubtitle,
              positive: false,
              onTap: submitting ? null : onNegative,
            ),
          ),
        ];

        return Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: -80,
              height: phone ? 116 : (compact ? 156 : 230),
              child: FeedbackAirportSkylineStrip(isDark: isDark),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                phone ? 16 : (compact ? 18 : 30),
                phone ? 10 : (compact ? 14 : 24),
                phone ? 16 : (compact ? 18 : 30),
                phone ? 12 : (compact ? 18 : 24),
              ),
              child: Column(
                children: [
                  FeedbackStepHeader(
                    activeStep: 1,
                    compact: compact,
                    onBack: onBack,
                    showLanguage: true,
                  ),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 940),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _MoodFace(
                              positive: true,
                              size: phone ? 66 : (compact ? 72 : 88),
                              decorative: true,
                            ),
                            SizedBox(
                              height: phone ? 14 : (shortHeight ? 16 : 22),
                            ),
                            Text(
                              l10n.feedbackChoiceTitle,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(
                                    color: primaryText,
                                    fontSize: phone ? 28 : (compact ? 31 : 38),
                                    height: 1.08,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            SizedBox(
                              height: phone ? 7 : (shortHeight ? 8 : 12),
                            ),
                            Text(
                              l10n.feedbackChoiceSubtitle,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: secondaryText,
                                    fontSize: phone ? 12 : (compact ? 14 : 16),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            SizedBox(
                              height: phone ? 28 : (shortHeight ? 28 : 40),
                            ),
                            Flexible(
                              child: SizedBox(
                                height: buttonHeight,
                                child: stacked
                                    ? Column(children: children)
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: children,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MoodFace extends StatelessWidget {
  const _MoodFace({
    required this.positive,
    required this.size,
    this.decorative = false,
  });

  final bool positive;
  final double size;
  final bool decorative;

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: positive
          ? const [Color(0xFF7BE3BF), Color(0xFF05B78C)]
          : const [Color(0xFFFF8A99), Color(0xFFF13B49)],
    );

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        if (decorative) ...[
          Positioned(
            left: -42,
            bottom: 4,
            child: Icon(
              Icons.cloud_rounded,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.12)
                  : const Color(0xFFDAD5FF),
              size: size * 0.45,
            ),
          ),
          Positioned(
            right: -34,
            top: 8,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: AirportFeedbackColors.primaryPink,
              size: size * 0.22,
            ),
          ),
          Positioned(
            left: -26,
            top: -8,
            child: Icon(
              Icons.star_rounded,
              color: AirportFeedbackColors.darkPrimaryCyan,
              size: size * 0.18,
            ),
          ),
        ],
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: gradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color:
                    (positive
                            ? AirportFeedbackColors.goodActionLight
                            : AirportFeedbackColors.badActionLight)
                        .withValues(alpha: 0.24),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: CustomPaint(painter: _FacePainter(positive: positive)),
        ),
      ],
    );
  }
}

class _FeedbackChoiceButton extends StatelessWidget {
  const _FeedbackChoiceButton({
    required this.title,
    required this.subtitle,
    required this.positive,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool positive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final phoneCard =
            constraints.maxWidth < 210 || constraints.maxHeight < 215;
        final veryTight = constraints.maxHeight < 250;
        final tight = constraints.maxHeight < 320;
        final compact = phoneCard || tight || constraints.maxWidth < 330;
        final horizontalPadding = phoneCard
            ? 12.0
            : veryTight
            ? 14.0
            : tight
            ? 20.0
            : compact
            ? 18.0
            : 28.0;
        final verticalPadding = phoneCard
            ? 12.0
            : veryTight
            ? 14.0
            : tight
            ? 18.0
            : compact
            ? 18.0
            : 28.0;
        final faceSize = phoneCard
            ? 56.0
            : veryTight
            ? 58.0
            : tight
            ? 78.0
            : compact
            ? 72.0
            : 92.0;
        final titleFontSize = phoneCard
            ? 19.0
            : veryTight
            ? 20.0
            : tight
            ? 24.0
            : compact
            ? 22.0
            : 27.0;
        final subtitleFontSize = phoneCard
            ? 10.5
            : veryTight
            ? 11.5
            : tight
            ? 13.0
            : compact
            ? 12.5
            : 15.0;
        final actionSize = phoneCard
            ? 36.0
            : veryTight
            ? 36.0
            : tight
            ? 44.0
            : compact
            ? 42.0
            : 50.0;
        final cardColor = isDark
            ? (positive
                  ? AirportFeedbackColors.goodCardDark
                  : AirportFeedbackColors.badCardDark)
            : (positive
                  ? AirportFeedbackColors.goodCardLight
                  : AirportFeedbackColors.badCardLight);
        final borderColor = isDark
            ? (positive
                  ? AirportFeedbackColors.goodCardBorderDark
                  : AirportFeedbackColors.badCardBorderDark)
            : (positive
                  ? AirportFeedbackColors.goodCardBorderLight
                  : AirportFeedbackColors.badCardBorderLight);
        final actionColor = isDark
            ? (positive
                  ? AirportFeedbackColors.goodActionDark
                  : AirportFeedbackColors.badActionDark)
            : (positive
                  ? AirportFeedbackColors.goodActionLight
                  : AirportFeedbackColors.badActionLight);
        final primaryText = isDark
            ? AirportFeedbackColors.darkPrimaryText
            : AirportFeedbackColors.lightPrimaryText;
        final secondaryText = isDark
            ? AirportFeedbackColors.darkSecondaryText
            : AirportFeedbackColors.lightSecondaryText;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(phoneCard ? 18 : 26),
            onTap: onTap,
            child: Ink(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              decoration: BoxDecoration(
                color: cardColor.withValues(alpha: isDark ? 0.92 : 0.84),
                borderRadius: BorderRadius.circular(phoneCard ? 18 : 26),
                border: Border.all(color: borderColor, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: borderColor.withValues(alpha: isDark ? 0.16 : 0.2),
                    blurRadius: 26,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _MoodFace(positive: positive, size: faceSize),
                  SizedBox(
                    height: phoneCard
                        ? 8
                        : veryTight
                        ? 8
                        : tight
                        ? 14
                        : compact
                        ? 14
                        : 20,
                  ),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: primaryText,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: phoneCard ? 4 : (tight ? 5 : 8)),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: secondaryText,
                      fontSize: subtitleFontSize,
                      height: phoneCard ? 1.12 : 1.22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: phoneCard
                        ? 10
                        : veryTight
                        ? 8
                        : tight
                        ? 16
                        : compact
                        ? 18
                        : 26,
                  ),
                  Container(
                    width: actionSize,
                    height: actionSize,
                    decoration: BoxDecoration(
                      color: actionColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FacePainter extends CustomPainter {
  const _FacePainter({required this.positive});

  final bool positive;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AirportFeedbackColors.lightPrimaryText
      ..style = PaintingStyle.fill;
    final eyeRadius = size.width * 0.045;
    canvas.drawCircle(
      Offset(size.width * 0.36, size.height * 0.42),
      eyeRadius,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.64, size.height * 0.42),
      eyeRadius,
      paint,
    );

    final mouthPaint = Paint()
      ..color = AirportFeedbackColors.lightPrimaryText
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.055
      ..style = PaintingStyle.stroke;
    final mouthRect = Rect.fromCenter(
      center: Offset(
        size.width * 0.5,
        positive ? size.height * 0.5 : size.height * 0.72,
      ),
      width: size.width * 0.36,
      height: size.height * 0.32,
    );
    canvas.drawArc(
      mouthRect,
      positive ? 0.18 : 3.32,
      positive ? 2.78 : 2.78,
      false,
      mouthPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FacePainter oldDelegate) =>
      oldDelegate.positive != positive;
}
