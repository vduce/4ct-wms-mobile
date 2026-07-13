import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations_context.dart';
import '../../../shared/widgets/app_loading_dialog.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../auth/data/session_controller.dart';
import '../data/operations_repository.dart';
import '../domain/ticket_models.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.operationsTitle),
        actions: [
          IconButton(
            tooltip: l10n.ticketHistoryTitle,
            onPressed: () => context.go('/operations/ticket-history'),
            icon: const Icon(Icons.history_rounded),
          ),
          IconButton(
            tooltip: l10n.signOutTooltip,
            onPressed: () =>
                ref.read(sessionControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todaysSupervisorTicketsProvider);
          ref.invalidate(supervisedWashroomsProvider);
          await ref.read(todaysSupervisorTicketsProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _HeroPanel(
              username: username,
              role: session?.roleDisplayName ?? session?.role ?? '',
              tenantSummary: l10n.tenantAirportSummary(
                session?.tenantId ?? '-',
                session?.airportId ?? '-',
              ),
              lastLogin: _formatDateTime(session?.lastLogin),
              shiftLabel: ticketState.asData?.value.shiftLabel ?? '-',
            ),
            const SizedBox(height: 16),
            ticketState.when(
              data: (data) => _TicketStatsGrid(data: data),
              loading: () => const _LoadingPanel(),
              error: (error, _) => _ErrorPanel(
                message: l10n.supervisorTicketsLoadFailed,
                onRetry: () => ref.invalidate(todaysSupervisorTicketsProvider),
              ),
            ),
            const SizedBox(height: 16),
            _QuickActions(
              loadingPeaks: _loadingPeaks,
              onOpenHistory: () => context.go('/operations/ticket-history'),
              onOpenPassengerFlow: () => _openPassengerFlow(context),
            ),
            const SizedBox(height: 16),
            washroomState.when(
              data: (washrooms) => _WashroomSection(washrooms: washrooms),
              loading: () => const _LoadingPanel(),
              error: (error, _) => _ErrorPanel(
                message: l10n.supervisedUnitsLoadFailed,
                onRetry: () => ref.invalidate(supervisedWashroomsProvider),
              ),
            ),
            const SizedBox(height: 16),
            ticketState.when(
              data: (data) => _RosterSection(rosters: data.rosters),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
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
        showDragHandle: true,
        builder: (context) => _PassengerFlowSheet(peaks: peaks),
      );
    } catch (_) {
      _showSnack(l10n.passengerFlowLoadFailed);
    } finally {
      if (mounted) setState(() => _loadingPeaks = false);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.username,
    required this.role,
    required this.tenantSummary,
    required this.lastLogin,
    required this.shiftLabel,
  });

  final String username;
  final String role;
  final String tenantSummary;
  final String lastLogin;
  final String shiftLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.16),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.homeGreeting(username),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: colors.onPrimaryContainer,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role.isEmpty ? tenantSummary : '$role · $tenantSummary',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.onPrimaryContainer),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.admin_panel_settings_rounded,
                color: colors.onPrimaryContainer,
                size: 36,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: Icons.login_rounded,
                label: l10n.lastLoginLabel(lastLogin),
              ),
              _InfoChip(
                icon: Icons.schedule_rounded,
                label: l10n.activeShiftLabel(shiftLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TicketStatsGrid extends StatelessWidget {
  const _TicketStatsGrid({required this.data});

  final SupervisorTicketList data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final counts = data.counts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: l10n.ticketStatusCardsTitle),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: MediaQuery.sizeOf(context).width > 620 ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.12,
          children: [
            StatCard(
              label: l10n.statusPending,
              value: '${counts[SupervisorTicketStatus.pending] ?? 0}',
              icon: Icons.pending_actions_rounded,
              onTap: () => context.go('/operations/tickets?status=Pending'),
            ),
            StatCard(
              label: l10n.statusAcknowledged,
              value: '${counts[SupervisorTicketStatus.acknowledge] ?? 0}',
              icon: Icons.fact_check_rounded,
              onTap: () => context.go('/operations/tickets?status=Acknowledge'),
            ),
            StatCard(
              label: l10n.statusEscalated,
              value: '${counts[SupervisorTicketStatus.escalated] ?? 0}',
              icon: Icons.priority_high_rounded,
              onTap: () => context.go('/operations/tickets?status=Escalated'),
            ),
            StatCard(
              label: l10n.statusCompleted,
              value: '${counts[SupervisorTicketStatus.completed] ?? 0}',
              icon: Icons.check_circle_rounded,
              onTap: () => context.go('/operations/tickets?status=Completed'),
            ),
          ],
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
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        FilledButton.icon(
          onPressed: onOpenHistory,
          icon: const Icon(Icons.manage_search_rounded),
          label: Text(l10n.viewHistoryButton),
        ),
        OutlinedButton.icon(
          onPressed: loadingPeaks ? null : onOpenPassengerFlow,
          icon: loadingPeaks
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.groups_rounded),
          label: Text(l10n.passengerFlowTitle),
        ),
      ],
    );
  }
}

class _WashroomSection extends StatelessWidget {
  const _WashroomSection({required this.washrooms});

  final List<SupervisorWashroom> washrooms;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: l10n.supervisedUnitsTitle,
          trailing: l10n.supervisedUnitsCount(washrooms.length),
        ),
        const SizedBox(height: 10),
        if (washrooms.isEmpty)
          _EmptyPanel(message: l10n.emptyWashroomsMessage)
        else
          ...washrooms.map((washroom) => _WashroomTile(washroom: washroom)),
      ],
    );
  }
}

class _WashroomTile extends StatelessWidget {
  const _WashroomTile({required this.washroom});

  final SupervisorWashroom washroom;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: ListTile(
        leading: Icon(_washroomIcon(washroom.type)),
        title: Text(washroom.name),
        subtitle: Text(
          [
            if (washroom.code.isNotEmpty) washroom.code,
            l10n.cubiclesCount(washroom.cubicleCount),
          ].join(' · '),
        ),
      ),
    );
  }
}

class _RosterSection extends StatelessWidget {
  const _RosterSection({required this.rosters});

  final List<SupervisorRoster> rosters;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final uniqueJanitors = rosters
        .map((item) => item.janitorId)
        .where((id) => id.isNotEmpty)
        .toSet()
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: l10n.janitorScheduleTitle,
          trailing: l10n.janitorsAssignedCount(uniqueJanitors),
        ),
        const SizedBox(height: 10),
        if (rosters.isEmpty)
          _EmptyPanel(message: l10n.emptyScheduleMessage)
        else
          ...rosters.map((roster) => _RosterTile(roster: roster)),
      ],
    );
  }
}

class _RosterTile extends StatelessWidget {
  const _RosterTile({required this.roster});

  final SupervisorRoster roster;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.cleaning_services_rounded),
        title: Text(roster.janitorName),
        subtitle: Text(
          '${roster.washroomName.isEmpty ? l10n.washroomFallback : roster.washroomName} · ${roster.shift}',
        ),
        trailing: Text(_shiftTime(roster)),
      ),
    );
  }
}

class _PassengerFlowSheet extends StatelessWidget {
  const _PassengerFlowSheet({required this.peaks});

  final List<PassengerPeak> peaks;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.passengerFlowTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (peaks.isEmpty)
            _EmptyPanel(message: l10n.emptyPassengerFlowMessage)
          else
            ...peaks.map(
              (peak) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.trending_up_rounded),
                title: Text(l10n.passengerCount(peak.count)),
                subtitle: Text(
                  peak.hourRange.isEmpty ? peak.hour : peak.hourRange,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Chip(
      avatar: Icon(icon, size: 18, color: colors.onSecondaryContainer),
      label: Text(label),
      backgroundColor: colors.secondaryContainer,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        if (trailing != null) Text(trailing!),
      ],
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: AppLoadingIndicator(size: 88)),
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retryButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

String _formatDateTime(DateTime? date) {
  if (date == null) return '-';
  return DateFormat('dd MMM yyyy, h:mm a').format(date);
}

String _shiftTime(SupervisorRoster roster) {
  if (roster.shiftStart == null || roster.shiftEnd == null) return '-';
  final format = DateFormat.jm();
  return '${format.format(roster.shiftStart!)} - ${format.format(roster.shiftEnd!)}';
}

IconData _washroomIcon(SupervisorWashroomType type) {
  return switch (type) {
    SupervisorWashroomType.female => Icons.woman_rounded,
    SupervisorWashroomType.handicapped => Icons.accessible_forward_rounded,
    SupervisorWashroomType.unisex => Icons.wc_rounded,
    SupervisorWashroomType.male => Icons.man_rounded,
    SupervisorWashroomType.unknown => Icons.meeting_room_rounded,
  };
}
