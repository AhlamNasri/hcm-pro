import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/employee.dart';
import 'employee_repository.dart';

class FirebaseEmployeeRepository implements EmployeeRepository {
  FirebaseEmployeeRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('employees');

  @override
  Future<List<Employee>> getAll() async {
    final snapshot = await _collection.get();
    return snapshot.docs
        .map((doc) => Employee.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<Employee?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return Employee.fromFirestore(doc.id, doc.data()!);
  }

  @override
  Future<void> add(Employee employee) async {
    await _collection.doc(employee.id).set(employee.toFirestore());
  }

  @override
  Future<void> update(Employee employee) async {
    await _collection.doc(employee.id).update(employee.toFirestore());
  }
}
