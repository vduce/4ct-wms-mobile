import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/adani_design_tokens.dart';
import '../../../core/date/date_time.dart';
import '../../../l10n/app_localizations_context.dart';
import '../../../shared/widgets/app_loading_dialog.dart';
import '../../auth/data/session_controller.dart';
import '../../notifications/data/notification_inbox_controller.dart';
import '../../tenant/data/tenant_controller.dart';
import '../data/operations_repository.dart';
import '../domain/ticket_models.dart';
import 'widgets/operations_drawer.dart';
import 'widgets/operations_home_hero.dart';
import 'widgets/operations_passenger_flow_sheet.dart';
import 'widgets/operations_roster_section.dart';
import 'widgets/operations_sign_out_dialog.dart';
import 'widgets/operations_washroom_section.dart';
import 'widgets/supervisor_ui.dart';
import 'widgets/ticket_overview_grid.dart';

class OperationsHomePage extends ConsumerStatefulWidget {
  const OperationsHomePage({super.key});

  @override
  ConsumerState<OperationsHomePage> createState() => _OperationsHomePageState();
}

class _OperationsHomePageState extends ConsumerState<OperationsHomePage> {
  bool _loadingPeaks = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final session = ref.watch(sessionControllerProvider).session;
    final username = session?.username.isNotEmpty == true
        ? session!.username
        : l10n.defaultUserName;
    final ticketState = ref.watch(todaysSupervisorTicketsProvider);
    final washroomState = ref.watch(supervisedWashroomsProvider);
    final tenantState = ref.watch(tenantControllerProvider);
    final rosterState = ref.watch(supervisedRostersProvider);
    final shift = rosterState.asData == null
        ? null
        : _shiftDetails(context, rosterState.asData!.value);
    final lastLogin = session?.lastLogin;
    final unreadNotifications = ref.watch(
      notificationInboxControllerProvider.select((state) => state.unreadCount),
    );

    return Scaffold(
      drawer: OperationsDrawer(
        appName: tenantState.branding.appName,
        logoUrl: tenantState.branding.logoUrl,
        displayName: username,
        role: session?.roleDisplayName ?? session?.role ?? '',
        unreadCount: unreadNotifications,
        onOpenHome: () => context.go('/operations/home'),
        onOpenHistory: () => context.go('/operations/ticket-history'),
        onOpenNotifications: () => context.go('/notifications'),
        onOpenDashboards: () => context.go('/operations/dashboard'),
        onSignOut: () => _confirmSignOut(context),
      ),
      appBar: AppBar(
        leadingWidth: 72,
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: l10n.openNavigationTooltip,
            onPressed: Scaffold.of(context).openDrawer,
            icon: const Icon(Icons.menu_rounded, size: 30),
          ),
        ),
        titleSpacing: 0,
        title: Text(
          l10n.operationsTitle,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            tooltip: l10n.notificationsTooltip,
            onPressed: () => context.go('/notifications'),
            icon: const _NotificationIcon(),
          ),
          IconButton(
            tooltip: l10n.signOutTooltip,
            onPressed: () => _confirmSignOut(context),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SupervisorScrollableBody(
        onRefresh: () async {
          ref.invalidate(todaysSupervisorTicketsProvider);
          ref.invalidate(supervisedWashroomsProvider);
          ref.invalidate(supervisedRostersProvider);
          await ref.read(todaysSupervisorTicketsProvider.future);
        },
        children: [
          OperationsHomeHero(
            displayName: username,
            role: session?.roleDisplayName ?? session?.role ?? '',
            loginTime: lastLogin == null
                ? l10n.notAvailableLabel
                : context.formatAppTime(lastLogin),
            loginDate: lastLogin == null
                ? ''
                : context.formatAppDate(lastLogin),
            shiftName:
                shift?.name ??
                (rosterState.hasError
                    ? l10n.notAvailableLabel
                    : l10n.shiftNotScheduledLabel),
            shiftTime: shift?.time ?? '',
            shiftLoading: rosterState.isLoading,
          ),
          const SizedBox(height: 18),
          ticketState.when(
            data: (data) => TicketOverviewGrid(
              data: data,
              dateTimeSettings: tenantState.dateTimeSettings,
              onStatusTap: (status) => context.go(
                '/operations/tickets?status=${ticketStatusApiValue(status)}',
              ),
            ),
            loading: () => const _LoadingPanel(),
            error: (error, _) => SupervisorStatePanel(
              icon: Icons.error_outline_rounded,
              message: l10n.supervisorTicketsLoadFailed,
              actionLabel: l10n.retryButton,
              onAction: () => ref.invalidate(todaysSupervisorTicketsProvider),
            ),
          ),
          const SizedBox(height: 16),
          _QuickActions(
            loadingPeaks: _loadingPeaks,
            onOpenHistory: () => context.go('/operations/ticket-history'),
            onOpenPassengerFlow: () => _openPassengerFlow(context),
          ),
          const SizedBox(height: 18),
          washroomState.when(
            data: (washrooms) =>
                OperationsWashroomSection(washrooms: washrooms),
            loading: () => const _LoadingPanel(),
            error: (error, _) => SupervisorStatePanel(
              icon: Icons.error_outline_rounded,
              message: l10n.supervisedUnitsLoadFailed,
              actionLabel: l10n.retryButton,
              onAction: () => ref.invalidate(supervisedWashroomsProvider),
            ),
          ),
          const SizedBox(height: 18),
          rosterState.when(
            data: (rosters) => OperationsRosterSection(rosters: rosters),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => SupervisorStatePanel(
              icon: Icons.error_outline_rounded,
              message: l10n.supervisorRostersLoadFailed,
              actionLabel: l10n.retryButton,
              onAction: () => ref.invalidate(supervisedRostersProvider),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openPassengerFlow(BuildContext context) async {
    final l10n = context.l10n;
    final session = ref.read(sessionControllerProvider).session;
    if (session == null || session.washroomIds.isEmpty) {
      _showSnack(l10n.noWashroomsAssignedMessage);
      return;
    }
    setState(() => _loadingPeaks = true);
    try {
      final peaks = await ref
          .read(operationsRepositoryProvider)
          .fetchPassengerPeaks(
            washroomIds: session.washroomIds,
            range: DateRange(
              start: DateTime.now().subtract(const Duration(days: 7)),
              end: DateTime.now(),
            ),
          );
      if (!context.mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: false,
        backgroundColor: Colors.transparent,
        constraints: const BoxConstraints(maxWidth: 720),
        builder: (context) => OperationsPassengerFlowSheet(peaks: peaks),
      );
    } catch (_) {
      _showSnack(l10n.passengerFlowLoadFailed);
    } finally {
      if (mounted) setState(() => _loadingPeaks = false);
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showOperationsSignOutDialog(context);
    if (!mounted || !confirmed) return;
    await ref.read(sessionControllerProvider.notifier).signOut();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _NotificationIcon extends ConsumerWidget {
  const _NotificationIcon();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(notificationInboxControllerProvider).unreadCount;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications_none_rounded, size: 28),
        if (unread > 0)
          Positioned(
            top: 1,
            right: 1,
            child: Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: AdaniColors.error,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.loadingPeaks,
    required this.onOpenHistory,
    required this.onOpenPassengerFlow,
  });

  final bool loadingPeaks;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenPassengerFlow;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final historyButton = SupervisorGradientButton(
      label: l10n.viewHistoryButton,
      onPressed: onOpenHistory,
      icon: Icons.history_rounded,
    );
    final passengerButton = SupervisorOutlinedButton(
      label: l10n.passengerFlowTitle,
      onPressed: loadingPeaks ? null : onOpenPassengerFlow,
      icon: Icons.groups_outlined,
      loading: loadingPeaks,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 700) {
          return Row(
            children: [
              Expanded(child: historyButton),
              const SizedBox(width: 18),
              Expanded(child: passengerButton),
            ],
          );
        }
        return Column(
          children: [
            historyButton,
            const SizedBox(height: 12),
            passengerButton,
          ],
        );
      },
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return const SupervisorSurface(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: AppLoadingIndicator(size: 88)),
      ),
    );
  }
}

({String name, String time})? _shiftDetails(
  BuildContext context,
  List<SupervisorRoster> rosters,
) {
  if (rosters.isEmpty) return null;

  final now = DateTime.now();
  SupervisorRoster? relevant;
  for (final roster in rosters) {
    final start = roster.shiftStart;
    final end = roster.shiftEnd;
    if (start != null &&
        end != null &&
        !now.isBefore(start) &&
        now.isBefore(end)) {
      relevant = roster;
      break;
    }
  }

  if (relevant == null) {
    final upcoming =
        rosters
            .where((roster) => roster.shiftStart?.isAfter(now) == true)
            .toList()
          ..sort((a, b) => a.shiftStart!.compareTo(b.shiftStart!));
    if (upcoming.isNotEmpty) relevant = upcoming.first;
  }

  if (relevant == null) {
    final completed =
        rosters
            .where((roster) => roster.shiftEnd?.isBefore(now) == true)
            .toList()
          ..sort((a, b) => b.shiftEnd!.compareTo(a.shiftEnd!));
    if (completed.isNotEmpty) relevant = completed.first;
  }

  relevant ??= rosters.first;
  final shiftName = relevant.shift.trim();
  final time = _shiftTime(context, relevant);
  if (shiftName.isEmpty && time.isEmpty) return null;
  if (shiftName.isEmpty) return (name: time, time: '');
  return (name: shiftName, time: time);
}

String _shiftTime(BuildContext context, SupervisorRoster? roster) {
  if (roster?.shiftStart == null || roster?.shiftEnd == null) return '';
  return '${context.formatAppTime(roster!.shiftStart)} – '
      '${context.formatAppTime(roster.shiftEnd)}';
}
