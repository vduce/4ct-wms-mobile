import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:washroom_ops/core/storage/key_value_store.dart';
import 'package:washroom_ops/core/storage/session_keys.dart';
import 'package:washroom_ops/features/tenant/data/tenant_repository.dart';
import 'package:washroom_ops/features/tenant/domain/tenant_models.dart';

void main() {
  test('reads and caches tenant date-time settings from /tenants/me', () async {
    final adapter = _JsonAdapter({
      'data': {
        'branding': {'appName': 'Tenant App'},
        'config': {
          'timezone': 'Asia/Kolkata',
          'locale': 'en-IN',
          'dateFormat': 'DD.MM.YYYY',
          'timeFormat': '24-hour',
        },
      },
    });
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'));
    dio.httpClientAdapter = adapter;
    final store = _MemoryKeyValueStore();
    final repository = TenantRepository(dio, store);

    final result = await repository.fetchTenantSettings(
      const TenantContext(tenantId: 'tenant-1', airportId: 'airport-1'),
    );

    expect(adapter.path, '/tenants/me');
    expect(result.branding.appName, 'Tenant App');
    expect(result.dateTimeSettings.timeZone, 'Asia/Kolkata');
    expect(result.dateTimeSettings.dateFormat, 'DD.MM.YYYY');
    expect(result.dateTimeSettings.timeFormat, '24-hour');
    expect(
      jsonDecode(store.values[SessionKeys.cachedDateTimeSettings]!)['timezone'],
      'Asia/Kolkata',
    );
  });

  test('uses safe defaults for malformed backend format settings', () async {
    final adapter = _JsonAdapter({
      'data': {
        'branding': <String, Object?>{},
        'config': {
          'dateFormat': 'arbitrary-pattern',
          'timeFormat': 'arbitrary-pattern',
        },
      },
    });
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'));
    dio.httpClientAdapter = adapter;
    final repository = TenantRepository(dio, _MemoryKeyValueStore());

    final result = await repository.fetchTenantSettings(
      const TenantContext(tenantId: 'tenant-1', airportId: 'airport-1'),
    );

    expect(result.dateTimeSettings.dateFormat, 'DD.MM.YYYY');
    expect(result.dateTimeSettings.timeFormat, '24-hour');
    expect(result.dateTimeSettings.timeZone, 'Asia/Kolkata');
  });

  test('ignores a corrupt cached date-time settings value', () async {
    final store = _MemoryKeyValueStore()
      ..values[SessionKeys.cachedDateTimeSettings] = '{invalid-json';
    final repository = TenantRepository(Dio(), store);

    expect(await repository.readCachedDateTimeSettings(), isNull);
  });
}

class _MemoryKeyValueStore extends KeyValueStore {
  final values = <String, String>{};

  @override
  Future<String?> getString(String key) async => values[key];

  @override
  Future<void> setString(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    values.remove(key);
  }
}

class _JsonAdapter implements HttpClientAdapter {
  _JsonAdapter(this.payload);

  final Map<String, Object?> payload;
  String? path;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    path = options.path;
    return ResponseBody.fromString(
      jsonEncode(payload),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
