import 'dart:async';

import '../data/mock_data.dart';
import '../models/leave_request.dart';
import 'leave_repository.dart';

class MockLeaveRepository implements LeaveRepository {
  final _changes = StreamController<void>.broadcast();

  @override
  Stream<List<LeaveRequest>> streamForEmployee(String employeeId) {
    return _watch(() => MockData.leaveRequests
        .where((l) => l.employeeId == employeeId)
        .toList());
  }

  @override
  Stream<List<LeaveRequest>> streamAll() {
    return _watch(() => List.of(MockData.leaveRequests));
  }

  Stream<List<LeaveRequest>> _watch(List<LeaveRequest> Function() snapshot) {
    // Stream.multi gives each subscriber its own listener (replayed with the
    // current snapshot immediately), unlike a single-subscription async*
    // stream, which throws if more than one StreamBuilder ends up listening
    // to the same stream instance (happens inside TabBarView/nested builders).
    return Stream.multi((controller) {
      controller.add(snapshot());
      final sub = _changes.stream.listen((_) => controller.add(snapshot()));
      controller.onCancel = sub.cancel;
    });
  }

  @override
  Future<void> create(LeaveRequest request) async {
    MockData.leaveRequests.add(request);
    _changes.add(null);
  }

  @override
  Future<void> approve(String requestId, String approvedBy) async {
    _setStatus(requestId, LeaveStatus.approved, approvedBy);
  }

  @override
  Future<void> reject(String requestId, String approvedBy) async {
    _setStatus(requestId, LeaveStatus.rejected, approvedBy);
  }

  void _setStatus(String id, LeaveStatus status, String approvedBy) {
    final index = MockData.leaveRequests.indexWhere((l) => l.id == id);
    if (index == -1) return;
    final old = MockData.leaveRequests[index];
    MockData.leaveRequests[index] = LeaveRequest(
      id: old.id,
      employeeId: old.employeeId,
      employeeName: old.employeeName,
      type: old.type,
      status: status,
      startDate: old.startDate,
      endDate: old.endDate,
      reason: old.reason,
      requestedAt: old.requestedAt,
      approvedBy: approvedBy,
    );
    _changes.add(null);
  }
}
