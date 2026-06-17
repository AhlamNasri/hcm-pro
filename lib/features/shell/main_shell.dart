import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/auth_service.dart';
import '../../shared/widgets/app_widgets.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  List<({String path, FloatingNavItem item})> _destinations(bool isManager) {
    final base = [
      (path: '/dashboard', item: const FloatingNavItem(icon: Icons.dashboard_rounded, label: 'Home')),
      (path: '/leave', item: const FloatingNavItem(icon: Icons.event_note_rounded, label: 'Leave')),
      (path: '/payroll', item: const FloatingNavItem(icon: Icons.account_balance_wallet_rounded, label: 'Payroll')),
      (path: '/profile', item: const FloatingNavItem(icon: Icons.person_rounded, label: 'Profile')),
    ];
    if (isManager) {
      return [
        (path: '/dashboard', item: const FloatingNavItem(icon: Icons.dashboard_rounded, label: 'Home')),
        (path: '/employees', item: const FloatingNavItem(icon: Icons.people_rounded, label: 'Team')),
        (path: '/leave', item: const FloatingNavItem(icon: Icons.event_note_rounded, label: 'Leave')),
        (path: '/payroll', item: const FloatingNavItem(icon: Icons.account_balance_wallet_rounded, label: 'Payroll')),
        (path: '/profile', item: const FloatingNavItem(icon: Icons.person_rounded, label: 'Profile')),
      ];
    }
    return base;
  }

  int _currentIndex(BuildContext context, List<({String path, FloatingNavItem item})> destinations) {
    final loc = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < destinations.length; i++) {
      if (loc.startsWith(destinations[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;
    final isManager = auth.isManager;
    final role = auth.currentAccount?.role;
    final accent = role != null ? AppColors.roleColor(role) : AppColors.primary;
    final destinations = _destinations(isManager);
    final index = _currentIndex(context, destinations);

    return Scaffold(
      body: child,
      bottomNavigationBar: FloatingNavBar(
        items: destinations.map((d) => d.item).toList(),
        currentIndex: index,
        activeColor: accent,
        onTap: (i) => context.go(destinations[i].path),
      ),
    );
  }
}
