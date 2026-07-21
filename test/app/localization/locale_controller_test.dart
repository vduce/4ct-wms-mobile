import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:washroom_ops/app/localization/locale_controller.dart';
import 'package:washroom_ops/l10n/generated/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('generated localizations include English and Hindi', () async {
    expect(
      AppLocalizations.supportedLocales,
      containsAll(const [Locale('en'), Locale('hi')]),
    );

    final hindi = await AppLocalizations.delegate.load(const Locale('hi'));
    expect(hindi.appTitle, 'स्मार्ट शौचालय प्रबंधन');
    expect(hindi.homeGreeting('आरव'), 'नमस्ते आरव');
  });

  test('locale selection is persisted and restored', () async {
    SharedPreferences.setMockInitialValues({});
    final firstContainer = ProviderContainer();
    addTearDown(firstContainer.dispose);

    await firstContainer
        .read(localeControllerProvider.notifier)
        .setLocale(const Locale('hi'));
    expect(firstContainer.read(localeControllerProvider), const Locale('hi'));

    final secondContainer = ProviderContainer();
    addTearDown(secondContainer.dispose);
    secondContainer.read(localeControllerProvider);
    await pumpEventQueue();

    expect(secondContainer.read(localeControllerProvider), const Locale('hi'));
  });

  test('unsupported locale is ignored', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(localeControllerProvider.notifier)
        .setLocale(const Locale('fr'));

    expect(container.read(localeControllerProvider), isNull);
  });
}
