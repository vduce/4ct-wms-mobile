import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/key_value_store.dart';

final localeControllerProvider = NotifierProvider<LocaleController, Locale?>(
  LocaleController.new,
);

class LocaleController extends Notifier<Locale?> {
  static const _preferredLocaleKey = 'preferredLocale';
  static const supportedLanguageCodes = {'en', 'hi'};

  var _hasUserSelectedLocale = false;

  @override
  Locale? build() {
    unawaited(_restorePreferredLocale());
    return null;
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedLanguageCodes.contains(locale.languageCode)) return;

    _hasUserSelectedLocale = true;
    state = Locale(locale.languageCode);
    await ref
        .read(keyValueStoreProvider)
        .setString(_preferredLocaleKey, locale.languageCode);
  }

  Future<void> _restorePreferredLocale() async {
    final languageCode = await ref
        .read(keyValueStoreProvider)
        .getString(_preferredLocaleKey);
    if (_hasUserSelectedLocale ||
        languageCode == null ||
        !supportedLanguageCodes.contains(languageCode)) {
      return;
    }

    state = Locale(languageCode);
  }
}
