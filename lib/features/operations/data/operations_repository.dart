import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/date/date_time.dart';
import '../../../core/network/dio_provider.dart';
import '../../auth/data/session_controller.dart';
import '../../tenant/data/tenant_controller.dart';
import '../domain/ticket_models.dart';

final operationsRepositoryProvider = Provider<OperationsRepository>((ref) {
  return OperationsRepository(ref.watch(dioProvider));
});

final todaysSupervisorTicketsProvider =
    FutureProvider.autoDispose<SupervisorTicketList>((ref) async {
      final session = ref.watch(sessionControllerProvider).session;
      if (session == null) return _emptyTicketList();
      final dateTimeSettings = ref
          .watch(tenantControllerProvider)
          .dateTimeSettings;
      final range = DateRange.todayOperationalWindow(
        dateTimeSettings: dateTimeSettings,
      );
      return ref
          .read(operationsRepositoryProvider)
          .fetchTickets(
            userId: session.userId,
            startTime: range.startIsoUtc,
            endTime: range.endIsoUtc,
          );
    });

final supervisedWashroomsProvider =
    FutureProvider.autoDispose<List<SupervisorWashroom>>((ref) async {
      final session = ref.watch(sessionControllerProvider).session;
      if (session == null || session.washroomIds.isEmpty) return const [];
      return ref
          .read(operationsRepositoryProvider)
          .fetchWashrooms(session.washroomIds);
    });

final supervisedRostersProvider =
    FutureProvider.autoDispose<List<SupervisorRoster>>((ref) async {
      final session = ref.watch(sessionControllerProvider).session;
      if (session == null) return const [];
      final dateTimeSettings = ref
          .watch(tenantControllerProvider)
          .dateTimeSettings;
      final range = DateRange.todayOperationalWindow(
        dateTimeSettings: dateTimeSettings,
      );
      final tenantStart = tenantDateTimeFromUtc(
        value: range.start,
        timeZone: dateTimeSettings.timeZone,
      );
      final tenantEnd = tenantDateTimeFromUtc(
        value: range.end,
        timeZone: dateTimeSettings.timeZone,
      );
      return ref
          .read(operationsRepositoryProvider)
          .fetchSupervisedRosters(
            startDate: _dateKey(tenantStart),
            endDate: _dateKey(tenantEnd),
          );
    });

final ticketDetailProvider = FutureProvider.autoDispose
    .family<SupervisorTicketDetail, String>((ref, ticketId) {
      return ref.read(operationsRepositoryProvider).fetchTicketDetail(ticketId);
    });

final ticketHistoryProvider = FutureProvider.autoDispose
    .family<SupervisorTicketList, TicketHistoryQuery>((ref, query) async {
      final session = ref.watch(sessionControllerProvider).session;
      if (session == null) return _emptyTicketList();
      final range = DateRange.fromDateKeys(query.fromDate, query.toDate);
      return ref
          .read(operationsRepositoryProvider)
          .fetchTickets(
            userId: session.userId,
            startTime: range.startIsoUtc,
            endTime: range.endIsoUtc,
          );
    });

class TicketHistoryQuery {
  const TicketHistoryQuery({required this.fromDate, required this.toDate});

  final String fromDate;
  final String toDate;

  @override
  bool operator ==(Object other) {
    return other is TicketHistoryQuery &&
        other.fromDate == fromDate &&
        other.toDate == toDate;
  }

  @override
  int get hashCode => Object.hash(fromDate, toDate);
}

class OperationsRepository {
  const OperationsRepository(this._dio);

  final Dio _dio;

  Future<SupervisorTicketList> fetchTickets({
    required String userId,
    required String startTime,
    required String endTime,
  }) async {
    final response = await _dio.get<Map<String, Object?>>(
      '/tickets',
      queryParameters: {
        'startDate': startTime,
        'endDate': endTime,
        'page': 1,
        'limit': 100,
      },
    );
    return SupervisorTicketList.fromCanonicalApiResponse(
      response.data ?? <String, Object?>{},
      userId: userId,
    );
  }

  Future<SupervisorTicketDetail> fetchTicketDetail(String ticketId) async {
    final response = await _dio.get<Map<String, Object?>>('/tickets/$ticketId');
    return SupervisorTicketDetail.fromJson(_unwrapData(response.data));
  }

  Future<List<SupervisorWashroom>> fetchWashrooms(List<String> ids) async {
    final results = await Future.wait(
      ids.map((id) async {
        try {
          final response = await _dio.get<Map<String, Object?>>(
            '/washrooms/$id',
          );
          return SupervisorWashroom.fromJson(_unwrapData(response.data));
        } catch (_) {
          return null;
        }
      }),
    );
    return results.whereType<SupervisorWashroom>().toList();
  }

  Future<List<SupervisorRoster>> fetchSupervisedRosters({
    required String startDate,
    required String endDate,
  }) async {
    final response = await _dio.get<Map<String, Object?>>(
      '/rosters/supervised-units',
      queryParameters: {'startDate': startDate, 'endDate': endDate},
    );
    final rows = response.data?['data'];
    if (rows is! List) {
      throw const FormatException(
        'Supervised rosters response must contain a data list.',
      );
    }
    final rosters = <SupervisorRoster>[];
    for (final item in rows) {
      if (item is! Map) {
        throw const FormatException(
          'Supervised rosters response contains an invalid item.',
        );
      }
      rosters.add(SupervisorRoster.fromJson(Map<String, Object?>.from(item)));
    }
    return rosters;
  }

  Future<List<PassengerPeak>> fetchPassengerPeaks({
    required List<String> washroomIds,
    required DateRange range,
  }) async {
    if (washroomIds.isEmpty) return const [];
    final response = await _dio.post<Map<String, Object?>>(
      '/peak_footfall',
      data: {
        'washroomIds': washroomIds,
        'starttime': range.startIsoUtc.replaceFirst('Z', '+00:00'),
        'endtime': range.endIsoUtc.replaceFirst('Z', '+00:00'),
      },
    );
    final rows = response.data?['footfall_data'];
    if (rows is! List) return const [];
    final peaks = <PassengerPeak>[];
    for (final item in rows.whereType<Map>()) {
      final washroomId = item['washroomId']?.toString() ?? '';
      final topHours = item['top_3_peak_hours'];
      if (topHours is! List) continue;
      peaks.addAll(
        topHours.whereType<Map>().map(
          (peak) => PassengerPeak.fromJson(
            washroomId,
            Map<String, Object?>.from(peak),
          ),
        ),
      );
    }
    peaks.sort((a, b) => b.count.compareTo(a.count));
    return peaks.take(3).toList();
  }

  Future<void> acknowledgeTicket(String ticketId) {
    return updateTicket(
      ticketId: ticketId,
      status: SupervisorTicketStatus.acknowledge,
      comment: 'Acknowledged',
      attachments: const [],
    );
  }

  Future<void> updateTicket({
    required String ticketId,
    required SupervisorTicketStatus status,
    required String comment,
    required List<LocalTicketAttachment> attachments,
  }) async {
    if (attachments.isNotEmpty) {
      throw UnsupportedError(
        'Ticket attachments are not supported by the canonical API.',
      );
    }

    await _dio.patch<Map<String, Object?>>(
      '/tickets/$ticketId/status',
      data: {
        'ticketStatus': ticketStatusApiValue(status),
        if (comment.trim().isNotEmpty) 'notes': comment.trim(),
      },
    );
  }

  Map<String, Object?> _unwrapData(Map<String, Object?>? responseData) {
    final raw = responseData ?? <String, Object?>{};
    final data = raw['data'];
    if (data is Map) return Map<String, Object?>.from(data);
    return raw;
  }
}

String _dateKey(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

SupervisorTicketList _emptyTicketList() {
  return const SupervisorTicketList(
    userId: '',
    role: '',
    washroomIds: [],
    tickets: [],
    rosters: [],
  );
}
