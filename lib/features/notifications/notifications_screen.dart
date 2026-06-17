import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/notification_item.dart';
import '../../core/services/app_backend.dart';
import '../../core/services/auth_service.dart';
import '../../shared/widgets/app_widgets.dart';

(IconData, Color) _iconAndColorFor(NotificationType type) {
  switch (type) {
    case NotificationType.leaveApproved:
      return (Icons.check_circle_rounded, AppColors.success);
    case NotificationType.leaveRejected:
      return (Icons.cancel_rounded, AppColors.danger);
    case NotificationType.leavePending:
      return (Icons.pending_actions_rounded, AppColors.warning);
    case NotificationType.payslip:
      return (Icons.receipt_long_rounded, AppColors.primary);
    case NotificationType.birthday:
      return (Icons.cake_rounded, AppColors.accent);
    case NotificationType.performance:
      return (Icons.assessment_rounded, AppColors.pending);
    case NotificationType.general:
      return (Icons.notifications_rounded, AppColors.textSecondary);
  }
}

String? _routeFor(NotificationType type) {
  switch (type) {
    case NotificationType.leaveApproved:
    case NotificationType.leaveRejected:
    case NotificationType.leavePending:
      return '/leave';
    case NotificationType.payslip:
      return '/payroll';
    case NotificationType.birthday:
    case NotificationType.performance:
    case NotificationType.general:
      return null;
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final String _userId;

  @override
  void initState() {
    super.initState();
    _userId = AuthService.instance.currentEmployee.id;
  }

  Future<bool> _confirmDelete() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Notification', style: AppTextStyles.heading2),
        content: Text('This notification will be removed permanently.',
            style: AppTextStyles.body1),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: AppTextStyles.body1
                    .copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: Text('Delete', style: AppTextStyles.button),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _onTapNotification(NotificationItem n) {
    AppBackend.notificationRepository.markRead(n.id);
    final route = _routeFor(n.type);
    if (route != null) context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NotificationItem>>(
      stream: AppBackend.notificationRepository.streamForUser(_userId),
      builder: (context, snapshot) {
        final notifs = snapshot.data ?? const <NotificationItem>[];
        final unreadCount = notifs.where((n) => !n.isRead).length;

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: Colors.white, size: 20),
              // /notifications is always reached via context.go(), which
              // replaces the whole stack, so there's nothing to pop back
              // into — go to a known destination instead.
              onPressed: () => context.go('/dashboard'),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notifications',
                    style: AppTextStyles.heading2
                        .copyWith(color: Colors.white)),
                if (unreadCount > 0)
                  Text(
                    '$unreadCount unread',
                    style: AppTextStyles.caption
                        .copyWith(color: Colors.white70),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    AppBackend.notificationRepository.markAllRead(_userId),
                child: Text(
                  'Mark all read',
                  style: AppTextStyles.body2.copyWith(
                      color: Colors.white70, fontWeight: FontWeight.w600),
                ),
              ),
            ],
            flexibleSpace: Container(color: AppColors.primaryDark),
          ),
          body: notifs.isEmpty
              ? const EmptyState(
                  icon: Icons.notifications_off_rounded,
                  title: 'No Notifications',
                  message: 'You are all caught up!',
                )
              : _buildGroupedList(notifs),
        );
      },
    );
  }

  Widget _buildGroupedList(List<NotificationItem> notifs) {
    final sorted = [...notifs]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    const bucketOrder = ['Today', 'Earlier this week', 'Older'];
    final grouped = <String, List<NotificationItem>>{};
    for (final n in sorted) {
      grouped.putIfAbsent(_bucketFor(n.createdAt), () => []).add(n);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final bucket in bucketOrder)
          if (grouped[bucket] != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
              child: Text(bucket, style: AppTextStyles.label),
            ),
            for (final n in grouped[bucket]!) ...[
              _buildNotificationCard(n),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 8),
          ],
      ],
    );
  }

  String _bucketFor(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);
    final diffDays = today.difference(date).inDays;
    if (diffDays <= 0) return 'Today';
    if (diffDays <= 7) return 'Earlier this week';
    return 'Older';
  }

  Widget _buildNotificationCard(NotificationItem n) {
    final (icon, color) = _iconAndColorFor(n.type);
    return Dismissible(
                      key: Key(n.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) => _confirmDelete(),
                      onDismissed: (_) =>
                          AppBackend.notificationRepository.delete(n.id),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.delete_rounded,
                            color: Colors.white),
                      ),
                      child: GestureDetector(
                        onTap: () => _onTapNotification(n),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: n.isRead
                                ? AppColors.cardBg
                                : color.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: n.isRead
                                  ? AppColors.divider
                                  : color.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(icon, color: color, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            n.title,
                                            style: AppTextStyles.body1.copyWith(
                                              fontWeight: n.isRead
                                                  ? FontWeight.w500
                                                  : FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        if (!n.isRead)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: color,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(n.body,
                                        style: AppTextStyles.body2,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTime(n.createdAt),
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return DateFormat('d MMM').format(dt);
    }
  }
}
