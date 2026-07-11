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
    final response = await _dio.get<Map<String, Object?>>('/tenants/me');
    final tenant = response.data?['data'] as Map<String, Object?>? ?? {};
    final branding = _brandingFromTenantJson(tenant);
    await _cacheBranding(branding);
    return branding;
  }

  Future<TenantBranding> fetchBrandingBySlug(String slug) async {
    final response = await _dio.get<Map<String, Object?>>(
      '/tenants/branding/${Uri.encodeComponent(slug)}',
    );
    final body = response.data ?? {};
    final tenant = body['data'] as Map<String, Object?>? ?? body;
    final branding = _brandingFromTenantJson(tenant);
    await _cacheBranding(branding);
    return branding;
  }

  TenantBranding _brandingFromTenantJson(Map<String, Object?> tenant) {
    return TenantBranding.fromJson(
      tenant['branding'] as Map<String, Object?>? ?? {},
    );
  }

  Future<void> _cacheBranding(TenantBranding branding) {
    return _store.setString(
      SessionKeys.cachedBranding,
      jsonEncode(branding.toJson()),
    );
  }
}
