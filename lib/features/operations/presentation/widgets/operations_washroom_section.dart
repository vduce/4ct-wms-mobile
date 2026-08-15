import 'package:flutter/material.dart';

import '../../../../app/theme/adani_design_tokens.dart';
import '../../../../l10n/app_localizations_context.dart';
import '../../domain/ticket_models.dart';
import 'supervisor_ui.dart';

class OperationsWashroomSection extends StatelessWidget {
  const OperationsWashroomSection({required this.washrooms, super.key});

  final List<SupervisorWashroom> washrooms;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          title: l10n.supervisedUnitsTitle,
          countLabel: l10n.supervisedUnitsCount(washrooms.length),
          actionLabel: l10n.viewAllButton,
          onAction: () => _showAllWashrooms(context),
        ),
        const SizedBox(height: 12),
        if (washrooms.isEmpty)
          SupervisorDottedStatePanel(
            icon: Icons.meeting_room_outlined,
            message: l10n.emptyWashroomsMessage,
            minHeight: 106,
          )
        else
          _WashroomCards(washrooms: washrooms),
      ],
    );
  }

  Future<void> _showAllWashrooms(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: FractionallySizedBox(
          heightFactor: 0.78,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.supervisedUnitsTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 14),
                if (washrooms.isEmpty)
                  SupervisorDottedStatePanel(
                    icon: Icons.meeting_room_outlined,
                    message: context.l10n.emptyWashroomsMessage,
                    minHeight: 106,
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: washrooms.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) =>
                          _WashroomCard(washroom: washrooms[index]),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.countLabel,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String countLabel;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      children: [
        Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            countLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 4),
        TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}

class _WashroomCards extends StatelessWidget {
  const _WashroomCards({required this.washrooms});

  final List<SupervisorWashroom> washrooms;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 700;
        final width = twoColumns
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            for (final washroom in washrooms)
              SizedBox(
                width: width,
                child: _WashroomCard(washroom: washroom),
              ),
          ],
        );
      },
    );
  }
}

class _WashroomCard extends StatelessWidget {
  const _WashroomCard({required this.washroom});

  final SupervisorWashroom washroom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accent = _washroomAccent(washroom.type, colors);

    return SupervisorSurface(
      padding: EdgeInsets.zero,
      radius: 18,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 12,
            bottom: 12,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                gradient: AdaniGradients.action,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    _washroomIcon(washroom.type),
                    color: accent,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        washroom.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: [
                          if (washroom.code.isNotEmpty)
                            _MetaPill(
                              icon: Icons.tag_rounded,
                              label: washroom.code,
                            ),
                          _MetaPill(
                            icon: Icons.meeting_room_outlined,
                            label: context.l10n.cubiclesCount(
                              washroom.cubicleCount,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

Color _washroomAccent(SupervisorWashroomType type, ColorScheme colors) {
  return switch (type) {
    SupervisorWashroomType.female => AdaniColors.pink,
    SupervisorWashroomType.male => AdaniColors.blue,
    SupervisorWashroomType.handicapped => AdaniColors.success,
    SupervisorWashroomType.unisex => AdaniColors.purple,
    SupervisorWashroomType.unknown => colors.onSurfaceVariant,
  };
}

IconData _washroomIcon(SupervisorWashroomType type) {
  return switch (type) {
    SupervisorWashroomType.female => Icons.woman_rounded,
    SupervisorWashroomType.handicapped => Icons.accessible_forward_rounded,
    SupervisorWashroomType.unisex => Icons.wc_rounded,
    SupervisorWashroomType.male => Icons.man_rounded,
    SupervisorWashroomType.unknown => Icons.meeting_room_rounded,
  };
}
