import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/employee.dart';
import '../../core/models/leave_request.dart';
import '../../core/models/notification_item.dart';
import '../../core/models/user_account.dart';
import '../../core/services/app_backend.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/leave_approval_policy.dart';
import '../../shared/widgets/app_widgets.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  late bool _isManager;
  late String _myId;
  late Future<List<Employee>> _employeesFuture;

  @override
  void initState() {
    super.initState();
    final auth = AuthService.instance;
    _myId = auth.currentEmployee.id;
    _isManager = auth.isManager;
    _tabCtrl = TabController(length: _isManager ? 2 : 1, vsync: this);
    if (_isManager) {
      _employeesFuture = AppBackend.employeeRepository.getAll();
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<bool> _confirm(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: AppTextStyles.heading2),
        content: Text(message, style: AppTextStyles.body1),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: AppTextStyles.body1
                    .copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('Confirm', style: AppTextStyles.button),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _approve(LeaveRequest request) async {
    final confirmed = await _confirm(
        'Approve Leave', 'Approve ${request.employeeName}\'s ${request.typeLabel.toLowerCase()} request?');
    if (!confirmed) return;
    final managerName = AuthService.instance.currentEmployee.fullName;
    await AppBackend.leaveRepository.approve(request.id, managerName);
    final employee = await AppBackend.employeeRepository.getById(request.employeeId);
    if (employee != null) {
      final newBalance = employee.leaveBalance - request.durationDays;
      await AppBackend.employeeRepository
          .update(employee.copyWith(leaveBalance: newBalance < 0 ? 0 : newBalance));
    }
    await AppBackend.notificationRepository.create(NotificationItem(
      id: 'NTF${DateTime.now().microsecondsSinceEpoch}',
      userId: request.employeeId,
      title: 'Leave Request Approved',
      body: 'Your ${request.typeLabel.toLowerCase()} request was approved by $managerName.',
      type: NotificationType.leaveApproved,
      createdAt: DateTime.now(),
    ));
  }

  Future<void> _reject(LeaveRequest request) async {
    final confirmed = await _confirm(
        'Reject Leave', 'Reject ${request.employeeName}\'s ${request.typeLabel.toLowerCase()} request?');
    if (!confirmed) return;
    final managerName = AuthService.instance.currentEmployee.fullName;
    await AppBackend.leaveRepository.reject(request.id, managerName);
    await AppBackend.notificationRepository.create(NotificationItem(
      id: 'NTF${DateTime.now().microsecondsSinceEpoch}',
      userId: request.employeeId,
      title: 'Leave Request Rejected',
      body: 'Your ${request.typeLabel.toLowerCase()} request was rejected by $managerName.',
      type: NotificationType.leaveRejected,
      createdAt: DateTime.now(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LeaveRequest>>(
      stream: AppBackend.leaveRepository.streamForEmployee(_myId),
      builder: (context, snapshot) {
        final myRequests = snapshot.data ?? const <LeaveRequest>[];
        final employee = AuthService.instance.currentEmployee;
        final pendingCount =
            myRequests.where((l) => l.status == LeaveStatus.pending).length;

        return Scaffold(
          backgroundColor: AppColors.surface,
          body: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverAppBar(
                pinned: true,
                expandedHeight: 230,
                backgroundColor: AppColors.primaryDark,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      Container(color: AppColors.primaryDark),
                      BlobAccentBackdrop(color: AppColors.primary),
                      Positioned.fill(
                        child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Leave Management',
                                  style: AppTextStyles.heading1
                                      .copyWith(color: Colors.white)),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _LeaveCountBubble(
                                    label: 'Balance',
                                    value: '${employee.leaveBalance}d',
                                    icon: Icons.beach_access_rounded,
                                    color: AppColors.accent,
                                  ),
                                  const SizedBox(width: 12),
                                  _LeaveCountBubble(
                                    label: 'Used',
                                    value: '${employee.leaveDaysUsed}d',
                                    icon: Icons.check_circle_outline_rounded,
                                    color: AppColors.success,
                                  ),
                                  const SizedBox(width: 12),
                                  _LeaveCountBubble(
                                    label: 'Pending',
                                    value: '$pendingCount',
                                    icon: Icons.pending_actions_rounded,
                                    color: AppColors.warning,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      ),
                    ],
                  ),
                  collapseMode: CollapseMode.pin,
                ),
                bottom: SegmentedTabBar(
                  controller: _tabCtrl,
                  color: AppColors.primaryDark,
                  labels: [
                    'My Requests',
                    if (_isManager) 'Team Requests',
                  ],
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabCtrl,
              children: [
                _RequestList(requests: myRequests, isMyList: true),
                if (_isManager)
                  FutureBuilder<List<Employee>>(
                    future: _employeesFuture,
                    builder: (context, employeesSnapshot) {
                      final employeesById = {
                        for (final e in employeesSnapshot.data ?? const <Employee>[])
                          e.id: e,
                      };
                      final isOwner =
                          AuthService.instance.currentAccount?.role ==
                              UserRole.owner;
                      return StreamBuilder<List<LeaveRequest>>(
                        stream: AppBackend.leaveRepository.streamAll(),
                        builder: (context, teamSnapshot) {
                          final team = (teamSnapshot.data ?? const <LeaveRequest>[])
                              .where((l) {
                                final requester = employeesById[l.employeeId];
                                if (requester == null) return false;
                                return LeaveApprovalPolicy.canReview(
                                  approver: employee,
                                  requester: requester,
                                  approverIsOwner: isOwner,
                                );
                              })
                              .toList();
                          return _RequestList(
                            requests: team,
                            isMyList: false,
                            onApprove: _approve,
                            onReject: _reject,
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/leave/new'),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text('New Request',
                style: AppTextStyles.button.copyWith(fontSize: 14)),
          ),
        );
      },
    );
  }
}

class _RequestList extends StatelessWidget {
  final List<LeaveRequest> requests;
  final bool isMyList;
  final void Function(LeaveRequest)? onApprove;
  final void Function(LeaveRequest)? onReject;

  const _RequestList({
    required this.requests,
    required this.isMyList,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return const EmptyState(
        icon: Icons.event_busy_rounded,
        title: 'No requests',
        message: 'No leave requests to display.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _LeaveCard(
        request: requests[i],
        showEmployee: !isMyList,
        onApprove: onApprove,
        onReject: onReject,
      ),
    );
  }
}

class _LeaveCard extends StatelessWidget {
  final LeaveRequest request;
  final bool showEmployee;
  final void Function(LeaveRequest)? onApprove;
  final void Function(LeaveRequest)? onReject;

  const _LeaveCard({
    required this.request,
    required this.showEmployee,
    this.onApprove,
    this.onReject,
  });

  Color get _statusColor {
    switch (request.status) {
      case LeaveStatus.approved:
        return AppColors.success;
      case LeaveStatus.rejected:
        return AppColors.danger;
      case LeaveStatus.pending:
        return AppColors.warning;
      case LeaveStatus.cancelled:
        return AppColors.textLight;
    }
  }

  Color get _typeColor {
    switch (request.type) {
      case LeaveType.annual:
        return AppColors.primary;
      case LeaveType.sick:
        return AppColors.danger;
      case LeaveType.maternity:
      case LeaveType.paternity:
        return AppColors.pending;
      case LeaveType.remote:
        return AppColors.accent;
      case LeaveType.unpaid:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM yyyy');
    final canReview = showEmployee &&
        request.status == LeaveStatus.pending &&
        onApprove != null &&
        onReject != null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  request.typeLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: _typeColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              StatusBadge(
                label: request.statusLabel,
                color: _statusColor,
                bgColor: _statusColor.withValues(alpha: 0.12),
              ),
            ],
          ),
          if (showEmployee) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                AvatarWidget(
                  initials: request.employeeName
                      .split(' ')
                      .map((s) => s[0])
                      .join()
                      .substring(0, 2),
                  color: AppColors.accent,
                  size: 30,
                ),
                const SizedBox(width: 8),
                Text(request.employeeName, style: AppTextStyles.body1),
              ],
            ),
          ],
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.date_range_rounded,
                  color: AppColors.textSecondary, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${fmt.format(request.startDate)} → ${fmt.format(request.endDate)}',
                  style: AppTextStyles.body2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${request.durationDays} day${request.durationDays != 1 ? "s" : ""}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (request.reason.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.notes_rounded,
                    color: AppColors.textSecondary, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    request.reason,
                    style: AppTextStyles.body2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (request.approvedBy != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outlined,
                    color: AppColors.textSecondary, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${request.status == LeaveStatus.approved ? "Approved" : "Reviewed"} by ${request.approvedBy}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (canReview) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onReject!(request),
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.danger, size: 18),
                    label: Text('Reject',
                        style: AppTextStyles.button
                            .copyWith(color: AppColors.danger, fontSize: 14)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: AppColors.danger.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onApprove!(request),
                    icon: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 18),
                    label: Text('Approve',
                        style: AppTextStyles.button.copyWith(fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _LeaveCountBubble extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _LeaveCountBubble({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: AppTextStyles.body1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  )),
              Text(label,
                  style: AppTextStyles.caption
                      .copyWith(color: Colors.white60)),
            ],
          ),
        ],
      ),
    );
  }
}
