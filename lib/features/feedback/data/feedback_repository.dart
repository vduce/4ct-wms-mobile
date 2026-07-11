import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../auth/data/session_controller.dart';
import '../domain/feedback_models.dart';

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  return FeedbackRepository(ref.watch(dioProvider));
});

class FeedbackRepository {
  const FeedbackRepository(this._dio);

  final Dio _dio;

  Future<FeedbackWashroom?> resolveWashroom({
    required String locationId,
    required List<String> assignedWashroomIds,
  }) async {
    if (assignedWashroomIds.isNotEmpty) {
      final response = await _dio.get<Map<String, Object?>>(
        '/washrooms/${assignedWashroomIds.first}',
      );
      return FeedbackWashroom.fromJson(_unwrapData(response.data));
    }

    final response = await _dio.get<Map<String, Object?>>(
      '/washrooms',
      queryParameters: {
        'locationId': locationId,
        'page': 1,
        'limit': 1,
        'sortBy': 'createdAt',
        'sortOrder': 'asc',
      },
    );
    final washrooms = _unwrapList(response.data);
    if (washrooms.isEmpty) return null;
    return FeedbackWashroom.fromJson(washrooms.first);
  }

  Future<List<FeedbackReason>> fetchReasons({
    required String locationId,
  }) async {
    final response = await _dio.get<Map<String, Object?>>(
      '/feedback/reasons',
      queryParameters: {'locationId': locationId, 'isActive': 'true'},
    );

    return _unwrapList(response.data)
        .map(FeedbackReason.fromJson)
        .where((reason) => reason.id.isNotEmpty && reason.reason.isNotEmpty)
        .toList();
  }

  Future<FeedbackMetrics> fetchMetrics(String washroomId) async {
    try {
      final response = await _dio.get<Map<String, Object?>>(
        '/dashboard/screensaver',
        queryParameters: {'washroomId': washroomId},
      );
      return FeedbackMetrics.fromJson(_unwrapData(response.data));
    } on DioException {
      final response = await _dio.get<Map<String, Object?>>(
        '/user_screensaver_page',
        queryParameters: {'washroomId': washroomId},
      );
      return FeedbackMetrics.fromJson(response.data ?? {});
    }
  }

  Future<void> submitFeedback({
    required String washroomId,
    required bool positive,
    required List<String> reasons,
    String? comment,
  }) async {
    await _dio.post<void>(
      '/feedback',
      data: {
        'washroomId': washroomId,
        'feedbackPositive': positive,
        if (reasons.isNotEmpty) 'reasons': reasons,
        if (comment != null && comment.trim().isNotEmpty)
          'comment': comment.trim(),
      },
    );
  }

  Map<String, Object?> _unwrapData(Map<String, Object?>? responseData) {
    final raw = responseData ?? <String, Object?>{};
    final data = raw['data'];
    if (data is Map) return Map<String, Object?>.from(data);
    return raw;
  }

  List<Map<String, Object?>> _unwrapList(Map<String, Object?>? responseData) {
    final raw = responseData ?? <String, Object?>{};
    final data = raw['data'];
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, Object?>.from(item))
          .toList();
    }
    return const [];
  }
}

final feedbackDeviceStateProvider = FutureProvider<FeedbackDeviceState>((
  ref,
) async {
  final session = ref.watch(sessionControllerProvider).session;
  if (session == null) {
    return FeedbackDeviceState(
      washroom: null,
      metrics: FeedbackMetrics.empty(),
      reasons: const [],
    );
  }

  final repository = ref.watch(feedbackRepositoryProvider);
  final washroom = await repository.resolveWashroom(
    locationId: session.airportId,
    assignedWashroomIds: session.washroomIds,
  );
  final reasons = await repository.fetchReasons(locationId: session.airportId);
  final metrics = washroom == null
      ? FeedbackMetrics.empty()
      : await repository.fetchMetrics(washroom.id);

  return FeedbackDeviceState(
    washroom: washroom,
    metrics: metrics,
    reasons: reasons,
  );
});
