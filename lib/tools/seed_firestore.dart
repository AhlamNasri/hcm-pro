// One-shot seeding tool for a real Firebase project. Run with:
//   flutter run -t lib/tools/seed_firestore.dart -d <device-id>
// This boots through the Flutter engine on a connected device/emulator,
// which is required for firebase_core's native init on mobile (a plain
// `dart run` script has no Flutter engine and can't initialize Firebase).
//
// Steps:
//   1. flutterfire configure must already have replaced lib/firebase_options.dart
//      with real values.
//   2. Manually create the 9 demo accounts in Firebase Console > Authentication
//      (Email/Password) and fill in their uids in emailToUid below.
//   3. Run this entrypoint once, then close the app — it seeds Firestore and exits.
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase_options.dart';
import '../core/data/mock_data.dart';

const Map<String, String> emailToUid = {
  'nawal.idrissi@hcmpro.com': 'TODO_UID_nawal',
  'ahmed.benali@hcmpro.com': 'TODO_UID_ahmed',
  'youssef.tahiri@hcmpro.com': 'TODO_UID_youssef',
  'sara.benhaddou@hcmpro.com': 'TODO_UID_sara',
  'fatima.zahra@hcmpro.com': 'TODO_UID_fatima',
  'karim.mansouri@hcmpro.com': 'TODO_UID_karim',
  'nadia.elamrani@hcmpro.com': 'TODO_UID_nadia',
  'omar.fassi@hcmpro.com': 'TODO_UID_omar',
  'leila.chraibi@hcmpro.com': 'TODO_UID_leila',
  'hamza.idrissi@hcmpro.com': 'TODO_UID_hamza',
};

const Map<String, String> emailToEmployeeId = {
  'nawal.idrissi@hcmpro.com': 'EMP011',
  'ahmed.benali@hcmpro.com': 'EMP001',
  'youssef.tahiri@hcmpro.com': 'EMP005',
  'sara.benhaddou@hcmpro.com': 'EMP006',
  'fatima.zahra@hcmpro.com': 'EMP002',
  'karim.mansouri@hcmpro.com': 'EMP003',
  'nadia.elamrani@hcmpro.com': 'EMP004',
  'omar.fassi@hcmpro.com': 'EMP007',
  'leila.chraibi@hcmpro.com': 'EMP008',
  'hamza.idrissi@hcmpro.com': 'EMP009',
};

const Map<String, String> employeeIdToRole = {
  'EMP011': 'owner',
  'EMP001': 'hrManager',
  'EMP005': 'manager',
  'EMP006': 'manager',
  'EMP002': 'employee',
  'EMP003': 'employee',
  'EMP004': 'employee',
  'EMP007': 'employee',
  'EMP008': 'employee',
  'EMP009': 'employee',
};

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final firestore = FirebaseFirestore.instance;

  debugPrint('Seeding employees...');
  for (final employee in MockData.employees) {
    await firestore.collection('employees').doc(employee.id).set(employee.toFirestore());
  }

  debugPrint('Seeding leave requests...');
  for (final request in MockData.leaveRequests) {
    await firestore.collection('leave_requests').doc(request.id).set(request.toFirestore());
  }

  debugPrint('Seeding payslips...');
  for (final payslip in MockData.payslips) {
    await firestore.collection('payslips').doc(payslip.id).set(payslip.toFirestore());
  }

  debugPrint('Seeding attendance...');
  for (final record in MockData.attendance) {
    await firestore.collection('attendance').doc(record.id).set(record.toFirestore());
  }

  debugPrint('Seeding users (uid -> employeeId/role)...');
  for (final entry in emailToUid.entries) {
    final email = entry.key;
    final uid = entry.value;
    if (uid.startsWith('TODO_UID')) {
      debugPrint('  skipping $email — fill in its real uid first');
      continue;
    }
    final employeeId = emailToEmployeeId[email]!;
    final role = employeeIdToRole[employeeId]!;
    await firestore.collection('users').doc(uid).set({
      'email': email,
      'employeeId': employeeId,
      'role': role,
    });
  }

  debugPrint('Done. You can close the app now.');
}
