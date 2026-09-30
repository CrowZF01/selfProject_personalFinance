import 'package:flutter_test/flutter_test.dart';
import 'package:finlix/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FinlixApp());
    expect(find.text('Finlix Dashboard'), findsOneWidget);
  });
}
