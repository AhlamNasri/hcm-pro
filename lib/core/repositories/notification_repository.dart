import '../models/notification_item.dart';

abstract class NotificationRepository {
  Stream<List<NotificationItem>> streamForUser(String userId);

  Future<void> markRead(String id);

  Future<void> markAllRead(String userId);

  Future<void> delete(String id);
}
