import 'package:flutter/material.dart';

import '../../../../app/theme/adani_design_tokens.dart';
import '../../../../l10n/app_localizations_context.dart';
import 'operations_drawer_header.dart';

enum OperationsDrawerDestination {
  home,
  history,
  notifications,
  dashboards,
  settings,
}

class OperationsDrawer extends StatelessWidget {
  const OperationsDrawer({
    required this.appName,
    required this.logoUrl,
    required this.displayName,
    required this.role,
    required this.unreadCount,
    required this.selectedDestination,
    required this.onOpenHome,
    required this.onOpenHistory,
    required this.onOpenNotifications,
    required this.onOpenDashboards,
    required this.onOpenSettings,
    required this.onSignOut,
    super.key,
  });

  final String appName;
  final String? logoUrl;
  final String displayName;
  final String role;
  final int unreadCount;
  final OperationsDrawerDestination selectedDestination;
  final VoidCallback onOpenHome;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenDashboards;
  final VoidCallback onOpenSettings;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final drawerWidth = (MediaQuery.sizeOf(context).width * 0.86)
        .clamp(288.0, 348.0)
        .toDouble();

    return Drawer(
      width: drawerWidth,
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OperationsDrawerHeader(
              appName: appName,
              logoUrl: logoUrl,
              displayName: displayName,
              role: role,
              operationsLabel: l10n.operationsTitle,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 18, 14, 12),
                children: [
                  _DrawerDestination(
                    icon: Icons.home_rounded,
                    label: l10n.operationsTitle,
                    selected:
                        selectedDestination == OperationsDrawerDestination.home,
                    onTap: () => _closeThen(context, onOpenHome),
                  ),
                  const SizedBox(height: 6),
                  _DrawerDestination(
                    icon: Icons.history_rounded,
                    label: l10n.ticketHistoryTitle,
                    selected:
                        selectedDestination ==
                        OperationsDrawerDestination.history,
                    onTap: () => _closeThen(context, onOpenHistory),
                  ),
                  const SizedBox(height: 6),
                  _DrawerDestination(
                    icon: Icons.notifications_none_rounded,
                    label: l10n.notificationsTitle,
                    badgeCount: unreadCount,
                    selected:
                        selectedDestination ==
                        OperationsDrawerDestination.notifications,
                    onTap: () => _closeThen(context, onOpenNotifications),
                  ),
                  const SizedBox(height: 6),
                  _DrawerDestination(
                    icon: Icons.dashboard_outlined,
                    label: l10n.dashboardsTitle,
                    selected:
                        selectedDestination ==
                        OperationsDrawerDestination.dashboards,
                    onTap: () => _closeThen(context, onOpenDashboards),
                  ),
                  const SizedBox(height: 6),
                  _DrawerDestination(
                    icon: Icons.settings_outlined,
                    label: l10n.settingsTitle,
                    selected:
                        selectedDestination ==
                        OperationsDrawerDestination.settings,
                    onTap: () => _closeThen(context, onOpenSettings),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
              child: _SignOutButton(
                label: l10n.signOutTooltip,
                onTap: onSignOut,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _closeThen(BuildContext context, VoidCallback callback) {
    Navigator.of(context).pop();
    callback();
  }
}

class _DrawerDestination extends StatelessWidget {
  const _DrawerDestination({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final foreground = selected ? colors.primary : colors.onSurface;

    return Material(
      color: selected
          ? colors.primary.withValues(alpha: 0.08)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(15),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 54,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              if (selected)
                Positioned(
                  left: 0,
                  top: 10,
                  bottom: 10,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      gradient: AdaniGradients.action,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: selected
                            ? colors.primary.withValues(alpha: 0.1)
                            : colors.surfaceContainerHighest.withValues(
                                alpha: 0.62,
                              ),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(icon, size: 20, color: foreground),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: foreground,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (badgeCount > 0) _NotificationBadge(count: badgeCount),
                    if (selected) ...[
                      const SizedBox(width: 7),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 19,
                        color: colors.primary,
                      ),
                    ],
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

class _NotificationBadge extends StatelessWidget {
  const _NotificationBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      constraints: const BoxConstraints(minWidth: 22),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: AdaniGradients.action,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.error.withValues(alpha: 0.07),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: colors.error.withValues(alpha: 0.16)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 50,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(Icons.logout_rounded, color: colors.error, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
