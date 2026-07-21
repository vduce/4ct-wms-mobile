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

class FeedbackMetrics {
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
  });

  factory FeedbackMetrics.empty() => const FeedbackMetrics();

  factory FeedbackMetrics.fromJson(Map<String, Object?> json) {
    final details = json['details'] is Map
        ? Map<String, Object?>.from(json['details']! as Map)
        : json;

    return FeedbackMetrics(
      aqi: _num(details['aqiValue'] ?? details['aqi_value']),
      aqiStatus: details['aqiStatus']?.toString(),
      occupied: _int(details['occupied'] ?? details['occupancy']),
      totalOccupancy: _int(
        details['totalOccupancy'] ?? details['total_occupancy'],
      ),
      occupancyStatus: details['occupancyStatus']?.toString(),
      footfall: _int(details['footfall'] ?? details['people']),
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
      updatedAt: DateTime.tryParse(details['updatedAt']?.toString() ?? ''),
      source: details['source']?.toString(),
      isDemoData: details['isDemoData'] as bool? ?? false,
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
    );
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
