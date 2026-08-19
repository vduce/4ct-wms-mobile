import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:washroom_ops/features/feedback/domain/feedback_models.dart';
import 'package:washroom_ops/features/feedback/presentation/widgets/feedback_qr.dart';
import 'package:washroom_ops/features/feedback/presentation/widgets/feedback_screensaver_panel.dart';
import 'package:washroom_ops/l10n/generated/app_localizations.dart';

void main() {
  for (final viewport in <String, Size>{
    'narrow portrait': const Size(360, 640),
    'constrained landscape': const Size(1024, 600),
  }.entries) {
    testWidgets('debug control does not cover QR on ${viewport.key}', (
      tester,
    ) async {
      tester.view.physicalSize = viewport.value;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const debugControlKey = Key('debug-control');
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Stack(
                fit: StackFit.expand,
                children: [
                  FeedbackScreensaverPanel(
                    brandingName: 'Airport',
                    videoUrl: '',
                    metrics: FeedbackMetrics.empty(),
                    temperatureCelsius: 27,
                    feedbackQrUrl: 'https://example.com/feedback',
                    bottomContentPadding: 64,
                    onShowQr: () {},
                    onStart: () {},
                  ),
                  const Positioned(
                    right: 2,
                    bottom: 2,
                    child: SizedBox(
                      key: debugControlKey,
                      width: 320,
                      height: 48,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final scrollView = find.byType(SingleChildScrollView);
      if (scrollView.evaluate().isNotEmpty) {
        await tester.drag(scrollView, const Offset(0, -3000));
        await tester.pump();
      }

      final qrRect = tester.getRect(find.byType(FeedbackDirectQrCard));
      final debugControlRect = tester.getRect(find.byKey(debugControlKey));

      expect(qrRect.bottom, lessThan(debugControlRect.top));
      expect(tester.takeException(), isNull);
    });
  }
}
