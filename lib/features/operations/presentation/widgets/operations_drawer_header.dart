import 'package:flutter/material.dart';

import '../../../../app/theme/adani_design_tokens.dart';
import '../../../../shared/widgets/app_logo.dart';

class OperationsDrawerHeader extends StatelessWidget {
  const OperationsDrawerHeader({
    required this.appName,
    required this.logoUrl,
    required this.displayName,
    required this.role,
    required this.operationsLabel,
    super.key,
  });

  final String appName;
  final String? logoUrl;
  final String displayName;
  final String role;
  final String operationsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AdaniColors.darkHero : AdaniColors.lightHero,
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 4,
            decoration: const BoxDecoration(gradient: AdaniGradients.action),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: colors.outlineVariant),
                        boxShadow: isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: AdaniColors.purple.withValues(
                                    alpha: 0.1,
                                  ),
                                  blurRadius: 16,
                                  offset: const Offset(0, 7),
                                ),
                              ],
                      ),
                      child: AppLogo(
                        logoUrl: logoUrl,
                        maxWidth: 38,
                        maxHeight: 38,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            operationsLabel,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surface.withValues(
                      alpha: isDark ? 0.72 : 0.82,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      _UserAvatar(displayName: displayName),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (role.trim().isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                role,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
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

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    final initial = displayName.trim().isEmpty
        ? ''
        : displayName.trim().characters.first.toUpperCase();

    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: AdaniGradients.action,
        borderRadius: BorderRadius.circular(12),
      ),
      child: initial.isEmpty
          ? const Icon(
              Icons.person_outline_rounded,
              color: Colors.white,
              size: 20,
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
