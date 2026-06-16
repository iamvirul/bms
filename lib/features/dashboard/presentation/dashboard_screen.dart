import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:bms/core/router/app_router.dart';
import 'package:bms/core/theme/app_colors.dart';
import 'package:bms/core/theme/app_text_styles.dart';
import 'package:bms/core/utils/currency_utils.dart';
import 'package:bms/core/utils/date_utils.dart';
import 'package:bms/data/database/daos/reports_dao.dart';
import 'package:bms/providers/dashboard_provider.dart';
import 'package:bms/shared/widgets/stat_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard — ${BmsDateUtils.formatDate(DateTime.now())}'),
      ),
      body: stats.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (s) => RefreshIndicator(
          onRefresh: () => ref.refresh(dashboardStatsProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Stat Cards ──────────────────────────────────────────────
              GridView.extent(
                maxCrossAxisExtent: 300,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  StatCard(
                    label: "Today's Sales",
                    value: CurrencyUtils.format(s.todaySales),
                    icon: Icons.receipt_long_outlined,
                    color: AppColors.success,
                    onTap: () => context.go(AppRoutes.pos),
                  ),
                  StatCard(
                    label: 'Low Stock Items',
                    value: '${s.lowStockCount}',
                    icon: Icons.warning_amber_outlined,
                    color: AppColors.warning,
                    onTap: () => context.go(AppRoutes.inventory),
                  ),
                  StatCard(
                    label: 'Cheques Due (7d)',
                    value: '${s.chequesThisWeek}',
                    icon: Icons.calendar_today_outlined,
                    color: AppColors.primary,
                    onTap: () => context.go(AppRoutes.cheques),
                  ),
                  StatCard(
                    label: 'Total Receivables',
                    value: CurrencyUtils.format(s.totalDebtors),
                    icon: Icons.people_outline,
                    color: AppColors.error,
                    onTap: () => context.go(AppRoutes.customers),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── MTD Sales vs Last Month ──────────────────────────────────
              _MtdCard(
                mtd: s.mtdSales,
                lastMonth: s.lastMonthSales,
                growthPct: s.mtdGrowthPct,
              ),

              const SizedBox(height: 24),

              // ── 7-Day Revenue Chart ──────────────────────────────────────
              Text('7-Day Revenue', style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),
              _WeeklyBarChart(trend: s.weeklyTrend),

              // ── Payment Mix ──────────────────────────────────────────────
              if (s.paymentMix.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Payment Mix — This Month',
                    style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),
                _PaymentMixChart(mix: s.paymentMix),
              ],

              const SizedBox(height: 24),

              // ── Recent Invoices ──────────────────────────────────────────
              if (s.recentInvoices.isNotEmpty) ...[
                Text('Recent Invoices', style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),
                ...s.recentInvoices.map(
                  (inv) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.receipt_outlined,
                          color: AppColors.primary),
                      title: Text(inv.invoiceNo,
                          style: AppTextStyles.labelLarge),
                      subtitle: Text(
                          BmsDateUtils.formatDateTime(inv.createdAt),
                          style: AppTextStyles.bodySmall),
                      trailing: Text(
                        CurrencyUtils.format(inv.total),
                        style: AppTextStyles.titleMedium
                            .copyWith(color: AppColors.success),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── MTD Card ────────────────────────────────────────────────────────────────

class _MtdCard extends StatelessWidget {
  const _MtdCard({
    required this.mtd,
    required this.lastMonth,
    required this.growthPct,
  });
  final double mtd;
  final double lastMonth;
  final double growthPct;

  @override
  Widget build(BuildContext context) {
    final isPositive = growthPct >= 0;
    final color = isPositive ? AppColors.success : AppColors.error;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Month-to-Date Sales',
                      style: AppTextStyles.bodySmall),
                  const SizedBox(height: 4),
                  Text(CurrencyUtils.format(mtd),
                      style: AppTextStyles.titleLarge
                          .copyWith(color: AppColors.primary)),
                  if (lastMonth > 0)
                    Text(
                      'vs ${CurrencyUtils.format(lastMonth)} last month',
                      style: AppTextStyles.bodySmall,
                    ),
                ],
              ),
            ),
            if (lastMonth > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: color, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${growthPct.abs().toStringAsFixed(1)}%',
                      style: AppTextStyles.titleMedium.copyWith(color: color),
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

// ── Weekly Bar Chart ─────────────────────────────────────────────────────────

class _WeeklyBarChart extends StatelessWidget {
  const _WeeklyBarChart({required this.trend});
  final List<DailySales> trend;

  static String _compact(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    if (trend.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(
          child: Text('No sales in the last 7 days.',
              style: AppTextStyles.bodySmall),
        ),
      );
    }

    final maxY = trend.map((d) => d.revenue).fold<double>(0, (a, b) => a > b ? a : b);
    final fmt = DateFormat('EEE');

    final groups = trend.asMap().entries.map((e) {
      final d = e.value;
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: d.revenue,
            width: 28,
            color: d.revenue > 0 ? AppColors.primary : AppColors.border,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: maxY > 0 ? maxY * 1.2 : 100,
          barGroups: groups,
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (_, __, rod, ___) => BarTooltipItem(
                CurrencyUtils.format(rod.toY),
                AppTextStyles.bodySmall.copyWith(color: Colors.white),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 52,
                getTitlesWidget: (v, meta) => SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(_compact(v), style: AppTextStyles.bodySmall),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (v, meta) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= trend.length) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      fmt.format(trend[idx].date),
                      style: AppTextStyles.bodySmall,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Payment Mix Donut ────────────────────────────────────────────────────────

class _PaymentMixChart extends StatelessWidget {
  const _PaymentMixChart({required this.mix});
  final Map<String, double> mix;

  static const _colorMap = {
    'cash': AppColors.success,
    'card': AppColors.primary,
    'cheque': AppColors.warning,
    'credit': AppColors.error,
    'mixed': Color(0xFF7B1FA2),
  };

  Color _colorFor(String type) =>
      _colorMap[type.toLowerCase()] ?? AppColors.textSecondary;

  @override
  Widget build(BuildContext context) {
    final total = mix.values.fold<double>(0, (s, v) => s + v);
    final entries = mix.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Row(
      children: [
        SizedBox(
          width: 160,
          height: 160,
          child: PieChart(
            PieChartData(
              sections: entries.map((e) {
                final pct = total > 0 ? e.value / total * 100 : 0.0;
                return PieChartSectionData(
                  value: e.value,
                  color: _colorFor(e.key),
                  radius: 52,
                  title: '${pct.toStringAsFixed(0)}%',
                  titleStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  showTitle: pct >= 8,
                );
              }).toList(),
              centerSpaceRadius: 32,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: entries.map((e) {
              final pct = total > 0 ? e.value / total * 100 : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _colorFor(e.key),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e.key[0].toUpperCase() + e.key.substring(1),
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(CurrencyUtils.format(e.value),
                            style: AppTextStyles.labelLarge),
                        Text('${pct.toStringAsFixed(1)}%',
                            style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
