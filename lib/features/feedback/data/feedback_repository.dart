import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../auth/data/session_controller.dart';
import '../domain/feedback_models.dart';
import 'feedback_preview_controller.dart';

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  return FeedbackRepository(ref.watch(dioProvider));
});

class FeedbackRepository {
  const FeedbackRepository(this._dio);

  static const _mumbaiAirportLatitude = 19.0896;
  static const _mumbaiAirportLongitude = 72.8656;
  static const _previewWashroomPageSize = 100;

  final Dio _dio;

  Future<FeedbackWashroom?> resolveWashroom({
    required List<String> assignedWashroomIds,
  }) async {
    if (assignedWashroomIds.length != 1) return null;
    final washroomId = assignedWashroomIds.single.trim();
    if (washroomId.isEmpty) return null;

    final response = await _dio.get<Map<String, Object?>>(
      '/washrooms/$washroomId',
    );
    return FeedbackWashroom.fromJson(_unwrapData(response.data));
  }

  Future<List<FeedbackWashroom>> fetchPreviewWashrooms({
    required String locationId,
  }) async {
    final washrooms = <FeedbackWashroom>[];
    final loadedIds = <String>{};
    var page = 1;

    while (true) {
      final response = await _dio.get<Map<String, Object?>>(
        '/washrooms',
        queryParameters: {
          'locationId': locationId,
          'page': page,
          'limit': _previewWashroomPageSize,
          'sortBy': 'name',
          'sortOrder': 'asc',
        },
      );
      final pageItems = _unwrapList(response.data)
          .map(FeedbackWashroom.fromJson)
          .where((washroom) => washroom.id.isNotEmpty)
          .toList(growable: false);
      final countBeforePage = washrooms.length;
      for (final washroom in pageItems) {
        if (loadedIds.add(washroom.id)) washrooms.add(washroom);
      }

      final pageAddedNoWashrooms = washrooms.length == countBeforePage;
      if (pageItems.length < _previewWashroomPageSize || pageAddedNoWashrooms) {
        return List.unmodifiable(washrooms);
      }
      page += 1;
    }
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
    final response = await _dio.get<Map<String, Object?>>(
      '/dashboard/feedback-screen/$washroomId',
    );
    final metrics = FeedbackMetrics.fromJson(_unwrapData(response.data));

    final temperature =
        metrics.temperatureCelsius ?? await _fetchLiveTemperatureCelsius();
    return metrics.copyWith(temperatureCelsius: temperature);
  }

  Future<num?> _fetchLiveTemperatureCelsius() async {
    final weatherDio = Dio(
      BaseOptions(
        baseUrl: 'https://api.open-meteo.com/v1',
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
      ),
    );

    try {
      final response = await weatherDio.get<Map<String, Object?>>(
        '/forecast',
        queryParameters: {
          'latitude': _mumbaiAirportLatitude,
          'longitude': _mumbaiAirportLongitude,
          'current': 'temperature_2m',
          'temperature_unit': 'celsius',
        },
      );
      final current = response.data?['current'];
      if (current is! Map) return null;
      return _numOrNull(current['temperature_2m']);
    } on DioException {
      return null;
    }
  }

  num? _numOrNull(Object? value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '');
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
  final previewWashroomId = kDebugMode
      ? ref.watch(feedbackPreviewWashroomIdProvider)
      : null;
  final availableWashrooms = kDebugMode
      ? await repository.fetchPreviewWashrooms(locationId: session.airportId)
      : const <FeedbackWashroom>[];
  final washroom = kDebugMode
      ? _selectPreviewWashroom(
          availableWashrooms: availableWashrooms,
          previewWashroomId: previewWashroomId,
          assignedWashroomIds: session.washroomIds,
        )
      : await repository.resolveWashroom(
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
    availableWashrooms: availableWashrooms,
  );
});

FeedbackWashroom? _selectPreviewWashroom({
  required List<FeedbackWashroom> availableWashrooms,
  required String? previewWashroomId,
  required List<String> assignedWashroomIds,
}) {
  if (availableWashrooms.isEmpty) return null;

  final preferredIds = [?previewWashroomId, ...assignedWashroomIds];
  for (final preferredId in preferredIds) {
    for (final washroom in availableWashrooms) {
      if (washroom.id == preferredId) return washroom;
    }
  }
  return availableWashrooms.first;
}
