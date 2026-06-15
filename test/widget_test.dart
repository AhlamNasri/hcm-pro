import 'package:flutter_test/flutter_test.dart';
import 'package:hcm_pro/main.dart';

void main() {
  testWidgets('HCM Pro app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HCMProApp());
    await tester.pumpAndSettle();
    expect(find.text('HCM Pro'), findsAny);
  });
}
