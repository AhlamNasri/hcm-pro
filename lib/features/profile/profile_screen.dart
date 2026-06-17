import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/employee.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/auth_service.dart';
import '../../shared/widgets/app_widgets.dart';
import 'profile_dialogs.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final employee = AuthService.instance.currentEmployee;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          _buildHeader(context, employee),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStatsRow(employee),
                const SizedBox(height: 16),
                _buildMenuSection(context, employee),
                const SizedBox(height: 16),
                _buildAppInfo(context),
                const SizedBox(height: 16),
                _buildSignOut(context),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Employee employee) {
    final role = AuthService.instance.currentAccount?.role;
    final roleColor = role != null ? AppColors.roleColor(role) : AppColors.primaryDark;
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: roleColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(color: roleColor),
            BlobAccentBackdrop(color: Colors.white),
            Positioned.fill(
              child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Stack(
                  children: [
                    AvatarWidget(
                      initials: employee.initials,
                      color: Colors.white,
                      size: 80,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit_rounded,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(employee.fullName,
                    style: AppTextStyles.heading1
                        .copyWith(color: Colors.white)),
                const SizedBox(height: 4),
                Text(employee.position,
                    style: AppTextStyles.body1
                        .copyWith(color: Colors.white70)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: Text(
                    employee.id,
                    style: AppTextStyles.caption
                        .copyWith(color: Colors.white),
                  ),
                ),
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

  // Single connected card sitting directly beneath the header (no overlap,
  // no gaps between stats) — Profile's structural signature, distinct from
  // Employee Detail's peeking-above-the-fold overlap card.
  Widget _buildStatsRow(Employee employee) {
    final yearsAtCompany =
        DateTime.now().difference(employee.hireDate).inDays ~/ 365;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: ConnectedStat(
              value: '$yearsAtCompany',
              label: 'Years here',
              icon: Icons.business_center_rounded,
              color: AppColors.primary,
            ),
          ),
          const ConnectedStatDivider(),
          Expanded(
            child: ConnectedStat(
              value: '${employee.leaveBalance}d',
              label: 'Leave balance',
              icon: Icons.beach_access_rounded,
              color: AppColors.accent,
            ),
          ),
          const ConnectedStatDivider(),
          Expanded(
            child: ConnectedStat(
              value: employee.performanceScore.toStringAsFixed(1),
              label: 'Performance',
              icon: Icons.star_rounded,
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, Employee employee) {
    final items = [
      _MenuItem(
        icon: Icons.person_outline_rounded,
        label: 'Personal Information',
        subtitle: 'View & edit your details',
        color: AppColors.primary,
        onTap: () async {
          final changed = await showPersonalInfoSheet(context, employee);
          if (changed && mounted) setState(() {});
        },
      ),
      _MenuItem(
        icon: Icons.lock_outline_rounded,
        label: 'Security',
        subtitle: 'Password, 2FA',
        color: AppColors.accent,
        onTap: () => showSecurityDialog(context),
      ),
      _MenuItem(
        icon: Icons.notifications_outlined,
        label: 'Notifications',
        subtitle: 'Manage your alerts',
        color: AppColors.warning,
        onTap: () => context.go('/notifications'),
      ),
      _MenuItem(
        icon: Icons.language_rounded,
        label: 'Language',
        subtitle: 'English (EN)',
        color: AppColors.success,
        onTap: () => showLanguageDialog(context),
      ),
      _MenuItem(
        icon: Icons.help_outline_rounded,
        label: 'Help & Support',
        subtitle: 'FAQs, contact us',
        color: AppColors.pending,
        onTap: () => showHelpSupportSheet(context),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final item = e.value;
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              InkWell(
                onTap: item.onTap,
                borderRadius: isLast
                    ? const BorderRadius.vertical(
                        bottom: Radius.circular(16))
                    : BorderRadius.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.icon,
                            color: item.color, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.label,
                                style: AppTextStyles.body1
                                    .copyWith(
                                        fontWeight: FontWeight.w600)),
                            Text(item.subtitle,
                                style: AppTextStyles.body2),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.textLight),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                const Divider(
                    height: 1, indent: 70, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAppInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.business_center_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('HCM Pro',
                    style: AppTextStyles.body1
                        .copyWith(fontWeight: FontWeight.w700)),
                Text('Version 1.0.0',
                    style: AppTextStyles.body2),
              ],
            ),
          ),
          TextButton(
            onPressed: () => showWhatsNewDialog(context),
            child: Text(
              'What\'s new',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOut(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Text('Sign Out', style: AppTextStyles.heading2),
            content: Text(
                'Are you sure you want to sign out of HCM Pro?',
                style: AppTextStyles.body1),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel',
                    style: AppTextStyles.body1.copyWith(
                        color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () {
                  AuthService.instance.logout();
                  Navigator.pop(ctx);
                  context.go('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                ),
                child: Text('Sign Out', style: AppTextStyles.button),
              ),
            ],
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.dangerLight,
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded,
                color: AppColors.danger, size: 20),
            const SizedBox(width: 8),
            Text(
              'Sign Out',
              style: AppTextStyles.button.copyWith(
                color: AppColors.danger,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}
