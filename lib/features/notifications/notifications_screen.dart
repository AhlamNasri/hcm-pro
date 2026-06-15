import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_widgets.dart';

class _Notif {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  final IconData icon;
  final Color color;
  bool isRead;

  _Notif({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.color,
    this.isRead = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_Notif> _notifs = [
    _Notif(
      id: '1',
      title: 'Leave Request Approved',
      body: 'Your annual leave request for July 14–18 has been approved.',
      time: DateTime.now().subtract(const Duration(minutes: 20)),
      icon: Icons.check_circle_rounded,
      color: AppColors.success,
    ),
    _Notif(
      id: '2',
      title: 'New Pending Request',
      body: "Fatima Zahra requested 6 days annual leave. Your review needed.",
      time: DateTime.now().subtract(const Duration(hours: 2)),
      icon: Icons.pending_actions_rounded,
      color: AppColors.warning,
      isRead: false,
    ),
    _Notif(
      id: '3',
      title: 'Payslip Available',
      body: 'Your payslip for May 2026 is ready to download.',
      time: DateTime.now().subtract(const Duration(days: 1)),
      icon: Icons.receipt_long_rounded,
      color: AppColors.primary,
      isRead: true,
    ),
    _Notif(
      id: '4',
      title: "Birthday Reminder 🎂",
      body: "Fatima Zahra's birthday is in 7 days. Don't forget to wish her!",
      time: DateTime.now().subtract(const Duration(days: 2)),
      icon: Icons.cake_rounded,
      color: AppColors.accent,
      isRead: true,
    ),
    _Notif(
      id: '5',
      title: 'Leave Request Rejected',
      body: 'Leave request from Omar Fassi (Jun 16–20) was rejected.',
      time: DateTime.now().subtract(const Duration(days: 3)),
      icon: Icons.cancel_rounded,
      color: AppColors.danger,
      isRead: true,
    ),
    _Notif(
      id: '6',
      title: 'Performance Review',
      body: 'Your Q2 performance review is scheduled for June 25.',
      time: DateTime.now().subtract(const Duration(days: 5)),
      icon: Icons.assessment_rounded,
      color: AppColors.pending,
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifs.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
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
            onPressed: () {
              setState(() {
                for (final n in _notifs) {
                  n.isRead = true;
                }
              });
            },
            child: Text(
              'Mark all read',
              style: AppTextStyles.body2.copyWith(
                  color: Colors.white70, fontWeight: FontWeight.w600),
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, Color(0xFF283593)],
            ),
          ),
        ),
      ),
      body: _notifs.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_off_rounded,
              title: 'No Notifications',
              message: 'You are all caught up!',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _notifs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final n = _notifs[i];
                return Dismissible(
                  key: Key(n.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) =>
                      setState(() => _notifs.removeAt(i)),
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
                    onTap: () => setState(() => n.isRead = true),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: n.isRead
                            ? AppColors.cardBg
                            : n.color.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: n.isRead
                              ? AppColors.divider
                              : n.color.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: n.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(n.icon,
                                color: n.color, size: 20),
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
                                          color: n.color,
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
                                  _formatTime(n.time),
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
              },
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
