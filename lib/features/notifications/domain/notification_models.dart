import 'package:flutter/material.dart';

/// Known notification template keys.
///
/// Backends may send any string in the `template` field of the push
/// payload. Unknown/unmapped values fall back to [general] so the UI
/// always renders something sensible instead of crashing or showing a
/// blank card. New templates only need an entry in [NotificationTemplateType]
/// and in `NotificationTemplateService`/the ARB files - no widget changes.
enum NotificationTemplateType {
  ticketAssigned,
  ticketEscalated,
  ticketAcknowledged,
  ticketCompleted,
  feedbackNegative,
  shiftReminder,
  general;

  static NotificationTemplateType fromKey(String? key) {
    final normalized = (key ?? '').trim().toLowerCase().replaceAll(
      RegExp(r'[\s-]+'),
      '_',
    );
    return NotificationTemplateType.values.firstWhere(
      (item) => item.name.toLowerCase() == normalized,
      orElse: () => NotificationTemplateType.general,
    );
  }
}

/// A single push/local notification normalized into a shape the app can
/// render, persist, and act on regardless of the originating channel
/// (OneSignal push, in-app banner, or a future local notification).
@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    required this.template,
    required this.receivedAt,
    this.params = const {},
    this.deepLink,
    this.isRead = false,
  });

  factory AppNotification.fromOneSignalPayload(
    Map<String, Object?> additionalData, {
    required String id,
    String? fallbackTitle,
    String? fallbackBody,
  }) {
    final params = <String, String>{
      for (final entry in additionalData.entries)
        entry.key: entry.value?.toString() ?? '',
    };
    if (fallbackTitle != null && fallbackTitle.isNotEmpty) {
      params.putIfAbsent('title', () => fallbackTitle);
    }
    if (fallbackBody != null && fallbackBody.isNotEmpty) {
      params.putIfAbsent('body', () => fallbackBody);
    }

    return AppNotification(
      id: id,
      template: NotificationTemplateType.fromKey(
        additionalData['template']?.toString(),
      ),
      receivedAt: DateTime.now(),
      params: params,
      deepLink: additionalData['deepLink']?.toString(),
    );
  }

  factory AppNotification.fromJson(Map<String, Object?> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      template: NotificationTemplateType.fromKey(json['template']?.toString()),
      receivedAt:
          DateTime.tryParse(json['receivedAt']?.toString() ?? '') ??
          DateTime.now(),
      params: Map<String, String>.from(json['params'] as Map? ?? {}),
      deepLink: json['deepLink']?.toString(),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  final String id;
  final NotificationTemplateType template;
  final DateTime receivedAt;
  final Map<String, String> params;
  final String? deepLink;
  final bool isRead;

  Map<String, Object?> toJson() => {
    'id': id,
    'template': template.name,
    'receivedAt': receivedAt.toIso8601String(),
    'params': params,
    'deepLink': deepLink,
    'isRead': isRead,
  };

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      template: template,
      receivedAt: receivedAt,
      params: params,
      deepLink: deepLink,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// Fully resolved, localized presentation data for an [AppNotification].
/// Produced by `NotificationTemplateService` so every surface (push
/// foreground banner, local notification list, future local notifications)
/// renders identical copy, icon, and color for the same template.
@immutable
class NotificationPresentation {
  const NotificationPresentation({
    required this.title,
    required this.body,
    required this.icon,
    required this.color,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color color;
}
