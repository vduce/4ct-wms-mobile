import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:washroom_ops/main.dart' as app;

void main() {
  testWidgets('app starts at splash', (tester) async {
    app.main();
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
