import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:washroom_ops/features/feedback/data/feedback_repository.dart';

void main() {
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
}

Dio _dioWith(_FeedbackAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'));
  dio.httpClientAdapter = adapter;
  return dio;
}

class _FeedbackAdapter implements HttpClientAdapter {
  _FeedbackAdapter({required this.payload, this.statusCode = 200});

  final Map<String, Object?> payload;
  final int statusCode;
  final List<String> paths = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    paths.add(options.path);
    return ResponseBody.fromString(
      jsonEncode(payload),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
