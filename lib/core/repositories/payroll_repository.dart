import '../models/payslip.dart';

abstract class PayrollRepository {
  Stream<List<Payslip>> streamForEmployee(String employeeId);
}
