import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:washroom_ops/app/theme/theme_mode_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('theme mode selection is persisted and restored', () async {
    SharedPreferences.setMockInitialValues({});
    final firstContainer = ProviderContainer();
    addTearDown(firstContainer.dispose);

    await firstContainer
        .read(themeModeControllerProvider.notifier)
        .setThemeMode(ThemeMode.dark);
    expect(firstContainer.read(themeModeControllerProvider), ThemeMode.dark);

    final secondContainer = ProviderContainer();
    addTearDown(secondContainer.dispose);
    secondContainer.read(themeModeControllerProvider);
    await pumpEventQueue();

    expect(secondContainer.read(themeModeControllerProvider), ThemeMode.dark);
  });

  test('system theme mode does not replace tenant default', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(themeModeControllerProvider.notifier)
        .setThemeMode(ThemeMode.system);

    expect(container.read(themeModeControllerProvider), isNull);
  });
}
