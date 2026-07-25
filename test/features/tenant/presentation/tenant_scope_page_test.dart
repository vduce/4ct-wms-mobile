import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:washroom_ops/features/tenant/presentation/tenant_scope_page.dart';

void main() {
  testWidgets('renders the authenticated route child', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TenantScopePage(
          child: Scaffold(body: Center(child: Text('Authenticated page'))),
        ),
      ),
    );

    expect(find.text('Authenticated page'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
