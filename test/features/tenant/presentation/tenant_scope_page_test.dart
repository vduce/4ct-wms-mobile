import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:washroom_ops/features/tenant/presentation/tenant_scope_page.dart';
import 'package:washroom_ops/shared/widgets/authenticated_footer.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('shows the ${brightness.name} authenticated footer', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: const TenantScopePage(
            child: Scaffold(body: Center(child: Text('Authenticated page'))),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final image = tester.widget<Image>(
        find.byKey(AuthenticatedFooter.imageKey),
      );
      final provider = image.image as AssetImage;
      final expectedAsset = brightness == Brightness.dark
          ? AuthenticatedFooterAssets.dark
          : AuthenticatedFooterAssets.light;

      expect(provider.assetName, expectedAsset);
      expect(find.text('Authenticated page'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final size in [const Size(320, 700), const Size(1180, 700)]) {
    testWidgets('footer fits a ${size.width.toInt()}px authenticated screen', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: TenantScopePage(child: Scaffold(body: SizedBox.expand())),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AuthenticatedFooter), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
