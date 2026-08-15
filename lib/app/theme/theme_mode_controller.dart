import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/key_value_store.dart';

final themeModeControllerProvider =
    NotifierProvider<ThemeModeController, ThemeMode?>(ThemeModeController.new);

class ThemeModeController extends Notifier<ThemeMode?> {
  static const _preferredThemeModeKey = 'preferredThemeMode';

  var _hasUserSelectedThemeMode = false;

  @override
  ThemeMode? build() {
    unawaited(_restorePreferredThemeMode());
    return null;
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    _hasUserSelectedThemeMode = true;
    state = themeMode;
    await ref
        .read(keyValueStoreProvider)
        .setString(_preferredThemeModeKey, themeMode.name);
  }

  Future<void> _restorePreferredThemeMode() async {
    final storedThemeMode = await ref
        .read(keyValueStoreProvider)
        .getString(_preferredThemeModeKey);
    final themeMode = switch (storedThemeMode) {
      'system' => ThemeMode.system,
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => null,
    };

    if (_hasUserSelectedThemeMode || themeMode == null) return;
    state = themeMode;
  }
}
