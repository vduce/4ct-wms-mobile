import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations_context.dart';
import '../data/notification_inbox_controller.dart';
import '../domain/notification_models.dart';
import '../domain/notification_template_service.dart';
import 'widgets/notification_list_card.dart';

/// Local notifications inbox. Renders every received push/local notification
/// through [NotificationTemplateService] so copy, icon, and color stay
/// consistent with the native push banners regardless of template.
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final inbox = ref.watch(notificationInboxControllerProvider);
    final templateService = ref.watch(notificationTemplateServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        actions: [
          if (inbox.items.isNotEmpty) ...[
            IconButton(
              tooltip: l10n.markAllReadTooltip,
              onPressed: () => ref
                  .read(notificationInboxControllerProvider.notifier)
                  .markAllRead(),
              icon: const Icon(Icons.done_all_rounded),
            ),
            IconButton(
              tooltip: l10n.clearNotificationsTooltip,
              onPressed: () => ref
                  .read(notificationInboxControllerProvider.notifier)
                  .clear(),
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ],
      ),
      body: inbox.items.isEmpty
          ? _EmptyState(message: l10n.notificationsEmptyMessage)
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: inbox.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notification = inbox.items[index];
                final presentation = templateService.resolve(
                  l10n,
                  notification,
                );
                return NotificationListCard(
                  presentation: presentation,
                  notification: notification,
                  onTap: () => _open(context, ref, notification),
                );
              },
            ),
    );
  }

  void _open(
    BuildContext context,
    WidgetRef ref,
    AppNotification notification,
  ) {
    if (!notification.isRead) {
      ref
          .read(notificationInboxControllerProvider.notifier)
          .markRead(notification.id);
    }
    final deepLink = notification.deepLink;
    if (deepLink != null && deepLink.isNotEmpty) {
      context.go(deepLink);
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
