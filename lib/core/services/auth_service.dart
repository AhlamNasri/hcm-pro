import '../models/employee.dart';
import '../models/user_account.dart';
import 'app_backend.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  UserAccount? get currentAccount => AppBackend.authRepository.currentAccount;

  bool get isLoggedIn => AppBackend.authRepository.isLoggedIn;

  bool get isManager => AppBackend.authRepository.isManager;

  Employee get currentEmployee => AppBackend.authRepository.currentEmployee;

  /// Returns null on success, error message on failure
  Future<String?> login(String email, String password) =>
      AppBackend.authRepository.login(email, password);

  Future<void> logout() => AppBackend.authRepository.logout();

  Future<String?> changePassword(String currentPassword, String newPassword) =>
      AppBackend.authRepository.changePassword(currentPassword, newPassword);
}
