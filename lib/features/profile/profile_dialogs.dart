import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/employee.dart';
import '../../core/services/app_backend.dart';
import '../../core/services/auth_service.dart';

void _showSnack(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: AppTextStyles.body2.copyWith(color: Colors.white)),
      backgroundColor: isError ? AppColors.danger : AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

/// Returns true if the employee was updated.
Future<bool> showPersonalInfoSheet(BuildContext context, Employee employee) async {
  final firstNameCtrl = TextEditingController(text: employee.firstName);
  final lastNameCtrl = TextEditingController(text: employee.lastName);
  final phoneCtrl = TextEditingController(text: employee.phone);
  final positionCtrl = TextEditingController(text: employee.position);
  final formKey = GlobalKey<FormState>();

  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 20 + MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Personal Information', style: AppTextStyles.heading2),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(ctx).pop(false),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: firstNameCtrl,
                        decoration: const InputDecoration(labelText: 'First name'),
                        validator: (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: lastNameCtrl,
                        decoration: const InputDecoration(labelText: 'Last name'),
                        validator: (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: positionCtrl,
                  decoration: const InputDecoration(labelText: 'Position'),
                  validator: (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                InputDecorator(
                  decoration: const InputDecoration(labelText: 'Email'),
                  child: Text(employee.email, style: AppTextStyles.body1),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        Navigator.of(ctx).pop(true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Save Changes', style: AppTextStyles.button),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      );
    },
  );

  if (saved != true) return false;

  final updated = employee.copyWith(
    firstName: firstNameCtrl.text.trim(),
    lastName: lastNameCtrl.text.trim(),
    phone: phoneCtrl.text.trim(),
    position: positionCtrl.text.trim(),
  );
  await AppBackend.employeeRepository.update(updated);
  if (context.mounted) _showSnack(context, 'Personal information updated');
  return true;
}

Future<void> showSecurityDialog(BuildContext context) async {
  final currentCtrl = TextEditingController();
  final newCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isSubmitting = false;

  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Change Password', style: AppTextStyles.heading2),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Current password'),
                validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: newCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New password'),
                validator: (v) =>
                    (v?.length ?? 0) < 6 ? 'At least 6 characters' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirm new password'),
                validator: (v) => v != newCtrl.text ? 'Passwords do not match' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: isSubmitting
                ? null
                : () async {
                    if (!formKey.currentState!.validate()) return;
                    setState(() => isSubmitting = true);
                    final error = await AuthService.instance
                        .changePassword(currentCtrl.text, newCtrl.text);
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    if (error != null) {
                      _showSnack(context, error, isError: true);
                    } else {
                      _showSnack(context, 'Password updated');
                    }
                  },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : Text('Update', style: AppTextStyles.button),
          ),
        ],
      ),
    ),
  );
}

Future<void> showLanguageDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Language', style: AppTextStyles.heading2),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.check_circle_rounded, color: AppColors.primary),
            title: Text('English', style: AppTextStyles.body1),
            onTap: () => Navigator.pop(ctx),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.radio_button_unchecked, color: AppColors.textLight),
            title: Text('Français', style: AppTextStyles.body1),
            subtitle: Text('Coming soon', style: AppTextStyles.caption),
            enabled: false,
          ),
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

Future<void> showHelpSupportSheet(BuildContext context) {
  const faqs = [
    ('How do I request leave?', 'Go to Leave > New Request, fill in the dates and reason, then submit. Your manager will be notified.'),
    ('How is my net salary calculated?', 'Net salary = gross salary (base + bonus + overtime + allowances) minus social security and income tax deductions. See the Payroll tab for a full breakdown.'),
    ('Who approves my leave requests?', 'Your direct manager or HR, depending on your department setup.'),
    ('How do I update my personal information?', 'Go to Profile > Personal Information to edit your name, phone and position.'),
  ];

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Help & Support', style: AppTextStyles.heading2),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('FAQs', style: AppTextStyles.label),
            const SizedBox(height: 8),
            ...faqs.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f.$1,
                          style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(f.$2, style: AppTextStyles.body2),
                    ],
                  ),
                )),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Text('Contact us', style: AppTextStyles.label),
            const SizedBox(height: 8),
            _ContactRow(
              icon: Icons.email_outlined,
              value: 'support@hcmpro.com',
            ),
            const SizedBox(height: 8),
            _ContactRow(
              icon: Icons.phone_outlined,
              value: '+212 5 22 00 00 00',
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}

Future<void> showWhatsNewDialog(BuildContext context) {
  const updates = [
    'Real-time backend sync for employees, leave and notifications.',
    'Approve / reject leave requests directly from the Leave tab.',
    'Add new employees from the Team Directory.',
    'Route protection: manager-only screens are blocked for employees.',
  ];
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text("What's New — v1.0.0", style: AppTextStyles.heading2),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: updates
            .map((u) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.circle, size: 6, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(child: Text(u, style: AppTextStyles.body2)),
                    ],
                  ),
                ))
            .toList(),
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
            _showSnack(context, 'Copied to clipboard');
          },
        ),
      ],
    );
  }
}
