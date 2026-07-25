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
          actions: [
            IconButton(
              tooltip: l10n.filterTicketsTooltip,
              onPressed: ticketsState.asData == null
                  ? null
                  : () => _showStatusFilter(ticketsState.asData!.value.counts),
              icon: const Icon(Icons.filter_list_rounded),
            ),
            const SizedBox(width: 8),
          ],
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

  void _changeStatus(SupervisorTicketStatus status) {
    setState(() => _activeStatus = status);
    context.go('/operations/tickets?status=${ticketStatusApiValue(status)}');
  }

  Future<void> _showStatusFilter(
    Map<SupervisorTicketStatus, int> counts,
  ) async {
    final selected = await showModalBottomSheet<SupervisorTicketStatus>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          children: [
            for (final status in SupervisorTicketStatus.values)
              ListTile(
                leading: Icon(
                  ticketStatusIcon(status),
                  color: SupervisorPalette.status(status),
                ),
                title: Text(ticketStatusLabel(context, status)),
                trailing: Text('${counts[status] ?? 0}'),
                selected: status == _activeStatus,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () => Navigator.of(context).pop(status),
              ),
          ],
        ),
      ),
    );
    if (selected != null && mounted) _changeStatus(selected);
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
      maxWidth: 780,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
      onRefresh: () async {
        ref.invalidate(todaysSupervisorTicketsProvider);
        await ref.read(todaysSupervisorTicketsProvider.future);
      },
      children: [
        _StatusTabs(
          activeStatus: _activeStatus,
          counts: data.counts,
          onChanged: _changeStatus,
        ),
        const SizedBox(height: 28),
        _TicketSectionHeader(
          title: l10n.userTicketsTitle,
          count: userTickets.length,
        ),
        const SizedBox(height: 12),
        if (userTickets.isEmpty)
          SupervisorDottedStatePanel(
            icon: Icons.inbox_outlined,
            message: l10n.noTicketsForFilterMessage,
          )
        else
          ...userTickets.map(_ticketCard),
        const SizedBox(height: 26),
        _TicketSectionHeader(
          title: l10n.systemTicketsTitle,
          count: systemTickets.length,
        ),
        const SizedBox(height: 12),
        if (systemTickets.isEmpty)
          SupervisorDottedStatePanel(
            icon: Icons.memory_rounded,
            message: l10n.noSystemTicketsMessage,
          )
        else
          ...systemTickets.map(_ticketCard),
      ],
    );
  }

  Widget _ticketCard(SupervisorTicket ticket) {
    final canAcknowledge =
        ticket.status == SupervisorTicketStatus.pending &&
        !ticket.isSystemGenerated;
    final isBusy = _acknowledging.contains(ticket.id);
    final accent = SupervisorPalette.status(ticket.status);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SupervisorSurface(
        padding: EdgeInsets.zero,
        radius: 16,
        onTap: () => context.go('/operations/tickets/${ticket.id}'),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 700;
            return IntrinsicHeight(
              child: Row(
                children: [
                  Container(width: 5, color: accent),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        wide ? 20 : 14,
                        wide ? 16 : 14,
                        wide ? 14 : 12,
                        wide ? 16 : 14,
                      ),
                      child: wide
                          ? _WideTicketCardContent(
                              ticket: ticket,
                              accent: accent,
                              canAcknowledge: canAcknowledge,
                              isBusy: isBusy,
                              onAcknowledge: () => _acknowledge(ticket),
                            )
                          : _MobileTicketCardContent(
                              ticket: ticket,
                              accent: accent,
                              canAcknowledge: canAcknowledge,
                              isBusy: isBusy,
                              onAcknowledge: () => _acknowledge(ticket),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
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
    final tabs = <Widget>[
      for (final status in SupervisorTicketStatus.values) ...[
        SupervisorFilterPill(
          label:
              '${ticketStatusLabel(context, status)} (${counts[status] ?? 0})',
          selected: activeStatus == status,
          height: 48,
          horizontalPadding: 20,
          onPressed: () => onChanged(status),
        ),
        if (status != SupervisorTicketStatus.values.last)
          const SizedBox(width: 10),
      ],
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 700) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: tabs,
          );
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: tabs),
        );
      },
    );
  }
}

class _TicketSectionHeader extends StatelessWidget {
  const _TicketSectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Text(
          '$count',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: count == 0
                ? colors.onSurfaceVariant.withValues(alpha: 0.48)
                : colors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _TicketIcon extends StatelessWidget {
  const _TicketIcon({required this.ticket, required this.accent});

  final SupervisorTicket ticket;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(_ticketIcon(ticket), color: accent, size: 24),
    );
  }
}

class _WideTicketCardContent extends StatelessWidget {
  const _WideTicketCardContent({
    required this.ticket,
    required this.accent,
    required this.canAcknowledge,
    required this.isBusy,
    required this.onAcknowledge,
  });

  final SupervisorTicket ticket;
  final Color accent;
  final bool canAcknowledge;
  final bool isBusy;
  final VoidCallback onAcknowledge;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        _TicketIcon(ticket: ticket, accent: accent),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _ticketTitle(context, ticket),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 3),
              Text(
                '${ticket.washroomLabel} · ${ticket.shortId} · '
                '${_formatTicketTime(ticket.createdAt)} · '
                '${_ticketSourceLabel(context, ticket)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        TicketPriorityBadge(priority: ticket.priority),
        const SizedBox(width: 10),
        if (canAcknowledge)
          _AcknowledgeControl(loading: isBusy, onPressed: onAcknowledge)
        else
          Icon(
            ticket.isLocked
                ? Icons.lock_outline_rounded
                : Icons.chevron_right_rounded,
            color: colors.onSurfaceVariant.withValues(alpha: 0.5),
          ),
      ],
    );
  }
}

class _MobileTicketCardContent extends StatelessWidget {
  const _MobileTicketCardContent({
    required this.ticket,
    required this.accent,
    required this.canAcknowledge,
    required this.isBusy,
    required this.onAcknowledge,
  });

  final SupervisorTicket ticket;
  final Color accent;
  final bool canAcknowledge;
  final bool isBusy;
  final VoidCallback onAcknowledge;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TicketIcon(ticket: ticket, accent: accent),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _ticketTitle(context, ticket),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TicketPriorityBadge(priority: ticket.priority),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                '${ticket.washroomLabel} · ${ticket.shortId}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_formatTicketTime(ticket.createdAt)} · '
                      '${_ticketSourceLabel(context, ticket)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (canAcknowledge) ...[
                    const SizedBox(width: 4),
                    _AcknowledgeControl(
                      loading: isBusy,
                      onPressed: onAcknowledge,
                      compact: true,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AcknowledgeControl extends StatelessWidget {
  const _AcknowledgeControl({
    required this.loading,
    required this.onPressed,
    this.compact = false,
  });

  final bool loading;
  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return SizedBox.square(
        dimension: compact ? 26 : 34,
        child: const Padding(
          padding: EdgeInsets.all(6),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return IconButton(
      tooltip: context.l10n.acknowledgeButton,
      constraints: BoxConstraints.tightFor(
        width: compact ? 28 : 36,
        height: compact ? 28 : 36,
      ),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      onPressed: onPressed,
      icon: Icon(Icons.done_rounded, size: compact ? 18 : 21),
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
  return DateFormat('dd MMM yyyy, hh:mm a').format(date);
}

String _ticketTitle(BuildContext context, SupervisorTicket ticket) {
  return ticket.category.isEmpty
      ? context.l10n.ticketCategoryFallback
      : ticket.category;
}

String _ticketSourceLabel(BuildContext context, SupervisorTicket ticket) {
  return ticket.isSystemGenerated
      ? context.l10n.ticketSourceSystemGenerated
      : context.l10n.ticketSourceUserReported;
}

IconData _ticketIcon(SupervisorTicket ticket) {
  final category = normalizeLoose(ticket.category);
  if (category.contains('bin') ||
      category.contains('waste') ||
      category.contains('trash')) {
    return Icons.delete_outline_rounded;
  }
  if (category.contains('water') || category.contains('leak')) {
    return Icons.water_drop_outlined;
  }
  if (category.contains('soap') || category.contains('dispenser')) {
    return Icons.soap_outlined;
  }
  return _washroomIcon(ticket.washroomType);
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
