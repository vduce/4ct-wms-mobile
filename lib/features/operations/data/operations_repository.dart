import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../auth/data/session_controller.dart';
import '../domain/ticket_models.dart';

final operationsRepositoryProvider = Provider<OperationsRepository>((ref) {
  return OperationsRepository(ref.watch(dioProvider));
});

final todaysSupervisorTicketsProvider =
    FutureProvider.autoDispose<SupervisorTicketList>((ref) async {
      final session = ref.watch(sessionControllerProvider).session;
      if (session == null) return _emptyTicketList();
      final range = DateRange.todayOperationalWindow();
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
      '/list_tickets_feedback',
      queryParameters: {
        'userId': userId,
        'startTime': startTime,
        'endTime': endTime,
      },
    );
    return SupervisorTicketList.fromJson(response.data ?? {});
  }

  Future<SupervisorTicketDetail> fetchTicketDetail(String ticketId) async {
    final response = await _dio.get<Map<String, Object?>>(
      '/get_ticket_by_id',
      queryParameters: {'ticketId': ticketId},
    );
    return SupervisorTicketDetail.fromJson(_unwrapData(response.data));
  }

  Future<List<SupervisorWashroom>> fetchWashrooms(List<String> ids) async {
    final results = await Future.wait(
      ids.map((id) async {
        try {
          final response = await _dio.get<Map<String, Object?>>(
            '/get_washroom',
            queryParameters: {'id': id},
          );
          return SupervisorWashroom.fromJson(_unwrapData(response.data));
        } catch (_) {
          return null;
        }
      }),
    );
    return results.whereType<SupervisorWashroom>().toList();
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
    final response = await _dio.put<Map<String, Object?>>(
      '/update_ticket',
      data: {
        'ticketId': ticketId,
        'status': ticketStatusApiValue(status),
        if (comment.trim().isNotEmpty) 'comment': comment.trim(),
        'attachments': attachments.map((item) => item.name).toList(),
      },
    );
    final urls = _stringList(response.data?['attachment_urls']);
    await _uploadAttachments(attachments, urls);
  }

  Future<void> _uploadAttachments(
    List<LocalTicketAttachment> attachments,
    List<String> urls,
  ) async {
    final uploads = attachments.length < urls.length
        ? attachments.length
        : urls.length;
    final uploadDio = Dio();
    for (var i = 0; i < uploads; i += 1) {
      final file = File(attachments[i].path);
      if (!file.existsSync()) continue;
      await uploadDio.putUri<void>(
        Uri.parse(urls[i]),
        data: file.openRead(),
        options: Options(
          headers: {
            'x-ms-blob-type': 'BlockBlob',
            'Content-Type': attachments[i].mimeType.isEmpty
                ? 'application/octet-stream'
                : attachments[i].mimeType,
          },
        ),
      );
    }
  }

  Map<String, Object?> _unwrapData(Map<String, Object?>? responseData) {
    final raw = responseData ?? <String, Object?>{};
    final data = raw['data'];
    if (data is Map) return Map<String, Object?>.from(data);
    return raw;
  }

  List<String> _stringList(Object? value) {
    if (value is List) return value.map((item) => item.toString()).toList();
    return const [];
  }
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
