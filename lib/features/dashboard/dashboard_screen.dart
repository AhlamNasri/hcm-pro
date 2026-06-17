import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/employee.dart';
import '../../core/models/leave_request.dart';
import '../../core/models/notification_item.dart';
import '../../core/models/payslip.dart';
import '../../core/models/user_account.dart';
import '../../core/services/app_backend.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/leave_approval_policy.dart';
import '../../shared/widgets/app_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _scrollController = ScrollController();
  late Future<List<Employee>> _employeesFuture;

  @override
  void initState() {
    super.initState();
    _employeesFuture = AppBackend.employeeRepository.getAll();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _approve(LeaveRequest request) async {
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
    final auth = AuthService.instance;
    final employee = auth.currentEmployee;
    final isManager = auth.isManager;
    final now = DateTime.now();
    final greeting = _greeting();

    final roleColor = AppColors.roleColor(auth.currentAccount!.role);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(employee, greeting, now, roleColor),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildRoleBanner(auth.currentAccount!.role),
                const SizedBox(height: 16),
                _buildQuickActions(context, isManager),
                const SizedBox(height: 20),
                if (isManager)
                  _buildManagerSection(context, employee)
                else
                  _buildEmployeeSection(context, employee),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeSection(BuildContext context, Employee employee) {
    return StreamBuilder<List<LeaveRequest>>(
      stream: AppBackend.leaveRepository.streamForEmployee(employee.id),
      builder: (context, leaveSnapshot) {
        final myLeaves = leaveSnapshot.data ?? const <LeaveRequest>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMyStatsGrid(context, employee, myLeaves),
            const SizedBox(height: 20),
            _buildAttendanceSection(employee),
            const SizedBox(height: 20),
            _buildMyLeaveCard(context, myLeaves),
          ],
        );
      },
    );
  }

  Widget _buildManagerSection(BuildContext context, Employee employee) {
    return FutureBuilder<List<Employee>>(
      future: _employeesFuture,
      builder: (context, employeesSnapshot) {
        if (employeesSnapshot.connectionState == ConnectionState.waiting) {
          return Column(
            children: [
              ShimmerBox(height: 140, width: double.infinity),
              const SizedBox(height: 12),
              ShimmerBox(height: 90, width: double.infinity),
            ],
          );
        }
        final allEmployees = employeesSnapshot.data ?? const <Employee>[];
        return StreamBuilder<List<LeaveRequest>>(
          stream: AppBackend.leaveRepository.streamAll(),
          builder: (context, leaveSnapshot) {
            final allLeaves = leaveSnapshot.data ?? const <LeaveRequest>[];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsGrid(context, employee, allEmployees, allLeaves),
                const SizedBox(height: 20),
                _buildAttendanceSection(employee),
                const SizedBox(height: 20),
                _buildHeadcountChart(allEmployees),
                const SizedBox(height: 20),
                _buildPendingLeaveSection(context, employee, allEmployees, allLeaves),
                const SizedBox(height: 20),
                _buildBirthdays(),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildAttendanceSection(Employee employee) {
    return StreamBuilder<List<AttendanceRecord>>(
      stream: AppBackend.payrollRepository.streamAttendanceForEmployee(employee.id),
      builder: (context, snapshot) {
        final records = snapshot.data ?? const <AttendanceRecord>[];
        return _buildAttendanceCard(records);
      },
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildAppBar(Employee employee, String greeting, DateTime now, Color roleColor) {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      backgroundColor: roleColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(color: roleColor),
            BlobAccentBackdrop(color: Colors.white),
            Positioned.fill(
              child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$greeting,',
                          style: AppTextStyles.body1
                              .copyWith(color: Colors.white.withValues(alpha: 0.8)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          employee.firstName,
                          style: AppTextStyles.displayLarge
                              .copyWith(color: Colors.white, fontSize: 24),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                color: Colors.white54, size: 13),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('EEEE, d MMMM yyyy').format(now),
                              style: AppTextStyles.caption
                                  .copyWith(color: Colors.white60),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/notifications'),
                    child: Stack(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.notifications_outlined,
                              color: Colors.white, size: 22),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppColors.danger,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => context.go('/profile'),
                    child: AvatarWidget(
                      initials: employee.initials,
                      color: Colors.white,
                      size: 44,
                    ),
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
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
              color: Colors.white, size: 22),
          onPressed: () => context.go('/notifications'),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildRoleBanner(UserRole role) {
    final color = AppColors.roleColor(role);
    final icon = switch (role) {
      UserRole.owner => Icons.workspace_premium_rounded,
      UserRole.hrManager => Icons.admin_panel_settings_rounded,
      UserRole.manager => Icons.supervisor_account_rounded,
      UserRole.employee => Icons.badge_rounded,
    };
    final label = switch (role) {
      UserRole.owner => 'Logged in as Owner — full access',
      UserRole.hrManager => 'Logged in as HR Manager — full access',
      UserRole.manager => 'Logged in as Manager — team access',
      UserRole.employee => 'Logged in as Employee — personal view',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body2.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyStatsGrid(
      BuildContext context, Employee employee, List<LeaveRequest> myLeaves) {
    final pendingCount =
        myLeaves.where((l) => l.status == LeaveStatus.pending).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Overview', style: AppTextStyles.heading2),
        const SizedBox(height: 12),
        HeroStatCard(
          title: 'Leave Balance',
          value: '${employee.leaveBalance}d',
          icon: Icons.beach_access_rounded,
          color: AppColors.accent,
          subtitle: '$pendingCount pending request${pendingCount == 1 ? '' : 's'}',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'My Requests',
                value: '${myLeaves.length}',
                icon: Icons.event_note_rounded,
                color: AppColors.primary,
                subtitle: '$pendingCount pending',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Performance',
                value: employee.performanceScore.toStringAsFixed(1),
                icon: Icons.star_rounded,
                color: AppColors.warning,
                subtitle: 'out of 5.0',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StatCard(
          title: 'Department',
          value: employee.department.name.toUpperCase(),
          icon: Icons.apartment_rounded,
          color: AppColors.success,
          subtitle: employee.contractLabel,
        ),
      ],
    );
  }

  Widget _buildMyLeaveCard(BuildContext context, List<LeaveRequest> allMyLeaves) {
    final myLeaves = allMyLeaves.take(3).toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'My Leave Requests',
            actionLabel: 'View All',
            onAction: () => context.go('/leave'),
          ),
          const SizedBox(height: 12),
          if (myLeaves.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('No leave requests yet.',
                    style: AppTextStyles.body2),
              ),
            )
          else
            ...myLeaves.map((l) {
              final fmt = DateFormat('d MMM');
              Color sc;
              if (l.statusLabel == 'Approved') {
                sc = AppColors.success;
              } else if (l.statusLabel == 'Rejected') {
                sc = AppColors.danger;
              } else {
                sc = AppColors.warning;
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(width: 6, height: 6,
                        decoration: BoxDecoration(color: sc, shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(l.typeLabel, style: AppTextStyles.body2, overflow: TextOverflow.ellipsis)),
                    Flexible(
                      child: Text('${fmt.format(l.startDate)} – ${fmt.format(l.endDate)}',
                          style: AppTextStyles.caption, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(label: l.statusLabel, color: sc,
                        bgColor: sc.withValues(alpha: 0.1)),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isManager) {
    final actions = [
      _QuickAction(
        icon: Icons.event_note_rounded,
        label: 'Request\nLeave',
        color: AppColors.accent,
        onTap: () => context.go('/leave/new'),
      ),
      _QuickAction(
        icon: Icons.access_time_rounded,
        label: 'My\nAttendance',
        color: AppColors.success,
        onTap: () => context.go('/payroll'),
      ),
      if (isManager)
        _QuickAction(
          icon: Icons.people_alt_rounded,
          label: 'Team\nDirectory',
          color: AppColors.warning,
          onTap: () => context.go('/employees'),
        ),
      _QuickAction(
        icon: Icons.receipt_long_rounded,
        label: 'My\nPayslip',
        color: AppColors.pending,
        onTap: () => context.go('/payroll'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppTextStyles.heading2),
        const SizedBox(height: 12),
        Row(
          children: actions
              .map((a) => Expanded(
                    child: _QuickActionCard(action: a),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, Employee employee,
      List<Employee> allEmployees, List<LeaveRequest> allLeaves) {
    final activeCount =
        allEmployees.where((e) => e.status == EmployeeStatus.active).length;
    final onLeaveCount =
        allEmployees.where((e) => e.status == EmployeeStatus.onLeave).length;
    final employeesById = {for (final e in allEmployees) e.id: e};
    final isOwner =
        AuthService.instance.currentAccount?.role == UserRole.owner;
    final pendingCount = allLeaves.where((l) {
      if (l.status != LeaveStatus.pending) return false;
      final requester = employeesById[l.employeeId];
      if (requester == null) return false;
      return LeaveApprovalPolicy.canReview(
        approver: employee,
        requester: requester,
        approverIsOwner: isOwner,
      );
    }).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Overview',
          actionLabel: 'View All',
          onAction: () => context.go('/employees'),
        ),
        const SizedBox(height: 12),
        HeroStatCard(
          title: 'Pending Leaves — needs your review',
          value: '$pendingCount',
          icon: Icons.pending_actions_rounded,
          color: AppColors.warning,
          subtitle: pendingCount == 0 ? 'All caught up' : 'Tap to review',
          onTap: () => context.go('/leave'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Total Employees',
                value: '${allEmployees.length}',
                icon: Icons.people_rounded,
                color: AppColors.primary,
                subtitle: '$activeCount active',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Active Today',
                value: '$activeCount',
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
                subtitle: '$onLeaveCount on leave',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StatCard(
          title: 'My Leave Balance',
          value: '${employee.leaveBalance}d',
          icon: Icons.beach_access_rounded,
          color: AppColors.accent,
          subtitle: 'Days remaining',
        ),
      ],
    );
  }

  Widget _buildAttendanceCard(List<AttendanceRecord> records) {
    if (records.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: const EmptyState(
          icon: Icons.access_time_rounded,
          title: 'No attendance yet',
          message: 'Check-ins will appear here once recorded.',
        ),
      );
    }
    final totalHours =
        records.fold<double>(0, (sum, r) => sum + r.hoursWorked);
    final avgHours = totalHours / records.length;
    final lateCount = records.where((r) => r.isLate).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('This Week Attendance', style: AppTextStyles.heading2),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${records.length}/5 days',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.success, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _AttendanceStat(
                label: 'Avg Hours/Day',
                value: '${avgHours.toStringAsFixed(1)}h',
                icon: Icons.access_time_rounded,
                color: AppColors.accent,
              ),
              const SizedBox(width: 16),
              _AttendanceStat(
                label: 'Late Arrivals',
                value: '$lateCount day${lateCount != 1 ? 's' : ''}',
                icon: Icons.timer_off_rounded,
                color: lateCount > 0 ? AppColors.warning : AppColors.success,
              ),
              const SizedBox(width: 16),
              _AttendanceStat(
                label: 'On Time Rate',
                value:
                    '${(((records.length - lateCount) / records.length) * 100).toInt()}%',
                icon: Icons.thumb_up_rounded,
                color: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...records.take(3).map((r) {
            final fmt = DateFormat('EEE, d MMM');
            final timeFmt = DateFormat('HH:mm');
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: r.isLate ? AppColors.warning : AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(fmt.format(r.date),
                        style: AppTextStyles.body2),
                  ),
                  if (r.checkIn != null)
                    Text(
                      '${timeFmt.format(r.checkIn!)} - ${r.checkOut != null ? timeFmt.format(r.checkOut!) : "--:--"}',
                      style: AppTextStyles.body2
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  const SizedBox(width: 8),
                  Text(
                    '${r.hoursWorked.toStringAsFixed(1)}h',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeadcountChart(List<Employee> allEmployees) {
    final data = <Department, int>{};
    for (final e in allEmployees) {
      data[e.department] = (data[e.department] ?? 0) + 1;
    }
    final colors = [
      AppColors.primary,
      AppColors.accent,
      AppColors.success,
      AppColors.warning,
      AppColors.pending,
      AppColors.danger,
      AppColors.roleEmployee,
    ];

    final sections = data.entries.toList().asMap().entries.map((e) {
      final count = e.value.value;
      final color = colors[e.key % colors.length];
      return PieChartSectionData(
        value: count.toDouble(),
        color: color,
        radius: 60,
        title: '$count',
        titleStyle: AppTextStyles.body1.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Headcount by Department', style: AppTextStyles.heading2),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 32,
                    sectionsSpace: 3,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: data.entries.toList().asMap().entries.map((e) {
                    final dept = e.value.key;
                    final count = e.value.value;
                    final color = colors[e.key % colors.length];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _deptShort(dept),
                              style: AppTextStyles.body2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '$count',
                            style: AppTextStyles.body2.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _deptShort(Department dept) {
    switch (dept) {
      case Department.executive:
        return 'Executive';
      case Department.hr:
        return 'HR';
      case Department.it:
        return 'IT';
      case Department.finance:
        return 'Finance';
      case Department.marketing:
        return 'Marketing';
      case Department.operations:
        return 'Operations';
      case Department.sales:
        return 'Sales';
      case Department.legal:
        return 'Legal';
    }
  }

  Widget _buildPendingLeaveSection(BuildContext context, Employee employee,
      List<Employee> allEmployees, List<LeaveRequest> allLeaves) {
    final employeesById = {for (final e in allEmployees) e.id: e};
    final isOwner =
        AuthService.instance.currentAccount?.role == UserRole.owner;
    final pending = allLeaves.where((l) {
      if (l.status != LeaveStatus.pending) return false;
      final requester = employeesById[l.employeeId];
      if (requester == null) return false;
      return LeaveApprovalPolicy.canReview(
        approver: employee,
        requester: requester,
        approverIsOwner: isOwner,
      );
    }).toList();

    return Column(
      children: [
        SectionHeader(
          title: 'Pending Approvals',
          actionLabel: 'View All',
          onAction: () => context.go('/leave'),
        ),
        const SizedBox(height: 12),
        if (pending.isEmpty)
          const EmptyState(
            icon: Icons.check_circle_rounded,
            title: 'All caught up!',
            message: 'No pending leave requests.',
          )
        else
          ...pending.map((l) => _PendingLeaveCard(
                request: l,
                onApprove: _approve,
                onReject: _reject,
              )),
      ],
    );
  }

  Widget _buildBirthdays() {
    final upcoming = [
      ('Fatima Zahra', 'IT', DateTime(2026, 6, 22), AppColors.accent),
      ('Karim Mansouri', 'Finance', DateTime(2026, 6, 28), AppColors.success),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.accent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLighter),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cake_rounded,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('Upcoming Birthdays', style: AppTextStyles.heading2),
            ],
          ),
          const SizedBox(height: 12),
          ...upcoming.map((b) {
            final daysUntil = b.$3.difference(DateTime.now()).inDays;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  AvatarWidget(
                    initials: b.$1.split(' ').map((s) => s[0]).join(),
                    color: b.$4,
                    size: 38,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b.$1, style: AppTextStyles.body1),
                        Text(b.$2, style: AppTextStyles.body2),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLighter,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      daysUntil == 0
                          ? '🎂 Today!'
                          : 'in $daysUntil days',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});
}

class _QuickActionCard extends StatelessWidget {
  final _QuickAction action;
  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: action.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: action.color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(action.icon, color: action.color, size: 26),
              const SizedBox(height: 6),
              Text(
                action.label,
                style: AppTextStyles.caption.copyWith(
                  color: action.color,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttendanceStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _AttendanceStat(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value,
              style: AppTextStyles.body2
                  .copyWith(fontWeight: FontWeight.w700, color: color, fontSize: 13),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center),
          Text(label,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _PendingLeaveCard extends StatefulWidget {
  final LeaveRequest request;
  final Future<void> Function(LeaveRequest) onApprove;
  final Future<void> Function(LeaveRequest) onReject;

  const _PendingLeaveCard({
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<_PendingLeaveCard> createState() => _PendingLeaveCardState();
}

class _PendingLeaveCardState extends State<_PendingLeaveCard> {
  bool _isProcessing = false;

  Future<void> _handle(Future<void> Function(LeaveRequest) action) async {
    setState(() => _isProcessing = true);
    await action(widget.request);
    // No setState afterwards: the pending list this card is rendered from
    // is fed by a stream, so once the backend write lands the card simply
    // stops being included in the next snapshot.
  }

  String _initials(String name) {
    final letters = name.split(' ').where((s) => s.isNotEmpty).map((s) => s[0]);
    final initials = letters.take(2).join();
    return initials.isEmpty ? '?' : initials.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.request;
    final fmt = DateFormat('d MMM');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          AvatarWidget(
            initials: _initials(l.employeeName),
            color: AppColors.accent,
            size: 40,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.employeeName, style: AppTextStyles.body1),
                Text(
                  '${l.typeLabel} • ${fmt.format(l.startDate)} – ${fmt.format(l.endDate)} (${l.durationDays}d)',
                  style: AppTextStyles.body2,
                ),
              ],
            ),
          ),
          if (_isProcessing)
            const SizedBox(
              width: 32,
              height: 32,
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            Row(
              children: [
                _ActionBtn(
                  icon: Icons.close_rounded,
                  color: AppColors.danger,
                  onTap: () => _handle(widget.onReject),
                ),
                const SizedBox(width: 6),
                _ActionBtn(
                  icon: Icons.check_rounded,
                  color: AppColors.success,
                  onTap: () => _handle(widget.onApprove),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
