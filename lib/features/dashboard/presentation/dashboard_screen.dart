import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../auth/domain/auth_state.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(currentAuthStateProvider);
    final userName = authState is Authenticated ? authState.user.name : '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard -- ${BmsDateUtils.formatDate(DateTime.now())}'),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
            },
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back, $userName', style: AppTextStyles.titleLarge),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.extent(
                maxCrossAxisExtent: 300,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2,
                children: [
                  StatCard(
                    label: "Today's Sales",
                    value: 'Rs. 0.00',
                    icon: Icons.receipt_long_outlined,
                    color: AppColors.success,
                    onTap: () => context.go(AppRoutes.pos),
                  ),
                  StatCard(
                    label: 'Low Stock Items',
                    value: '0',
                    icon: Icons.warning_amber_outlined,
                    color: AppColors.warning,
                    onTap: () => context.go(AppRoutes.inventory),
                  ),
                  StatCard(
                    label: 'Cheques Due This Week',
                    value: '0',
                    icon: Icons.calendar_today_outlined,
                    color: AppColors.primary,
                    onTap: () => context.go(AppRoutes.cheques),
                  ),
                  StatCard(
                    label: 'Pending Debtor Payments',
                    value: 'Rs. 0.00',
                    icon: Icons.people_outline,
                    color: AppColors.error,
                    onTap: () => context.go(AppRoutes.debtors),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
