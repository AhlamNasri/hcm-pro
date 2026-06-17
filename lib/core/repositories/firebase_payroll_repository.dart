import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/payslip.dart';
import 'payroll_repository.dart';

class FirebasePayrollRepository implements PayrollRepository {
  FirebasePayrollRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<Payslip>> streamForEmployee(String employeeId) {
    return _firestore
        .collection('payslips')
        .where('employeeId', isEqualTo: employeeId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Payslip.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Stream<List<AttendanceRecord>> streamAttendanceForEmployee(String employeeId) {
    return _firestore
        .collection('attendance')
        .where('employeeId', isEqualTo: employeeId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AttendanceRecord.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }
}
