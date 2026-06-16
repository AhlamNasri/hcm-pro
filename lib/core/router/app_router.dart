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

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  redirect: _routeGuard,
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/employees',
          builder: (context, state) => const EmployeesScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) => EmployeeDetailScreen(
                employeeId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/leave',
          builder: (context, state) => const LeaveScreen(),
          routes: [
            GoRoute(
              path: 'new',
              builder: (context, state) => const LeaveRequestForm(),
            ),
          ],
        ),
        GoRoute(
          path: '/payroll',
          builder: (context, state) => const PayrollScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
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
