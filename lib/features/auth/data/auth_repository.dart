import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../domain/user_session.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

class AuthRepository {
  const AuthRepository(this._dio);

  final Dio _dio;

  Future<void> requestOtp(String username) async {
    await _dio.post<void>('/otp_generator', data: {'username': username});
  }

  Future<UserSession> verifyOtp(String otp) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/check_otp',
      data: {'otp': otp},
    );
    final data = response.data ?? {};
    final user = data['user'] as Map<String, dynamic>? ?? {};
    final washroomIds = (user['washroomIds'] as List? ?? [])
        .map((item) => item.toString())
        .where((item) => item.isNotEmpty)
        .toList();

    return UserSession(
      userId: user['user_id']?.toString() ?? '',
      tenantId: user['tenant_id']?.toString() ?? '',
      airportId: user['airport_id']?.toString() ?? '',
      username: user['username']?.toString() ?? '',
      role: user['role']?.toString() ?? '',
      email: user['email']?.toString() ?? '',
      lastLogin: DateTime.tryParse(user['lastLogin']?.toString() ?? ''),
      washroomIds: washroomIds,
      authToken: data['authToken']?.toString() ?? '',
      webappUrl: data['webappUrl']?.toString(),
    );
  }

  Future<void> updatePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    await _dio.put<void>(
      '/update_password',
      data: {
        'email': email,
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );
  }

  Future<void> updatePushToken({
    required String userId,
    required String token,
  }) async {
    await _dio.post<void>(
      '/update_push_notification_token',
      data: {'userId': userId, 'token': token},
    );
  }
}
