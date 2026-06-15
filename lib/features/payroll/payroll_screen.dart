import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/data/mock_data.dart';
import '../../core/services/auth_service.dart';
import '../../core/models/payslip.dart';
import '../../shared/widgets/app_widgets.dart';

class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  int _selectedPayslipIndex = 0;
  late List<dynamic> _payslips;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    final uid = AuthService.instance.currentEmployee.id;
    _payslips = MockData.payslips.where((p) => p.employeeId == uid).toList();
    if (_payslips.isEmpty) _payslips = MockData.payslips;
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Payslip get _currentPayslip => _payslips[_selectedPayslipIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
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
                        Text('Payroll & Payslips',
                            style: AppTextStyles.heading1
                                .copyWith(color: Colors.white)),
                        const SizedBox(height: 6),
                        Text(
                          'Your salary history & attendance',
                          style: AppTextStyles.body2
                              .copyWith(color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              collapseMode: CollapseMode.pin,
            ),
            title: Text('Payroll',
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
                  tabs: const [
                    Tab(text: 'Payslips'),
                    Tab(text: 'Attendance'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _buildPayslipsTab(),
            _buildAttendanceTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildPayslipsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPayslipSelector(),
          const SizedBox(height: 16),
          _buildNetSalaryCard(),
          const SizedBox(height: 16),
          _buildBreakdownCard(),
          const SizedBox(height: 16),
          _buildSalaryTrendChart(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildPayslipSelector() {
    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _payslips.length,
        itemBuilder: (context, i) {
          final p = _payslips[i];
          final selected = i == _selectedPayslipIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedPayslipIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color:
                    selected ? AppColors.primary : AppColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : AppColors.divider,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    p.monthName.substring(0, 3),
                    style: AppTextStyles.body1.copyWith(
                      color: selected
                          ? Colors.white
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${p.year}',
                    style: AppTextStyles.caption.copyWith(
                      color: selected
                          ? Colors.white70
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNetSalaryCard() {
    final p = _currentPayslip;
    final currFmt = NumberFormat('#,###', 'fr');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF283593)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Net Salary',
                        style: AppTextStyles.body2
                            .copyWith(color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text(
                      '${currFmt.format(p.netSalary.toInt())} MAD',
                      style: AppTextStyles.stat.copyWith(
                        color: Colors.white,
                        fontSize: 28,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _NetItem(
                  label: 'Gross',
                  value: currFmt.format(p.grossSalary.toInt()),
                  icon: Icons.trending_up_rounded,
                ),
              ),
              Expanded(
                child: _NetItem(
                  label: 'Deductions',
                  value: '-${currFmt.format(p.totalDeductions.toInt())}',
                  icon: Icons.remove_circle_outline_rounded,
                ),
              ),
              Expanded(
                child: _NetItem(
                  label: 'Period',
                  value: p.period,
                  icon: Icons.calendar_month_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard() {
    final p = _currentPayslip;
    final currFmt = NumberFormat('#,###');

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
          Text('Pay Breakdown', style: AppTextStyles.heading2),
          const SizedBox(height: 16),
          _SectionTitle(label: 'EARNINGS', color: AppColors.success),
          const SizedBox(height: 8),
          _PayRow(
            label: 'Base Salary',
            value: '${currFmt.format(p.baseSalary.toInt())} MAD',
            isBold: true,
          ),
          if (p.bonus > 0)
            _PayRow(
              label: 'Bonus',
              value: '+${currFmt.format(p.bonus.toInt())} MAD',
              color: AppColors.success,
            ),
          if (p.overtime > 0)
            _PayRow(
              label: 'Overtime',
              value: '+${currFmt.format(p.overtime.toInt())} MAD',
              color: AppColors.success,
            ),
          _PayRow(
            label: 'Transport Allowance',
            value: '+${currFmt.format(p.transportAllowance.toInt())} MAD',
            color: AppColors.success,
          ),
          _PayRow(
            label: 'Meal Allowance',
            value: '+${currFmt.format(p.mealAllowance.toInt())} MAD',
            color: AppColors.success,
          ),
          const SizedBox(height: 4),
          _PayRow(
            label: 'Gross Total',
            value: '${currFmt.format(p.grossSalary.toInt())} MAD',
            isBold: true,
            color: AppColors.success,
            isTotal: true,
          ),
          const SizedBox(height: 14),
          _SectionTitle(label: 'DEDUCTIONS', color: AppColors.danger),
          const SizedBox(height: 8),
          _PayRow(
            label: 'Social Security (CNSS)',
            value: '-${currFmt.format(p.socialSecurity.toInt())} MAD',
            color: AppColors.danger,
          ),
          _PayRow(
            label: 'Income Tax (IR)',
            value: '-${currFmt.format(p.incomeTax.toInt())} MAD',
            color: AppColors.danger,
          ),
          if (p.otherDeductions > 0)
            _PayRow(
              label: 'Other Deductions',
              value: '-${currFmt.format(p.otherDeductions.toInt())} MAD',
              color: AppColors.danger,
            ),
          const SizedBox(height: 4),
          _PayRow(
            label: 'Total Deductions',
            value: '-${currFmt.format(p.totalDeductions.toInt())} MAD',
            isBold: true,
            color: AppColors.danger,
            isTotal: true,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('NET SALARY',
                    style: AppTextStyles.heading3
                        .copyWith(color: AppColors.primary)),
                Text(
                  '${currFmt.format(p.netSalary.toInt())} MAD',
                  style: AppTextStyles.heading2
                      .copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildDeductionPie(p),
        ],
      ),
    );
  }

  Widget _buildDeductionPie(Payslip p) {
    final sections = [
      PieChartSectionData(
        value: p.netSalary,
        color: AppColors.success,
        radius: 45,
        title: 'Net\n${(p.netSalary / p.grossSalary * 100).toInt()}%',
        titleStyle: AppTextStyles.caption
            .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
      ),
      PieChartSectionData(
        value: p.socialSecurity,
        color: AppColors.danger.withValues(alpha: 0.7),
        radius: 40,
        title: 'CNSS',
        titleStyle: AppTextStyles.caption.copyWith(color: Colors.white),
      ),
      PieChartSectionData(
        value: p.incomeTax,
        color: AppColors.warning.withValues(alpha: 0.8),
        radius: 40,
        title: 'IR',
        titleStyle: AppTextStyles.caption.copyWith(color: Colors.white),
      ),
    ];

    return Row(
      children: [
        SizedBox(
          width: 130,
          height: 130,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 20,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LegendItem(color: AppColors.success, label: 'Net Salary'),
              const SizedBox(height: 8),
              _LegendItem(
                  color: AppColors.danger.withValues(alpha: 0.7),
                  label: 'CNSS'),
              const SizedBox(height: 8),
              _LegendItem(
                  color: AppColors.warning.withValues(alpha: 0.8),
                  label: 'Income Tax (IR)'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSalaryTrendChart() {
    final spots = _payslips.reversed.toList().asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.netSalary / 1000);
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
          Text('Salary Trend (6 months)', style: AppTextStyles.heading2),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color:
                          AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.divider,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, _) => Text(
                        '${value.toInt()}k',
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final payslip = _payslips.reversed
                            .toList()[value.toInt()];
                        return Text(
                          payslip.monthName.substring(0, 3),
                          style: AppTextStyles.caption,
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab() {
    final records = MockData.attendance;
    final fmt = DateFormat('EEEE, d MMMM');
    final timeFmt = DateFormat('HH:mm');
    final totalHours = records.fold(0.0, (s, r) => s + r.hoursWorked);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Days Present',
                  value: '${records.where((r) => !r.isAbsent).length}',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Total Hours',
                  value: '${totalHours.toStringAsFixed(1)}h',
                  icon: Icons.access_time_rounded,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('This Week', style: AppTextStyles.heading2),
          const SizedBox(height: 12),
          ...records.map((r) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 50,
                      decoration: BoxDecoration(
                        color: r.isAbsent
                            ? AppColors.danger
                            : r.isLate
                                ? AppColors.warning
                                : AppColors.success,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(fmt.format(r.date),
                              style: AppTextStyles.body1),
                          const SizedBox(height: 4),
                          if (r.isAbsent)
                            Text('Absent',
                                style: AppTextStyles.body2.copyWith(
                                    color: AppColors.danger))
                          else
                            Text(
                              '${r.checkIn != null ? timeFmt.format(r.checkIn!) : "--:--"} → ${r.checkOut != null ? timeFmt.format(r.checkOut!) : "--:--"}',
                              style: AppTextStyles.body2,
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${r.hoursWorked.toStringAsFixed(1)}h',
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        if (r.isLate)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warningLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Late',
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _NetItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _NetItem(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(height: 4),
        Text(value,
            style: AppTextStyles.body2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            )),
        Text(label,
            style: AppTextStyles.caption.copyWith(color: Colors.white60)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionTitle({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: AppTextStyles.label
            .copyWith(color: color, letterSpacing: 1.0));
  }
}

class _PayRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? color;
  final bool isTotal;

  const _PayRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.color,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTotal ? 6 : 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold
                ? AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)
                : AppTextStyles.body2,
          ),
          Text(
            value,
            style: AppTextStyles.body1.copyWith(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: AppTextStyles.body2,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
