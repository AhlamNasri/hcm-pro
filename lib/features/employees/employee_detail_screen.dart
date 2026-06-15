import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../core/theme/app_theme.dart';
import '../../core/data/mock_data.dart';
import '../../core/models/employee.dart';
import '../../shared/widgets/app_widgets.dart';

class EmployeeDetailScreen extends StatelessWidget {
  final String employeeId;
  const EmployeeDetailScreen({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context) {
    final employee = MockData.employees.firstWhere(
      (e) => e.id == employeeId,
      orElse: () => MockData.employees.first,
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          _buildHeader(context, employee),
          SliverPadding(
            padding: const EdgeInsets.all(16),
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
        onPressed: () {},
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.message_rounded, color: Colors.white),
        label: Text('Message',
            style: AppTextStyles.button.copyWith(fontSize: 14)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Employee employee) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, Color(0xFF283593)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
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
        collapseMode: CollapseMode.pin,
      ),
      title: Text(employee.fullName,
          style: AppTextStyles.heading2.copyWith(color: Colors.white)),
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
                          color: const Color(0xFFFFB300),
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
          _SkillBar(label: 'Technical Skills', value: 0.85, color: AppColors.primary),
          const SizedBox(height: 8),
          _SkillBar(label: 'Communication', value: 0.78, color: AppColors.accent),
          const SizedBox(height: 8),
          _SkillBar(label: 'Leadership', value: 0.72, color: AppColors.success),
          const SizedBox(height: 8),
          _SkillBar(label: 'Punctuality', value: 0.90, color: AppColors.warning),
        ],
      ),
    );
  }

  Widget _buildLeaveCard(Employee employee) {
    final leaves = MockData.leaveRequests
        .where((l) => l.employeeId == employee.id)
        .toList();

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
            percent: (30 - employee.leaveBalance) / 30,
            progressColor: AppColors.accent,
            backgroundColor: AppColors.accentLight,
            barRadius: const Radius.circular(8),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Used: ${30 - employee.leaveBalance} days',
                  style: AppTextStyles.caption),
              Text('Total: 30 days', style: AppTextStyles.caption),
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
        color = const Color(0xFF66BB6A);
        label = '● Active';
        break;
      case EmployeeStatus.onLeave:
        color = const Color(0xFFFFA726);
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
