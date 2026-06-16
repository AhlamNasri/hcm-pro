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
}
