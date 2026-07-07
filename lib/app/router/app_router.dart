import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/session_controller.dart';
import '../../features/auth/domain/user_session.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/splash_page.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/feedback/presentation/feedback_device_page.dart';
import '../../features/operations/presentation/operations_home_page.dart';
import '../../features/operations/presentation/ticket_detail_page.dart';
import '../../features/operations/presentation/tickets_page.dart';
import '../../features/tenant/presentation/tenant_scope_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(sessionControllerProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final location = state.uri.path;
      final isPublic = location == '/login' || location == '/splash';

      if (session.status == SessionStatus.unknown) {
        return location == '/splash' ? null : '/splash';
      }
      if (!session.isAuthenticated) {
        return location == '/login' ? null : '/login';
      }
      if (isPublic) {
        return session.session!.isFeedbackDevice
            ? '/feedback/screensaver'
            : '/operations/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      ShellRoute(
        builder: (_, _, child) => TenantScopePage(child: child),
        routes: [
          GoRoute(
            path: '/operations/home',
            builder: (_, _) => const OperationsHomePage(),
          ),
          GoRoute(
            path: '/operations/tickets',
            builder: (_, state) =>
                TicketsPage(initialStatus: state.uri.queryParameters['status']),
          ),
          GoRoute(
            path: '/operations/tickets/:ticketId',
            builder: (_, state) =>
                TicketDetailPage(ticketId: state.pathParameters['ticketId']!),
          ),
          GoRoute(
            path: '/operations/dashboard',
            builder: (_, _) => const DashboardPage(),
          ),
          GoRoute(
            path: '/feedback/screensaver',
            builder: (_, _) => const FeedbackDevicePage(),
          ),
        ],
      ),
    ],
  );
});
