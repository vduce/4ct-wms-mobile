import 'package:flutter/material.dart';

import '../../../../app/theme/adani_design_tokens.dart';
import '../../../../l10n/app_localizations_context.dart';
import 'supervisor_ui.dart';

Future<bool> showOperationsSignOutDialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => const _OperationsSignOutDialog(),
      ) ??
      false;
}

class _OperationsSignOutDialog extends StatelessWidget {
  const _OperationsSignOutDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: Material(
          color: colors.surface,
          elevation: isDark ? 0 : 10,
          shadowColor: AdaniColors.purple.withValues(alpha: 0.18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: colors.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 4,
                decoration: const BoxDecoration(
                  gradient: AdaniGradients.action,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: colors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.logout_rounded,
                        color: colors.error,
                        size: 27,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      l10n.signOutConfirmTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.signOutConfirmMessage,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: SupervisorGradientButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        icon: Icons.logout_rounded,
                        label: l10n.signOutTooltip,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(l10n.staySignedInButton),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
