import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:washroom_ops/features/feedback/domain/feedback_models.dart';
import 'package:washroom_ops/features/feedback/presentation/widgets/feedback_debug_washroom_control.dart';
import 'package:washroom_ops/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('selects a washroom without overflow on a narrow device', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    String? selectedWashroomId;

    await tester.pumpWidget(
      _DebugPreviewHarness(
        onSelected: (washroomId) => selectedWashroomId = washroomId,
      ),
    );

    await tester.tap(find.text('DEV · Arrivals Male'));
    await tester.pumpAndSettle();

    expect(find.text('Preview washroom'), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -180));
    await tester.pumpAndSettle();
    expect(find.text('Arrivals Female'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Arrivals Female'));
    await tester.pumpAndSettle();

    expect(selectedWashroomId, 'washroom-2');
    expect(find.text('Preview washroom'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('can restore the assigned washroom on a tablet', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1180, 820));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var selectionHandled = false;
    String? selectedWashroomId = 'unchanged';

    await tester.pumpWidget(
      _DebugPreviewHarness(
        selectedWashroomId: 'washroom-2',
        onSelected: (washroomId) {
          selectionHandled = true;
          selectedWashroomId = washroomId;
        },
      ),
    );

    await tester.tap(find.text('DEV · Arrivals Male'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use assigned washroom'));
    await tester.pumpAndSettle();

    expect(selectionHandled, isTrue);
    expect(selectedWashroomId, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('remains usable with large text in dark landscape mode', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(640, 360));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const _DebugPreviewHarness(
        darkMode: true,
        textScaler: TextScaler.linear(1.6),
        onSelected: _ignoreSelection,
      ),
    );

    await tester.tap(find.text('DEV · Arrivals Male'));
    await tester.pumpAndSettle();

    expect(find.text('Preview washroom'), findsOneWidget);
    expect(find.byType(CustomScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _ignoreSelection(String? _) {}

class _DebugPreviewHarness extends StatelessWidget {
  const _DebugPreviewHarness({
    required this.onSelected,
    this.selectedWashroomId,
    this.darkMode = false,
    this.textScaler = TextScaler.noScaling,
  });

  final ValueChanged<String?> onSelected;
  final String? selectedWashroomId;
  final bool darkMode;
  final TextScaler textScaler;

  static const washrooms = [
    FeedbackWashroom(
      id: 'washroom-1',
      name: 'Arrivals Male',
      code: 'ARR-M',
      type: 'male',
    ),
    FeedbackWashroom(
      id: 'washroom-2',
      name: 'Arrivals Female',
      code: 'ARR-F',
      type: 'female',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: child ?? const SizedBox.shrink(),
      ),
      home: Builder(
        builder: (context) => Scaffold(
          body: Align(
            alignment: Alignment.bottomRight,
            child: FeedbackDebugWashroomControl(
              washroomName: washrooms.first.name,
              onPressed: () => showFeedbackDebugWashroomSheet(
                context: context,
                washrooms: washrooms,
                selectedWashroomId: selectedWashroomId,
                assignedWashroomId: washrooms.first.id,
                onSelected: onSelected,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
