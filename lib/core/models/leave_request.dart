enum LeaveType { annual, sick, maternity, paternity, unpaid, remote }

enum LeaveStatus { pending, approved, rejected, cancelled }

class LeaveRequest {
  final String id;
  final String employeeId;
  final String employeeName;
  final LeaveType type;
  final LeaveStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final DateTime requestedAt;
  final String? approvedBy;

  const LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.type,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.requestedAt,
    this.approvedBy,
  });

  int get durationDays => endDate.difference(startDate).inDays + 1;

  String get typeLabel {
    switch (type) {
      case LeaveType.annual:
        return 'Annual Leave';
      case LeaveType.sick:
        return 'Sick Leave';
      case LeaveType.maternity:
        return 'Maternity Leave';
      case LeaveType.paternity:
        return 'Paternity Leave';
      case LeaveType.unpaid:
        return 'Unpaid Leave';
      case LeaveType.remote:
        return 'Remote Work';
    }
  }

  String get statusLabel {
    switch (status) {
      case LeaveStatus.pending:
        return 'Pending';
      case LeaveStatus.approved:
        return 'Approved';
      case LeaveStatus.rejected:
        return 'Rejected';
      case LeaveStatus.cancelled:
        return 'Cancelled';
    }
  }

  factory LeaveRequest.fromFirestore(String id, Map<String, dynamic> data) {
    return LeaveRequest(
      id: id,
      employeeId: data['employeeId'] as String,
      employeeName: data['employeeName'] as String,
      type: LeaveType.values.byName(data['type'] as String),
      status: LeaveStatus.values.byName(data['status'] as String),
      startDate: DateTime.parse(data['startDate'] as String),
      endDate: DateTime.parse(data['endDate'] as String),
      reason: data['reason'] as String,
      requestedAt: DateTime.parse(data['requestedAt'] as String),
      approvedBy: data['approvedBy'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'employeeId': employeeId,
      'employeeName': employeeName,
      'type': type.name,
      'status': status.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'reason': reason,
      'requestedAt': requestedAt.toIso8601String(),
      'approvedBy': approvedBy,
    };
  }
}
