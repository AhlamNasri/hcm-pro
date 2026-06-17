import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/leave_request.dart';
import '../../core/models/notification_item.dart';
import '../../core/models/user_account.dart';
import '../../core/services/app_backend.dart';
import '../../core/services/auth_service.dart';
import '../../shared/widgets/app_widgets.dart';

const _reasonRequiredTypes = {
  LeaveType.sick,
  LeaveType.maternity,
  LeaveType.paternity,
  LeaveType.unpaid,
};

class LeaveRequestForm extends StatefulWidget {
  const LeaveRequestForm({super.key});

  @override
  State<LeaveRequestForm> createState() => _LeaveRequestFormState();
}

class _LeaveRequestFormState extends State<LeaveRequestForm> {
  LeaveType _selectedType = LeaveType.annual;
  DateTime? _startDate;
  DateTime? _endDate;
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;

  int get _durationDays {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? now)
          : (_endDate ?? (_startDate ?? now).add(const Duration(days: 1))),
      firstDate: now,
      lastDate: DateTime(now.year + 1, 12, 31),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
      } else {
        _endDate = picked;
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: AppTextStyles.body2.copyWith(color: Colors.white)),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _submit() async {
    if (_startDate == null || _endDate == null) {
      _showError('Please select dates');
      return;
    }
    if (_reasonRequiredTypes.contains(_selectedType) &&
        _reasonController.text.trim().isEmpty) {
      _showError('A reason is required for ${_selectedType.name} leave');
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final employee = AuthService.instance.currentEmployee;
      // The Owner has no one above them to approve a request, so their
      // leave is self-approved and recorded immediately instead of sitting
      // pending forever with no possible reviewer.
      final isOwner =
          AuthService.instance.currentAccount?.role == UserRole.owner;
      final request = LeaveRequest(
        id: 'LR${DateTime.now().millisecondsSinceEpoch}',
        employeeId: employee.id,
        employeeName: employee.fullName,
        type: _selectedType,
        status: isOwner ? LeaveStatus.approved : LeaveStatus.pending,
        startDate: _startDate!,
        endDate: _endDate!,
        reason: _reasonController.text.trim(),
        requestedAt: DateTime.now(),
        approvedBy: isOwner ? '${employee.fullName} (Owner)' : null,
      );
      await AppBackend.leaveRepository.create(request);
      if (isOwner) {
        final newBalance = employee.leaveBalance - request.durationDays;
        await AppBackend.employeeRepository.update(
            employee.copyWith(leaveBalance: newBalance < 0 ? 0 : newBalance));
      } else {
        final approverId = employee.managerId.isNotEmpty
            ? employee.managerId
            : await AppBackend.authRepository.findOwnerEmployeeId();
        if (approverId != null) {
          await AppBackend.notificationRepository.create(NotificationItem(
            id: 'NTF${DateTime.now().microsecondsSinceEpoch}',
            userId: approverId,
            title: 'New Leave Request',
            body: '${employee.fullName} requested ${request.durationDays} '
                'day${request.durationDays == 1 ? '' : 's'} of '
                '${request.typeLabel.toLowerCase()}.',
            type: NotificationType.leavePending,
            createdAt: DateTime.now(),
          ));
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                    isOwner
                        ? 'Leave recorded — no approval needed.'
                        : 'Leave request submitted successfully!',
                    style: AppTextStyles.body2
                        .copyWith(color: Colors.white),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
      context.pop();
    } catch (e) {
      if (mounted) _showError('Could not submit request: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMMM yyyy');
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: HCMAppBar(
        title: 'New Leave Request',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLeaveTypeSection(),
            const SizedBox(height: 16),
            _buildDateSection(fmt),
            const SizedBox(height: 16),
            if (_startDate != null && _endDate != null)
              _buildSummaryCard(),
            if (_startDate != null && _endDate != null)
              const SizedBox(height: 16),
            _buildReasonSection(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text('Submit Request', style: AppTextStyles.button),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveTypeSection() {
    final labels = {
      LeaveType.annual: ('Annual', 'Planned time off', Icons.beach_access_rounded),
      LeaveType.sick: ('Sick', 'Medical leave', Icons.medical_services_rounded),
      LeaveType.maternity: ('Maternity', 'Maternity leave', Icons.child_friendly_rounded),
      LeaveType.paternity: ('Paternity', 'Paternity leave', Icons.family_restroom_rounded),
      LeaveType.remote: ('Remote', 'Work from home', Icons.home_work_rounded),
      LeaveType.unpaid: ('Unpaid', 'Unpaid leave', Icons.money_off_rounded),
    };
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
          Text('Leave Type', style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.4,
            children: LeaveType.values.map((type) {
              final selected = _selectedType == type;
              final info = labels[type]!;
              return InkWell(
                onTap: () => setState(() => _selectedType = type),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.primaryLighter,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.white.withValues(alpha: 0.2)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(info.$3,
                            size: 18,
                            color: selected ? Colors.white : AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              info.$1,
                              style: AppTextStyles.body2.copyWith(
                                color: selected ? Colors.white : AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              info.$2,
                              style: AppTextStyles.caption.copyWith(
                                color: selected
                                    ? Colors.white.withValues(alpha: 0.85)
                                    : AppColors.textLight,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(DateFormat fmt) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('Period', style: AppTextStyles.heading3),
          ),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _DatePicker(
                    label: 'Start Date',
                    value: _startDate != null ? fmt.format(_startDate!) : null,
                    onTap: () => _pickDate(isStart: true),
                    flat: true,
                  ),
                ),
                Container(width: 1, color: AppColors.divider),
                Expanded(
                  child: _DatePicker(
                    label: 'End Date',
                    value: _endDate != null ? fmt.format(_endDate!) : null,
                    onTap: () => _pickDate(isStart: false),
                    flat: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryLighter,
            AppColors.accentLight,
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'This request covers $_durationDays business day${_durationDays != 1 ? "s" : ""}.',
              style: AppTextStyles.body2
                  .copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonSection() {
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
          Text('Reason (optional)', style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          TextField(
            controller: _reasonController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText:
                  'Briefly describe the reason for your leave request...',
              contentPadding: EdgeInsets.all(14),
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePicker extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;
  final bool flat;

  const _DatePicker(
      {required this.label, this.value, required this.onTap, this.flat = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: flat
            ? null
            : BoxDecoration(
                color: value != null
                    ? AppColors.primaryLighter
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: value != null
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : AppColors.divider,
                ),
              ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  size: 14,
                  color: value != null
                      ? AppColors.primary
                      : AppColors.textLight,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    value ?? 'Select',
                    style: AppTextStyles.body2.copyWith(
                      color: value != null
                          ? AppColors.textPrimary
                          : AppColors.textLight,
                      fontWeight: value != null
                          ? FontWeight.w600
                          : FontWeight.w400,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
