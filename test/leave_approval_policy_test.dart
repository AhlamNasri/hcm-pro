import 'package:flutter_test/flutter_test.dart';
import 'package:hcm_pro/core/models/employee.dart';
import 'package:hcm_pro/core/services/leave_approval_policy.dart';

Employee _employee({
  required String id,
  String managerId = '',
  int leaveBalance = 20,
  int totalLeaveAllowance = 30,
}) {
  return Employee(
    id: id,
    firstName: 'Test',
    lastName: id,
    email: '$id@hcmpro.com',
    phone: '',
    position: 'Tester',
    department: Department.it,
    status: EmployeeStatus.active,
    contractType: ContractType.cdi,
    hireDate: DateTime(2020, 1, 1),
    salary: 10000,
    managerId: managerId,
    avatarColor: '000000',
    leaveBalance: leaveBalance,
    totalLeaveAllowance: totalLeaveAllowance,
    performanceScore: 4.0,
  );
}

void main() {
  group('LeaveApprovalPolicy.canReview', () {
    test('the requester\'s direct manager can review', () {
      final manager = _employee(id: 'MGR');
      final requester = _employee(id: 'EMP', managerId: 'MGR');

      expect(
        LeaveApprovalPolicy.canReview(
          approver: manager,
          requester: requester,
          approverIsOwner: false,
        ),
        isTrue,
      );
    });

    test('someone who is not the direct manager cannot review', () {
      final otherManager = _employee(id: 'MGR2');
      final requester = _employee(id: 'EMP', managerId: 'MGR');

      expect(
        LeaveApprovalPolicy.canReview(
          approver: otherManager,
          requester: requester,
          approverIsOwner: false,
        ),
        isFalse,
      );
    });

    test('Owner is the fallback approver when requester has no manager', () {
      final owner = _employee(id: 'OWNER');
      final requester = _employee(id: 'CFO', managerId: '');

      expect(
        LeaveApprovalPolicy.canReview(
          approver: owner,
          requester: requester,
          approverIsOwner: true,
        ),
        isTrue,
      );
    });

    test('a non-Owner cannot use the no-manager fallback', () {
      final manager = _employee(id: 'MGR');
      final requester = _employee(id: 'CFO', managerId: '');

      expect(
        LeaveApprovalPolicy.canReview(
          approver: manager,
          requester: requester,
          approverIsOwner: false,
        ),
        isFalse,
      );
    });

    test('nobody can review their own request, even the Owner fallback', () {
      final owner = _employee(id: 'OWNER', managerId: '');

      expect(
        LeaveApprovalPolicy.canReview(
          approver: owner,
          requester: owner,
          approverIsOwner: true,
        ),
        isFalse,
      );
    });
  });

  group('Employee.leaveDaysUsed', () {
    test('is the difference between allowance and remaining balance', () {
      final employee =
          _employee(id: 'EMP', leaveBalance: 22, totalLeaveAllowance: 30);
      expect(employee.leaveDaysUsed, 8);
    });

    test('is zero for a brand-new employee with a full balance', () {
      final employee =
          _employee(id: 'EMP', leaveBalance: 30, totalLeaveAllowance: 30);
      expect(employee.leaveDaysUsed, 0);
    });
  });
}
