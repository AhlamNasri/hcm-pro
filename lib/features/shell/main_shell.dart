import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/auth_service.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  List<_NavItem> _destinations(bool isManager) {
    final base = [
      const _NavItem(path: '/dashboard', icon: Icons.dashboard_rounded, label: 'Home'),
      const _NavItem(path: '/leave', icon: Icons.event_note_rounded, label: 'Leave'),
      const _NavItem(path: '/payroll', icon: Icons.account_balance_wallet_rounded, label: 'Payroll'),
      const _NavItem(path: '/profile', icon: Icons.person_rounded, label: 'Profile'),
    ];
    if (isManager) {
      return [
        const _NavItem(path: '/dashboard', icon: Icons.dashboard_rounded, label: 'Home'),
        const _NavItem(path: '/employees', icon: Icons.people_rounded, label: 'Team'),
        const _NavItem(path: '/leave', icon: Icons.event_note_rounded, label: 'Leave'),
        const _NavItem(path: '/payroll', icon: Icons.account_balance_wallet_rounded, label: 'Payroll'),
        const _NavItem(path: '/profile', icon: Icons.person_rounded, label: 'Profile'),
      ];
    }
    return base;
  }

  int _currentIndex(BuildContext context, List<_NavItem> destinations) {
    final loc = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < destinations.length; i++) {
      if (loc.startsWith(destinations[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isManager = AuthService.instance.isManager;
    final destinations = _destinations(isManager);
    final index = _currentIndex(context, destinations);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(destinations.length, (i) {
                final dest = destinations[i];
                final selected = i == index;
                return InkWell(
                  onTap: () => context.go(dest.path),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primaryLighter
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(dest.icon, size: 22,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textLight),
                        const SizedBox(height: 2),
                        Text(dest.label,
                            style: AppTextStyles.caption.copyWith(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textLight,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            )),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String path;
  final IconData icon;
  final String label;
  const _NavItem({required this.path, required this.icon, required this.label});
}
