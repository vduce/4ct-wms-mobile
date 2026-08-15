import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:washroom_ops/features/operations/domain/ticket_models.dart';
import 'package:washroom_ops/features/operations/presentation/widgets/operations_passenger_flow_sheet.dart';
import 'package:washroom_ops/l10n/generated/app_localizations.dart';

void main() {
  final peaks = [
    const PassengerPeak(
      washroomId: 'washroom-1',
      washroomName: 'E7 Belt 14 (ARRIVAL SIDE) Family Care 1',
      hour: '2026-08-14T05:30:00.000Z',
      count: 15,
      hourRange: '14.08.2026 05:30',
      timestamp: null,
    ),
    const PassengerPeak(
      washroomId: 'washroom-2',
      washroomName: 'E7 Belt 14 (ARRIVAL SIDE) Family Care 2',
      hour: '2026-08-14T11:30:00.000Z',
      count: 13,
      hourRange: '14.08.2026 11:30',
      timestamp: null,
    ),
    const PassengerPeak(
      washroomId: 'washroom-3',
      washroomName: 'Domestic departures washroom',
      hour: '2026-08-15T00:30:00.000Z',
      count: 11,
      hourRange: '15.08.2026 00:30',
      timestamp: null,
    ),
  ];

  for (final testCase in [
    (
      name: 'narrow portrait',
      size: const Size(375, 667),
      textScale: 1.0,
      brightness: Brightness.light,
    ),
    (
      name: 'constrained landscape',
      size: const Size(800, 360),
      textScale: 1.0,
      brightness: Brightness.dark,
    ),
    (
      name: 'large text',
      size: const Size(375, 667),
      textScale: 2.0,
      brightness: Brightness.light,
    ),
  ]) {
    testWidgets('passenger flow sheet fits ${testCase.name}', (tester) async {
      await tester.binding.setSurfaceSize(testCase.size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(
            size: testCase.size,
            textScaler: TextScaler.linear(testCase.textScale),
          ),
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData(
              useMaterial3: true,
              brightness: testCase.brightness,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF7004A0),
                brightness: testCase.brightness,
              ),
            ),
            home: Scaffold(
              body: Align(
                alignment: Alignment.bottomCenter,
                child: OperationsPassengerFlowSheet(peaks: peaks),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Passenger flow'), findsOneWidget);
      expect(find.text('15 passengers'), findsOneWidget);
      expect(find.text(peaks.first.washroomName), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('passenger flow sheet shows empty state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: OperationsPassengerFlowSheet(peaks: []),
          ),
        ),
      ),
    );

    expect(find.text('No passenger flow peaks are available.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
