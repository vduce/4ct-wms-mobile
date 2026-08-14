import 'package:flutter/material.dart';

import '../../../../app/theme/adani_design_tokens.dart';
import '../../../../l10n/app_localizations_context.dart';
import '../../domain/ticket_models.dart';
import 'supervisor_ui.dart';

class TicketHistoryFilters extends StatelessWidget {
  const TicketHistoryFilters({
    required this.fromDate,
    required this.toDate,
    required this.statusFilter,
    required this.sourceFilter,
    required this.washroomFilter,
    required this.washroomOptions,
    required this.onPickFrom,
    required this.onPickTo,
    required this.onStatusChanged,
    required this.onSourceChanged,
    required this.onWashroomChanged,
    required this.displayDate,
    super.key,
  });

  final String fromDate;
  final String toDate;
  final SupervisorTicketStatus? statusFilter;
  final TicketSource? sourceFilter;
  final String? washroomFilter;
  final List<MapEntry<String, String>> washroomOptions;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;
  final ValueChanged<SupervisorTicketStatus?> onStatusChanged;
  final ValueChanged<TicketSource?> onSourceChanged;
  final ValueChanged<String?> onWashroomChanged;
  final String Function(String date) displayDate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SupervisorSurface(
      padding: EdgeInsets.zero,
      radius: 22,
      color: isDark ? AdaniColors.darkHero : AdaniColors.lightHero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 4,
            decoration: const BoxDecoration(gradient: AdaniGradients.action),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 18),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 700;
                final status = _FilterGroup(
                  label: l10n.statusLabel,
                  children: [
                    SupervisorFilterPill(
                      label: l10n.allStatusesLabel,
                      selected: statusFilter == null,
                      height: 32,
                      horizontalPadding: 12,
                      onPressed: () => onStatusChanged(null),
                    ),
                    for (final item in SupervisorTicketStatus.values)
                      SupervisorFilterPill(
                        label: ticketStatusLabel(context, item),
                        selected: statusFilter == item,
                        height: 32,
                        horizontalPadding: 12,
                        onPressed: () => onStatusChanged(item),
                      ),
                  ],
                );
                final source = _FilterGroup(
                  label: l10n.ticketSourceLabel,
                  children: [
                    SupervisorFilterPill(
                      label: l10n.allSourcesLabel,
                      selected: sourceFilter == null,
                      height: 32,
                      horizontalPadding: 12,
                      onPressed: () => onSourceChanged(null),
                    ),
                    SupervisorFilterPill(
                      label: l10n.ticketSourceUser,
                      selected: sourceFilter == TicketSource.user,
                      height: 32,
                      horizontalPadding: 12,
                      onPressed: () => onSourceChanged(TicketSource.user),
                    ),
                    SupervisorFilterPill(
                      label: l10n.ticketSourceSystem,
                      selected: sourceFilter == TicketSource.system,
                      height: 32,
                      horizontalPadding: 12,
                      onPressed: () => onSourceChanged(TicketSource.system),
                    ),
                  ],
                );
                final washroom = _WashroomFilter(
                  selected: washroomFilter,
                  options: washroomOptions,
                  onChanged: onWashroomChanged,
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.filterTicketsTooltip,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _DateFilterField(
                            label: l10n.historyFromLabel,
                            value: displayDate(fromDate),
                            onTap: onPickFrom,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DateFilterField(
                            label: l10n.historyToLabel,
                            value: displayDate(toDate),
                            onTap: onPickTo,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: wide ? 20 : 16),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: status),
                          const SizedBox(width: 18),
                          Expanded(flex: 3, child: source),
                          const SizedBox(width: 18),
                          Expanded(flex: 3, child: washroom),
                        ],
                      )
                    else ...[
                      status,
                      const SizedBox(height: 14),
                      source,
                      const SizedBox(height: 14),
                      washroom,
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterGroup extends StatelessWidget {
  const _FilterGroup({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FilterLabel(label: label),
        const SizedBox(height: 8),
        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(right: 4),
            itemCount: children.length,
            separatorBuilder: (_, _) => const SizedBox(width: 7),
            itemBuilder: (context, index) => children[index],
          ),
        ),
      ],
    );
  }
}

class _WashroomFilter extends StatelessWidget {
  const _WashroomFilter({
    required this.selected,
    required this.options,
    required this.onChanged,
  });

  final String? selected;
  final List<MapEntry<String, String>> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FilterLabel(label: l10n.washroomFallback),
        const SizedBox(height: 8),
        SupervisorSurface(
          radius: 14,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 1),
          child: DropdownButtonFormField<String?>(
            initialValue: selected,
            isExpanded: true,
            decoration: const InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
            ),
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(l10n.allWashroomsLabel),
              ),
              for (final item in options)
                DropdownMenuItem(value: item.key, child: Text(item.value)),
            ],
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _FilterLabel extends StatelessWidget {
  const _FilterLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: colors.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _DateFilterField extends StatelessWidget {
  const _DateFilterField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return SupervisorSurface(
      onTap: onTap,
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              Icons.calendar_today_rounded,
              color: colors.primary,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
