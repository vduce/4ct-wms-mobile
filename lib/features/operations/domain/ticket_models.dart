import 'package:intl/intl.dart';

enum SupervisorTicketStatus { pending, acknowledge, escalated, completed }

enum TicketSource { user, system }

enum SupervisorWashroomType { male, female, handicapped, unisex, unknown }

class DateRange {
  const DateRange({required this.start, required this.end});

  factory DateRange.todayOperationalWindow() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day - 1);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    return DateRange(start: start, end: end);
  }

  factory DateRange.fromDateKeys(String fromYmd, String toYmd) {
    final from = _parseDateKey(fromYmd) ?? DateTime.now();
    final to = _parseDateKey(toYmd) ?? from;
    return DateRange(
      start: DateTime(from.year, from.month, from.day),
      end: DateTime(to.year, to.month, to.day, 23, 59, 59, 999),
    );
  }

  final DateTime start;
  final DateTime end;

  String get startIsoUtc => _legacyUtcIso(start);
  String get endIsoUtc => _legacyUtcIso(end);

  static DateTime? _parseDateKey(String value) {
    final parts = value.split('-').map(int.tryParse).toList();
    if (parts.length != 3 || parts.any((item) => item == null)) return null;
    return DateTime(parts[0]!, parts[1]!, parts[2]!);
  }

  static String _legacyUtcIso(DateTime local) {
    return DateTime.fromMillisecondsSinceEpoch(
      local.millisecondsSinceEpoch - local.timeZoneOffset.inMilliseconds,
      isUtc: true,
    ).toIso8601String();
  }
}

class SupervisorTicketList {
  const SupervisorTicketList({
    required this.userId,
    required this.role,
    required this.washroomIds,
    required this.tickets,
    required this.rosters,
  });

  factory SupervisorTicketList.fromJson(Map<String, Object?> json) {
    final rostersBlock = _map(json['rosters']);
    final rosterRows = _list(
      rostersBlock['rosters'],
    ).map(SupervisorRoster.fromJson).toList();
    final typeByWashroom = {
      for (final roster in rosterRows)
        if (roster.washroomId.isNotEmpty)
          roster.washroomId: roster.washroomType,
    };
    final nameByWashroom = {
      for (final roster in rosterRows)
        if (roster.washroomId.isNotEmpty && roster.washroomName.isNotEmpty)
          roster.washroomId: roster.washroomName,
    };

    return SupervisorTicketList(
      userId: _string(json['userId']),
      role: _string(json['role']),
      washroomIds: _stringList(json['washroomIds']),
      tickets: _list(json['tickets'])
          .map(
            (item) => SupervisorTicket.fromJson(
              item,
              washroomName: nameByWashroom[_string(item['washroomId'])],
              washroomType: typeByWashroom[_string(item['washroomId'])],
            ),
          )
          .toList(),
      rosters: rosterRows,
    );
  }

  final String userId;
  final String role;
  final List<String> washroomIds;
  final List<SupervisorTicket> tickets;
  final List<SupervisorRoster> rosters;

  Map<SupervisorTicketStatus, int> get counts {
    final result = {
      SupervisorTicketStatus.pending: 0,
      SupervisorTicketStatus.acknowledge: 0,
      SupervisorTicketStatus.escalated: 0,
      SupervisorTicketStatus.completed: 0,
    };
    for (final ticket in tickets) {
      result[ticket.status] = (result[ticket.status] ?? 0) + 1;
    }
    return result;
  }

  String get shiftLabel {
    final latest = rosters
        .where((roster) => roster.shiftStart != null && roster.shiftEnd != null)
        .fold<SupervisorRoster?>(null, (current, roster) {
          if (current == null) return roster;
          return roster.shiftEnd!.isAfter(current.shiftEnd!) ? roster : current;
        });
    if (latest?.shiftStart == null || latest?.shiftEnd == null) return '-';
    final time = DateFormat.jm();
    return '${time.format(latest!.shiftStart!)} - ${time.format(latest.shiftEnd!)}';
  }

  int get uniqueJanitors {
    final ids = rosters
        .map((item) => item.janitorId)
        .where((id) => id.isNotEmpty);
    return ids.toSet().length;
  }
}

class SupervisorTicket {
  const SupervisorTicket({
    required this.id,
    required this.washroomId,
    required this.zoneId,
    required this.status,
    required this.category,
    required this.priority,
    required this.description,
    required this.createdAt,
    required this.tenantId,
    required this.airportId,
    required this.userId,
    required this.ticketType,
    required this.assignedUserRole,
    required this.logs,
    this.washroomName,
    this.washroomType = SupervisorWashroomType.unknown,
  });

  factory SupervisorTicket.fromJson(
    Map<String, Object?> json, {
    String? washroomName,
    SupervisorWashroomType? washroomType,
  }) {
    final explicitName = _string(json['washroomName']);
    final resolvedName = explicitName.isNotEmpty ? explicitName : washroomName;
    return SupervisorTicket(
      id: _string(json['ticketId'] ?? json['id'] ?? json['_id']),
      washroomId: _string(json['washroomId']),
      zoneId: _string(json['zoneId']),
      status: normalizeTicketStatus(
        _string(json['status'] ?? json['ticketStatus']),
      ),
      category: _string(
        json['category'] ?? json['reasonType'] ?? json['ticketType'],
      ),
      priority: _string(json['priority']).isEmpty
          ? 'Medium'
          : _string(json['priority']),
      description: _string(json['description'] ?? json['ticket']),
      createdAt: parseBackendDate(json['createdAt']) ?? DateTime.now(),
      tenantId: _string(json['tenantId']),
      airportId: _string(json['airportId'] ?? json['locationId']),
      userId: _string(json['userId']),
      ticketType: _string(json['ticketType']),
      assignedUserRole: _string(
        json['assigned_user_role'] ?? json['assignedUserRole'],
      ),
      logs: _list(
        json['status_log'] ?? json['ticketLog'],
      ).map(SupervisorTicketLog.fromJson).toList(),
      washroomName: resolvedName,
      washroomType:
          washroomType ??
          parseWashroomType(
            _string(
              json['washroomType'] ?? json['washroomGender'] ?? resolvedName,
            ),
          ),
    );
  }

  final String id;
  final String washroomId;
  final String zoneId;
  final SupervisorTicketStatus status;
  final String category;
  final String priority;
  final String description;
  final DateTime createdAt;
  final String tenantId;
  final String airportId;
  final String userId;
  final String ticketType;
  final String assignedUserRole;
  final List<SupervisorTicketLog> logs;
  final String? washroomName;
  final SupervisorWashroomType washroomType;

  bool get isSystemGenerated {
    final source = normalizeLoose(ticketType.isEmpty ? category : ticketType);
    if (source == 'system_generated') return true;
    if (userId.isEmpty) return true;
    return logs.any((log) => log.hasDeviceHints);
  }

  bool get isLocked =>
      isSystemGenerated || status == SupervisorTicketStatus.completed;

  TicketSource get source =>
      isSystemGenerated ? TicketSource.system : TicketSource.user;

  String get shortId {
    if (id.isEmpty) return '';
    final start = id.length > 4 ? id.length - 4 : 0;
    return 'ID-${id.substring(start).toUpperCase()}';
  }

  String get washroomLabel {
    final name = washroomName?.trim();
    if (name != null && name.isNotEmpty) return name;
    if (washroomId.isEmpty) return 'Washroom';
    return 'Washroom ${washroomId.substring(washroomId.length > 2 ? washroomId.length - 2 : 0)}';
  }
}

class SupervisorTicketDetail {
  const SupervisorTicketDetail({
    required this.id,
    required this.ticketNumber,
    required this.washroomId,
    required this.washroomName,
    required this.locationName,
    required this.category,
    required this.priority,
    required this.issue,
    required this.status,
    required this.createdAt,
    required this.assignedTo,
    required this.ticketType,
    required this.logs,
  });

  factory SupervisorTicketDetail.fromJson(Map<String, Object?> json) {
    final logs =
        _list(
            json['ticketLog'] ?? json['status_log'],
          ).map(SupervisorTicketLog.fromJson).toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final assignedRole = _string(
      json['assigned_user_role'] ?? json['assignedUserRole'],
    );
    final latest = logs.isEmpty ? null : logs.first;
    var assignedTo = '';
    if (normalizeLoose(assignedRole) == 'shift_incharge') {
      assignedTo = latest?.shiftInchargeName ?? '';
    } else if (normalizeLoose(assignedRole) == 'admin') {
      assignedTo = latest?.adminName ?? '';
    } else {
      assignedTo = latest?.zoneLeadName ?? '';
    }

    return SupervisorTicketDetail(
      id: _string(json['ticketId'] ?? json['id'] ?? json['_id']),
      ticketNumber: _string(json['ticketNumber']),
      washroomId: _string(json['washroomId']),
      washroomName: _string(json['washroomName']),
      locationName: _string(json['zoneName'] ?? json['locationName']),
      category: _string(
        json['reasonType'] ?? json['category'] ?? json['ticketType'],
      ),
      priority: _string(json['priority']).isEmpty
          ? 'Medium'
          : _string(json['priority']),
      issue: _string(
        json['ticket'] ?? json['description'] ?? json['reasonType'],
      ),
      status: normalizeTicketStatus(
        _string(json['ticketStatus'] ?? json['status']),
      ),
      createdAt: parseBackendDate(json['createdAt']) ?? DateTime.now(),
      assignedTo: assignedTo,
      ticketType: _string(json['ticketType']),
      logs: logs,
    );
  }

  final String id;
  final String ticketNumber;
  final String washroomId;
  final String washroomName;
  final String locationName;
  final String category;
  final String priority;
  final String issue;
  final SupervisorTicketStatus status;
  final DateTime createdAt;
  final String assignedTo;
  final String ticketType;
  final List<SupervisorTicketLog> logs;

  bool get isSystemGenerated =>
      normalizeLoose(ticketType) == 'system_generated';

  bool get isLocked =>
      isSystemGenerated || status == SupervisorTicketStatus.completed;

  List<SupervisorTicketAttachment> get attachments {
    return logs.expand((log) => log.attachments).toList();
  }
}

class SupervisorTicketLog {
  const SupervisorTicketLog({
    required this.status,
    required this.timestamp,
    required this.comment,
    required this.zoneLeadName,
    required this.shiftInchargeName,
    required this.adminName,
    required this.attachments,
    required this.hasDeviceHints,
  });

  factory SupervisorTicketLog.fromJson(Map<String, Object?> json) {
    final names = _stringList(json['attachments']);
    final urls = _stringList(
      json['attachments_urls'] ?? json['attachmentUrls'],
    );
    final attachments = <SupervisorTicketAttachment>[
      for (var i = 0; i < names.length; i += 1)
        SupervisorTicketAttachment(
          name: names[i].split('/').last,
          url: i < urls.length ? urls[i] : '',
        ),
    ];

    return SupervisorTicketLog(
      status: _string(json['ticket_log'] ?? json['status']),
      timestamp:
          parseBackendDate(json['timestamp'] ?? json['changedAt']) ??
          DateTime.now(),
      comment: _string(json['comment'] ?? json['notes']),
      zoneLeadName: _string(json['zone_lead_Name']).isEmpty
          ? 'Zone Lead'
          : _string(json['zone_lead_Name']),
      shiftInchargeName: _string(json['shift_incharge_Name']).isEmpty
          ? 'Shift Incharge'
          : _string(json['shift_incharge_Name']),
      adminName: _string(json['admin_Name']).isEmpty
          ? 'Admin'
          : _string(json['admin_Name']),
      attachments: attachments,
      hasDeviceHints:
          _string(json['deviceId']).isNotEmpty ||
          _string(json['deviceType']).isNotEmpty ||
          _stringList(json['conditions']).isNotEmpty,
    );
  }

  final String status;
  final DateTime timestamp;
  final String comment;
  final String zoneLeadName;
  final String shiftInchargeName;
  final String adminName;
  final List<SupervisorTicketAttachment> attachments;
  final bool hasDeviceHints;
}

class SupervisorTicketAttachment {
  const SupervisorTicketAttachment({required this.name, required this.url});

  final String name;
  final String url;
}

class SupervisorRoster {
  const SupervisorRoster({
    required this.id,
    required this.date,
    required this.shift,
    required this.washroomId,
    required this.washroomName,
    required this.washroomType,
    required this.janitorId,
    required this.janitorName,
    this.shiftStart,
    this.shiftEnd,
  });

  factory SupervisorRoster.fromJson(Map<String, Object?> json) {
    return SupervisorRoster(
      id: _string(json['rosterId'] ?? json['id'] ?? json['_id']),
      date: _string(json['date']),
      shift: _string(json['shift']),
      shiftStart: parseBackendDate(json['shiftStart']),
      shiftEnd: parseBackendDate(json['shiftEnd']),
      washroomId: _string(json['washroomId']),
      washroomName: _string(json['washroomName']),
      washroomType: parseWashroomType(_string(json['washroomType'])),
      janitorId: _string(json['janitorId']),
      janitorName: _string(json['janitorName']).isEmpty
          ? 'Janitor'
          : _string(json['janitorName']),
    );
  }

  final String id;
  final String date;
  final String shift;
  final DateTime? shiftStart;
  final DateTime? shiftEnd;
  final String washroomId;
  final String washroomName;
  final SupervisorWashroomType washroomType;
  final String janitorId;
  final String janitorName;
}

class SupervisorWashroom {
  const SupervisorWashroom({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    required this.cubicleCount,
  });

  factory SupervisorWashroom.fromJson(Map<String, Object?> json) {
    return SupervisorWashroom(
      id: _string(json['id'] ?? json['_id']),
      name: _string(json['name']).isEmpty ? 'Washroom' : _string(json['name']),
      code: _string(json['code']),
      type: parseWashroomType(_string(json['type'])),
      cubicleCount: _list(json['cubicles']).length,
    );
  }

  final String id;
  final String name;
  final String code;
  final SupervisorWashroomType type;
  final int cubicleCount;
}

class PassengerPeak {
  const PassengerPeak({
    required this.washroomId,
    required this.hour,
    required this.count,
    required this.hourRange,
  });

  factory PassengerPeak.fromJson(String washroomId, Map<String, Object?> json) {
    return PassengerPeak(
      washroomId: washroomId,
      hour: _string(json['hour']),
      count: _int(json['count']),
      hourRange: _string(json['hour_range']),
    );
  }

  final String washroomId;
  final String hour;
  final int count;
  final String hourRange;
}

class LocalTicketAttachment {
  const LocalTicketAttachment({
    required this.name,
    required this.path,
    required this.mimeType,
    required this.sizeBytes,
  });

  final String name;
  final String path;
  final String mimeType;
  final int sizeBytes;
}

SupervisorTicketStatus normalizeTicketStatus(String raw) {
  final value = normalizeLoose(raw);
  return switch (value) {
    'pending' => SupervisorTicketStatus.pending,
    'acknowledge' || 'acknowledged' => SupervisorTicketStatus.acknowledge,
    'escalated' ||
    'escalate' ||
    'on_escalation' => SupervisorTicketStatus.escalated,
    'approval' ||
    'approved' ||
    'completed' ||
    'complete' ||
    'closed' ||
    'resolved' => SupervisorTicketStatus.completed,
    _ => SupervisorTicketStatus.pending,
  };
}

String ticketStatusApiValue(SupervisorTicketStatus status) {
  return switch (status) {
    SupervisorTicketStatus.pending => 'Pending',
    SupervisorTicketStatus.acknowledge => 'Acknowledge',
    SupervisorTicketStatus.escalated => 'Escalated',
    SupervisorTicketStatus.completed => 'Completed',
  };
}

String normalizeLoose(String raw) {
  return raw.trim().toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
}

SupervisorWashroomType parseWashroomType(String raw) {
  final value = normalizeLoose(raw);
  if (value.contains('female') ||
      value.contains('ladies') ||
      value.contains('women')) {
    return SupervisorWashroomType.female;
  }
  if (value.contains('handicapped') ||
      value.contains('accessible') ||
      value.contains('divyang') ||
      value == 'pwd') {
    return SupervisorWashroomType.handicapped;
  }
  if (value.contains('unisex') || value.contains('family')) {
    return SupervisorWashroomType.unisex;
  }
  if (value == 'male' || value.contains('gents') || value.contains('men')) {
    return SupervisorWashroomType.male;
  }
  return SupervisorWashroomType.unknown;
}

DateTime? parseBackendDate(Object? value) {
  final raw = _string(value);
  if (raw.isEmpty) return null;
  final normalized = raw.contains(' ') ? raw.replaceFirst(' ', 'T') : raw;
  return DateTime.tryParse(normalized);
}

String dateKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

String _string(Object? value) => value?.toString().trim() ?? '';

int _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(_string(value)) ?? 0;
}

Map<String, Object?> _map(Object? value) {
  if (value is Map) return Map<String, Object?>.from(value);
  return <String, Object?>{};
}

List<Map<String, Object?>> _list(Object? value) {
  if (value is List) {
    return value
        .whereType<Map>()
        .map((item) => Map<String, Object?>.from(item))
        .toList();
  }
  return const [];
}

List<String> _stringList(Object? value) {
  if (value is List) {
    return value
        .map((item) => item.toString())
        .where((item) => item.isNotEmpty)
        .toList();
  }
  final string = _string(value);
  if (string.isEmpty) return const [];
  return string
      .split(RegExp(r'[\s,]+'))
      .where((item) => item.isNotEmpty)
      .toList();
}
