import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import 'sidebar_nav.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final isWide = MediaQuery.sizeOf(context).width >= 700;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          if (isWide) SidebarNav(currentLocation: location),
          Expanded(
            child: ClipRect(child: child),
          ),
        ],
      ),
      bottomNavigationBar: isWide ? null : _BottomNav(currentLocation: location),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentLocation});

  final String currentLocation;

  static const _items = [
    (label: 'Dashboard', icon: Icons.grid_view_rounded, route: AppRoutes.dashboard),
    (label: 'POS', icon: Icons.point_of_sale_rounded, route: AppRoutes.pos),
    (label: 'Inventory', icon: Icons.inventory_2_rounded, route: AppRoutes.inventory),
    (label: 'Customers', icon: Icons.people_rounded, route: AppRoutes.customers),
    (label: 'More', icon: Icons.menu_rounded, route: AppRoutes.reports),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _items.indexWhere((i) => currentLocation.startsWith(i.route));

    return NavigationBar(
      selectedIndex: currentIndex < 0 ? 0 : currentIndex,
      onDestinationSelected: (i) => context.go(_items[i].route),
      destinations: _items
          .map((i) => NavigationDestination(icon: Icon(i.icon), label: i.label))
          .toList(),
    );
  }
}
