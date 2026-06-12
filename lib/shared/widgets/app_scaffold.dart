import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../features/auth/domain/auth_state.dart';
import '../../providers/auth_provider.dart';
import 'sidebar_nav.dart';

class AppScaffold extends ConsumerWidget {
  const AppScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(currentAuthStateProvider);
    final role = authState is Authenticated ? authState.user.role : 'cashier';
    final location = GoRouterState.of(context).matchedLocation;
    final isWide = MediaQuery.sizeOf(context).width >= AppConstants.sidebarBreakpoint;

    return Scaffold(
      body: Row(
        children: [
          if (isWide)
            SidebarNav(currentLocation: location, role: role),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : _BottomNav(currentLocation: location, role: role),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentLocation, required this.role});

  final String currentLocation;
  final String role;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (_) {},
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.point_of_sale_outlined), label: 'POS'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Inventory'),
      ],
    );
  }
}
