import '../models/employee.dart';
import '../models/user_account.dart';

abstract class AuthRepository {
  UserAccount? get currentAccount;

  bool get isLoggedIn;

  bool get isManager;

  Employee get currentEmployee;

  /// Returns null on success, an error message on failure.
  Future<String?> login(String email, String password);

  Future<void> logout();

  /// Returns null on success, an error message on failure.
  Future<String?> changePassword(String currentPassword, String newPassword);

  /// Provisions a login account for a newly added employee (always created
  /// with [UserRole.employee] — HR can promote them later). Returns the
  /// generated temporary password so the caller can hand it to the
  /// employee. Throws if an account for [email] already exists.
  Future<String> createAccountForEmployee({
    required String employeeId,
    required String email,
  });

  /// Employee id of the org's Owner — the fallback approver for anyone
  /// with no manager on record (see [LeaveApprovalPolicy]). Null if no
  /// Owner account exists.
  Future<String?> findOwnerEmployeeId();

  /// Restores a previously logged-in session (e.g. after the app was
  /// fully closed and reopened), so the user doesn't have to log in
  /// again every launch. Returns true if a session was restored.
  Future<bool> restoreSession();
}
