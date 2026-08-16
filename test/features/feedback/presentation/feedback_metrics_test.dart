import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:washroom_ops/features/feedback/domain/feedback_models.dart';
import 'package:washroom_ops/features/feedback/presentation/widgets/feedback_metrics.dart';
import 'package:washroom_ops/features/feedback/presentation/widgets/feedback_screensaver_panel.dart';
import 'package:washroom_ops/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('shows stale values and truthful unavailable metric state', (
    tester,
  ) async {
    final metrics = FeedbackMetrics(
      aqi: 18,
      occupied: 0,
      totalOccupancy: 15,
      odour: 0.18,
      updatedAt: DateTime.utc(2026, 8, 11, 18, 41),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              final items = buildFeedbackScreensaverMetrics(context, metrics);
              return ListView(
                children: [
                  for (final item in items)
                    FeedbackMetricStatusCard(
                      item: item,
                      compact: false,
                      horizontal: true,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('18'), findsOneWidget);
    expect(find.text('0 of 15 occupied'), findsOneWidget);
    expect(find.text('0.18'), findsOneWidget);
    expect(find.text('Stale data'), findsNWidgets(3));
    expect(find.text('Unavailable'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows occupancy band and percentage without estimated count', (
    tester,
  ) async {
    final metrics = FeedbackMetrics(
      aqi: 18,
      occupied: 3,
      totalOccupancy: 4,
      cubicleOccupancy: const FeedbackCubicleOccupancy(
        occupied: 3,
        total: 4,
        monitored: 4,
        percentage: 75,
        dataStatus: 'live',
      ),
      washroomOccupancy: const FeedbackWashroomOccupancy(
        estimatedCount: 9,
        percentage: 58,
        band: 'moderate',
        capacity: 16,
        displayLimit: 20,
        isCapped: false,
        dataStatus: 'live',
        washroomType: 'female',
        urinalCount: 0,
        windowMinutes: 15,
      ),
      updatedAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              final items = buildFeedbackScreensaverMetrics(context, metrics);
              return ListView(
                children: [
                  for (final item in items)
                    FeedbackMetricStatusCard(
                      item: item,
                      compact: false,
                      horizontal: true,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Washroom Occupancy'), findsOneWidget);
    expect(find.text('Moderate'), findsOneWidget);
    expect(find.text('58% occupied'), findsOneWidget);
    expect(find.text('3 of 4 occupied'), findsOneWidget);
    expect(find.text('Footfall'), findsNothing);
    expect(find.text('9'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('uses backend-aligned fifteen-minute stale threshold', () {
    final updatedAt = DateTime.utc(2026, 8, 15, 12);
    final metrics = FeedbackMetrics(updatedAt: updatedAt);

    expect(
      metrics.isStaleAt(updatedAt.add(const Duration(minutes: 15))),
      isFalse,
    );
    expect(
      metrics.isStaleAt(
        updatedAt.add(const Duration(minutes: 15, milliseconds: 1)),
      ),
      isTrue,
    );
  });

  for (final viewport in <String, Size>{
    'narrow mobile': const Size(360, 640),
    'constrained tablet': const Size(1024, 600),
  }.entries) {
    testWidgets('occupancy cards fit ${viewport.key}', (tester) async {
      tester.view.physicalSize = viewport.value;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: viewport.key == 'constrained tablet'
                ? ThemeMode.dark
                : ThemeMode.light,
            builder: (context, child) {
              final mediaQuery = MediaQuery.of(context);
              return MediaQuery(
                data: mediaQuery.copyWith(
                  disableAnimations: true,
                  textScaler: TextScaler.linear(
                    viewport.key == 'constrained tablet' ? 1.2 : 1,
                  ),
                ),
                child: child!,
              );
            },
            home: Scaffold(
              body: FeedbackScreensaverPanel(
                brandingName: 'Airport',
                videoUrl: '',
                metrics: FeedbackMetrics(
                  aqi: 52,
                  odour: 0.18,
                  occupied: 3,
                  totalOccupancy: 4,
                  cubicleOccupancy: const FeedbackCubicleOccupancy(
                    occupied: 3,
                    total: 4,
                    monitored: 4,
                    percentage: 75,
                    dataStatus: 'live',
                  ),
                  washroomOccupancy: const FeedbackWashroomOccupancy(
                    estimatedCount: 9,
                    percentage: 58,
                    band: 'moderate',
                    capacity: 16,
                    displayLimit: 20,
                    isCapped: false,
                    dataStatus: 'live',
                    washroomType: 'female',
                    urinalCount: 0,
                    windowMinutes: 15,
                  ),
                  updatedAt: DateTime.now(),
                ),
                temperatureCelsius: 27,
                feedbackQrUrl: null,
                onShowQr: () {},
                onStart: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Washroom Occupancy'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
