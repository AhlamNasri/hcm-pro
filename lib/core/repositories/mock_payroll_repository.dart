import '../data/mock_data.dart';
import '../models/payslip.dart';
import 'payroll_repository.dart';

class MockPayrollRepository implements PayrollRepository {
  @override
  Stream<List<Payslip>> streamForEmployee(String employeeId) {
    // Stream.multi (not async*) so this can be listened to by more than one
    // subscriber — TabBarView keeps offscreen tabs alive and may rebuild a
    // StreamBuilder with the same source more than once, which a plain
    // single-subscription async* stream can't survive.
    return Stream.multi((controller) {
      controller.add(MockData.payslips.where((p) => p.employeeId == employeeId).toList());
      controller.close();
    });
  }

  @override
  Stream<List<AttendanceRecord>> streamAttendanceForEmployee(String employeeId) {
    return Stream.multi((controller) {
      controller.add(MockData.attendance.where((a) => a.employeeId == employeeId).toList());
      controller.close();
    });
  }
}
