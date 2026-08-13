import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/notification_models.dart';
import 'notification_inbox_repository.dart';

final notificationInboxControllerProvider =
    NotifierProvider<NotificationInboxController, NotificationInboxState>(
      NotificationInboxController.new,
    );

/// In-memory source of truth for the local notifications page. Persisted via
/// [NotificationInboxRepository] so history survives app restarts.
class NotificationInboxController extends Notifier<NotificationInboxState> {
  @override
  NotificationInboxState build() {
    unawaited(_restore());
    return const NotificationInboxState([]);
  }

  Future<void> _restore() async {
    try {
      final items = await ref
          .read(notificationInboxRepositoryProvider)
          .readAll();
      state = NotificationInboxState(items);
    } catch (_) {
      // Storage unavailable (e.g. plugin not registered in tests) or corrupt
      // payload: start with an empty inbox instead of failing the build.
      state = const NotificationInboxState([]);
    }
  }

  Future<void> add(AppNotification notification) async {
    final items = [notification, ...state.items];
    state = NotificationInboxState(items);
    await ref.read(notificationInboxRepositoryProvider).saveAll(items);
  }

  Future<void> markRead(String id) async {
    final items = [
      for (final item in state.items)
        if (item.id == id) item.copyWith(isRead: true) else item,
    ];
    state = NotificationInboxState(items);
    await ref.read(notificationInboxRepositoryProvider).saveAll(items);
  }

  Future<void> markAllRead() async {
    final items = [for (final item in state.items) item.copyWith(isRead: true)];
    state = NotificationInboxState(items);
    await ref.read(notificationInboxRepositoryProvider).saveAll(items);
  }

  Future<void> clear() async {
    state = const NotificationInboxState([]);
    await ref.read(notificationInboxRepositoryProvider).clear();
  }
}

class NotificationInboxState {
  const NotificationInboxState(this.items);

  final List<AppNotification> items;

  int get unreadCount => items.where((item) => !item.isRead).length;
}
