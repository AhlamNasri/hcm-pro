import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/employee.dart';
import '../../core/models/leave_request.dart';
import '../../core/models/payslip.dart';
import '../../core/services/app_backend.dart';
import '../../shared/widgets/app_widgets.dart';
import 'add_employee_sheet.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final String employeeId;
  const EmployeeDetailScreen({super.key, required this.employeeId});

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  Employee? _employee;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final employee = await AppBackend.employeeRepository.getById(widget.employeeId);
    if (!mounted) return;
    setState(() {
      _employee = employee;
      _isLoading = false;
    });
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTextStyles.body2.copyWith(color: Colors.white)),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showMessageDialog(Employee employee) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Contact ${employee.firstName}', style: AppTextStyles.heading2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ContactRow(icon: Icons.email_outlined, value: employee.email),
            const SizedBox(height: 10),
            _ContactRow(icon: Icons.phone_outlined, value: employee.phone),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: AppTextStyles.body1.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Future<void> _showMoreMenu(Employee employee) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
              title: Text('Edit Employee', style: AppTextStyles.body1),
              onTap: () => Navigator.pop(ctx, 'edit'),
            ),
            ListTile(
              leading: Icon(
                employee.status == EmployeeStatus.inactive
                    ? Icons.check_circle_outline_rounded
                    : Icons.block_rounded,
                color: employee.status == EmployeeStatus.inactive
                    ? AppColors.success
                    : AppColors.danger,
              ),
              title: Text(
                employee.status == EmployeeStatus.inactive
                    ? 'Activate Employee'
                    : 'Deactivate Employee',
                style: AppTextStyles.body1,
              ),
              onTap: () => Navigator.pop(ctx, 'toggle'),
            ),
          ],
        ),
      ),
    );

    if (!mounted) return;

    if (action == 'edit') {
      final updated = await showEditEmployeeSheet(context, employee);
      if (updated != null) {
        await AppBackend.employeeRepository.update(updated);
        await _load();
        if (mounted) _showSnack('Employee updated');
      }
    } else if (action == 'toggle') {
      final newStatus = employee.status == EmployeeStatus.inactive
          ? EmployeeStatus.active
          : EmployeeStatus.inactive;
      await AppBackend.employeeRepository.update(employee.copyWith(status: newStatus));
      await _load();
      if (mounted) {
        _showSnack(newStatus == EmployeeStatus.active
            ? 'Employee activated'
            : 'Employee deactivated');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ShimmerBox(height: 160, width: double.infinity, borderRadius: BorderRadius.circular(18)),
                const SizedBox(height: 16),
                const Expanded(child: ShimmerListPlaceholder(itemCount: 3, itemHeight: 120)),
              ],
            ),
          ),
        ),
      );
    }
    final employee = _employee;
    if (employee == null) {
      return Scaffold(
        appBar: HCMAppBar(title: 'Employee', showBackButton: true),
        body: const EmptyState(
          icon: Icons.person_off_rounded,
          title: 'Employee not found',
          message: 'This employee record could not be loaded.',
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          _buildHeader(context, employee),
          SliverToBoxAdapter(child: _buildQuickStatsOverlap(employee)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildInfoCard(employee),
                const SizedBox(height: 16),
                _buildPerformanceCard(employee),
                const SizedBox(height: 16),
                _buildLeaveCard(employee),
                const SizedBox(height: 16),
                _buildContactCard(employee),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMessageDialog(employee),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.message_rounded, color: Colors.white),
        label: Text('Message',
            style: AppTextStyles.button.copyWith(fontSize: 14)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Employee employee) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primaryDark,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
          onPressed: () => _showMoreMenu(employee),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(color: AppColors.primaryDark),
            BlobAccentBackdrop(color: employee.avatarColorValue),
            Positioned.fill(
              child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AvatarWidget(
                  initials: employee.initials,
                  color: Colors.white,
                  size: 80,
                ),
                const SizedBox(height: 12),
                Text(
                  employee.fullName,
                  style: AppTextStyles.heading1
                      .copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  employee.position,
                  style: AppTextStyles.body1
                      .copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 6),
                _StatusChip(employee: employee),
              ],
            ),
          ),
          ),
          ],
        ),
        collapseMode: CollapseMode.pin,
      ),
    );
  }

  /// A card that peeks above the fold, overlapping the cover header — the
  /// distinct structural signature of this screen (vs. the dashboard's flat
  /// stat grid or the profile's connected stats row).
  Widget _buildQuickStatsOverlap(Employee employee) {
    final yearsAtCompany =
        DateTime.now().difference(employee.hireDate).inDays ~/ 365;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, -28, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ConnectedStat(
              icon: Icons.business_center_rounded,
              value: '$yearsAtCompany',
              label: yearsAtCompany == 1 ? 'Year here' : 'Years here',
              color: AppColors.primary,
            ),
          ),
          const ConnectedStatDivider(),
          Expanded(
            child: ConnectedStat(
              icon: Icons.beach_access_rounded,
              value: '${employee.leaveBalance}d',
              label: 'Leave left',
              color: AppColors.accent,
            ),
          ),
          const ConnectedStatDivider(),
          Expanded(
            child: ConnectedStat(
              icon: Icons.star_rounded,
              value: employee.performanceScore.toStringAsFixed(1),
              label: 'Performance',
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Employee employee) {
    final fmt = DateFormat('d MMMM yyyy');
    final yearsAtCompany = DateTime.now()
        .difference(employee.hireDate)
        .inDays ~/
        365;

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
            children: [
              const Icon(Icons.badge_rounded,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text('Employee Information', style: AppTextStyles.heading3),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          _InfoRow2(label: 'Employee ID', value: employee.id),
          _InfoRow2(
              label: 'Department', value: employee.departmentLabel),
          _InfoRow2(label: 'Contract', value: employee.contractLabel),
          _InfoRow2(
              label: 'Hire Date', value: fmt.format(employee.hireDate)),
          _InfoRow2(
              label: 'Experience',
              value: '$yearsAtCompany year${yearsAtCompany != 1 ? "s" : ""} at company'),
          _InfoRow2(
              label: 'Monthly Salary',
              value:
                  '${NumberFormat('#,###').format(employee.salary)} MAD'),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard(Employee employee) {
    return StreamBuilder<List<AttendanceRecord>>(
      stream: AppBackend.payrollRepository.streamAttendanceForEmployee(employee.id),
      builder: (context, snapshot) {
        final records = snapshot.data ?? const <AttendanceRecord>[];
        final onTimeRate =
            records.isEmpty ? null : (records.where((r) => !r.isLate).length / records.length);
        return _buildPerformanceCardContent(employee, onTimeRate);
      },
    );
  }

  Widget _buildPerformanceCardContent(Employee employee, double? onTimeRate) {
    final yearsAtCompany =
        DateTime.now().difference(employee.hireDate).inDays / 365;
    final tenureProgress = (yearsAtCompany / 5).clamp(0.0, 1.0);
    final leaveUtilization = employee.totalLeaveAllowance == 0
        ? 0.0
        : (employee.leaveDaysUsed / employee.totalLeaveAllowance).clamp(0.0, 1.0);

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
            children: [
              const Icon(Icons.star_rounded,
                  color: AppColors.warning, size: 18),
              const SizedBox(width: 8),
              Text('Performance', style: AppTextStyles.heading3),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.performanceScore.toStringAsFixed(1),
                      style: AppTextStyles.stat.copyWith(
                        color: AppColors.warning,
                        fontSize: 36,
                      ),
                    ),
                    Text('Overall Score (out of 5)',
                        style: AppTextStyles.body2),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (i) {
                        final filled =
                            i < employee.performanceScore.floor();
                        final half = !filled &&
                            i < employee.performanceScore;
                        return Icon(
                          half
                              ? Icons.star_half_rounded
                              : filled
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                          color: AppColors.warning,
                          size: 20,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              CircularPercentIndicator(
                radius: 50,
                lineWidth: 8,
                percent: employee.performanceScore / 5,
                center: Text(
                  '${(employee.performanceScore / 5 * 100).toInt()}%',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.warning,
                  ),
                ),
                progressColor: AppColors.warning,
                backgroundColor: AppColors.warningLight,
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SkillBar(label: 'Tenure (of 5y)', value: tenureProgress, color: AppColors.primary),
          const SizedBox(height: 8),
          _SkillBar(label: 'Leave Utilization', value: leaveUtilization, color: AppColors.accent),
          const SizedBox(height: 8),
          if (onTimeRate != null)
            _SkillBar(label: 'On-Time Rate', value: onTimeRate, color: AppColors.success)
          else
            Text('On-Time Rate: no attendance recorded yet',
                style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildLeaveCard(Employee employee) {
    return StreamBuilder<List<LeaveRequest>>(
      stream: AppBackend.leaveRepository.streamForEmployee(employee.id),
      builder: (context, snapshot) {
        final leaves = snapshot.data ?? const <LeaveRequest>[];
        return _buildLeaveCardContent(employee, leaves);
      },
    );
  }

  Widget _buildLeaveCardContent(Employee employee, List<LeaveRequest> leaves) {
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
              Row(
                children: [
                  const Icon(Icons.event_note_rounded,
                      color: AppColors.accent, size: 18),
                  const SizedBox(width: 8),
                  Text('Leave Information', style: AppTextStyles.heading3),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${employee.leaveBalance} days left',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearPercentIndicator(
            lineHeight: 8,
            percent: employee.leaveDaysUsed / employee.totalLeaveAllowance,
            progressColor: AppColors.accent,
            backgroundColor: AppColors.accentLight,
            barRadius: const Radius.circular(8),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Used: ${employee.leaveDaysUsed} days',
                  style: AppTextStyles.caption),
              Text('Total: ${employee.totalLeaveAllowance} days',
                  style: AppTextStyles.caption),
            ],
          ),
          if (leaves.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Text('Recent Requests', style: AppTextStyles.label),
            const SizedBox(height: 8),
            ...leaves.take(2).map((l) {
              final fmt = DateFormat('d MMM');
              Color statusColor;
              if (l.statusLabel == 'Approved') {
                statusColor = AppColors.success;
              } else if (l.statusLabel == 'Rejected') {
                statusColor = AppColors.danger;
              } else {
                statusColor = AppColors.warning;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(l.typeLabel,
                            style: AppTextStyles.body2,
                            overflow: TextOverflow.ellipsis)),
                    Flexible(
                      child: Text(
                        '${fmt.format(l.startDate)} – ${fmt.format(l.endDate)}',
                        style: AppTextStyles.caption,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    StatusBadge(
                      label: l.statusLabel,
                      color: statusColor,
                      bgColor: statusColor.withValues(alpha: 0.1),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildContactCard(Employee employee) {
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
            children: [
              const Icon(Icons.contact_phone_rounded,
                  color: AppColors.success, size: 18),
              const SizedBox(width: 8),
              Text('Contact', style: AppTextStyles.heading3),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 10),
          InfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: employee.email,
            iconColor: AppColors.primary,
          ),
          const Divider(height: 1),
          InfoRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: employee.phone,
            iconColor: AppColors.success,
          ),
        ],
      ),
    );
  }
}

class _InfoRow2 extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow2({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: AppTextStyles.body2),
          ),
          Expanded(
            child: Text(value,
                style: AppTextStyles.body1
                    .copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final Employee employee;
  const _StatusChip({required this.employee});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (employee.status) {
      case EmployeeStatus.active:
        color = AppColors.success;
        label = '● Active';
        break;
      case EmployeeStatus.onLeave:
        color = AppColors.warning;
        label = '● On Leave';
        break;
      case EmployeeStatus.inactive:
        color = Colors.white38;
        label = '● Inactive';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white30),
      ),
      child: Text(label,
          style: AppTextStyles.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          )),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String value;
  const _ContactRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(child: Text(value, style: AppTextStyles.body1)),
        IconButton(
          icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.primary),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Copied to clipboard',
                    style: AppTextStyles.body2.copyWith(color: Colors.white)),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SkillBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _SkillBar(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: AppTextStyles.body2),
        ),
        Expanded(
          child: LinearPercentIndicator(
            lineHeight: 6,
            percent: value,
            progressColor: color,
            backgroundColor: color.withValues(alpha: 0.12),
            barRadius: const Radius.circular(6),
            padding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text(
            '${(value * 100).toInt()}%',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

