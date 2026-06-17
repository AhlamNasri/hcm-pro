import '../models/employee.dart';

/// Decides who is allowed to review a given employee's leave request.
///
/// Requests route to the requester's direct manager (`Employee.managerId`).
/// Employees with no manager on record fall back to the Owner — this is
/// the terminus of the hierarchy, so the Owner's own requests have no
/// reviewer, same as in a real company.
/// Nobody can review their own request, even via the Owner fallback.
class LeaveApprovalPolicy {
  LeaveApprovalPolicy._();

  static bool canReview({
    required Employee approver,
    required Employee requester,
    required bool approverIsOwner,
  }) {
    if (requester.id == approver.id) return false;
    if (requester.managerId.isEmpty) return approverIsOwner;
    return requester.managerId == approver.id;
  }
}
