import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hcm_pro/core/repositories/mock_auth_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('MockAuthRepository.createAccountForEmployee', () {
    test('provisions a working login for a new employee', () async {
      final repo = MockAuthRepository();
      final password = await repo.createAccountForEmployee(
        employeeId: 'EMPTEST1',
        email: 'new.hire@hcmpro.com',
      );

      expect(password, hasLength(8));
      final error = await repo.login('new.hire@hcmpro.com', password);
      expect(error, isNull);
      expect(repo.currentAccount?.employeeId, 'EMPTEST1');
    });

    test('rejects a second account for an email that already exists', () async {
      final repo = MockAuthRepository();
      await repo.createAccountForEmployee(
        employeeId: 'EMPTEST2',
        email: 'duplicate@hcmpro.com',
      );

      expect(
        () => repo.createAccountForEmployee(
          employeeId: 'EMPTEST3',
          email: 'duplicate@hcmpro.com',
        ),
        throwsStateError,
      );
    });

    test('email matching is case-insensitive', () async {
      final repo = MockAuthRepository();
      await repo.createAccountForEmployee(
        employeeId: 'EMPTEST4',
        email: 'Case.Test@hcmpro.com',
      );

      expect(
        () => repo.createAccountForEmployee(
          employeeId: 'EMPTEST5',
          email: 'case.test@hcmpro.com',
        ),
        throwsStateError,
      );
    });
  });

  group('MockAuthRepository.findOwnerEmployeeId', () {
    test('returns the seeded Owner account\'s employee id', () async {
      final repo = MockAuthRepository();
      expect(await repo.findOwnerEmployeeId(), 'EMP011');
    });
  });
}
