import 'package:flutter_test/flutter_test.dart';
import 'package:washroom_ops/features/auth/domain/user_session.dart';
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
        SupervisorTicketStatus.acknowledge,
      );
      expect(
        normalizeTicketStatus('on escalation'),
        SupervisorTicketStatus.escalated,
      );
    });
  });

  group('ticket dates and duration', () {
    test('keeps ticket number and description as separate fields', () {
      final detail = SupervisorTicketDetail.fromJson({
        'ticketNumber': 'TKT-20260813-0001',
        'sourceRuleName': 'DEV-FIX-VERIFY 04',
        'reasonType': 'Cleaning',
        'description': 'Date boundary/list check: verify timezone.',
      });

      expect(detail.ticketNumber, 'TKT-20260813-0001');
      expect(detail.sourceRuleName, 'DEV-FIX-VERIFY 04');
      expect(detail.description, 'Date boundary/list check: verify timezone.');
      expect(detail.category, 'Cleaning');
    });

    test('serializes local date ranges as the correct UTC instants', () {
      final range = DateRange.fromDateKeys('2026-08-13', '2026-08-13');
      final localStart = DateTime(2026, 8, 13);
      final localEnd = DateTime(2026, 8, 13, 23, 59, 59, 999);

      expect(range.startIsoUtc, localStart.toUtc().toIso8601String());
      expect(range.endIsoUtc, localEnd.toUtc().toIso8601String());
    });

    test('derives completion time and duration from the ticket log', () {
      final detail = SupervisorTicketDetail.fromJson({
        'ticketId': 'ticket-1',
        'ticketStatus': 'Completed',
        'createdAt': '2026-08-13T08:00:00Z',
        'ticketLog': [
          {'status': 'Pending', 'changedAt': '2026-08-13T08:00:00Z'},
          {
            'status': 'Completed',
            'changedAt': '2026-08-13T09:45:00Z',
            'notes': 'Resolved',
          },
        ],
      });

      expect(detail.completedAt, DateTime.parse('2026-08-13T09:45:00Z'));
      expect(detail.elapsedDuration, const Duration(hours: 1, minutes: 45));
      expect(detail.logs.first.comment, 'Resolved');
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

  test('recognizes canonical supervisor role', () {
    const session = UserSession(
      userId: 'user-1',
      tenantId: 'tenant-1',
      airportId: 'airport-1',
      username: 'Supervisor',
      role: 'supervisor',
      email: 'supervisor@example.com',
      lastLogin: null,
      washroomIds: [],
      authToken: 'token',
      refreshToken: 'refresh-token',
    );

    expect(session.isSupervisor, isTrue);
  });
}
