import 'dart:async';

import '../models/notification_item.dart';
import 'notification_repository.dart';

class MockNotificationRepository implements NotificationRepository {
  final List<NotificationItem> _items = [
    NotificationItem(
      id: '1',
      userId: 'EMP001',
      title: 'Leave Request Approved',
      body: 'Your annual leave request for July 14-18 has been approved.',
      type: NotificationType.leaveApproved,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
    NotificationItem(
      id: '2',
      userId: 'EMP001',
      title: 'New Pending Request',
      body: 'Fatima Zahra requested 6 days annual leave. Your review needed.',
      type: NotificationType.leavePending,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationItem(
      id: '3',
      userId: 'EMP001',
      title: 'Payslip Available',
      body: 'Your payslip for May 2026 is ready to download.',
      type: NotificationType.payslip,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  final _changes = StreamController<void>.broadcast();

  @override
  Stream<List<NotificationItem>> streamForUser(String userId) {
    List<NotificationItem> snapshot() =>
        _items.where((n) => n.userId == userId).toList();
    return Stream.multi((controller) {
      controller.add(snapshot());
      final sub = _changes.stream.listen((_) => controller.add(snapshot()));
      controller.onCancel = sub.cancel;
    });
  }

  @override
  Future<void> create(NotificationItem notification) async {
    _items.add(notification);
    _changes.add(null);
  }

  @override
  Future<void> markRead(String id) async {
    final index = _items.indexWhere((n) => n.id == id);
    if (index == -1) return;
    _items[index] = _items[index].copyWith(isRead: true);
    _changes.add(null);
  }

  @override
  Future<void> markAllRead(String userId) async {
    for (var i = 0; i < _items.length; i++) {
      if (_items[i].userId == userId) {
        _items[i] = _items[i].copyWith(isRead: true);
      }
    }
    _changes.add(null);
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((n) => n.id == id);
    _changes.add(null);
  }
}
