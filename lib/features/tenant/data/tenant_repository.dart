import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../../core/storage/key_value_store.dart';
import '../../../core/storage/session_keys.dart';
import '../domain/tenant_models.dart';

final tenantRepositoryProvider = Provider<TenantRepository>((ref) {
  return TenantRepository(
    ref.watch(dioProvider),
    ref.watch(keyValueStoreProvider),
  );
});

class TenantRepository {
  const TenantRepository(this._dio, this._store);

  final Dio _dio;
  final KeyValueStore _store;

  Future<TenantBranding?> readCachedBranding() async {
    final raw = await _store.getString(SessionKeys.cachedBranding);
    if (raw == null) return null;
    return TenantBranding.fromJson(jsonDecode(raw) as Map<String, Object?>);
  }

  Future<TenantBranding> fetchBranding(TenantContext context) async {
    // TBD: replace when backend exposes tenant configuration.
    final response = await _dio.get<Map<String, Object?>>(
      '/tenant_config',
      queryParameters: {
        'tenantId': context.tenantId,
        'airportId': context.airportId,
      },
    );
    final branding = TenantBranding.fromJson(
      response.data?['branding'] as Map<String, Object?>? ?? {},
    );
    await _store.setString(
      SessionKeys.cachedBranding,
      jsonEncode(branding.toJson()),
    );
    return branding;
  }
}
