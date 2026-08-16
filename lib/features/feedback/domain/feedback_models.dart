import '../../../core/date/date_time.dart';

class FeedbackReason {
  const FeedbackReason({
    required this.id,
    required this.reason,
    required this.isActive,
    required this.reasonType,
    required this.priority,
    this.imageUrl,
  });

  factory FeedbackReason.fromJson(Map<String, Object?> json) {
    return FeedbackReason(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      imageUrl: (json['imageUrl'] ?? json['imagePath'])?.toString(),
      isActive: json['isActive'] as bool? ?? true,
      reasonType: json['reasonType']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
    );
  }

  final String id;
  final String reason;
  final String? imageUrl;
  final bool isActive;
  final String reasonType;
  final String priority;
}

class FeedbackWashroom {
  const FeedbackWashroom({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
  });

  factory FeedbackWashroom.fromJson(Map<String, Object?> json) {
    return FeedbackWashroom(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      name: json['name']?.toString() ?? 'Washroom',
      code: json['code']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }

  final String id;
  final String name;
  final String code;
  final String type;
}

class FeedbackCubicleOccupancy {
  const FeedbackCubicleOccupancy({
    required this.occupied,
    required this.total,
    required this.monitored,
    required this.percentage,
    required this.dataStatus,
  });

  factory FeedbackCubicleOccupancy.fromJson(Map<String, Object?> json) {
    return FeedbackCubicleOccupancy(
      occupied: FeedbackMetrics._int(json['occupied']),
      total: FeedbackMetrics._int(json['total']),
      monitored: FeedbackMetrics._int(json['monitored']),
      percentage: FeedbackMetrics._int(json['percentage']),
      dataStatus: json['dataStatus']?.toString() ?? 'unavailable',
    );
  }

  final int? occupied;
  final int? total;
  final int? monitored;
  final int? percentage;
  final String dataStatus;
}

class FeedbackWashroomOccupancy {
  const FeedbackWashroomOccupancy({
    required this.estimatedCount,
    required this.percentage,
    required this.band,
    required this.capacity,
    required this.displayLimit,
    required this.isCapped,
    required this.dataStatus,
    required this.washroomType,
    required this.urinalCount,
    required this.windowMinutes,
  });

  factory FeedbackWashroomOccupancy.fromJson(Map<String, Object?> json) {
    return FeedbackWashroomOccupancy(
      estimatedCount: FeedbackMetrics._int(json['estimatedCount']),
      percentage: FeedbackMetrics._int(json['percentage']),
      band: json['band']?.toString(),
      capacity: FeedbackMetrics._int(json['capacity']),
      displayLimit: FeedbackMetrics._int(json['displayLimit']),
      isCapped: json['isCapped'] as bool? ?? false,
      dataStatus: json['dataStatus']?.toString() ?? 'unavailable',
      washroomType: json['washroomType']?.toString() ?? '',
      urinalCount: FeedbackMetrics._int(json['urinalCount']) ?? 0,
      windowMinutes: FeedbackMetrics._int(json['windowMinutes']) ?? 15,
    );
  }

  final int? estimatedCount;
  final int? percentage;
  final String? band;
  final int? capacity;
  final int? displayLimit;
  final bool isCapped;
  final String dataStatus;
  final String washroomType;
  final int urinalCount;
  final int windowMinutes;
}

class FeedbackMetrics {
  static const staleAfter = Duration(minutes: 15);

  const FeedbackMetrics({
    this.aqi,
    this.aqiStatus,
    this.occupied,
    this.totalOccupancy,
    this.occupancyStatus,
    this.footfall,
    this.footfallStatus,
    this.odour,
    this.odourStatus,
    this.odourUnit,
    this.temperatureCelsius,
    this.updatedAt,
    this.source,
    this.isDemoData = false,
    this.cubicleOccupancy,
    this.washroomOccupancy,
  });

  factory FeedbackMetrics.empty() => const FeedbackMetrics();

  factory FeedbackMetrics.fromJson(Map<String, Object?> json) {
    final metrics = json['metrics'];
    final legacyDetails = json['details'];
    final details = metrics is Map
        ? Map<String, Object?>.from(metrics)
        : legacyDetails is Map
        ? Map<String, Object?>.from(legacyDetails)
        : json;
    final cubicleOccupancyJson = _map(details['cubicleOccupancy']);
    final washroomOccupancyJson = _map(details['washroomOccupancy']);
    final cubicleOccupancy = cubicleOccupancyJson == null
        ? null
        : FeedbackCubicleOccupancy.fromJson(cubicleOccupancyJson);

    return FeedbackMetrics(
      aqi: _num(details['aqi'] ?? details['aqiValue'] ?? details['aqi_value']),
      aqiStatus: details['aqiStatus']?.toString(),
      occupied:
          cubicleOccupancy?.occupied ??
          _int(details['occupied'] ?? details['occupancy']),
      totalOccupancy: _int(
        cubicleOccupancy?.total ??
            details['totalOccupancy'] ??
            details['total_occupancy'],
      ),
      occupancyStatus: details['occupancyStatus']?.toString(),
      footfall: _int(details['footfall']),
      footfallStatus: details['footfallStatus']?.toString(),
      odour: _num(details['odour'] ?? details['odor']),
      odourStatus: (details['odourStatus'] ?? details['odorStatus'])
          ?.toString(),
      odourUnit: (details['odourUnit'] ?? details['odorUnit'])?.toString(),
      temperatureCelsius: _num(
        details['temperature'] ??
            details['temperature_celsius'] ??
            details['temperatureCelsius'] ??
            details['temp'] ??
            details['temp_c'],
      ),
      updatedAt: parseBackendUtcDate(details['updatedAt'] ?? json['updatedAt']),
      source: (details['source'] ?? json['source'])?.toString(),
      isDemoData:
          (details['isDemoData'] ?? json['isDemoData']) as bool? ?? false,
      cubicleOccupancy: cubicleOccupancy,
      washroomOccupancy: washroomOccupancyJson == null
          ? null
          : FeedbackWashroomOccupancy.fromJson(washroomOccupancyJson),
    );
  }

  final num? aqi;
  final String? aqiStatus;
  final int? occupied;
  final int? totalOccupancy;
  final String? occupancyStatus;
  final int? footfall;
  final String? footfallStatus;
  final num? odour;
  final String? odourStatus;
  final String? odourUnit;
  final num? temperatureCelsius;
  final DateTime? updatedAt;
  final String? source;
  final bool isDemoData;
  final FeedbackCubicleOccupancy? cubicleOccupancy;
  final FeedbackWashroomOccupancy? washroomOccupancy;

  bool isStaleAt(DateTime now) {
    final timestamp = updatedAt;
    if (timestamp == null) return false;
    return now.toUtc().difference(timestamp.toUtc()) > staleAfter;
  }

  String get occupancyLabel {
    if (occupied == null && totalOccupancy == null) return '-';
    return '${occupied ?? 0} / ${totalOccupancy ?? 0}';
  }

  FeedbackMetrics copyWith({
    num? aqi,
    String? aqiStatus,
    int? occupied,
    int? totalOccupancy,
    String? occupancyStatus,
    int? footfall,
    String? footfallStatus,
    num? odour,
    String? odourStatus,
    String? odourUnit,
    num? temperatureCelsius,
    DateTime? updatedAt,
    String? source,
    bool? isDemoData,
    FeedbackCubicleOccupancy? cubicleOccupancy,
    FeedbackWashroomOccupancy? washroomOccupancy,
  }) {
    return FeedbackMetrics(
      aqi: aqi ?? this.aqi,
      aqiStatus: aqiStatus ?? this.aqiStatus,
      occupied: occupied ?? this.occupied,
      totalOccupancy: totalOccupancy ?? this.totalOccupancy,
      occupancyStatus: occupancyStatus ?? this.occupancyStatus,
      footfall: footfall ?? this.footfall,
      footfallStatus: footfallStatus ?? this.footfallStatus,
      odour: odour ?? this.odour,
      odourStatus: odourStatus ?? this.odourStatus,
      odourUnit: odourUnit ?? this.odourUnit,
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
      updatedAt: updatedAt ?? this.updatedAt,
      source: source ?? this.source,
      isDemoData: isDemoData ?? this.isDemoData,
      cubicleOccupancy: cubicleOccupancy ?? this.cubicleOccupancy,
      washroomOccupancy: washroomOccupancy ?? this.washroomOccupancy,
    );
  }

  static Map<String, Object?>? _map(Object? value) {
    return value is Map ? Map<String, Object?>.from(value) : null;
  }

  static num? _num(Object? value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '');
  }

  static int? _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '');
  }
}

class FeedbackDeviceState {
  const FeedbackDeviceState({
    required this.washroom,
    required this.metrics,
    required this.reasons,
  });

  final FeedbackWashroom? washroom;
  final FeedbackMetrics metrics;
  final List<FeedbackReason> reasons;
}
