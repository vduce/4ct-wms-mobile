import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/adani_design_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'notification_models.dart';

final notificationTemplateServiceProvider =
    Provider<NotificationTemplateService>(
      (_) => const NotificationTemplateService(),
    );

/// Turns an [AppNotification] into fully localized, ready-to-render
/// [NotificationPresentation] data.
///
/// This is the single source of truth for "what a notification looks like"
/// so the OneSignal foreground handler, the local notifications list page,
/// and any future local-notification scheduling share identical copy,
/// icon, and color per template - only the delivery channel differs.
///
/// Every string is resolved through [AppLocalizations] so templates are
/// automatically multi-language; add a new template by adding a case here
/// and matching keys in `lib/l10n/app_en.arb` / `app_hi.arb`.
class NotificationTemplateService {
  const NotificationTemplateService();

  NotificationPresentation resolve(
    AppLocalizations l10n,
    AppNotification notification,
  ) {
    final params = notification.params;

    return switch (notification.template) {
      NotificationTemplateType.ticketAssigned => NotificationPresentation(
        title: l10n.notificationTicketAssignedTitle,
        body: l10n.notificationTicketAssignedBody(
          _param(params, 'ticketId'),
          _washroom(params),
        ),
        icon: Icons.assignment_late_rounded,
        color: AdaniColors.blue,
      ),
      NotificationTemplateType.ticketEscalated => NotificationPresentation(
        title: l10n.notificationTicketEscalatedTitle,
        body: l10n.notificationTicketEscalatedBody(
          _param(params, 'ticketId'),
          _param(params, 'washroomId'),
        ),
        icon: Icons.warning_amber_rounded,
        color: AdaniColors.warning,
      ),
      NotificationTemplateType.ticketAcknowledged => NotificationPresentation(
        title: l10n.notificationTicketAcknowledgedTitle,
        body: l10n.notificationTicketAcknowledgedBody(
          _param(params, 'ticketId'),
        ),
        icon: Icons.task_alt_rounded,
        color: AdaniColors.success,
      ),
      NotificationTemplateType.ticketCompleted => NotificationPresentation(
        title: l10n.notificationTicketCompletedTitle,
        body: l10n.notificationTicketCompletedBody(_param(params, 'ticketId')),
        icon: Icons.check_circle_rounded,
        color: AdaniColors.success,
      ),
      NotificationTemplateType.feedbackNegative => NotificationPresentation(
        title: l10n.notificationFeedbackNegativeTitle,
        body: l10n.notificationFeedbackNegativeBody(
          _param(params, 'washroomId'),
        ),
        icon: Icons.sentiment_dissatisfied_rounded,
        color: AdaniColors.error,
      ),
      NotificationTemplateType.shiftReminder => NotificationPresentation(
        title: l10n.notificationShiftReminderTitle,
        body: l10n.notificationShiftReminderBody(_param(params, 'shiftLabel')),
        icon: Icons.schedule_rounded,
        color: AdaniColors.purple,
      ),
      NotificationTemplateType.general => NotificationPresentation(
        title: _fallback(params, 'title', l10n.notificationGeneralTitle),
        body: _fallback(params, 'body', l10n.notificationGeneralBody),
        icon: Icons.notifications_rounded,
        color: AdaniColors.purpleBright,
      ),
    };
  }

  String _param(Map<String, String> params, String key) => params[key] ?? '-';

  String _washroom(Map<String, String> params) {
    final name = params['washroomName'];
    return name == null || name.trim().isEmpty
        ? _param(params, 'washroomId')
        : name;
  }

  String _fallback(Map<String, String> params, String key, String orElse) {
    final value = params[key];
    return (value != null && value.trim().isNotEmpty) ? value : orElse;
  }
}
