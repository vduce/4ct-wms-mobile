import 'package:flutter/material.dart';

import '../../../../app/theme/adani_design_tokens.dart';
import '../../../../core/date/date_time.dart';
import '../../../../l10n/app_localizations_context.dart';
import '../../domain/ticket_models.dart';
import 'supervisor_ui.dart';

class TicketOverviewGrid extends StatelessWidget {
  const TicketOverviewGrid({
    required this.data,
    required this.dateTimeSettings,
    required this.onStatusTap,
    super.key,
  });

  final SupervisorTicketList data;
  final AppDateTimeSettings dateTimeSettings;
  final ValueChanged<SupervisorTicketStatus> onStatusTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final counts = data.counts;
    final deltas = data.countDeltasFromYesterday(
      dateTimeSettings: dateTimeSettings,
    );
    final items = [
      _TicketOverviewItem(
        status: SupervisorTicketStatus.pending,
        label: l10n.statusPending,
        accent: SupervisorPalette.pending,
      ),
      _TicketOverviewItem(
        status: SupervisorTicketStatus.acknowledge,
        label: l10n.statusAcknowledged,
        accent: SupervisorPalette.acknowledged,
      ),
      _TicketOverviewItem(
        status: SupervisorTicketStatus.escalated,
        label: l10n.statusEscalated,
        accent: SupervisorPalette.escalated,
      ),
      _TicketOverviewItem(
        status: SupervisorTicketStatus.completed,
        label: l10n.statusCompleted,
        accent: SupervisorPalette.completed,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SupervisorSectionHeader(title: l10n.ticketStatusCardsTitle),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 760;
            return GridView.builder(
              itemCount: items.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isWide ? 4 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: isWide ? 132 : 126,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                final delta = deltas[item.status] ?? 0;
                return _TicketOverviewCard(
                  label: item.label,
                  value: (counts[item.status] ?? 0).toString(),
                  icon: ticketStatusIcon(item.status),
                  accent: item.accent,
                  deltaText: _deltaLabel(context, delta),
                  deltaColor: _deltaColor(context, item.status, delta),
                  onTap: () => onStatusTap(item.status),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _TicketOverviewCard extends StatelessWidget {
  const _TicketOverviewCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.deltaText,
    required this.deltaColor,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final String deltaText;
  final Color deltaColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final radius = BorderRadius.circular(18);
    return Material(
      color: Color.alphaBlend(
        accent.withValues(alpha: isDark ? 0.07 : 0.035),
        colors.surface,
      ),
      elevation: isDark ? 0 : 1,
      shadowColor: AdaniColors.purple.withValues(alpha: 0.09),
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: accent.withValues(alpha: 0.18)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(height: 3, color: accent),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 15, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(icon, color: accent, size: 19),
                      ),
                      const Spacer(),
                      Text(
                        value,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          height: 1,
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.timeline_rounded, size: 13, color: deltaColor),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          deltaText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: deltaColor,
                          ),
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
    );
  }
}

class _TicketOverviewItem {
  const _TicketOverviewItem({
    required this.status,
    required this.label,
    required this.accent,
  });

  final SupervisorTicketStatus status;
  final String label;
  final Color accent;
}

String _deltaLabel(BuildContext context, int delta) {
  final signedDelta = delta >= 0 ? '+$delta' : '$delta';
  return context.l10n.ticketDeltaFromYesterday(signedDelta);
}

Color _deltaColor(
  BuildContext context,
  SupervisorTicketStatus status,
  int delta,
) {
  if (delta == 0) return Theme.of(context).colorScheme.onSurfaceVariant;
  final isOpenStatus =
      status == SupervisorTicketStatus.pending ||
      status == SupervisorTicketStatus.escalated;
  if (isOpenStatus) {
    return delta > 0 ? AdaniColors.error : AdaniColors.success;
  }
  return delta > 0 ? AdaniColors.success : AdaniColors.warning;
}
