import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/date/date_time.dart';
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

  Future<AppDateTimeSettings?> readCachedDateTimeSettings() async {
    final raw = await _store.getString(SessionKeys.cachedDateTimeSettings);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return AppDateTimeSettings.fromJson(Map<String, Object?>.from(decoded));
    } on FormatException {
      return null;
    }
  }

  Future<TenantPresentationSettings> fetchTenantSettings(
    TenantContext context,
  ) async {
    final response = await _dio.get<Map<String, Object?>>('/tenants/me');
    final tenant = response.data?['data'] as Map<String, Object?>? ?? {};
    final branding = _brandingFromTenantJson(tenant);
    final dateTimeSettings = _dateTimeSettingsFromTenantJson(tenant);
    await _cacheBranding(branding);
    await _cacheDateTimeSettings(dateTimeSettings);
    return TenantPresentationSettings(
      branding: branding,
      dateTimeSettings: dateTimeSettings,
    );
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

  AppDateTimeSettings _dateTimeSettingsFromTenantJson(
    Map<String, Object?> tenant,
  ) {
    final config = tenant['config'];
    if (config is! Map) return AppDateTimeSettings.defaults;
    return AppDateTimeSettings.fromJson(Map<String, Object?>.from(config));
  }

  Future<void> _cacheBranding(TenantBranding branding) {
    return _store.setString(
      SessionKeys.cachedBranding,
      jsonEncode(branding.toJson()),
    );
  }

  Future<void> _cacheDateTimeSettings(AppDateTimeSettings settings) {
    return _store.setString(
      SessionKeys.cachedDateTimeSettings,
      jsonEncode(settings.toJson()),
    );
  }
}
