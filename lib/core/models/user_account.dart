enum UserRole { owner, hrManager, manager, employee }

class UserAccount {
  final String email;
  final String? password;
  final String employeeId;
  final UserRole role;

  const UserAccount({
    required this.email,
    this.password,
    required this.employeeId,
    required this.role,
  });

  bool get isManager =>
      role == UserRole.owner || role == UserRole.hrManager || role == UserRole.manager;
}
