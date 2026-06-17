import 'dart:math';

import '../data/mock_data.dart';
import '../models/employee.dart';
import '../models/user_account.dart';
import 'auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  static final List<UserAccount> _accounts = [
    UserAccount(
      email: 'nawal.idrissi@hcmpro.com',
      password: 'owner123',
      employeeId: 'EMP011',
      role: UserRole.owner,
    ),
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
  final Map<String, String> _passwordOverrides = {};

  @override
  UserAccount? get currentAccount => _currentAccount;

  @override
  bool get isLoggedIn => _currentAccount != null;

  @override
  bool get isManager => _currentAccount?.isManager ?? false;

  @override
  Employee get currentEmployee {
    final id = _currentAccount?.employeeId ?? 'EMP001';
    return MockData.employees.firstWhere(
      (e) => e.id == id,
      orElse: () => MockData.employees.first,
    );
  }

  @override
  Future<String?> login(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    try {
      final account = _accounts.firstWhere(
        (a) => a.email.toLowerCase() == normalizedEmail,
      );
      final effectivePassword =
          _passwordOverrides[normalizedEmail] ?? account.password;
      if (effectivePassword != password) {
        return 'Incorrect password.';
      }
      _currentAccount = account;
      return null;
    } catch (_) {
      return 'No account found for this email.';
    }
  }

  @override
  Future<void> logout() async => _currentAccount = null;

  @override
  Future<String?> changePassword(String currentPassword, String newPassword) async {
    final account = _currentAccount;
    if (account == null) return 'Not logged in.';
    final normalizedEmail = account.email.toLowerCase();
    final effectivePassword =
        _passwordOverrides[normalizedEmail] ?? account.password;
    if (effectivePassword != currentPassword) {
      return 'Current password is incorrect.';
    }
    _passwordOverrides[normalizedEmail] = newPassword;
    return null;
  }

  @override
  Future<String> createAccountForEmployee({
    required String employeeId,
    required String email,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final exists =
        _accounts.any((a) => a.email.toLowerCase() == normalizedEmail);
    if (exists) {
      throw StateError('An account with this email already exists.');
    }
    final password = _generateTempPassword();
    _accounts.add(UserAccount(
      email: email.trim(),
      password: password,
      employeeId: employeeId,
      role: UserRole.employee,
    ));
    return password;
  }

  static String _generateTempPassword() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789';
    final rand = Random.secure();
    return List.generate(8, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}
