import 'package:flutter/material.dart';

import '../../../../app/theme/adani_design_tokens.dart';
import '../../../../core/date/date_time.dart';
import '../../../../l10n/app_localizations_context.dart';
import '../../domain/ticket_models.dart';
import 'supervisor_ui.dart';

class OperationsPassengerFlowSheet extends StatelessWidget {
  const OperationsPassengerFlowSheet({required this.peaks, super.key});

  final List<PassengerPeak> peaks;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Material(
      color: colors.surface,
      elevation: 8,
      shadowColor: colors.shadow.withValues(alpha: isDark ? 0.44 : 0.2),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.42),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _SheetHeader(title: l10n.passengerFlowTitle),
              const SizedBox(height: 12),
              if (peaks.isEmpty)
                SupervisorStatePanel(
                  icon: Icons.info_outline_rounded,
                  message: l10n.emptyPassengerFlowMessage,
                  compact: true,
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: peaks.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) =>
                        _PassengerPeakCard(rank: index + 1, peak: peaks[index]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: AdaniGradients.action,
            borderRadius: BorderRadius.circular(11),
          ),
          child: const ExcludeSemantics(
            child: Icon(Icons.groups_rounded, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }
}

class _PassengerPeakCard extends StatelessWidget {
  const _PassengerPeakCard({required this.rank, required this.peak});

  final int rank;
  final PassengerPeak peak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final washroomName = peak.washroomName.trim();

    return Semantics(
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PeakRankBadge(rank: rank),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.passengerCount(peak.count),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    if (washroomName.isNotEmpty) ...[
                      _PeakMetadata(
                        icon: Icons.location_on_outlined,
                        value: washroomName,
                      ),
                      const SizedBox(height: 4),
                    ],
                    _PeakMetadata(
                      icon: Icons.schedule_rounded,
                      value: _passengerPeakTime(context, peak),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ExcludeSemantics(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    Icons.trending_up_rounded,
                    size: 20,
                    color: colors.primary,
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

class _PeakRankBadge extends StatelessWidget {
  const _PeakRankBadge({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: AdaniGradients.action,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$rank',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PeakMetadata extends StatelessWidget {
  const _PeakMetadata({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 15, color: colors.primary),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

String _passengerPeakTime(BuildContext context, PassengerPeak peak) {
  if (peak.timestamp != null) return context.formatAppDateTime(peak.timestamp);
  final fallback = peak.hourRange.trim().isEmpty
      ? peak.hour.trim()
      : peak.hourRange.trim();
  return fallback.isEmpty ? context.l10n.notAvailableLabel : fallback;
}
