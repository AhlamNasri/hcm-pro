enum NotificationType {
  leaveApproved,
  leaveRejected,
  leavePending,
  payslip,
  birthday,
  performance,
  general,
}

class NotificationItem {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;

  const NotificationItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      userId: userId,
      title: title,
      body: body,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  factory NotificationItem.fromFirestore(String id, Map<String, dynamic> data) {
    return NotificationItem(
      id: id,
      userId: data['userId'] as String,
      title: data['title'] as String,
      body: data['body'] as String,
      type: NotificationType.values.byName(data['type'] as String),
      isRead: data['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(data['createdAt'] as String),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'type': type.name,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
