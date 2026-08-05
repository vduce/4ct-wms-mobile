import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/airport_feedback_design_tokens.dart';
import '../../../../l10n/app_localizations_context.dart';
import '../../../../shared/widgets/app_gradient_button.dart';
import '../../domain/feedback_models.dart';
import 'feedback_step_header.dart';

class FeedbackNegativePanel extends StatelessWidget {
  const FeedbackNegativePanel({
    required this.reasons,
    required this.selectedReasonIds,
    required this.comment,
    required this.submitting,
    required this.onBack,
    required this.onToggleReason,
    required this.onAddComment,
    required this.onSubmit,
    super.key,
  });

  final List<FeedbackReason> reasons;
  final Set<String> selectedReasonIds;
  final String comment;
  final bool submitting;
  final VoidCallback onBack;
  final ValueChanged<String> onToggleReason;
  final VoidCallback onAddComment;
  final VoidCallback onSubmit;

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
      builder: (context, panelConstraints) {
        final phone = panelConstraints.maxWidth < 520;
        final compact =
            phone ||
            panelConstraints.maxWidth < 760 ||
            panelConstraints.maxHeight < 620;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            phone ? 14 : (compact ? 18 : 30),
            phone ? 10 : (compact ? 14 : 24),
            phone ? 14 : (compact ? 18 : 30),
            phone ? 12 : (compact ? 18 : 24),
          ),
          child: Column(
            children: [
              FeedbackStepHeader(
                activeStep: 2,
                compact: compact,
                onBack: submitting ? () {} : onBack,
              ),
              SizedBox(height: phone ? 12 : (compact ? 18 : 26)),
              Text(
                l10n.feedbackNegativeTitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: primaryText,
                  fontSize: phone ? 18 : (compact ? 21 : 27),
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: phone ? 2 : 4),
              Text(
                l10n.feedbackNegativeSubtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: primaryText,
                  fontSize: phone ? 17 : (compact ? 18 : 22),
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: phone ? 6 : 8),
              Text(
                l10n.feedbackNegativeHelper,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: secondaryText,
                  fontSize: phone ? 10.5 : (compact ? 12 : 14),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: phone ? 12 : (compact ? 18 : 24)),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1040),
                    child: reasons.isEmpty
                        ? const _EmptyReasons()
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final minTileWidth = compact ? 118.0 : 150.0;
                              final count = phone
                                  ? 4
                                  : math.max(
                                      2,
                                      math.min(
                                        5,
                                        constraints.maxWidth ~/ minTileWidth,
                                      ),
                                    );
                              return GridView.builder(
                                itemCount: reasons.length,
                                padding: EdgeInsets.zero,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: count,
                                      crossAxisSpacing: phone
                                          ? 8
                                          : (compact ? 12 : 18),
                                      mainAxisSpacing: phone
                                          ? 8
                                          : (compact ? 12 : 18),
                                      childAspectRatio: phone
                                          ? 1.02
                                          : (compact ? 1.08 : 1.14),
                                    ),
                                itemBuilder: (context, index) {
                                  final reason = reasons[index];
                                  return _ReasonTile(
                                    reason: reason,
                                    selected: selectedReasonIds.contains(
                                      reason.id,
                                    ),
                                    onTap: submitting
                                        ? null
                                        : () => onToggleReason(reason.id),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ),
              ),
              SizedBox(height: phone ? 10 : (compact ? 14 : 18)),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: _CommentFieldButton(
                  comment: comment,
                  onPressed: submitting ? null : onAddComment,
                ),
              ),
              SizedBox(height: phone ? 10 : (compact ? 14 : 18)),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: AppGradientButton(
                  onPressed: submitting ? null : onSubmit,
                  height: phone ? 52 : (compact ? 58 : 66),
                  radius: 12,
                  label: submitting
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.feedbackSubmitButton,
                          style: TextStyle(
                            fontSize: phone ? 14 : (compact ? 15 : 18),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                  trailingIcon: submitting
                      ? null
                      : Icon(
                          Icons.send_rounded,
                          size: phone ? 18 : (compact ? 20 : 23),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CommentFieldButton extends StatelessWidget {
  const _CommentFieldButton({required this.comment, required this.onPressed});

  final String comment;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final phone = MediaQuery.sizeOf(context).width < 520;
    final textColor = isDark
        ? AirportFeedbackColors.darkSecondaryText
        : AirportFeedbackColors.lightSecondaryText;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Ink(
          height: phone ? 46 : 54,
          padding: EdgeInsets.symmetric(horizontal: phone ? 14 : 18),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0B2A37).withValues(alpha: 0.86)
                : const Color(0xFFF1F0FA).withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF245162) : const Color(0xFFE6E5F0),
            ),
          ),
          child: Row(
            children: [
              Icon(
                comment.isEmpty
                    ? Icons.chat_bubble_outline_rounded
                    : Icons.chat_bubble_rounded,
                color: textColor,
                size: phone ? 17 : 20,
              ),
              SizedBox(width: phone ? 9 : 12),
              Expanded(
                child: Text(
                  comment.isEmpty
                      ? l10n.feedbackCommentFieldPlaceholder
                      : comment,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: phone ? 12.5 : 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({
    required this.reason,
    required this.selected,
    required this.onTap,
  });

  final FeedbackReason reason;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = selected
        ? (isDark
              ? AirportFeedbackColors.issueSelectedDark
              : AirportFeedbackColors.issueSelectedLight)
        : (isDark
              ? AirportFeedbackColors.issueCardDark
              : AirportFeedbackColors.issueCardLight);
    final borderColor = selected
        ? (isDark
              ? AirportFeedbackColors.issueSelectedBorderDark
              : AirportFeedbackColors.issueSelectedBorderLight)
        : (isDark
              ? AirportFeedbackColors.issueCardBorderDark
              : AirportFeedbackColors.issueCardBorderLight);
    final textColor = isDark
        ? AirportFeedbackColors.darkPrimaryText
        : AirportFeedbackColors.lightPrimaryText;

    return LayoutBuilder(
      builder: (context, constraints) {
        final phoneTile =
            constraints.maxWidth < 96 || constraints.maxHeight < 92;
        final compact =
            phoneTile ||
            constraints.maxHeight < 124 ||
            constraints.maxWidth < 132;
        final graphicSize = phoneTile ? 30.0 : (compact ? 42.0 : 58.0);
        final radius = phoneTile ? 10.0 : 14.0;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(radius),
            onTap: onTap,
            child: Ink(
              padding: EdgeInsets.symmetric(
                horizontal: phoneTile ? 5 : (compact ? 8 : 12),
                vertical: phoneTile ? 5 : (compact ? 8 : 11),
              ),
              decoration: BoxDecoration(
                color: cardColor.withValues(alpha: isDark ? 0.92 : 0.96),
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: borderColor,
                  width: selected ? 1.6 : 1,
                ),
                boxShadow: isDark
                    ? const []
                    : [
                        BoxShadow(
                          color: const Color(
                            0xFF09183A,
                          ).withValues(alpha: 0.05),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _reasonGraphic(
                          size: graphicSize,
                          iconSize: phoneTile ? 20 : (compact ? 25 : 34),
                        ),
                        SizedBox(height: phoneTile ? 3 : (compact ? 10 : 15)),
                        Text(
                          reason.reason,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: textColor,
                                fontSize: phoneTile
                                    ? 8.4
                                    : (compact ? 13.5 : 16),
                                height: phoneTile ? 1.05 : 1.12,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: borderColor,
                        size: phoneTile ? 14 : (compact ? 17 : 20),
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

  Widget _reasonGraphic({required double size, required double iconSize}) {
    final asset = _reasonAsset(reason.reason);
    final imageUrl = reason.imageUrl?.trim() ?? '';
    final color = _reasonColor(reason);
    final fallbackIcon = Icon(
      _reasonIcon(reason.reason),
      color: color,
      size: iconSize,
    );

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      child: asset != null
          ? Image.asset(asset, fit: BoxFit.contain)
          : imageUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => fallbackIcon,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return fallbackIcon;
                },
              ),
            )
          : fallbackIcon,
    );
  }

  String? _reasonAsset(String label) {
    final value = label.toLowerCase();
    if (value.contains('slippery') || value.contains('floor')) {
      return AirportFeedbackAssets.slipperyFloor;
    }
    if (value.contains('soap')) return AirportFeedbackAssets.noSoap;
    if (value.contains('paper')) return AirportFeedbackAssets.noToiletPaper;
    if (value.contains('mirror')) return AirportFeedbackAssets.mirrorDirty;
    if (value.contains('urinal')) return AirportFeedbackAssets.urinalDirty;
    if (value.contains('commode') || value.contains('toilet')) {
      return AirportFeedbackAssets.commodeDirty;
    }
    if (value.contains('sink')) return AirportFeedbackAssets.sinkClogged;
    if (value.contains('basin')) return AirportFeedbackAssets.washbasinDirty;
    if (value.contains('water')) return AirportFeedbackAssets.waterjetIssue;
    if (value.contains('smell') ||
        value.contains('odor') ||
        value.contains('odour')) {
      return AirportFeedbackAssets.unpleasantSmell;
    }
    if (value.contains('other')) return AirportFeedbackAssets.others;
    return null;
  }

  IconData _reasonIcon(String label) {
    final value = label.toLowerCase();
    if (value.contains('bin')) return Icons.delete_outline_rounded;
    if (value.contains('smell') || value.contains('odor')) {
      return Icons.air_rounded;
    }
    if (value.contains('basin') || value.contains('sink')) {
      return Icons.countertops_rounded;
    }
    if (value.contains('paper')) return Icons.receipt_long_rounded;
    if (value.contains('soap')) return Icons.soap_rounded;
    if (value.contains('slippery') || value.contains('floor')) {
      return Icons.warning_amber_rounded;
    }
    if (value.contains('mirror')) return Icons.crop_portrait_rounded;
    if (value.contains('commode') || value.contains('toilet')) {
      return Icons.wc_rounded;
    }
    if (value.contains('urinal')) return Icons.male_rounded;
    if (value.contains('water')) return Icons.water_drop_rounded;
    return Icons.cleaning_services_rounded;
  }

  Color _reasonColor(FeedbackReason reason) {
    return switch (reason.priority.toLowerCase()) {
      'high' => const Color(0xFFE04F4F),
      'low' => const Color(0xFF1D9A6C),
      _ => const Color(0xFF3157D5),
    };
  }
}

class _EmptyReasons extends StatelessWidget {
  const _EmptyReasons();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        context.l10n.feedbackEmptyReasonsMessage,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.black54,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
