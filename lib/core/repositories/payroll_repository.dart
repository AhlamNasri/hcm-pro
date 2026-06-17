import '../models/payslip.dart';

abstract class PayrollRepository {
  Stream<List<Payslip>> streamForEmployee(String employeeId);

  Stream<List<AttendanceRecord>> streamAttendanceForEmployee(String employeeId);
}
