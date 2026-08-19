import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:washroom_ops/features/feedback/data/feedback_repository.dart';

void main() {
  test('fails closed when the kiosk has no single washroom assignment', () async {
    final adapter = _FeedbackAdapter(payload: const {});
    final repository = FeedbackRepository(_dioWith(adapter));

    final washroom = await repository.resolveWashroom(
      assignedWashroomIds: const ['washroom-1', 'washroom-2'],
    );

    expect(washroom, isNull);
    expect(adapter.paths, isEmpty);
  });

  test('parses canonical production feedback metrics envelope', () async {
    final adapter = _FeedbackAdapter(
      payload: {
        'success': true,
        'data': {
          'washroom': {'id': 'washroom-1'},
          'metrics': {
            'aqi': 18,
            'occupancy': 0,
            'totalOccupancy': 15,
            'footfall': null,
            'odour': 0.18,
            'cubicleOccupancy': {
              'occupied': 8,
              'total': 12,
              'monitored': 12,
              'percentage': 67,
              'dataStatus': 'live',
            },
            'washroomOccupancy': {
              'estimatedCount': 15,
              'percentage': 75,
              'band': 'busy',
              'capacity': 20,
              'displayLimit': 25,
              'isCapped': false,
              'dataStatus': 'live',
              'washroomType': 'female',
              'urinalCount': 0,
              'windowMinutes': 15,
            },
          },
          'updatedAt': '2026-08-11T18:41:10.998Z',
        },
      },
    );
    final repository = FeedbackRepository(_dioWith(adapter));

    final metrics = await repository.fetchMetrics('washroom-1');

    expect(metrics.aqi, 18);
    expect(metrics.occupied, 8);
    expect(metrics.totalOccupancy, 12);
    expect(metrics.footfall, isNull);
    expect(metrics.odour, 0.18);
    expect(metrics.cubicleOccupancy?.monitored, 12);
    expect(metrics.washroomOccupancy?.estimatedCount, 15);
    expect(metrics.washroomOccupancy?.band, 'busy');
    expect(metrics.washroomOccupancy?.washroomType, 'female');
    expect(metrics.updatedAt, DateTime.parse('2026-08-11T18:41:10.998Z'));
  });

  test(
    'uses canonical feedback metrics and ignores cumulative people field',
    () async {
      final adapter = _FeedbackAdapter(
        payload: {
          'details': {
            'footfall': 42,
            'people': 900,
            'occupied': 1,
            'totalOccupancy': 2,
            'temperature': 24,
          },
        },
      );
      final repository = FeedbackRepository(_dioWith(adapter));

      final metrics = await repository.fetchMetrics('washroom-1');

      expect(metrics.footfall, 42);
      expect(metrics.occupied, 1);
      expect(adapter.paths, ['/dashboard/feedback-screen/washroom-1']);
    },
  );

  test(
    'does not fall back to legacy metrics after canonical endpoint failure',
    () async {
      final adapter = _FeedbackAdapter(
        payload: {'message': 'unavailable'},
        statusCode: 503,
      );
      final repository = FeedbackRepository(_dioWith(adapter));

      await expectLater(
        repository.fetchMetrics('washroom-1'),
        throwsA(isA<DioException>()),
      );
      expect(adapter.paths, ['/dashboard/feedback-screen/washroom-1']);
    },
  );

  test('loads all location washrooms for development preview', () async {
    final adapter = _FeedbackAdapter(
      payload: {
        'data': [
          {
            '_id': 'washroom-1',
            'name': 'Arrivals Male',
            'code': 'ARR-M',
            'type': 'male',
          },
          {
            '_id': 'washroom-2',
            'name': 'Arrivals Female',
            'code': 'ARR-F',
            'type': 'female',
          },
        ],
      },
    );
    final repository = FeedbackRepository(_dioWith(adapter));

    final washrooms = await repository.fetchPreviewWashrooms(
      locationId: 'airport-1',
    );

    expect(washrooms.map((washroom) => washroom.id), [
      'washroom-1',
      'washroom-2',
    ]);
    expect(adapter.requests.single.path, '/washrooms');
    expect(adapter.requests.single.queryParameters, {
      'locationId': 'airport-1',
      'page': 1,
      'limit': 100,
      'sortBy': 'name',
      'sortOrder': 'asc',
    });
  });

  test('surfaces preview washroom authorization failure', () async {
    final adapter = _FeedbackAdapter(
      payload: {'message': 'forbidden'},
      statusCode: 403,
    );
    final repository = FeedbackRepository(_dioWith(adapter));

    await expectLater(
      repository.fetchPreviewWashrooms(locationId: 'airport-1'),
      throwsA(isA<DioException>()),
    );
    expect(adapter.paths, ['/washrooms']);
  });

  test('loads every preview washroom page', () async {
    final adapter = _FeedbackAdapter(
      payload: const {},
      payloadForRequest: (options) {
        final page = options.queryParameters['page'];
        return {
          'data': page == 1
              ? List.generate(
                  100,
                  (index) => {
                    '_id': 'washroom-$index',
                    'name': 'Washroom $index',
                  },
                )
              : [
                  {'_id': 'washroom-100', 'name': 'Washroom 100'},
                ],
        };
      },
    );
    final repository = FeedbackRepository(_dioWith(adapter));

    final washrooms = await repository.fetchPreviewWashrooms(
      locationId: 'airport-1',
    );

    expect(washrooms, hasLength(101));
    expect(adapter.requests, hasLength(2));
    expect(adapter.requests.last.queryParameters['page'], 2);
  });
}

Dio _dioWith(_FeedbackAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'));
  dio.httpClientAdapter = adapter;
  return dio;
}

class _FeedbackAdapter implements HttpClientAdapter {
  _FeedbackAdapter({
    required this.payload,
    this.statusCode = 200,
    this.payloadForRequest,
  });

  final Map<String, Object?> payload;
  final int statusCode;
  final Map<String, Object?> Function(RequestOptions options)?
  payloadForRequest;
  final List<String> paths = [];
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    paths.add(options.path);
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode(payloadForRequest?.call(options) ?? payload),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
