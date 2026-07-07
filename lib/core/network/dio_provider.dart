import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/tenant/data/tenant_controller.dart';
import '../config/environment_config.dart';
import '../errors/app_failure.dart';
import '../logging/app_logger.dart';
import '../storage/secure_storage.dart';
import '../storage/session_keys.dart';

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(environmentConfigProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(AuthTenantInterceptor(ref));

  if (config.enableNetworkLogging) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => ref.read(appLoggerProvider).debug('$object'),
      ),
    );
  }

  return dio;
});

class AuthTenantInterceptor extends Interceptor {
  AuthTenantInterceptor(this._ref);

  final Ref _ref;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final storage = _ref.read(secureStorageProvider);
    final token = await storage.read(SessionKeys.authToken);
    final tenant = _ref.read(activeTenantProvider);

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    if (tenant != null) {
      options.headers['X-Tenant-Id'] = tenant.tenantId;
      options.headers['X-Airport-Id'] = tenant.airportId;
      if (tenant.terminalId != null) {
        options.headers['X-Terminal-Id'] = tenant.terminalId;
      }
      if (tenant.zoneId != null) options.headers['X-Zone-Id'] = tenant.zoneId;
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    final data = response?.data;
    var message = err.message ?? 'Network request failed';
    if (data is Map && data['message'] != null) {
      message = data['message'].toString();
    }
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: response,
        type: err.type,
        error: AppFailure(
          message: message,
          statusCode: response?.statusCode,
          cause: err,
        ),
      ),
    );
  }
}
