import '../models/user_account.dart';
import '../models/employee.dart';
import '../data/mock_data.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _accounts = [
    UserAccount(
      email: 'ahmed.benali@hcmpro.com',
      password: 'admin123',
      employeeId: 'EMP001',
      role: UserRole.hrManager,
    ),
    UserAccount(
      email: 'youssef.tahiri@hcmpro.com',
      password: 'manager123',
      employeeId: 'EMP005',
      role: UserRole.manager,
    ),
    UserAccount(
      email: 'sara.benhaddou@hcmpro.com',
      password: 'manager123',
      employeeId: 'EMP006',
      role: UserRole.manager,
    ),
    UserAccount(
      email: 'fatima.zahra@hcmpro.com',
      password: 'emp123',
      employeeId: 'EMP002',
      role: UserRole.employee,
    ),
    UserAccount(
      email: 'karim.mansouri@hcmpro.com',
      password: 'emp123',
      employeeId: 'EMP003',
      role: UserRole.employee,
    ),
    UserAccount(
      email: 'nadia.elamrani@hcmpro.com',
      password: 'emp123',
      employeeId: 'EMP004',
      role: UserRole.employee,
    ),
    UserAccount(
      email: 'omar.fassi@hcmpro.com',
      password: 'emp123',
      employeeId: 'EMP007',
      role: UserRole.employee,
    ),
    UserAccount(
      email: 'leila.chraibi@hcmpro.com',
      password: 'emp123',
      employeeId: 'EMP008',
      role: UserRole.employee,
    ),
    UserAccount(
      email: 'hamza.idrissi@hcmpro.com',
      password: 'emp123',
      employeeId: 'EMP009',
      role: UserRole.employee,
    ),
  ];

  UserAccount? _currentAccount;

  UserAccount? get currentAccount => _currentAccount;

  bool get isLoggedIn => _currentAccount != null;

  bool get isManager => _currentAccount?.isManager ?? false;

  Employee get currentEmployee {
    final id = _currentAccount?.employeeId ?? 'EMP001';
    return MockData.employees.firstWhere(
      (e) => e.id == id,
      orElse: () => MockData.employees.first,
    );
  }

  /// Returns null on success, error message on failure
  String? login(String email, String password) {
    final email_ = email.trim().toLowerCase();
    try {
      final account = _accounts.firstWhere(
        (a) => a.email.toLowerCase() == email_,
      );
      if (account.password != password) {
        return 'Incorrect password.';
      }
      _currentAccount = account;
      return null;
    } catch (_) {
      return 'No account found for this email.';
    }
  }

  void logout() => _currentAccount = null;

  static List<UserAccount> get allAccounts => _accounts;
}
