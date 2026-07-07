import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/storage/session_keys.dart';
import '../../tenant/data/tenant_controller.dart';
import '../../tenant/domain/tenant_models.dart';
import 'auth_repository.dart';
import '../domain/user_session.dart';

final sessionControllerProvider =
    NotifierProvider<SessionController, SessionState>(SessionController.new);

class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() => const SessionState.unknown();

  Future<void> restore() async {
    try {
      await ref.read(tenantControllerProvider.notifier).restoreCachedBranding();
      final storage = ref.read(secureStorageProvider);
      final token = await storage.read(SessionKeys.authToken);
      final userId = await storage.read(SessionKeys.userId);
      final tenantId = await storage.read(SessionKeys.tenantId);
      final airportId = await storage.read(SessionKeys.airportId);
      final role = await storage.read(SessionKeys.role);

      if ([
        token,
        userId,
        tenantId,
        airportId,
        role,
      ].any((item) => item == null)) {
        state = const SessionState.unauthenticated();
        return;
      }

      final washroomRaw = await storage.read(SessionKeys.washroomIds);
      final washroomIds = (jsonDecode(washroomRaw ?? '[]') as List)
          .map((item) => item.toString())
          .toList();

      final session = UserSession(
        userId: userId!,
        tenantId: tenantId!,
        airportId: airportId!,
        username: await storage.read(SessionKeys.username) ?? '',
        role: role!,
        email: await storage.read(SessionKeys.email) ?? '',
        lastLogin: DateTime.tryParse(
          await storage.read(SessionKeys.lastLogin) ?? '',
        ),
        washroomIds: washroomIds,
        authToken: token!,
        webappUrl: await storage.read(SessionKeys.webappUrl),
      );
      state = SessionState.authenticated(session);
      unawaited(_setTenantContext(session));
    } catch (error, stackTrace) {
      ref
          .read(appLoggerProvider)
          .warning('Failed to restore local session.', error, stackTrace);
      state = const SessionState.unauthenticated();
    }
  }

  Future<void> requestOtp(String username) {
    return ref.read(authRepositoryProvider).requestOtp(username);
  }

  Future<void> verifyOtp(String otp) async {
    final session = await ref.read(authRepositoryProvider).verifyOtp(otp);
    await _persist(session);
    state = SessionState.authenticated(session);
    await _setTenantContext(session);
  }

  Future<void> signOut() async {
    await ref.read(secureStorageProvider).deleteMany(const [
      SessionKeys.authToken,
      SessionKeys.refreshToken,
      SessionKeys.userId,
      SessionKeys.tenantId,
      SessionKeys.airportId,
      SessionKeys.username,
      SessionKeys.role,
      SessionKeys.email,
      SessionKeys.lastLogin,
      SessionKeys.washroomIds,
      SessionKeys.webappUrl,
    ]);
    ref.read(tenantControllerProvider.notifier).clear();
    state = const SessionState.unauthenticated();
  }

  Future<void> _persist(UserSession session) async {
    final storage = ref.read(secureStorageProvider);
    await storage.write(SessionKeys.authToken, session.authToken);
    await storage.write(SessionKeys.userId, session.userId);
    await storage.write(SessionKeys.tenantId, session.tenantId);
    await storage.write(SessionKeys.airportId, session.airportId);
    await storage.write(SessionKeys.username, session.username);
    await storage.write(SessionKeys.role, session.role);
    await storage.write(SessionKeys.email, session.email);
    await storage.write(
      SessionKeys.lastLogin,
      session.lastLogin?.toIso8601String() ?? '',
    );
    await storage.write(
      SessionKeys.washroomIds,
      jsonEncode(session.washroomIds),
    );
    if (session.webappUrl != null) {
      await storage.write(SessionKeys.webappUrl, session.webappUrl!);
    }
  }

  Future<void> _setTenantContext(UserSession session) {
    return ref
        .read(tenantControllerProvider.notifier)
        .setContext(
          TenantContext(
            tenantId: session.tenantId,
            airportId: session.airportId,
            washroomIds: session.washroomIds,
          ),
        );
  }
}
