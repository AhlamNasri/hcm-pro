import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/data/mock_data.dart';
import '../../core/models/employee.dart';
import '../../shared/widgets/app_widgets.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  Department? _selectedDept;
  EmployeeStatus? _selectedStatus;
  String _query = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Employee> get _filtered {
    return MockData.employees.where((e) {
      final matchesQuery = _query.isEmpty ||
          e.fullName.toLowerCase().contains(_query) ||
          e.email.toLowerCase().contains(_query) ||
          e.position.toLowerCase().contains(_query);
      final matchesDept =
          _selectedDept == null || e.department == _selectedDept;
      final matchesStatus =
          _selectedStatus == null || e.status == _selectedStatus;
      return matchesQuery && matchesDept && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.primary,
            expandedHeight: 110,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, Color(0xFF283593)],
                  ),
                ),
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Team Directory',
                        style: AppTextStyles.heading1
                            .copyWith(color: Colors.white)),
                    Text(
                      '${MockData.employees.length} employees',
                      style: AppTextStyles.body2
                          .copyWith(color: Colors.white60),
                    ),
                  ],
                ),
              ),
              collapseMode: CollapseMode.pin,
            ),
            title: Text('Team Directory',
                style: AppTextStyles.heading2.copyWith(color: Colors.white)),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list_rounded,
                    color: Colors.white),
                onPressed: _showFilterSheet,
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: AppColors.primary,
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  indicatorColor: Colors.white,
                  indicatorWeight: 2.5,
                  labelStyle: AppTextStyles.label
                      .copyWith(color: Colors.white, letterSpacing: 0.3),
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Active'),
                    Tab(text: 'On Leave'),
                    Tab(text: 'Inactive'),
                  ],
                  onTap: (i) {
                    setState(() {
                      _selectedStatus = i == 0
                          ? null
                          : i == 1
                              ? EmployeeStatus.active
                              : i == 2
                                  ? EmployeeStatus.onLeave
                                  : EmployeeStatus.inactive;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search employees...',
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.textSecondary, size: 20),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: AppColors.textSecondary, size: 18),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (_filtered.isEmpty)
              const Expanded(
                child: EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No results',
                  message: 'Try a different search or filter.',
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, i) =>
                      _EmployeeCard(employee: _filtered[i]),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEmployee(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: Text('Add Employee',
            style: AppTextStyles.button.copyWith(fontSize: 14)),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _FilterSheet(
        selectedDept: _selectedDept,
        onDeptChanged: (d) => setState(() => _selectedDept = d),
        onClear: () => setState(() {
          _selectedDept = null;
          _selectedStatus = null;
          _tabController.animateTo(0);
        }),
      ),
    );
  }

  void _showAddEmployee(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Add employee feature coming soon',
            style: AppTextStyles.body2.copyWith(color: Colors.white)),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final Employee employee;
  const _EmployeeCard({required this.employee});

  Color get _statusColor {
    switch (employee.status) {
      case EmployeeStatus.active:
        return AppColors.success;
      case EmployeeStatus.onLeave:
        return AppColors.warning;
      case EmployeeStatus.inactive:
        return AppColors.textLight;
    }
  }

  String get _statusLabel {
    switch (employee.status) {
      case EmployeeStatus.active:
        return 'Active';
      case EmployeeStatus.onLeave:
        return 'On Leave';
      case EmployeeStatus.inactive:
        return 'Inactive';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/employees/${employee.id}'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            AvatarWidget(
              initials: employee.initials,
              color: employee.avatarColorValue,
              size: 48,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(employee.fullName,
                            style: AppTextStyles.body1.copyWith(
                                fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis),
                      ),
                      StatusBadge(
                        label: _statusLabel,
                        color: _statusColor,
                        bgColor: _statusColor.withValues(alpha: 0.12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(employee.position,
                      style: AppTextStyles.body2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Tag(
                        label: employee.departmentLabel
                            .split(' ')
                            .first,
                        color: employee.avatarColorValue,
                      ),
                      const SizedBox(width: 6),
                      _Tag(
                        label: employee.contractLabel,
                        color: AppColors.accent,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Color(0xFFFFB300), size: 14),
                          const SizedBox(width: 2),
                          Text(
                            employee.performanceScore.toStringAsFixed(1),
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  final Department? selectedDept;
  final ValueChanged<Department?> onDeptChanged;
  final VoidCallback onClear;

  const _FilterSheet({
    required this.selectedDept,
    required this.onDeptChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filter by Department', style: AppTextStyles.heading2),
              TextButton(
                onPressed: () {
                  onClear();
                  Navigator.pop(context);
                },
                child: Text('Clear all',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DeptChip(
                label: 'All',
                isSelected: selectedDept == null,
                onTap: () {
                  onDeptChanged(null);
                  Navigator.pop(context);
                },
              ),
              ...Department.values.map((d) {
                final label = d.name.toUpperCase();
                return _DeptChip(
                  label: label,
                  isSelected: selectedDept == d,
                  onTap: () {
                    onDeptChanged(d);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _DeptChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DeptChip(
      {required this.label,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.primaryLighter,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: isSelected ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }
}
