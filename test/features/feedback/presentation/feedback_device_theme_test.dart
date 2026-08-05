import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:washroom_ops/app/localization/locale_controller.dart';
import 'package:washroom_ops/app/theme/app_theme.dart';
import 'package:washroom_ops/app/theme/theme_mode_controller.dart';
import 'package:washroom_ops/features/feedback/data/feedback_repository.dart';
import 'package:washroom_ops/features/feedback/domain/feedback_models.dart';
import 'package:washroom_ops/features/feedback/presentation/feedback_device_page.dart';
import 'package:washroom_ops/features/tenant/domain/tenant_models.dart';
import 'package:washroom_ops/l10n/generated/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('theme switch stays visible and toggles at narrow mobile width', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const _ThemeSwitchHarness(viewportSize: Size(320, 640)),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
    expect(
      tester.getSize(find.widgetWithIcon(IconButton, Icons.dark_mode_rounded)),
      const Size.square(40),
    );
    expect(
      tester.getSize(
        find.byKey(const ValueKey('feedback-theme-toggle-visual')),
      ),
      const Size.square(36),
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.dark_mode_rounded));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'theme switch stays visible without overflow on landscape tablet',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.binding.setSurfaceSize(const Size(1180, 820));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const _ThemeSwitchHarness(viewportSize: Size(1180, 820)),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('selected Hindi shows full label on narrow mobile', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const _ThemeSwitchHarness(viewportSize: Size(320, 640)),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(FeedbackDevicePage)),
    );
    await container
        .read(localeControllerProvider.notifier)
        .setLocale(const Locale('hi'));
    await tester.pump();

    expect(find.text('हिन्दी'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('custom language and theme reset after 30 seconds idle', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1180, 820));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const _ThemeSwitchHarness(viewportSize: Size(1180, 820)),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(FeedbackDevicePage)),
    );
    await container
        .read(localeControllerProvider.notifier)
        .setLocale(const Locale('hi'));
    await container
        .read(themeModeControllerProvider.notifier)
        .setThemeMode(ThemeMode.light);
    await tester.pump();

    await tester.pump(const Duration(seconds: 29));
    expect(container.read(localeControllerProvider)?.languageCode, 'hi');
    expect(container.read(themeModeControllerProvider), ThemeMode.light);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(container.read(localeControllerProvider)?.languageCode, 'en');
    expect(container.read(themeModeControllerProvider), ThemeMode.dark);
  });

  testWidgets('passenger activity restarts preference reset countdown', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1180, 820));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const _ThemeSwitchHarness(viewportSize: Size(1180, 820)),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(FeedbackDevicePage)),
    );
    await container
        .read(localeControllerProvider.notifier)
        .setLocale(const Locale('hi'));
    await container
        .read(themeModeControllerProvider.notifier)
        .setThemeMode(ThemeMode.light);
    await tester.pump();

    await tester.pump(const Duration(seconds: 20));
    await tester.tapAt(const Offset(20, 300));
    await tester.pump();
    await tester.pump(const Duration(seconds: 20));

    expect(container.read(localeControllerProvider)?.languageCode, 'hi');
    expect(container.read(themeModeControllerProvider), ThemeMode.light);

    await tester.pump(const Duration(seconds: 10));
    await tester.pump();
    expect(container.read(localeControllerProvider)?.languageCode, 'en');
    expect(container.read(themeModeControllerProvider), ThemeMode.dark);
  });
}

class _ThemeSwitchHarness extends StatelessWidget {
  const _ThemeSwitchHarness({required this.viewportSize});

  final Size viewportSize;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        feedbackDeviceStateProvider.overrideWith(
          (_) async => FeedbackDeviceState(
            washroom: null,
            metrics: FeedbackMetrics.empty(),
            reasons: const [],
          ),
        ),
      ],
      child: _TestApp(viewportSize: viewportSize),
    );
  }
}

class _TestApp extends ConsumerWidget {
  const _TestApp({required this.viewportSize});

  final Size viewportSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branding = TenantBranding.default4ct();
    return MaterialApp(
      theme: AppTheme.light(branding),
      darkTheme: AppTheme.dark(branding),
      themeMode: ref.watch(themeModeControllerProvider) ?? ThemeMode.light,
      locale: ref.watch(localeControllerProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(size: viewportSize),
        child: const FeedbackDevicePage(),
      ),
    );
  }
}
