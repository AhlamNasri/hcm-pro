import '../data/mock_data.dart';
import '../models/payslip.dart';
import 'payroll_repository.dart';

class MockPayrollRepository implements PayrollRepository {
  @override
  Stream<List<Payslip>> streamForEmployee(String employeeId) async* {
    yield MockData.payslips.where((p) => p.employeeId == employeeId).toList();
  }
}
