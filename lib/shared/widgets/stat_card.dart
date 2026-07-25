import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.accentColor,
    this.changeText,
    this.changeColor,
    this.onTap,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? accentColor;
  final String? changeText;
  final Color? changeColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = accentColor ?? colors.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(16);
    return Material(
      color: colors.surface,
      elevation: isDark ? 0 : 3,
      shadowColor: const Color(0xFF7004A0).withValues(alpha: 0.14),
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: accent, size: 19),
              ),
              const SizedBox(height: 10),
              Text(
                value,
                maxLines: 1,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  height: 1,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  height: 1,
                  fontSize: 12,
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (changeText != null) ...[
                const SizedBox(height: 5),
                Text(
                  changeText!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    height: 1,
                    fontSize: 10.5,
                    color: changeColor ?? colors.onSurfaceVariant,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
