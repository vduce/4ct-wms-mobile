import 'dart:convert';

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
    await _dio.post<void>('/auth/request-otp', data: {'username': username});
  }

  Future<UserSession> verifyOtp(String otp) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/verify-otp',
      data: {'otp': otp},
    );
    final data = _unwrapData(response.data);
    return _sessionFromTokenPair(data);
  }

  Future<UserSession> loginWithPassword({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login-password',
      data: {'username': username, 'password': password},
    );
    final data = _unwrapData(response.data);
    return _sessionFromTokenPair(data);
  }

  UserSession _sessionFromTokenPair(Map<String, dynamic> data) {
    final accessToken = data['accessToken']?.toString() ?? '';
    final refreshToken = data['refreshToken']?.toString() ?? '';
    if (accessToken.isEmpty || refreshToken.isEmpty) {
      throw const FormatException('Invalid login response.');
    }

    final payload = _decodeJwt(accessToken);
    if (payload.isEmpty) {
      throw const FormatException('Invalid access token.');
    }

    final washroomIds = (payload['washroomIds'] as List? ?? [])
        .map((item) => item.toString())
        .where((item) => item.isNotEmpty)
        .toList();

    return UserSession(
      userId: (payload['sub'] ?? payload['user_id'])?.toString() ?? '',
      tenantId: (payload['tenantId'] ?? payload['tenant_id'])?.toString() ?? '',
      airportId:
          (payload['locationId'] ?? payload['airport_id'])?.toString() ?? '',
      username: (payload['name'] ?? payload['username'])?.toString() ?? '',
      role: payload['role']?.toString() ?? '',
      roleDisplayName: payload['roleDisplayName']?.toString(),
      email: payload['email']?.toString() ?? '',
      lastLogin: DateTime.now(),
      washroomIds: washroomIds,
      authToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  Future<void> updatePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    await _dio.post<void>(
      '/auth/update-password',
      data: {'currentPassword': oldPassword, 'newPassword': newPassword},
    );
  }

  Future<void> updatePushToken({
    required String userId,
    required String token,
  }) async {
    await _dio.put<void>('/auth/push-token', data: {'token': token});
  }

  Map<String, dynamic> _unwrapData(Map<String, dynamic>? responseData) {
    final raw = responseData ?? <String, dynamic>{};
    final data = raw['data'];
    return data is Map<String, dynamic> ? data : raw;
  }

  Map<String, dynamic> _decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return <String, dynamic>{};

      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return <String, dynamic>{};
    }
  }
}
