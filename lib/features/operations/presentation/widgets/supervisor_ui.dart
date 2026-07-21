import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations_context.dart';
import '../../domain/ticket_models.dart';

abstract final class SupervisorPalette {
  static const pending = Color(0xFF246BFD);
  static const acknowledged = Color(0xFFF06A18);
  static const escalated = Color(0xFFEF3340);
  static const completed = Color(0xFF159B67);
  static const actionGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [pending, Color(0xFF7248E8), Color(0xFFE83E8C)],
  );

  static Color status(SupervisorTicketStatus status) {
    return switch (status) {
      SupervisorTicketStatus.pending => pending,
      SupervisorTicketStatus.acknowledge => acknowledged,
      SupervisorTicketStatus.escalated => escalated,
      SupervisorTicketStatus.completed => completed,
    };
  }

  static Color priority(String priority, ColorScheme colors) {
    return switch (normalizeLoose(priority)) {
      'high' => escalated,
      'moderate' || 'medium' => acknowledged,
      'low' => completed,
      _ => colors.onSurfaceVariant,
    };
  }
}

class SupervisorScrollableBody extends StatelessWidget {
  const SupervisorScrollableBody({
    required this.children,
    this.onRefresh,
    this.maxWidth = 1180,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 24),
    super.key,
  });

  final List<Widget> children;
  final RefreshCallback? onRefresh;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    Widget content = LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < 520 ? 14.0 : 20.0;
        final resolvedPadding = padding.resolve(Directionality.of(context));
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                resolvedPadding.top,
                horizontalPadding,
                resolvedPadding.bottom,
              ),
              children: children,
            ),
          ),
        );
      },
    );
    if (onRefresh != null) {
      content = RefreshIndicator(onRefresh: onRefresh!, child: content);
    }
    return content;
  }
}

class SupervisorSurface extends StatelessWidget {
  const SupervisorSurface({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.radius = 12,
    this.color,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final borderRadius = BorderRadius.circular(radius);

    return Material(
      color: color ?? colors.surface.withValues(alpha: isDark ? 0.94 : 0.98),
      elevation: isDark ? 0 : 2,
      shadowColor: colors.shadow.withValues(alpha: 0.09),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(
          color: colors.outlineVariant.withValues(alpha: isDark ? 0.72 : 0.82),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class SupervisorSectionHeader extends StatelessWidget {
  const SupervisorSectionHeader({
    required this.title,
    this.trailing,
    super.key,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class SupervisorGradientButton extends StatelessWidget {
  const SupervisorGradientButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 48,
    this.loading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(8);
    final enabled = onPressed != null && !loading;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: enabled ? onPressed : null,
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            gradient: !enabled ? null : SupervisorPalette.actionGradient,
            color: !enabled
                ? Theme.of(context).colorScheme.outlineVariant
                : null,
            borderRadius: radius,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading) ...[
                const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 8),
              ] else if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
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

class SupervisorOutlinedButton extends StatelessWidget {
  const SupervisorOutlinedButton({
    required this.label,
    required this.onPressed,
    required this.icon,
    this.loading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: loading ? null : onPressed,
        icon: loading
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon),
        label: Text(label),
      ),
    );
  }
}

class SupervisorFilterPill extends StatelessWidget {
  const SupervisorFilterPill({
    required this.label,
    required this.selected,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(9);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Ink(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            gradient: selected ? SupervisorPalette.actionGradient : null,
            color: selected ? null : colors.surface,
            borderRadius: radius,
            border: selected ? null : Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 17,
                  color: selected ? Colors.white : colors.primary,
                ),
                const SizedBox(width: 7),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected ? Colors.white : colors.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SupervisorStatePanel extends StatelessWidget {
  const SupervisorStatePanel({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.compact = false,
    super.key,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SupervisorSurface(
      padding: EdgeInsets.all(compact ? 14 : 20),
      child: Column(
        children: [
          Icon(icon, size: compact ? 24 : 32, color: colors.primary),
          SizedBox(height: compact ? 8 : 10),
          Text(message, textAlign: TextAlign.center),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class TicketStatusBadge extends StatelessWidget {
  const TicketStatusBadge({required this.status, super.key});

  final SupervisorTicketStatus status;

  @override
  Widget build(BuildContext context) {
    final color = SupervisorPalette.status(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        ticketStatusLabel(context, status),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class TicketPriorityBadge extends StatelessWidget {
  const TicketPriorityBadge({required this.priority, super.key});

  final String priority;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = SupervisorPalette.priority(priority, colors);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        priority.isEmpty ? context.l10n.priorityFallback : priority,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class TicketStatusDot extends StatelessWidget {
  const TicketStatusDot({required this.status, this.icon, super.key});

  final SupervisorTicketStatus status;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final color = SupervisorPalette.status(status);
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon ?? Icons.circle,
        color: color,
        size: icon == null ? 10 : 19,
      ),
    );
  }
}

String ticketStatusLabel(BuildContext context, SupervisorTicketStatus status) {
  final l10n = context.l10n;
  return switch (status) {
    SupervisorTicketStatus.pending => l10n.statusPending,
    SupervisorTicketStatus.acknowledge => l10n.statusAcknowledged,
    SupervisorTicketStatus.escalated => l10n.statusEscalated,
    SupervisorTicketStatus.completed => l10n.statusCompleted,
  };
}

IconData ticketStatusIcon(SupervisorTicketStatus status) {
  return switch (status) {
    SupervisorTicketStatus.pending => Icons.pending_actions_rounded,
    SupervisorTicketStatus.acknowledge => Icons.fact_check_rounded,
    SupervisorTicketStatus.escalated => Icons.priority_high_rounded,
    SupervisorTicketStatus.completed => Icons.check_circle_outline_rounded,
  };
}
