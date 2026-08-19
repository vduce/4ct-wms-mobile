import 'package:flutter/material.dart';

import '../../../../app/theme/airport_feedback_design_tokens.dart';
import '../../../../l10n/app_localizations_context.dart';
import '../../domain/feedback_models.dart';

class FeedbackDebugWashroomControl extends StatelessWidget {
  const FeedbackDebugWashroomControl({
    required this.washroomName,
    required this.onPressed,
    super.key,
  });

  final String? washroomName;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final label = washroomName == null
        ? l10n.feedbackDebugPreviewFallback
        : l10n.feedbackDebugPreviewBadge(washroomName!);
    final foreground = isDark
        ? AirportFeedbackColors.darkPrimaryCyan
        : AirportFeedbackColors.primaryPurple;

    return Semantics(
      label: l10n.feedbackDebugPreviewControlLabel,
      button: true,
      onTap: onPressed,
      child: Tooltip(
        message: l10n.feedbackDebugPreviewControlLabel,
        child: Material(
          color: isDark
              ? AirportFeedbackColors.darkSurface.withValues(alpha: 0.94)
              : AirportFeedbackColors.lightSurface.withValues(alpha: 0.96),
          shape: StadiumBorder(
            side: BorderSide(color: foreground.withValues(alpha: 0.55)),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: 48,
                minWidth: 48,
                maxWidth: 260,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.science_outlined, size: 18, color: foreground),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.expand_less_rounded,
                      size: 18,
                      color: foreground,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showFeedbackDebugWashroomSheet({
  required BuildContext context,
  required List<FeedbackWashroom> washrooms,
  required String? selectedWashroomId,
  required String? assignedWashroomId,
  required ValueChanged<String?> onSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (context) => _FeedbackDebugWashroomSheet(
      washrooms: washrooms,
      selectedWashroomId: selectedWashroomId,
      assignedWashroomId: assignedWashroomId,
      onSelected: onSelected,
    ),
  );
}

class _FeedbackDebugWashroomSheet extends StatelessWidget {
  const _FeedbackDebugWashroomSheet({
    required this.washrooms,
    required this.selectedWashroomId,
    required this.assignedWashroomId,
    required this.onSelected,
  });

  final List<FeedbackWashroom> washrooms;
  final String? selectedWashroomId;
  final String? assignedWashroomId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryText = isDark
        ? AirportFeedbackColors.darkSecondaryText
        : AirportFeedbackColors.lightSecondaryText;
    final availableHeight = MediaQuery.sizeOf(context).height * 0.78;

    return Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 640, maxHeight: availableHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: CustomScrollView(
            shrinkWrap: true,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AirportFeedbackColors.primaryPurple
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.science_outlined,
                            color: AirportFeedbackColors.primaryPurple,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.feedbackDebugPreviewTitle,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.feedbackDebugPreviewSubtitle,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AirportFeedbackColors.primaryPurple.withValues(
                          alpha: isDark ? 0.14 : 0.08,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 20,
                            color: AirportFeedbackColors.primaryPurple,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l10n.feedbackDebugPreviewWarning,
                              style: theme.textTheme.bodySmall?.copyWith(
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              SliverList.builder(
                itemCount: washrooms.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _WashroomOption(
                      title: l10n.feedbackDebugUseAssigned,
                      subtitle: l10n.feedbackDebugUseAssignedSubtitle,
                      selected: selectedWashroomId == null,
                      onTap: () => _select(context, null),
                    );
                  }
                  final washroom = washrooms[index - 1];
                  return _WashroomOption(
                    title: washroom.name,
                    subtitle: _washroomSubtitle(
                      washroom,
                      assignedWashroomId,
                      l10n.feedbackDebugAssignedLabel,
                    ),
                    selected: selectedWashroomId == washroom.id,
                    onTap: () => _select(context, washroom.id),
                  );
                },
              ),
              if (washrooms.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Text(
                      l10n.feedbackDebugNoWashrooms,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: secondaryText,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String? _washroomSubtitle(
    FeedbackWashroom washroom,
    String? assignedWashroomId,
    String assignedLabel,
  ) {
    final details = [
      if (washroom.code.isNotEmpty) washroom.code,
      if (washroom.type.isNotEmpty) washroom.type,
    ];
    if (washroom.id == assignedWashroomId) {
      details.add(assignedLabel);
    }
    return details.isEmpty ? null : details.join(' • ');
  }

  void _select(BuildContext context, String? washroomId) {
    onSelected(washroomId);
    Navigator.of(context).pop();
  }
}

class _WashroomOption extends StatelessWidget {
  const _WashroomOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = Theme.of(context).brightness == Brightness.dark
        ? AirportFeedbackColors.darkPrimaryCyan
        : AirportFeedbackColors.primaryPurple;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected
            ? selectedColor.withValues(alpha: 0.1)
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selected
                ? selectedColor.withValues(alpha: 0.65)
                : theme.dividerColor.withValues(alpha: 0.5),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          minTileHeight: 56,
          onTap: onTap,
          title: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: selected ? selectedColor : null,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
          subtitle: subtitle == null ? null : Text(subtitle!),
          trailing: Icon(
            selected ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: selected ? selectedColor : theme.disabledColor,
          ),
        ),
      ),
    );
  }
}
