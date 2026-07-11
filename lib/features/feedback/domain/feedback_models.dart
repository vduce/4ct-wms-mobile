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
    this.occupied,
    this.totalOccupancy,
    this.footfall,
    this.odour,
    this.updatedAt,
  });

  factory FeedbackMetrics.empty() => const FeedbackMetrics();

  factory FeedbackMetrics.fromJson(Map<String, Object?> json) {
    final details = json['details'] is Map
        ? Map<String, Object?>.from(json['details']! as Map)
        : json;

    return FeedbackMetrics(
      aqi: _num(details['aqi_value']),
      occupied: _int(details['occupancy']),
      totalOccupancy: _int(details['total_occupancy']),
      footfall: _int(details['people']),
      odour: _num(details['odour']),
      updatedAt: DateTime.tryParse(details['updatedAt']?.toString() ?? ''),
    );
  }

  final num? aqi;
  final int? occupied;
  final int? totalOccupancy;
  final int? footfall;
  final num? odour;
  final DateTime? updatedAt;

  String get occupancyLabel {
    if (occupied == null && totalOccupancy == null) return '-';
    return '${occupied ?? 0} / ${totalOccupancy ?? 0}';
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
