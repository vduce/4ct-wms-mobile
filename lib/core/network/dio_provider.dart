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
      options.headers['X-Location-Id'] = tenant.airportId;
      options.headers['X-Airport-Id'] = tenant.airportId;
      if (tenant.terminalId != null) {
        options.headers['X-Terminal-Id'] = tenant.terminalId;
      }
      if (tenant.zoneId != null) options.headers['X-Zone-Id'] = tenant.zoneId;
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final refreshed = await _tryRefreshAndRetry(err, handler);
    if (refreshed) return;

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

  Future<bool> _tryRefreshAndRetry(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final requestOptions = err.requestOptions;
    final alreadyRetried = requestOptions.extra['authRetry'] == true;
    final path = requestOptions.path;

    if (response?.statusCode != 401 ||
        alreadyRetried ||
        path.contains('/auth/refresh')) {
      return false;
    }

    final storage = _ref.read(secureStorageProvider);
    final refreshToken = await storage.read(SessionKeys.refreshToken);
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final config = _ref.read(environmentConfigProvider);
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: config.apiBaseUrl,
          headers: {'Content-Type': 'application/json'},
        ),
      );
      final refreshResponse = await refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final tokens = _unwrapData(refreshResponse.data);
      final accessToken = tokens['accessToken']?.toString() ?? '';
      final newRefreshToken = tokens['refreshToken']?.toString() ?? '';

      if (accessToken.isEmpty || newRefreshToken.isEmpty) return false;

      await storage.write(SessionKeys.authToken, accessToken);
      await storage.write(SessionKeys.refreshToken, newRefreshToken);

      requestOptions.extra['authRetry'] = true;
      requestOptions.headers['Authorization'] = 'Bearer $accessToken';

      final retryResponse = await Dio().fetch<dynamic>(requestOptions);
      handler.resolve(retryResponse);
      return true;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> _unwrapData(Map<String, dynamic>? responseData) {
    final raw = responseData ?? <String, dynamic>{};
    final data = raw['data'];
    return data is Map<String, dynamic> ? data : raw;
  }
}
