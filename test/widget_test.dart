import 'package:flutter_test/flutter_test.dart';
import 'package:skavia/app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build root app
    await tester.pumpWidget(const SkaviaApp());
    // Advance timers (animations & splash delay)
    await tester.pump(const Duration(seconds: 3));
    expect(find.byType(SkaviaApp), findsOneWidget);
  });
}
