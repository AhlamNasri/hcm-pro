import '../models/leave_request.dart';

abstract class LeaveRepository {
  Stream<List<LeaveRequest>> streamForEmployee(String employeeId);

  Stream<List<LeaveRequest>> streamAll();

  Future<void> create(LeaveRequest request);

  Future<void> approve(String requestId, String approvedBy);

  Future<void> reject(String requestId, String approvedBy);
}
