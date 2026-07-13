import 'package:flutter_test/flutter_test.dart';
import 'package:washroom_ops/main.dart' as app;
import 'package:washroom_ops/shared/widgets/app_loading_dialog.dart';

void main() {
  testWidgets('app starts at splash', (tester) async {
    app.main();
    await tester.pump();

    expect(find.byType(AppLoadingDialog), findsOneWidget);
  });
}
