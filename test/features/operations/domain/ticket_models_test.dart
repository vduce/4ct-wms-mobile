import 'package:flutter_test/flutter_test.dart';
import 'package:washroom_ops/features/operations/domain/ticket_models.dart';

void main() {
  group('ticket status normalization', () {
    test('maps backend variants to canonical supervisor statuses', () {
      expect(
        normalizeTicketStatus('Acknowledged'),
        SupervisorTicketStatus.acknowledge,
      );
      expect(
        normalizeTicketStatus('Approval'),
        SupervisorTicketStatus.completed,
      );
      expect(
        normalizeTicketStatus('on escalation'),
        SupervisorTicketStatus.escalated,
      );
    });
  });

  group('ticket source and lock rules', () {
    test('locks system generated tickets', () {
      final ticket = SupervisorTicket.fromJson({
        'ticketId': 'abc1234',
        'status': 'Pending',
        'ticketType': 'System Generated',
        'createdAt': '2026-07-11T08:00:00Z',
      });

      expect(ticket.source, TicketSource.system);
      expect(ticket.isLocked, isTrue);
    });

    test('allows pending user ticket actions', () {
      final ticket = SupervisorTicket.fromJson({
        'ticketId': 'abc1234',
        'status': 'Pending',
        'ticketType': 'user_generated',
        'userId': 'user-1',
        'createdAt': '2026-07-11T08:00:00Z',
      });

      expect(ticket.source, TicketSource.user);
      expect(ticket.isLocked, isFalse);
    });
  });

  group('ticket dashboard comparisons', () {
    test('compares status counts for today and yesterday', () {
      final tickets = SupervisorTicketList.fromJson({
        'tickets': [
          {
            'ticketId': 'pending-today-1',
            'status': 'Pending',
            'createdAt': '2026-07-24T08:00:00',
          },
          {
            'ticketId': 'pending-today-2',
            'status': 'Pending',
            'createdAt': '2026-07-24T09:00:00',
          },
          {
            'ticketId': 'pending-yesterday',
            'status': 'Pending',
            'createdAt': '2026-07-23T08:00:00',
          },
          {
            'ticketId': 'completed-yesterday',
            'status': 'Completed',
            'createdAt': '2026-07-23T10:00:00',
          },
        ],
      });

      final deltas = tickets.countDeltasFromYesterday(
        now: DateTime(2026, 7, 24, 12),
      );

      expect(deltas[SupervisorTicketStatus.pending], 1);
      expect(deltas[SupervisorTicketStatus.completed], -1);
      expect(deltas[SupervisorTicketStatus.acknowledge], 0);
    });
  });
}
