import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:washroom_ops/features/auth/data/session_controller.dart';
import 'package:washroom_ops/features/auth/domain/user_session.dart';
import 'package:washroom_ops/features/operations/data/operations_repository.dart';
import 'package:washroom_ops/features/operations/domain/ticket_models.dart';
import 'package:washroom_ops/features/operations/presentation/operations_home_page.dart';
import 'package:washroom_ops/features/operations/presentation/ticket_detail_page.dart';
import 'package:washroom_ops/features/operations/presentation/ticket_history_page.dart';
import 'package:washroom_ops/features/operations/presentation/tickets_page.dart';
import 'package:washroom_ops/l10n/generated/app_localizations.dart';

void main() {
  final tickets = SupervisorTicketList(
    userId: 'user-1',
    role: 'Zone-lead',
    washroomIds: const ['washroom-1'],
    rosters: const [],
    tickets: [
      SupervisorTicket(
        id: 'ticket-7234',
        washroomId: 'washroom-1',
        zoneId: 'zone-1',
        status: SupervisorTicketStatus.pending,
        category: 'Bin overflowing near the main entrance',
        priority: 'High',
        description: 'Passenger reported an overflowing bin.',
        createdAt: DateTime(2026, 7, 13, 15, 44),
        tenantId: 'tenant-1',
        airportId: 'airport-1',
        userId: 'passenger-1',
        ticketType: 'User',
        assignedUserRole: 'Zone-lead',
        logs: const [],
        washroomName: 'Arrival family care washroom',
        washroomType: SupervisorWashroomType.unisex,
      ),
    ],
  );
  final detail = SupervisorTicketDetail(
    id: 'ticket-7234',
    ticketNumber: 'TKT-20260713-7234',
    washroomId: 'washroom-1',
    washroomName: 'Arrival family care washroom',
    locationName: 'Arrival side',
    category: 'Cleaning',
    priority: 'High',
    issue: 'Bin overflowing near the main entrance',
    status: SupervisorTicketStatus.escalated,
    createdAt: DateTime(2026, 7, 13, 15, 44),
    assignedTo: 'Zone Lead',
    ticketType: 'User',
    logs: [
      SupervisorTicketLog(
        status: 'Escalated',
        timestamp: DateTime(2026, 7, 13, 15, 44),
        comment: 'Bin not emptied for more than 24 hours.',
        zoneLeadName: 'Zone Lead',
        shiftInchargeName: 'Shift Incharge',
        adminName: 'Admin',
        attachments: const [],
        hasDeviceHints: false,
      ),
    ],
  );

  for (final size in [const Size(320, 700), const Size(1180, 700)]) {
    testWidgets('operations home has no overflow at ${size.width.toInt()}px', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionControllerProvider.overrideWith(_TestSessionController.new),
            todaysSupervisorTicketsProvider.overrideWith(
              (ref) async => tickets,
            ),
            supervisedWashroomsProvider.overrideWith((ref) async => const []),
          ],
          child: const _TestApp(home: OperationsHomePage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hi Supervisor'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ticket list has no overflow at ${size.width.toInt()}px', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todaysSupervisorTicketsProvider.overrideWith(
              (ref) async => tickets,
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF7248E8),
              ),
            ),
            home: const TicketsPage(initialStatus: 'Pending'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Bin overflowing'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ticket history has no overflow at ${size.width.toInt()}px', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ticketHistoryProvider.overrideWith((ref, query) async => tickets),
          ],
          child: const _TestApp(home: TicketHistoryPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('From'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.drag(find.byType(Scrollable).first, const Offset(0, -700));
      await tester.pumpAndSettle();
      expect(find.textContaining('Bin overflowing'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ticket detail has no overflow at ${size.width.toInt()}px', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ticketDetailProvider.overrideWith((ref, id) async => detail),
          ],
          child: const _TestApp(
            home: TicketDetailPage(ticketId: 'ticket-7234'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Bin overflowing'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

class _TestSessionController extends SessionController {
  @override
  SessionState build() {
    return SessionState.authenticated(
      UserSession(
        userId: 'user-1',
        tenantId: 'tenant-1',
        airportId: 'airport-1',
        username: 'Supervisor',
        role: 'Zone-lead',
        email: 'supervisor@example.com',
        lastLogin: DateTime(2026, 7, 13, 15, 44),
        washroomIds: const ['washroom-1'],
        authToken: 'test-token',
        refreshToken: 'test-refresh-token',
        roleDisplayName: 'Supervisor',
      ),
    );
  }
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7248E8)),
      ),
      home: home,
    );
  }
}
