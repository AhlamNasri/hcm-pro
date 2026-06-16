import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/leave_request.dart';
import 'leave_repository.dart';

class FirebaseLeaveRepository implements LeaveRepository {
  FirebaseLeaveRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('leave_requests');

  @override
  Stream<List<LeaveRequest>> streamForEmployee(String employeeId) {
    return _collection.where('employeeId', isEqualTo: employeeId).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => LeaveRequest.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Stream<List<LeaveRequest>> streamAll() {
    return _collection.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => LeaveRequest.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Future<void> create(LeaveRequest request) async {
    await _collection.doc(request.id).set(request.toFirestore());
  }

  @override
  Future<void> approve(String requestId, String approvedBy) async {
    await _collection.doc(requestId).update({
      'status': LeaveStatus.approved.name,
      'approvedBy': approvedBy,
    });
  }

  @override
  Future<void> reject(String requestId, String approvedBy) async {
    await _collection.doc(requestId).update({
      'status': LeaveStatus.rejected.name,
      'approvedBy': approvedBy,
    });
  }
}
