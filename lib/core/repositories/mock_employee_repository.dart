import '../data/mock_data.dart';
import '../models/employee.dart';
import 'employee_repository.dart';

class MockEmployeeRepository implements EmployeeRepository {
  @override
  Future<List<Employee>> getAll() async => List.unmodifiable(MockData.employees);

  @override
  Future<Employee?> getById(String id) async {
    for (final e in MockData.employees) {
      if (e.id == id) return e;
    }
    return null;
  }

  @override
  Future<void> add(Employee employee) async {
    MockData.employees.add(employee);
  }

  @override
  Future<void> update(Employee employee) async {
    final index = MockData.employees.indexWhere((e) => e.id == employee.id);
    if (index != -1) {
      MockData.employees[index] = employee;
    }
  }
}
