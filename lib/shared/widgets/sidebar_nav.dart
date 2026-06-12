import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class SidebarNav extends StatelessWidget {
  const SidebarNav({super.key, required this.currentLocation, required this.role});

  final String currentLocation;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppConstants.sidebarWidth,
      color: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const Divider(color: Colors.white24, height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: _buildItems(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Text(
        AppConstants.appName,
        style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
      ),
    );
  }

  List<Widget> _buildItems(BuildContext context) {
    final items = _navItems.where((item) => _isVisible(item)).toList();
    return items
        .map((item) => _NavItem(
              item: item,
              isActive: currentLocation == item.route,
              onTap: () => context.go(item.route),
            ))
        .toList();
  }

  bool _isVisible(_NavItemData item) {
    if (item.adminOnly && role == 'cashier') return false;
    return true;
  }

  static const List<_NavItemData> _navItems = [
    _NavItemData(label: 'Dashboard', icon: Icons.dashboard_outlined, route: AppRoutes.dashboard),
    _NavItemData(label: 'POS / Sales', icon: Icons.point_of_sale_outlined, route: AppRoutes.pos),
    _NavItemData(label: 'Inventory', icon: Icons.inventory_2_outlined, route: AppRoutes.inventory),
    _NavItemData(label: 'Debtors', icon: Icons.people_outline, route: AppRoutes.debtors),
    _NavItemData(
      label: 'Suppliers',
      icon: Icons.local_shipping_outlined,
      route: AppRoutes.suppliers,
      adminOnly: true,
    ),
    _NavItemData(label: 'Cheques', icon: Icons.calendar_month_outlined, route: AppRoutes.cheques),
    _NavItemData(label: 'Petty Cash', icon: Icons.account_balance_wallet_outlined, route: AppRoutes.pettyCash),
    _NavItemData(label: 'Reports', icon: Icons.bar_chart_outlined, route: AppRoutes.reports),
  ];
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.item, required this.isActive, required this.onTap});

  final _NavItemData item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: isActive ? Colors.white.withAlpha(30) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          splashColor: Colors.white.withAlpha(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(item.icon, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  item.label,
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({
    required this.label,
    required this.icon,
    required this.route,
    this.adminOnly = false,
  });

  final String label;
  final IconData icon;
  final String route;
  final bool adminOnly;
}
