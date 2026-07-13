import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations_context.dart';
import '../../../shared/widgets/app_loading_dialog.dart';
import '../data/operations_repository.dart';
import '../domain/ticket_models.dart';

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
          title: Text(l10n.ticketsTitle(_statusLabel(context, _activeStatus))),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(todaysSupervisorTicketsProvider);
            await ref.read(todaysSupervisorTicketsProvider.future);
          },
          child: ticketsState.when(
            data: _buildTickets,
            loading: () => const AppLoadingDialog(),
            error: (error, _) => ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _StatePanel(
                  icon: Icons.error_outline_rounded,
                  message: l10n.supervisorTicketsLoadFailed,
                  actionLabel: l10n.retryButton,
                  onAction: () =>
                      ref.invalidate(todaysSupervisorTicketsProvider),
                ),
              ],
            ),
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

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
        _SectionHeader(title: l10n.userTicketsTitle, count: userTickets.length),
        const SizedBox(height: 8),
        if (userTickets.isEmpty)
          _StatePanel(
            icon: Icons.inbox_outlined,
            message: l10n.noTicketsForFilterMessage,
          )
        else
          ...userTickets.map(_ticketCard),
        const SizedBox(height: 18),
        _SectionHeader(
          title: l10n.systemTicketsTitle,
          count: systemTickets.length,
        ),
        const SizedBox(height: 8),
        if (systemTickets.isEmpty)
          _StatePanel(
            icon: Icons.memory_rounded,
            message: l10n.noSystemTicketsMessage,
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
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => context.go('/operations/tickets/${ticket.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.16),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      _washroomIcon(ticket.washroomType),
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.washroomLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${ticket.shortId} · ${_formatTicketTime(ticket.createdAt)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _PriorityBadge(priority: ticket.priority),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                ticket.category.isEmpty
                    ? l10n.ticketCategoryFallback
                    : ticket.category,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              if (ticket.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  ticket.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Chip(
                    avatar: Icon(
                      ticket.isSystemGenerated
                          ? Icons.memory_rounded
                          : Icons.person_outline_rounded,
                      size: 18,
                    ),
                    label: Text(
                      ticket.isSystemGenerated
                          ? l10n.ticketSourceSystem
                          : l10n.ticketSourceUser,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const Spacer(),
                  if (canAcknowledge)
                    FilledButton.tonalIcon(
                      onPressed: isBusy ? null : () => _acknowledge(ticket),
                      icon: isBusy
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.done_rounded),
                      label: Text(l10n.acknowledgeButton),
                    )
                  else
                    Icon(
                      ticket.isLocked
                          ? Icons.lock_outline_rounded
                          : Icons.chevron_right_rounded,
                    ),
                ],
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
    final statuses = SupervisorTicketStatus.values;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<SupervisorTicketStatus>(
        segments: [
          for (final status in statuses)
            ButtonSegment(
              value: status,
              icon: Icon(_statusIcon(status)),
              label: Text(
                '${_statusLabel(context, status)} (${counts[status] ?? 0})',
              ),
            ),
        ],
        selected: {activeStatus},
        onSelectionChanged: (selected) => onChanged(selected.first),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});

  final String priority;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final value = normalizeLoose(priority);
    final color = switch (value) {
      'high' => colors.errorContainer,
      'moderate' || 'medium' => colors.tertiaryContainer,
      _ => colors.surfaceContainerHighest,
    };
    final textColor = switch (value) {
      'high' => colors.onErrorContainer,
      'moderate' || 'medium' => colors.onTertiaryContainer,
      _ => colors.onSurfaceVariant,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priority.isEmpty ? context.l10n.priorityFallback : priority,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

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
        Text('$count'),
      ],
    );
  }
}

class _StatePanel extends StatelessWidget {
  const _StatePanel({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(icon, size: 34),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
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

String _statusLabel(BuildContext context, SupervisorTicketStatus status) {
  final l10n = context.l10n;
  return switch (status) {
    SupervisorTicketStatus.pending => l10n.statusPending,
    SupervisorTicketStatus.acknowledge => l10n.statusAcknowledged,
    SupervisorTicketStatus.escalated => l10n.statusEscalated,
    SupervisorTicketStatus.completed => l10n.statusCompleted,
  };
}

IconData _statusIcon(SupervisorTicketStatus status) {
  return switch (status) {
    SupervisorTicketStatus.pending => Icons.pending_actions_rounded,
    SupervisorTicketStatus.acknowledge => Icons.fact_check_rounded,
    SupervisorTicketStatus.escalated => Icons.priority_high_rounded,
    SupervisorTicketStatus.completed => Icons.check_circle_rounded,
  };
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
