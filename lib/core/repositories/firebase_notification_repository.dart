import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification_item.dart';
import 'notification_repository.dart';

class FirebaseNotificationRepository implements NotificationRepository {
  FirebaseNotificationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('notifications');

  @override
  Stream<List<NotificationItem>> streamForUser(String userId) {
    return _collection.where('userId', isEqualTo: userId).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationItem.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Future<void> markRead(String id) async {
    await _collection.doc(id).update({'isRead': true});
  }

  @override
  Future<void> markAllRead(String userId) async {
    final snapshot =
        await _collection.where('userId', isEqualTo: userId).get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  @override
  Future<void> delete(String id) async {
    await _collection.doc(id).delete();
  }
}
