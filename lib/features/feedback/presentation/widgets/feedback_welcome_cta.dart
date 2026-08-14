import 'package:flutter/material.dart';

import '../../../../app/theme/airport_feedback_design_tokens.dart';
import '../../../../l10n/app_localizations_context.dart';
import '../../../../shared/widgets/app_gradient_button.dart';

class FeedbackWelcomeCta extends StatelessWidget {
  const FeedbackWelcomeCta({
    required this.compact,
    required this.onPressed,
    this.expanded = false,
    super.key,
  });

  final bool compact;
  final VoidCallback onPressed;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final phone = MediaQuery.sizeOf(context).width < 520;

    return SizedBox(
      width: expanded ? double.infinity : (phone ? double.infinity : 430),
      child: AppGradientButton(
        onPressed: onPressed,
        height: compact ? 58 : 76,
        radius: 18,
        gradient: isDark
            ? AirportFeedbackGradients.darkWelcome
            : AirportFeedbackGradients.lightWelcome,
        padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 20),
        icon: _FeedbackCommentIcon(compact: compact),
        label: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.feedbackShareFeedbackTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 15 : 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              expanded
                  ? l10n.feedbackTapAnywhereSubtitle
                  : l10n.feedbackStartSubtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.82),
                fontSize: compact ? 11 : 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        trailingIcon: Icon(
          Icons.arrow_forward_rounded,
          size: compact ? 22 : 26,
        ),
      ),
    );
  }
}

class _FeedbackCommentIcon extends StatelessWidget {
  const _FeedbackCommentIcon({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final phone = MediaQuery.sizeOf(context).width < 520;
    final size = phone ? 42.0 : (compact ? 42.0 : 48.0);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      child: CustomPaint(painter: _FeedbackCommentIconPainter()),
    );
  }
}

class _FeedbackCommentIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bubblePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final dotPaint = Paint()
      ..color = AirportFeedbackColors.primaryPurple.withValues(alpha: 0.76)
      ..style = PaintingStyle.fill;

    final bubbleRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.25,
        size.height * 0.28,
        size.width * 0.52,
        size.height * 0.39,
      ),
      Radius.circular(size.width * 0.11),
    );
    canvas.drawRRect(bubbleRect, bubblePaint);

    final tail = Path()
      ..moveTo(size.width * 0.36, size.height * 0.64)
      ..lineTo(size.width * 0.28, size.height * 0.76)
      ..lineTo(size.width * 0.49, size.height * 0.66)
      ..close();
    canvas.drawPath(tail, bubblePaint);

    final dotRadius = size.width * 0.035;
    for (final offset in const [0.42, 0.51, 0.60]) {
      canvas.drawCircle(
        Offset(size.width * offset, size.height * 0.475),
        dotRadius,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
