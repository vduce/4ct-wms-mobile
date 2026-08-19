import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/airport_feedback_design_tokens.dart';
import '../../../../l10n/app_localizations_context.dart';
import '../../domain/feedback_models.dart';

class FeedbackScreensaverMetricItem {
  const FeedbackScreensaverMetricItem({
    required this.label,
    required this.value,
    required this.status,
    required this.icon,
    required this.color,
    required this.progress,
  });

  final String label;
  final String value;
  final String status;
  final IconData icon;
  final Color color;
  final double? progress;
}

List<FeedbackScreensaverMetricItem> buildFeedbackScreensaverMetrics(
  BuildContext context,
  FeedbackMetrics metrics,
) {
  final l10n = context.l10n;
  final stale = metrics.isStaleAt(DateTime.now());
  final cubicleOccupancy = metrics.cubicleOccupancy;
  final washroomOccupancy = metrics.washroomOccupancy;

  String status({required bool available, String? provided}) {
    if (!available) return l10n.metricStatusUnavailable;
    if (stale) return l10n.metricStatusStale;
    return provided ?? l10n.metricStatusLive;
  }

  return [
    FeedbackScreensaverMetricItem(
      label: l10n.metricAqiLabel,
      value: _formatMetricNumber(metrics.aqi, decimalPlaces: 2),
      status: status(
        available: metrics.aqi != null,
        provided: metrics.aqiStatus,
      ),
      icon: Icons.eco_outlined,
      color: const Color(0xFF16B872),
      progress: _aqiProgress(metrics.aqi),
    ),
    FeedbackScreensaverMetricItem(
      label: l10n.metricCubicleOccupancyLabel,
      value: _cubicleOccupancyValue(context, metrics),
      status: _sensorStatus(
        context,
        available: metrics.occupied != null && metrics.totalOccupancy != null,
        stale: stale,
        dataStatus: cubicleOccupancy?.dataStatus,
        provided: metrics.occupancyStatus,
      ),
      icon: Icons.sensor_occupied_outlined,
      color: _cubicleOccupancyColor(metrics),
      progress: _occupancyProgress(metrics),
    ),
    FeedbackScreensaverMetricItem(
      label: l10n.metricWashroomOccupancyLabel,
      value: _washroomOccupancyBand(context, washroomOccupancy?.band),
      status: _washroomOccupancyStatus(
        context,
        occupancy: washroomOccupancy,
        stale: stale,
      ),
      icon: _washroomTypeIcon(washroomOccupancy?.washroomType),
      color: _washroomOccupancyColor(washroomOccupancy?.band),
      progress: _washroomOccupancyProgress(washroomOccupancy),
    ),
    FeedbackScreensaverMetricItem(
      label: l10n.metricOdourLabel,
      value: _formatOdourValue(metrics),
      status: status(
        available: metrics.odour != null,
        provided: metrics.odourStatus,
      ),
      icon: Icons.air_rounded,
      color: const Color(0xFFFF9D25),
      progress: _odourProgress(metrics.odour),
    ),
  ];
}

String _cubicleOccupancyValue(BuildContext context, FeedbackMetrics metrics) {
  final occupied = metrics.occupied;
  final total = metrics.totalOccupancy;
  if (occupied == null || total == null) return '-';
  return context.l10n.metricCubicleOccupiedValue(occupied, total);
}

String _sensorStatus(
  BuildContext context, {
  required bool available,
  required bool stale,
  String? dataStatus,
  String? provided,
}) {
  final l10n = context.l10n;
  if (!available || dataStatus == 'unavailable') {
    return l10n.metricStatusUnavailable;
  }
  if (stale) return l10n.metricStatusStale;
  if (dataStatus == 'partial') return l10n.metricStatusPartial;
  return provided ?? l10n.metricStatusLive;
}

String _washroomOccupancyBand(BuildContext context, String? band) {
  return switch (band) {
    'comfortable' => context.l10n.metricOccupancyBandComfortable,
    'moderate' => context.l10n.metricOccupancyBandModerate,
    'busy' => context.l10n.metricOccupancyBandBusy,
    'at_capacity' => context.l10n.metricOccupancyBandAtCapacity,
    _ => '-',
  };
}

String _washroomOccupancyStatus(
  BuildContext context, {
  required FeedbackWashroomOccupancy? occupancy,
  required bool stale,
}) {
  final percentage = occupancy?.percentage;
  if (occupancy == null ||
      occupancy.dataStatus == 'unavailable' ||
      percentage == null) {
    return context.l10n.metricStatusUnavailable;
  }
  if (stale) return context.l10n.metricStatusStale;
  if (occupancy.dataStatus == 'partial') {
    return context.l10n.metricOccupancyPercentagePartial(percentage);
  }
  return context.l10n.metricOccupancyPercentage(percentage);
}

IconData _washroomTypeIcon(String? washroomType) {
  return switch (washroomType) {
    'male' => Icons.male_rounded,
    'female' => Icons.female_rounded,
    'accessible' => Icons.accessible_rounded,
    _ => Icons.family_restroom_rounded,
  };
}

Color _washroomOccupancyColor(String? band) {
  return switch (band) {
    'comfortable' => const Color(0xFF16B872),
    'moderate' => const Color(0xFF2E7BFF),
    'busy' => const Color(0xFFFF9D25),
    'at_capacity' => const Color(0xFFE05252),
    _ => const Color(0xFF7A8497),
  };
}

Color _cubicleOccupancyColor(FeedbackMetrics metrics) {
  final progress = _occupancyProgress(metrics);
  if (progress == null) return const Color(0xFF7A8497);
  if (progress >= 0.9) return const Color(0xFFE05252);
  if (progress > 0.5) return const Color(0xFFFF9D25);
  return const Color(0xFF16B872);
}

double? _washroomOccupancyProgress(FeedbackWashroomOccupancy? occupancy) {
  final percentage = occupancy?.percentage;
  if (percentage == null || occupancy?.dataStatus == 'unavailable') {
    return null;
  }
  return (percentage / 100).clamp(0, 1).toDouble();
}

double? _aqiProgress(num? value) {
  if (value == null) return null;
  return (value / 500).clamp(0, 1).toDouble();
}

String _formatMetricNumber(num? value, {int decimalPlaces = 0}) {
  if (value == null) return '-';
  if (decimalPlaces > 0 && value % 1 != 0) {
    return NumberFormat.decimalPatternDigits(
      decimalDigits: decimalPlaces,
    ).format(value);
  }
  return NumberFormat.decimalPattern().format(value.round());
}

String _formatOdourValue(FeedbackMetrics metrics) {
  final value = metrics.odour;
  if (value == null) return '-';
  final formatted = _formatMetricNumber(value, decimalPlaces: 2);
  final unit = metrics.odourUnit;
  if (unit == null || unit.trim().isEmpty) return formatted;
  return '$formatted ${unit.trim()}';
}

double? _occupancyProgress(FeedbackMetrics metrics) {
  final occupied = metrics.occupied;
  final total = metrics.totalOccupancy;
  if (occupied == null || total == null || total <= 0) return null;
  return (occupied / total).clamp(0, 1).toDouble();
}

double? _odourProgress(num? value) {
  if (value == null) return null;
  return (value / 1).clamp(0, 1).toDouble();
}

class FeedbackMetricStatusCard extends StatelessWidget {
  const FeedbackMetricStatusCard({
    required this.item,
    required this.compact,
    required this.horizontal,
    super.key,
  });

  final FeedbackScreensaverMetricItem item;
  final bool compact;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final phone = MediaQuery.sizeOf(context).width < 520;
    final foreground = isDark
        ? AirportFeedbackColors.darkPrimaryText
        : AirportFeedbackColors.lightPrimaryText;
    final muted = isDark
        ? AirportFeedbackColors.darkSecondaryText
        : AirportFeedbackColors.lightSecondaryText;
    final minHeight = horizontal ? (phone ? 58.0 : 68.0) : 0.0;

    return Semantics(
      container: true,
      label: '${item.label}, ${item.value}, ${item.status}',
      child: ExcludeSemantics(
        child: Container(
          constraints: BoxConstraints(minHeight: minHeight),
          padding: EdgeInsets.symmetric(
            horizontal: horizontal ? 14 : 15,
            vertical: horizontal ? 9 : (compact ? 7 : 13),
          ),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF071B31).withValues(alpha: 0.82)
                : Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF263C5B) : const Color(0xFFE7E6F1),
            ),
            boxShadow: isDark
                ? const []
                : [
                    BoxShadow(
                      color: const Color(0xFF09183A).withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _MetricIconBadge(
                icon: item.icon,
                color: item.color,
                compact: horizontal || compact,
              ),
              SizedBox(width: horizontal ? 12 : 14),
              Expanded(
                child: _MetricCardText(
                  item: item,
                  foreground: foreground,
                  muted: muted,
                  compact: compact,
                  horizontal: horizontal,
                ),
              ),
              if (horizontal) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: foreground,
                  size: phone ? 20 : 22,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricIconBadge extends StatelessWidget {
  const _MetricIconBadge({
    required this.icon,
    required this.color,
    required this.compact,
  });

  final IconData icon;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 38 : 44,
      height: compact ? 38 : 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        shape: BoxShape.circle,
      ),
      child: IconTheme(
        data: IconThemeData(color: color, size: compact ? 24 : 27),
        child: Icon(icon),
      ),
    );
  }
}

class _MetricCardText extends StatelessWidget {
  const _MetricCardText({
    required this.item,
    required this.foreground,
    required this.muted,
    required this.compact,
    required this.horizontal,
  });

  final FeedbackScreensaverMetricItem item;
  final Color foreground;
  final Color muted;
  final bool compact;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final phone = MediaQuery.sizeOf(context).width < 520;
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final tightVertical =
            !horizontal &&
            constraints.maxHeight.isFinite &&
            constraints.maxHeight < 118;
        final narrowValue = !horizontal && constraints.maxWidth < 96;
        final titleStyle =
            (phone || tightVertical
                    ? textTheme.labelMedium
                    : compact
                    ? textTheme.labelLarge
                    : textTheme.titleSmall)
                ?.copyWith(
                  color: foreground,
                  height: tightVertical ? 1.25 : 1.32,
                  fontWeight: FontWeight.w500,
                );
        final valueStyle =
            (narrowValue
                    ? textTheme.titleMedium
                    : phone
                    ? textTheme.titleLarge
                    : tightVertical
                    ? textTheme.titleMedium
                    : compact
                    ? textTheme.titleLarge
                    : textTheme.headlineSmall)
                ?.copyWith(
                  color: foreground,
                  height: tightVertical ? 1.25 : 1.32,
                  fontWeight: FontWeight.w600,
                );
        final statusStyle =
            (phone || tightVertical
                    ? textTheme.labelSmall
                    : compact
                    ? textTheme.labelMedium
                    : textTheme.labelLarge)
                ?.copyWith(
                  color: item.color,
                  height: tightVertical ? 1.25 : 1.32,
                  fontWeight: FontWeight.w500,
                );
        final labelGap = horizontal
            ? 2.0
            : (tightVertical ? 6.0 : (compact ? 7.0 : 8.0));
        final statusGap = tightVertical ? 8.0 : (compact ? 11.0 : 12.0);
        final progressGap = tightVertical ? 8.0 : (compact ? 10.0 : 11.0);

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.label,
              maxLines: phone && !horizontal ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: titleStyle,
            ),
            SizedBox(height: labelGap),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    item.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: valueStyle,
                  ),
                ),
                if (horizontal) ...[
                  const SizedBox(width: 12),
                  Flexible(
                    child: _MetricStatusText(item: item, style: statusStyle),
                  ),
                ],
              ],
            ),
            if (!horizontal) ...[
              SizedBox(height: statusGap),
              _MetricStatusText(item: item, style: statusStyle),
              if (item.progress != null) ...[
                SizedBox(height: progressGap),
                _MetricProgressBar(item: item),
              ],
            ],
          ],
        );
      },
    );
  }
}

class _MetricStatusText extends StatelessWidget {
  const _MetricStatusText({required this.item, required this.style});

  final FeedbackScreensaverMetricItem item;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      item.status,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }
}

class _MetricProgressBar extends StatelessWidget {
  const _MetricProgressBar({required this.item});

  final FeedbackScreensaverMetricItem item;

  @override
  Widget build(BuildContext context) {
    final progress = item.progress;
    if (progress == null) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 4.5,
        backgroundColor: item.color.withValues(alpha: 0.28),
        valueColor: AlwaysStoppedAnimation<Color>(item.color),
      ),
    );
  }
}
