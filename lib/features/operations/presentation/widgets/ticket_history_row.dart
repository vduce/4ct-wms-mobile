import 'package:flutter/material.dart';

import '../../../../core/date/date_time.dart';
import '../../../../l10n/app_localizations_context.dart';
import '../../domain/ticket_models.dart';
import 'supervisor_ui.dart';

class TicketHistoryRow extends StatelessWidget {
  const TicketHistoryRow({required this.ticket, super.key});

  final SupervisorTicket ticket;

  @override
  Widget build(BuildContext context) {
    final statusColor = SupervisorPalette.status(ticket.status);
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 700;
        return Stack(
          children: [
            Positioned(
              top: 12,
              bottom: 12,
              left: 0,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                wide ? 20 : 16,
                wide ? 16 : 14,
                wide ? 20 : 14,
                wide ? 16 : 14,
              ),
              child: wide
                  ? _WideHistoryTicket(ticket: ticket)
                  : _MobileHistoryTicket(ticket: ticket),
            ),
          ],
        );
      },
    );
  }
}

class _WideHistoryTicket extends StatelessWidget {
  const _WideHistoryTicket({required this.ticket});

  final SupervisorTicket ticket;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        _HistoryStatusDot(status: ticket.status),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _historyTicketTitle(context, ticket),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 3),
              Text(
                '${ticket.washroomLabel} · ${ticket.shortId} · '
                '${ticketStatusLabel(context, ticket.status)} · '
                '${context.formatAppDateTime(ticket.createdAt)} · '
                '${_historySourceLabel(context, ticket)}',
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
        const SizedBox(width: 12),
        Icon(
          Icons.chevron_right_rounded,
          color: colors.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ],
    );
  }
}

class _MobileHistoryTicket extends StatelessWidget {
  const _MobileHistoryTicket({required this.ticket});

  final SupervisorTicket ticket;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _HistoryStatusDot(status: ticket.status),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _historyTicketTitle(context, ticket),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(width: 8),
            TicketPriorityBadge(priority: ticket.priority),
          ],
        ),
        const SizedBox(height: 9),
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${ticket.washroomLabel} · ${ticket.shortId} · '
                '${ticketStatusLabel(context, ticket.status)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text(
                '${context.formatAppDateTime(ticket.createdAt)} · '
                '${_historySourceLabel(context, ticket)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HistoryStatusDot extends StatelessWidget {
  const _HistoryStatusDot({required this.status});

  final SupervisorTicketStatus status;

  @override
  Widget build(BuildContext context) {
    final color = SupervisorPalette.status(status);
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

String _historyTicketTitle(BuildContext context, SupervisorTicket ticket) {
  return ticket.category.isEmpty
      ? context.l10n.ticketCategoryFallback
      : ticket.category;
}

String _historySourceLabel(BuildContext context, SupervisorTicket ticket) {
  return ticket.source == TicketSource.system
      ? context.l10n.ticketSourceSystemGenerated
      : context.l10n.ticketSourceUserReported;
}
