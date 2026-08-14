import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../app/theme/airport_feedback_design_tokens.dart';
import '../../../../l10n/app_localizations_context.dart';

class FeedbackDirectQrCard extends StatelessWidget {
  const FeedbackDirectQrCard({
    required this.qrUrl,
    required this.compact,
    required this.horizontal,
    this.dense = false,
    this.footer = false,
    this.onTap,
    super.key,
  });

  final String qrUrl;
  final bool compact;
  final bool horizontal;
  final bool dense;
  final bool footer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final phone = MediaQuery.sizeOf(context).width < 520;
    final foreground = isDark
        ? Colors.white
        : AirportFeedbackColors.lightPrimaryText;
    final qrSize = footer
        ? (phone ? 68.0 : 62.0)
        : horizontal
        ? (dense ? 82.0 : 102.0)
        : (dense ? 104.0 : (compact ? 110.0 : 138.0));
    final cardPadding = footer ? 6.0 : (dense ? 10.0 : (compact ? 10.0 : 14.0));
    final qrPadding = footer ? 5.0 : (dense ? 6.0 : 7.0);
    final radius = BorderRadius.circular(14);

    final qrCode = DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(qrPadding),
        child: QrImageView(
          data: qrUrl,
          version: QrVersions.auto,
          size: qrSize,
          padding: EdgeInsets.zero,
          backgroundColor: Colors.white,
          semanticsLabel: l10n.feedbackQrDialogMessage,
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: Colors.black,
          ),
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: Colors.black,
          ),
        ),
      ),
    );

    final instructions = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: horizontal
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text(
          l10n.feedbackQrStartLabel,
          maxLines: 2,
          overflow: TextOverflow.visible,
          textAlign: horizontal ? TextAlign.start : TextAlign.center,
          style: TextStyle(
            color: foreground,
            fontSize: footer ? 10 : (dense ? 11.5 : (compact ? 13 : 15)),
            height: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    return SizedBox(
      width: horizontal || phone
          ? double.infinity
          : footer
          ? 122
          : qrSize + (2 * qrPadding) + (2 * cardPadding),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Ink(
            padding: footer ? EdgeInsets.zero : EdgeInsets.all(cardPadding),
            decoration: footer
                ? null
                : BoxDecoration(
                    color: isDark
                        ? const Color(0xFF081B33).withValues(alpha: 0.92)
                        : Colors.white.withValues(alpha: 0.94),
                    borderRadius: radius,
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF243B5A)
                          : const Color(0xFFE6E8EF),
                    ),
                  ),
            child: horizontal
                ? Row(
                    children: [
                      qrCode,
                      SizedBox(width: compact ? 12 : 16),
                      Expanded(child: instructions),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!footer) SizedBox(height: dense ? 8 : 12),
                      qrCode,
                      SizedBox(height: footer ? 8 : (dense ? 8 : 12)),
                      instructions,
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class FeedbackQrDialog extends StatelessWidget {
  const FeedbackQrDialog({
    required this.qrUrl,
    required this.onActivity,
    super.key,
  });

  final String qrUrl;
  final VoidCallback onActivity;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark
        ? AirportFeedbackColors.darkPrimaryText
        : AirportFeedbackColors.lightPrimaryText;
    final muted = isDark
        ? AirportFeedbackColors.darkSecondaryText
        : AirportFeedbackColors.lightSecondaryText;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => onActivity(),
      child: Dialog(
        insetPadding: const EdgeInsets.all(24),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isDark
                  ? AirportFeedbackColors.darkSurface
                  : AirportFeedbackColors.lightSurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF263C5B)
                    : const Color(0xFFE7E6F1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.14),
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: l10n.feedbackQrDialogCloseButton,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                  Text(
                    l10n.feedbackQrDialogTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.feedbackQrDialogMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: muted,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: QrImageView(
                        data: qrUrl,
                        version: QrVersions.auto,
                        size: 230,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Colors.black,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.feedbackQrDialogCloseButton),
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
