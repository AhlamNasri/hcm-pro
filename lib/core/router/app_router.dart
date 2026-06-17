import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/login_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/employees/employees_screen.dart';
import '../../features/employees/employee_detail_screen.dart';
import '../../features/leave/leave_screen.dart';
import '../../features/leave/leave_request_form.dart';
import '../../features/payroll/payroll_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../services/auth_service.dart';

// Routes only the HR manager / line managers may reach. Plain employees get
// bounced back to the dashboard if they try to deep-link into one of these.
const _managerOnlyPaths = ['/employees'];

String? _routeGuard(BuildContext context, GoRouterState state) {
  final loggedIn = AuthService.instance.isLoggedIn;
  final goingToLogin = state.matchedLocation == '/login';

  if (!loggedIn) {
    return goingToLogin ? null : '/login';
  }
  if (goingToLogin) {
    return '/dashboard';
  }
  final isManager = AuthService.instance.isManager;
  if (!isManager &&
      _managerOnlyPaths.any((p) => state.matchedLocation.startsWith(p))) {
    return '/dashboard';
  }
  return null;
}

/// One consistent fade+slide transition for every route, instead of the
/// platform default — a small, repeated touch that makes navigation feel
/// considered rather than stock.
CustomTransitionPage<void> _appPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      final slide = Tween<Offset>(begin: const Offset(0, 0.025), end: Offset.zero)
          .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  redirect: _routeGuard,
  routes: [
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => _appPage(state, const LoginScreen()),
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          pageBuilder: (context, state) => _appPage(state, const DashboardScreen()),
        ),
        GoRoute(
          path: '/employees',
          pageBuilder: (context, state) => _appPage(state, const EmployeesScreen()),
          routes: [
            GoRoute(
              path: ':id',
              pageBuilder: (context, state) => _appPage(
                state,
                EmployeeDetailScreen(employeeId: state.pathParameters['id']!),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/leave',
          pageBuilder: (context, state) => _appPage(state, const LeaveScreen()),
          routes: [
            GoRoute(
              path: 'new',
              pageBuilder: (context, state) => _appPage(state, const LeaveRequestForm()),
            ),
          ],
        ),
        GoRoute(
          path: '/payroll',
          pageBuilder: (context, state) => _appPage(state, const PayrollScreen()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => _appPage(state, const ProfileScreen()),
        ),
        GoRoute(
          path: '/notifications',
          pageBuilder: (context, state) => _appPage(state, const NotificationsScreen()),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri}'),
    ),
  ),
);
