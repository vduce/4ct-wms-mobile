import 'package:flutter/material.dart';

import '../../../../app/theme/adani_design_tokens.dart';
import '../../../../l10n/app_localizations_context.dart';
import '../../../../shared/widgets/app_logo.dart';
import 'supervisor_ui.dart';

class OperationsHomeHero extends StatelessWidget {
  const OperationsHomeHero({
    required this.displayName,
    required this.role,
    required this.loginTime,
    required this.loginDate,
    required this.shiftName,
    required this.shiftTime,
    this.shiftLoading = false,
    super.key,
  });

  final String displayName;
  final String role;
  final String loginTime;
  final String loginDate;
  final String shiftName;
  final String shiftTime;
  final bool shiftLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return SupervisorSurface(
      padding: EdgeInsets.zero,
      radius: 24,
      color: isDark ? AdaniColors.darkHero : AdaniColors.lightHero,
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          Positioned(
            top: -72,
            right: -64,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    (isDark
                            ? AdaniColors.darkHeroAccent
                            : AdaniColors.lightHeroAccent)
                        .withValues(alpha: isDark ? 0.52 : 0.72),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                height: 5,
                decoration: const BoxDecoration(
                  gradient: AdaniGradients.action,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.homeGreeting(displayName),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: colors.onSurface,
                                    fontWeight: FontWeight.w600,
                                    height: 1.18,
                                  ),
                                ),
                                if (role.trim().isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  _RoleBadge(role: role.trim()),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const _HeroBrandMark(),
                      ],
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final loginTile = _DetailTile(
                          icon: Icons.login_rounded,
                          label: context.l10n.lastLoginTitle,
                          primaryValue: loginTime,
                          secondaryValue: loginDate,
                        );
                        final shiftTile = _DetailTile(
                          icon: Icons.schedule_rounded,
                          label: context.l10n.currentShiftTitle,
                          primaryValue: shiftName,
                          secondaryValue: shiftTime,
                          loading: shiftLoading,
                        );
                        if (constraints.maxWidth < 270) {
                          return Column(
                            children: [
                              loginTile,
                              const SizedBox(height: 10),
                              shiftTile,
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(child: loginTile),
                            const SizedBox(width: 10),
                            Expanded(child: shiftTile),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: colors.primary.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.badge_outlined, size: 15, color: colors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              role,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBrandMark extends StatelessWidget {
  const _HeroBrandMark();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 68,
      height: 68,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.primary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: AdaniColors.purple.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: const AdaniBrandMark(size: 58),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.primaryValue,
    required this.secondaryValue,
    this.loading = false,
  });

  final IconData icon;
  final String label;
  final String primaryValue;
  final String secondaryValue;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      constraints: const BoxConstraints(minHeight: 92),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: isDark ? 0.68 : 0.74),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.72),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 16, color: colors.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (loading)
            SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.primary,
              ),
            )
          else ...[
            Text(
              primaryValue,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (secondaryValue.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                secondaryValue,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
