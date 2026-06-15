import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/data/mock_data.dart';
import '../../core/models/leave_request.dart';
import '../../core/services/auth_service.dart';
import '../../shared/widgets/app_widgets.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  late List<LeaveRequest> _myRequests;
  late List<LeaveRequest> _teamRequests;
  late bool _isManager;

  @override
  void initState() {
    super.initState();
    final auth = AuthService.instance;
    final myId = auth.currentEmployee.id;
    _isManager = auth.isManager;
    _myRequests = MockData.leaveRequests
        .where((l) => l.employeeId == myId)
        .toList();
    _teamRequests = MockData.leaveRequests
        .where((l) => l.employeeId != myId)
        .toList();
    _tabCtrl = TabController(length: _isManager ? 2 : 1, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employee = AuthService.instance.currentEmployee;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 180,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, Color(0xFF283593)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
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
                              value: '${30 - employee.leaveBalance}d',
                              icon: Icons.check_circle_outline_rounded,
                              color: const Color(0xFF66BB6A),
                            ),
                            const SizedBox(width: 12),
                            _LeaveCountBubble(
                              label: 'Pending',
                              value:
                                  '${_myRequests.where((l) => l.status == LeaveStatus.pending).length}',
                              icon: Icons.pending_actions_rounded,
                              color: const Color(0xFFFFA726),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              collapseMode: CollapseMode.pin,
            ),
            title: Text('Leave Management',
                style:
                    AppTextStyles.heading2.copyWith(color: Colors.white)),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(46),
              child: Container(
                color: AppColors.primary,
                child: TabBar(
                  controller: _tabCtrl,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  indicatorColor: Colors.white,
                  indicatorWeight: 2.5,
                  labelStyle: AppTextStyles.label
                      .copyWith(color: Colors.white, letterSpacing: 0.3),
                  tabs: [
                    const Tab(text: 'My Requests'),
                    if (_isManager) const Tab(text: 'Team Requests'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _RequestList(requests: _myRequests, isMyList: true),
            if (_isManager)
              _RequestList(requests: _teamRequests, isMyList: false),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/leave/new'),
        backgroundColor: AppColors.primary,
        icon:
            const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('New Request',
            style: AppTextStyles.button.copyWith(fontSize: 14)),
      ),
    );
  }
}

class _RequestList extends StatelessWidget {
  final List<LeaveRequest> requests;
  final bool isMyList;
  const _RequestList(
      {required this.requests, required this.isMyList});

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
      itemBuilder: (context, i) =>
          _LeaveCard(request: requests[i], showEmployee: !isMyList),
    );
  }
}

class _LeaveCard extends StatelessWidget {
  final LeaveRequest request;
  final bool showEmployee;
  const _LeaveCard(
      {required this.request, required this.showEmployee});

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
