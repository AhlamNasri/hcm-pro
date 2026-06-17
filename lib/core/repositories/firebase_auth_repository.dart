import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';

import '../models/employee.dart';
import '../models/user_account.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({fb.FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? fb.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  UserAccount? _currentAccount;
  Employee? _currentEmployee;

  @override
  UserAccount? get currentAccount => _currentAccount;

  @override
  bool get isLoggedIn => _currentAccount != null;

  @override
  bool get isManager => _currentAccount?.isManager ?? false;

  @override
  Employee get currentEmployee {
    final employee = _currentEmployee;
    if (employee == null) {
      throw StateError('No employee loaded — call login() first.');
    }
    return employee;
  }

  @override
  Future<String?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) return 'Login failed.';

      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        return 'No HCM profile found for this account.';
      }
      final userData = userDoc.data()!;
      final employeeId = userData['employeeId'] as String;
      final role = UserRole.values.byName(userData['role'] as String);

      final employeeDoc =
          await _firestore.collection('employees').doc(employeeId).get();
      if (!employeeDoc.exists) {
        return 'Employee record not found for this account.';
      }

      _currentEmployee = Employee.fromFirestore(employeeId, employeeDoc.data()!);
      _currentAccount = UserAccount(
        email: email.trim(),
        employeeId: employeeId,
        role: role,
      );
      return null;
    } on fb.FirebaseAuthException catch (e) {
      return e.message ?? 'Login failed.';
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
    _currentAccount = null;
    _currentEmployee = null;
  }

  @override
  Future<String?> changePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null) return 'Not logged in.';
    try {
      final credential = fb.EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return null;
    } on fb.FirebaseAuthException catch (e) {
      return e.message ?? 'Could not change password.';
    }
  }

  @override
  Future<String> createAccountForEmployee({
    required String employeeId,
    required String email,
  }) async {
    final password = _generateTempPassword();
    // Creating a user via the default FirebaseAuth instance signs the
    // caller into that new account, kicking the HR Manager out of their own
    // session. Provision it on a throwaway secondary app instance instead,
    // so the primary instance (and HR's session) is never touched.
    final secondaryApp = await Firebase.initializeApp(
      name: 'employee-provisioning-${DateTime.now().microsecondsSinceEpoch}',
      options: Firebase.app().options,
    );
    try {
      final secondaryAuth = fb.FirebaseAuth.instanceFor(app: secondaryApp);
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;
      await secondaryAuth.signOut();
      await _firestore.collection('users').doc(uid).set({
        'employeeId': employeeId,
        'role': UserRole.employee.name,
      });
      return password;
    } on fb.FirebaseAuthException catch (e) {
      throw StateError(e.message ?? 'Could not create account.');
    } finally {
      await secondaryApp.delete();
    }
  }

  static String _generateTempPassword() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789';
    final rand = Random.secure();
    return List.generate(8, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}
