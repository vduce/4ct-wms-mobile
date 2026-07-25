import 'package:flutter/material.dart';

import '../../../../app/theme/adani_design_tokens.dart';
import '../../../../l10n/app_localizations_context.dart';
import '../../domain/ticket_models.dart';

abstract final class SupervisorPalette {
  static const pending = AdaniColors.purple;
  static const acknowledged = AdaniColors.warning;
  static const escalated = AdaniColors.error;
  static const completed = AdaniColors.success;
  static const actionGradient = AdaniGradients.action;

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
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 28),
    this.showBrandedBackground = true,
    super.key,
  });

  final List<Widget> children;
  final RefreshCallback? onRefresh;
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final bool showBrandedBackground;

  @override
  Widget build(BuildContext context) {
    Widget content = LayoutBuilder(
      builder: (context, constraints) {
        const horizontalPadding = 20.0;
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
    if (!showBrandedBackground) return content;
    return Stack(
      fit: StackFit.expand,
      children: [const _SupervisorPageBackground(), content],
    );
  }
}

class _SupervisorPageBackground extends StatelessWidget {
  const _SupervisorPageBackground();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        final backgroundHeight = constraints.maxWidth >= 700 ? 300.0 : 150.0;
        return Align(
          alignment: Alignment.bottomCenter,
          child: IgnorePointer(
            child: SizedBox(
              width: constraints.maxWidth,
              height: backgroundHeight,
              child: Opacity(
                opacity: isDark ? 0.72 : 0.78,
                child: _AdaniSwirlBackground(isDark: isDark),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AdaniSwirlBackground extends StatelessWidget {
  const _AdaniSwirlBackground({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      AdaniAssets.swirl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.fill,
      alignment: Alignment.bottomCenter,
      excludeFromSemantics: true,
    );
    if (!isDark) return image;
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, Colors.white, Colors.white],
        stops: [0, 0.28, 1],
      ).createShader(bounds),
      child: Opacity(opacity: 0.24, child: image),
    );
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
      color: color ?? colors.surface,
      elevation: isDark ? 0 : 1,
      shadowColor: AdaniColors.purple.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(color: colors.outlineVariant),
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
    final radius = BorderRadius.circular(14);
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
    this.height = 48,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData icon;
  final bool loading;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: loading ? null : onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.outlineVariant),
            color: colors.surface.withValues(alpha: 0.78),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(icon, color: colors.primary, size: 21),
              const SizedBox(width: 9),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
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

class SupervisorFilterPill extends StatelessWidget {
  const SupervisorFilterPill({
    required this.label,
    required this.selected,
    required this.onPressed,
    this.icon,
    this.height = 40,
    this.horizontalPadding = 16,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final IconData? icon;
  final double height;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(height / 2);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Ink(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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

class SupervisorDottedStatePanel extends StatelessWidget {
  const SupervisorDottedStatePanel({
    required this.icon,
    required this.message,
    this.minHeight = 148,
    super.key,
  });

  final IconData icon;
  final String message;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return CustomPaint(
      foregroundPainter: _SupervisorDottedBorderPainter(
        color: colors.primary.withValues(alpha: isDark ? 0.36 : 0.22),
      ),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: minHeight),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        decoration: BoxDecoration(
          color: isDark
              ? colors.surface.withValues(alpha: 0.82)
              : colors.surfaceContainerHighest.withValues(alpha: 0.34),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 25, color: colors.primary),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant.withValues(alpha: 0.78),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupervisorDottedBorderPainter extends CustomPainter {
  const _SupervisorDottedBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const dotRadius = 1.0;
    const spacing = 5.5;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(16),
        ).deflate(dotRadius),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (final metric in path.computeMetrics()) {
      for (var distance = 0.0; distance < metric.length; distance += spacing) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          canvas.drawCircle(tangent.position, dotRadius, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_SupervisorDottedBorderPainter oldDelegate) {
    return oldDelegate.color != color;
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
    SupervisorTicketStatus.pending => Icons.note_add_outlined,
    SupervisorTicketStatus.acknowledge => Icons.check_box_outlined,
    SupervisorTicketStatus.escalated => Icons.warning_amber_rounded,
    SupervisorTicketStatus.completed => Icons.check_circle_outline_rounded,
  };
}
