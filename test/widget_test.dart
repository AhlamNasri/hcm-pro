import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hcm_pro/core/services/app_backend.dart';
import 'package:hcm_pro/main.dart';

void main() {
  testWidgets('HCM Pro app smoke test', (WidgetTester tester) async {
    // AppBackend.init() restores a persisted session via SharedPreferences;
    // give it an in-memory mock so the test doesn't hang on a missing
    // platform channel.
    SharedPreferences.setMockInitialValues({});
    await AppBackend.init();
    await tester.pumpWidget(const HCMProApp());
    // The login screen's hero backdrop runs a slow looping AnimationController
    // (AnimatedBlobAccentBackdrop), which never settles — pump explicit
    // frames instead of pumpAndSettle() to avoid a timeout.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(find.text('HCM Pro'), findsAny);
  });
}
