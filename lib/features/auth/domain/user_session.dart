class UserSession {
  const UserSession({
    required this.userId,
    required this.tenantId,
    required this.airportId,
    required this.username,
    required this.role,
    required this.email,
    required this.lastLogin,
    required this.washroomIds,
    required this.authToken,
    this.webappUrl,
  });

  final String userId;
  final String tenantId;
  final String airportId;
  final String username;
  final String role;
  final String email;
  final DateTime? lastLogin;
  final List<String> washroomIds;
  final String authToken;
  final String? webappUrl;

  bool get isFeedbackDevice => role == 'Feedback-device';

  bool get isSupervisor => role == 'Zone-lead' || role == 'Shift-Incharge';
}

class SessionState {
  const SessionState._({required this.status, this.session});

  const SessionState.unknown() : this._(status: SessionStatus.unknown);

  const SessionState.authenticated(UserSession session)
    : this._(status: SessionStatus.authenticated, session: session);

  const SessionState.unauthenticated()
    : this._(status: SessionStatus.unauthenticated);

  final SessionStatus status;
  final UserSession? session;

  bool get isAuthenticated => status == SessionStatus.authenticated;
}

enum SessionStatus { unknown, authenticated, unauthenticated }
