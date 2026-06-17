import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/employee.dart';

const _avatarColors = [
  '3949AB', 'E91E63', '00897B', 'F57C00', '5E35B1', '2E7D32', 'C62828',
];

Future<Employee?> showAddEmployeeSheet(BuildContext context) {
  return showModalBottomSheet<Employee>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => const _AddEmployeeForm(),
  );
}

/// Edits an existing employee, preserving id/hireDate/leaveBalance/etc.
Future<Employee?> showEditEmployeeSheet(BuildContext context, Employee employee) {
  return showModalBottomSheet<Employee>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => _AddEmployeeForm(initial: employee),
  );
}

class _AddEmployeeForm extends StatefulWidget {
  final Employee? initial;
  const _AddEmployeeForm({this.initial});

  @override
  State<_AddEmployeeForm> createState() => _AddEmployeeFormState();
}

class _AddEmployeeFormState extends State<_AddEmployeeForm> {
  final _formKey = GlobalKey<FormState>();
  late final _firstNameCtrl =
      TextEditingController(text: widget.initial?.firstName);
  late final _lastNameCtrl =
      TextEditingController(text: widget.initial?.lastName);
  late final _emailCtrl = TextEditingController(text: widget.initial?.email);
  late final _phoneCtrl = TextEditingController(text: widget.initial?.phone);
  late final _positionCtrl =
      TextEditingController(text: widget.initial?.position);
  late final _salaryCtrl =
      TextEditingController(text: widget.initial?.salary.toStringAsFixed(0));
  late Department _department = widget.initial?.department ?? Department.it;
  late ContractType _contractType =
      widget.initial?.contractType ?? ContractType.cdi;

  bool get _isEditing => widget.initial != null;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _positionCtrl.dispose();
    _salaryCtrl.dispose();
    super.dispose();
  }

  /// Standard annual leave entitlement granted to a brand-new employee with
  /// no leave taken yet. Existing employees keep whatever they already have.
  static const _defaultLeaveAllowance = 30;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final base = widget.initial;
    final totalLeaveAllowance = base?.totalLeaveAllowance ?? _defaultLeaveAllowance;
    final employee = Employee(
      id: base?.id ?? 'EMP${DateTime.now().millisecondsSinceEpoch}',
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      position: _positionCtrl.text.trim(),
      department: _department,
      status: base?.status ?? EmployeeStatus.active,
      contractType: _contractType,
      hireDate: base?.hireDate ?? DateTime.now(),
      salary: double.tryParse(_salaryCtrl.text.trim()) ?? 0,
      managerId: base?.managerId ?? '',
      avatarColor: base?.avatarColor ??
          _avatarColors[DateTime.now().millisecond % _avatarColors.length],
      leaveBalance: base?.leaveBalance ?? totalLeaveAllowance,
      totalLeaveAllowance: totalLeaveAllowance,
      performanceScore: base?.performanceScore ?? 0,
    );
    Navigator.of(context).pop(employee);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_isEditing ? 'Edit Employee' : 'Add Employee',
                      style: AppTextStyles.heading2),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _field(_firstNameCtrl, 'First name', required: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(_lastNameCtrl, 'Last name', required: true),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _field(_emailCtrl, 'Email', required: true, isEmail: true),
              const SizedBox(height: 12),
              _field(_phoneCtrl, 'Phone'),
              const SizedBox(height: 12),
              _field(_positionCtrl, 'Position', required: true),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Department>(
                      initialValue: _department,
                      decoration: const InputDecoration(labelText: 'Department'),
                      items: Department.values
                          .map((d) => DropdownMenuItem(
                                value: d,
                                child: Text(d.name.toUpperCase(),
                                    style: AppTextStyles.body2),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _department = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<ContractType>(
                      initialValue: _contractType,
                      decoration: const InputDecoration(labelText: 'Contract'),
                      items: ContractType.values
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c.name.toUpperCase(),
                                    style: AppTextStyles.body2),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _contractType = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _field(_salaryCtrl, 'Monthly salary (MAD)',
                  required: true, isNumber: true),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(_isEditing ? 'Save Changes' : 'Add Employee',
                      style: AppTextStyles.button),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    bool isEmail = false,
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber
          ? TextInputType.number
          : isEmail
              ? TextInputType.emailAddress
              : TextInputType.text,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        final v = value?.trim() ?? '';
        if (required && v.isEmpty) return 'Required';
        if (isEmail && v.isNotEmpty && !v.contains('@')) {
          return 'Enter a valid email';
        }
        if (isNumber && v.isNotEmpty && double.tryParse(v) == null) {
          return 'Enter a number';
        }
        return null;
      },
    );
  }
}
