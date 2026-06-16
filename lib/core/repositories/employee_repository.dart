import '../models/employee.dart';

abstract class EmployeeRepository {
  Future<List<Employee>> getAll();

  Future<Employee?> getById(String id);

  Future<void> add(Employee employee);

  Future<void> update(Employee employee);
}
