import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:washroom_ops/features/operations/data/operations_repository.dart';

void main() {
  group('OperationsRepository.fetchTickets', () {
    test('uses canonical paginated tickets endpoint', () async {
      final adapter = _RecordingAdapter({
        'success': true,
        'data': [
          {
            'id': 'ticket-1',
            'ticketStatus': 'Pending',
            'ticketType': 'user_generated',
            'userId': 'passenger-1',
            'createdAt': '2026-08-03T10:00:00Z',
          },
        ],
        'meta': {
          'total': 1,
          'page': 1,
          'limit': 100,
          'totalPages': 1,
          'hasNextPage': false,
          'hasPrevPage': false,
        },
      });
      final repository = OperationsRepository(_dioWith(adapter));

      final result = await repository.fetchTickets(
        userId: 'user-1',
        startTime: '2026-08-01T20:00:00.000Z',
        endTime: '2026-08-03T19:59:59.999Z',
      );

      expect(adapter.path, '/tickets');
      expect(adapter.queryParameters, {
        'startDate': '2026-08-01T20:00:00.000Z',
        'endDate': '2026-08-03T19:59:59.999Z',
        'page': 1,
        'limit': 100,
      });
      expect(result.userId, 'user-1');
      expect(result.tickets.single.id, 'ticket-1');
    });

    test('rejects a response without a ticket data list', () async {
      final adapter = _RecordingAdapter({
        'success': true,
        'data': {'tickets': []},
      });
      final repository = OperationsRepository(_dioWith(adapter));

      await expectLater(
        repository.fetchTickets(
          userId: 'user-1',
          startTime: '2026-08-01T20:00:00.000Z',
          endTime: '2026-08-03T19:59:59.999Z',
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

Dio _dioWith(_RecordingAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'));
  dio.httpClientAdapter = adapter;
  return dio;
}

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this.payload);

  final Map<String, Object?> payload;
  String? path;
  Map<String, dynamic>? queryParameters;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    path = options.path;
    queryParameters = options.queryParameters;
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
