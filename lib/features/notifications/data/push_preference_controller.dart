import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/key_value_store.dart';

final pushPreferenceControllerProvider =
    NotifierProvider<PushPreferenceController, bool>(
      PushPreferenceController.new,
    );

/// Device-level push notification preference, persisted in shared_preferences.
///
/// Defaults to enabled. The feedback-device (kiosk) role is force-disabled
/// separately in `OneSignalService` regardless of this value, so passenger
/// tablets can never receive push even if this flag is `true`.
class PushPreferenceController extends Notifier<bool> {
  static const _pushEnabledKey = 'pushNotificationsEnabled';

  var _hasUserSelected = false;

  @override
  bool build() {
    unawaited(_restore());
    return true;
  }

  Future<void> setEnabled(bool enabled) async {
    _hasUserSelected = true;
    state = enabled;
    await ref
        .read(keyValueStoreProvider)
        .setString(_pushEnabledKey, enabled ? 'true' : 'false');
  }

  Future<void> _restore() async {
    final stored = await ref
        .read(keyValueStoreProvider)
        .getString(_pushEnabledKey);
    if (_hasUserSelected || stored == null) return;
    state = stored == 'true';
  }
}
