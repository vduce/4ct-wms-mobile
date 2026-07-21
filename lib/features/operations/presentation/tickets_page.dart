import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations_context.dart';
import '../../../shared/widgets/app_loading_dialog.dart';
import '../data/operations_repository.dart';
import '../domain/ticket_models.dart';
import 'widgets/supervisor_ui.dart';

class TicketsPage extends ConsumerStatefulWidget {
  const TicketsPage({this.initialStatus, super.key});

  final String? initialStatus;

  @override
  ConsumerState<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends ConsumerState<TicketsPage> {
  late SupervisorTicketStatus _activeStatus;
  final Set<String> _acknowledging = <String>{};

  @override
  void initState() {
    super.initState();
    _activeStatus = normalizeTicketStatus(widget.initialStatus ?? 'Pending');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ticketsState = ref.watch(todaysSupervisorTicketsProvider);

    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goBack();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: Text(
            l10n.ticketsTitle(ticketStatusLabel(context, _activeStatus)),
          ),
        ),
        body: ticketsState.when(
          data: _buildTickets,
          loading: () => const AppLoadingDialog(),
          error: (error, _) => SupervisorScrollableBody(
            children: [
              SupervisorStatePanel(
                icon: Icons.error_outline_rounded,
                message: l10n.supervisorTicketsLoadFailed,
                actionLabel: l10n.retryButton,
                onAction: () => ref.invalidate(todaysSupervisorTicketsProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go('/operations/home');
  }

  Widget _buildTickets(SupervisorTicketList data) {
    final l10n = context.l10n;
    final matching = data.tickets
        .where((ticket) => ticket.status == _activeStatus)
        .toList();
    matching.sort(_prioritySort);
    final userTickets = matching
        .where((ticket) => ticket.source == TicketSource.user)
        .toList();
    final systemTickets = matching
        .where((ticket) => ticket.source == TicketSource.system)
        .toList();

    return SupervisorScrollableBody(
      onRefresh: () async {
        ref.invalidate(todaysSupervisorTicketsProvider);
        await ref.read(todaysSupervisorTicketsProvider.future);
      },
      children: [
        _StatusTabs(
          activeStatus: _activeStatus,
          counts: data.counts,
          onChanged: (status) {
            setState(() => _activeStatus = status);
            context.go(
              '/operations/tickets?status=${ticketStatusApiValue(status)}',
            );
          },
        ),
        const SizedBox(height: 14),
        SupervisorSectionHeader(
          title: l10n.userTicketsTitle,
          trailing: Text('${userTickets.length}'),
        ),
        const SizedBox(height: 8),
        if (userTickets.isEmpty)
          SupervisorStatePanel(
            icon: Icons.inbox_outlined,
            message: l10n.noTicketsForFilterMessage,
            compact: true,
          )
        else
          ...userTickets.map(_ticketCard),
        const SizedBox(height: 18),
        SupervisorSectionHeader(
          title: l10n.systemTicketsTitle,
          trailing: Text('${systemTickets.length}'),
        ),
        const SizedBox(height: 8),
        if (systemTickets.isEmpty)
          SupervisorStatePanel(
            icon: Icons.memory_rounded,
            message: l10n.noSystemTicketsMessage,
            compact: true,
          )
        else
          ...systemTickets.map(_ticketCard),
      ],
    );
  }

  Widget _ticketCard(SupervisorTicket ticket) {
    final l10n = context.l10n;
    final canAcknowledge =
        ticket.status == SupervisorTicketStatus.pending &&
        !ticket.isSystemGenerated;
    final isBusy = _acknowledging.contains(ticket.id);
    final colors = Theme.of(context).colorScheme;
    final accent = SupervisorPalette.status(ticket.status);
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: SupervisorSurface(
        padding: EdgeInsets.zero,
        onTap: () => context.go('/operations/tickets/${ticket.id}'),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 4, color: accent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _washroomIcon(ticket.washroomType),
                          color: accent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticket.category.isEmpty
                                  ? l10n.ticketCategoryFallback
                                  : ticket.category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${ticket.washroomLabel}  ·  ${ticket.shortId}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: colors.onSurfaceVariant),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${_formatTicketTime(ticket.createdAt)}  ·  ${ticket.isSystemGenerated ? l10n.ticketSourceSystem : l10n.ticketSourceUser}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: colors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      TicketPriorityBadge(priority: ticket.priority),
                      const SizedBox(width: 4),
                      if (canAcknowledge)
                        isBusy
                            ? const SizedBox.square(
                                dimension: 30,
                                child: Padding(
                                  padding: EdgeInsets.all(6),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : IconButton(
                                tooltip: l10n.acknowledgeButton,
                                onPressed: () => _acknowledge(ticket),
                                icon: const Icon(Icons.done_rounded),
                              )
                      else
                        Icon(
                          ticket.isLocked
                              ? Icons.lock_outline_rounded
                              : Icons.chevron_right_rounded,
                          color: colors.primary,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _acknowledge(SupervisorTicket ticket) async {
    setState(() => _acknowledging.add(ticket.id));
    try {
      await ref.read(operationsRepositoryProvider).acknowledgeTicket(ticket.id);
      ref.invalidate(todaysSupervisorTicketsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(context.l10n.ticketAcknowledgedMessage)),
          );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(context.l10n.ticketAcknowledgeFailed)),
          );
      }
    } finally {
      if (mounted) setState(() => _acknowledging.remove(ticket.id));
    }
  }
}

class _StatusTabs extends StatelessWidget {
  const _StatusTabs({
    required this.activeStatus,
    required this.counts,
    required this.onChanged,
  });

  final SupervisorTicketStatus activeStatus;
  final Map<SupervisorTicketStatus, int> counts;
  final ValueChanged<SupervisorTicketStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final status in SupervisorTicketStatus.values) ...[
            SupervisorFilterPill(
              label:
                  '${ticketStatusLabel(context, status)} (${counts[status] ?? 0})',
              selected: activeStatus == status,
              icon: ticketStatusIcon(status),
              onPressed: () => onChanged(status),
            ),
            if (status != SupervisorTicketStatus.values.last)
              const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

int _prioritySort(SupervisorTicket a, SupervisorTicket b) {
  return _priorityRank(a.priority).compareTo(_priorityRank(b.priority));
}

int _priorityRank(String priority) {
  return switch (normalizeLoose(priority)) {
    'high' => 0,
    'moderate' || 'medium' => 1,
    'low' => 2,
    _ => 9,
  };
}

String _formatTicketTime(DateTime date) {
  return DateFormat('dd/MM/yy | hh:mm a').format(date);
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
