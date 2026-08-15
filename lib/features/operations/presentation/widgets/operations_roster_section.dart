import 'package:flutter/material.dart';

import '../../../../app/theme/adani_design_tokens.dart';
import '../../../../core/date/date_time.dart';
import '../../../../l10n/app_localizations_context.dart';
import '../../domain/ticket_models.dart';
import 'supervisor_ui.dart';

class OperationsRosterSection extends StatelessWidget {
  const OperationsRosterSection({required this.rosters, super.key});

  final List<SupervisorRoster> rosters;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final uniqueJanitors = rosters
        .map((item) => item.janitorId)
        .where((id) => id.isNotEmpty)
        .toSet()
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.janitorScheduleTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            _AssignedPill(label: l10n.janitorsAssignedCount(uniqueJanitors)),
          ],
        ),
        const SizedBox(height: 12),
        if (rosters.isEmpty)
          SupervisorDottedStatePanel(
            icon: Icons.cleaning_services_outlined,
            message: l10n.emptyScheduleMessage,
            minHeight: 106,
          )
        else
          _RosterCards(rosters: rosters),
      ],
    );
  }
}

class _AssignedPill extends StatelessWidget {
  const _AssignedPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AdaniColors.success.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 15,
            color: AdaniColors.success,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.brightness == Brightness.dark
                  ? colors.onSurface
                  : AdaniColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RosterCards extends StatelessWidget {
  const _RosterCards({required this.rosters});

  final List<SupervisorRoster> rosters;

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
            for (final roster in rosters)
              SizedBox(
                width: width,
                child: _RosterCard(roster: roster),
              ),
          ],
        );
      },
    );
  }
}

class _RosterCard extends StatelessWidget {
  const _RosterCard({required this.roster});

  final SupervisorRoster roster;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final washroomName = roster.washroomName.isEmpty
        ? context.l10n.washroomFallback
        : roster.washroomName;
    final scheduleTime = _scheduleTime(context, roster);

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _JanitorAvatar(name: roster.janitorName),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        roster.janitorName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              washroomName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: [
                          if (roster.shift.trim().isNotEmpty)
                            _SchedulePill(
                              icon: Icons.badge_outlined,
                              label: roster.shift,
                              color: colors.primary,
                            ),
                          _SchedulePill(
                            icon: Icons.schedule_rounded,
                            label: scheduleTime,
                            color: AdaniColors.blue,
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

class _JanitorAvatar extends StatelessWidget {
  const _JanitorAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty
        ? ''
        : name.trim().characters.first.toUpperCase();
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: AdaniGradients.action,
        borderRadius: BorderRadius.circular(13),
      ),
      child: initial.isEmpty
          ? const Icon(
              Icons.cleaning_services_rounded,
              color: Colors.white,
              size: 21,
            )
          : Text(
              initial,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}

class _SchedulePill extends StatelessWidget {
  const _SchedulePill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.brightness == Brightness.dark
                  ? theme.colorScheme.onSurface
                  : color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

String _scheduleTime(BuildContext context, SupervisorRoster roster) {
  if (roster.shiftStart == null || roster.shiftEnd == null) {
    return context.l10n.notAvailableLabel;
  }
  return '${context.formatAppTime(roster.shiftStart)} – '
      '${context.formatAppTime(roster.shiftEnd)}';
}
