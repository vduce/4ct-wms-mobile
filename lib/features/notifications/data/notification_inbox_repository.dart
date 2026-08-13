import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/key_value_store.dart';
import '../../../core/storage/session_keys.dart';
import '../domain/notification_models.dart';

final notificationInboxRepositoryProvider =
    Provider<NotificationInboxRepository>((ref) {
      return NotificationInboxRepository(ref.watch(keyValueStoreProvider));
    });

/// Persists the in-app notification inbox (non-secret cached data) using
/// `shared_preferences`, so the local notifications page keeps history
/// across app restarts without needing a backend list endpoint.
class NotificationInboxRepository {
  const NotificationInboxRepository(this._store);

  static const int maxStored = 100;

  final KeyValueStore _store;

  Future<List<AppNotification>> readAll() async {
    final raw = await _store.getString(SessionKeys.notificationInbox);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded
          .map((item) => AppNotification.fromJson(item as Map<String, Object?>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveAll(List<AppNotification> notifications) async {
    final trimmed = notifications.length > maxStored
        ? notifications.sublist(0, maxStored)
        : notifications;
    try {
      await _store.setString(
        SessionKeys.notificationInbox,
        jsonEncode(trimmed.map((item) => item.toJson()).toList()),
      );
    } catch (_) {
      // Persistence is best-effort; the in-memory state stays authoritative.
    }
  }

  Future<void> clear() async {
    try {
      await _store.remove(SessionKeys.notificationInbox);
    } catch (_) {
      // Ignore storage failures when clearing.
    }
  }
}
