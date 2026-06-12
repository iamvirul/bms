import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/cheques/presentation/cheque_calendar_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/debtors/presentation/debtors_screen.dart';
import '../../features/inventory/presentation/inventory_screen.dart';
import '../../features/petty_cash/presentation/petty_cash_screen.dart';
import '../../features/pos/presentation/pos_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/suppliers/presentation/suppliers_screen.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/app_scaffold.dart';
import 'route_guard.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(currentAuthStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: false,
    redirect: (context, state) => RouteGuard.redirect(
      state: state,
      authState: authState,
    ),
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.pos,
            name: 'pos',
            builder: (context, state) => const PosScreen(),
          ),
          GoRoute(
            path: AppRoutes.inventory,
            name: 'inventory',
            builder: (context, state) => const InventoryScreen(),
          ),
          GoRoute(
            path: AppRoutes.debtors,
            name: 'debtors',
            builder: (context, state) => const DebtorsScreen(),
          ),
          GoRoute(
            path: AppRoutes.suppliers,
            name: 'suppliers',
            builder: (context, state) => const SuppliersScreen(),
          ),
          GoRoute(
            path: AppRoutes.cheques,
            name: 'cheques',
            builder: (context, state) => const ChequeCalendarScreen(),
          ),
          GoRoute(
            path: AppRoutes.pettyCash,
            name: 'pettyCash',
            builder: (context, state) => const PettyCashScreen(),
          ),
          GoRoute(
            path: AppRoutes.reports,
            name: 'reports',
            builder: (context, state) => const ReportsScreen(),
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
}

abstract final class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String pos = '/pos';
  static const String inventory = '/inventory';
  static const String debtors = '/debtors';
  static const String suppliers = '/suppliers';
  static const String cheques = '/cheques';
  static const String pettyCash = '/petty-cash';
  static const String reports = '/reports';
}
