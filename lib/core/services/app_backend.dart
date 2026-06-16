import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';
import '../repositories/auth_repository.dart';
import '../repositories/employee_repository.dart';
import '../repositories/firebase_auth_repository.dart';
import '../repositories/firebase_employee_repository.dart';
import '../repositories/firebase_leave_repository.dart';
import '../repositories/firebase_notification_repository.dart';
import '../repositories/firebase_payroll_repository.dart';
import '../repositories/leave_repository.dart';
import '../repositories/mock_auth_repository.dart';
import '../repositories/mock_employee_repository.dart';
import '../repositories/mock_leave_repository.dart';
import '../repositories/mock_notification_repository.dart';
import '../repositories/mock_payroll_repository.dart';
import '../repositories/notification_repository.dart';
import '../repositories/payroll_repository.dart';

/// Single place that decides whether the app talks to Firebase or runs on
/// in-memory mock data, and exposes whichever repositories are active.
/// `lib/firebase_options.dart` is a placeholder until `flutterfire configure`
/// is run against a real project, so [init] silently falls back to mock data
/// when Firebase.initializeApp throws.
class AppBackend {
  AppBackend._();

  static const _placeholderProjectId = 'hcm-pro-not-configured';

  static bool isFirebaseAvailable = false;

  static late AuthRepository authRepository;
  static late EmployeeRepository employeeRepository;
  static late LeaveRepository leaveRepository;
  static late PayrollRepository payrollRepository;
  static late NotificationRepository notificationRepository;

  static Future<void> init() async {
    try {
      // Firebase.initializeApp accepts any well-formed FirebaseOptions
      // without contacting the cloud project, so a placeholder projectId
      // would otherwise succeed silently. Check it explicitly before
      // bothering to initialize, instead of relying on a real failure.
      final options = DefaultFirebaseOptions.currentPlatform;
      if (options.projectId == _placeholderProjectId) {
        throw StateError('firebase_options.dart is still a placeholder');
      }
      await Firebase.initializeApp(options: options);
      isFirebaseAvailable = true;
      authRepository = FirebaseAuthRepository();
      employeeRepository = FirebaseEmployeeRepository();
      leaveRepository = FirebaseLeaveRepository();
      payrollRepository = FirebasePayrollRepository();
      notificationRepository = FirebaseNotificationRepository();
    } catch (_) {
      isFirebaseAvailable = false;
      authRepository = MockAuthRepository();
      employeeRepository = MockEmployeeRepository();
      leaveRepository = MockLeaveRepository();
      payrollRepository = MockPayrollRepository();
      notificationRepository = MockNotificationRepository();
    }
  }
}
