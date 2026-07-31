import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/currency/currency_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../orders/domain/order.dart';
import '../../../orders/presentation/orders_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final ordersAsync = ref.watch(allOrdersProvider);
    final money = ref.watch(currencyFormatterProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.appName)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        children: [
          _kpiCard(
            title: t.totalSales,
            value: money.format(45230),
            trend: '12.5%',
            icon: Icons.payments_outlined,
            iconBg: const Color(0xFFD7F5E9),
          ),
          const SizedBox(height: AppSpacing.stackMd),
          _kpiCard(
            title: t.totalOrders,
            value: '1,204',
            trend: '8.2%',
            icon: Icons.shopping_cart_outlined,
            iconBg: const Color(0xFFE3E9FF),
          ),
          const SizedBox(height: AppSpacing.stackMd),
          _kpiCard(title: t.activeProducts, value: '845', icon: Icons.inventory_2_outlined, iconBg: const Color(0xFFF6E3CE)),
          const SizedBox(height: AppSpacing.stackLg),
          _SalesTrendChart(t: t),
          const SizedBox(height: AppSpacing.stackLg),
          Row(
            children: [
              TextButton(onPressed: () => context.go('/admin/orders'), child: Text(t.viewAll)),
              const Spacer(),
              Text(t.recentOrders, style: AppTextStyles.headlineSm()),
            ],
          ),
          const SizedBox(height: AppSpacing.stackSm),
          ordersAsync.when(
            data: (orders) => Card(
              child: Column(
                children: [
                  for (final o in orders.take(3))
                    ListTile(
                      title: Text(o.customerName, textAlign: TextAlign.right),
                      subtitle: Text('${t.orderNumber}${o.id}', textAlign: TextAlign.right),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(money.format(o.total), style: AppTextStyles.bodyMd().copyWith(fontWeight: FontWeight.w700)),
                          _statusChip(o.status),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: AppSpacing.stackLg),
          Text(t.quickActions, style: AppTextStyles.headlineSm(), textAlign: TextAlign.right),
          const SizedBox(height: AppSpacing.stackSm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.bar_chart_rounded),
                  label: Text(t.viewAnalytics),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 56)),
                ),
              ),
              const SizedBox(width: AppSpacing.stackMd),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/admin/products/new'),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(t.addProduct),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.stackSm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/admin/banners'),
              icon: const Icon(Icons.campaign_outlined),
              label: const Text('إدارة البانرات'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 56)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kpiCard({required String title, required String value, String? trend, required IconData icon, required Color iconBg}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        child: Row(
          children: [
            CircleAvatar(radius: 22, backgroundColor: iconBg, child: Icon(icon, color: AppColors.onSurface, size: 20)),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (trend != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFD7F5E9), borderRadius: BorderRadius.circular(AppRadius.full)),
                    child: Text('$trend ↗', style: AppTextStyles.labelSm(color: AppColors.success)),
                  ),
                const SizedBox(height: 6),
                Text(value, style: AppTextStyles.headlineMd()),
                Text(title, style: AppTextStyles.labelMd()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(OrderStatus status) {
    return switch (status) {
      OrderStatus.completed => const StatusBadge(label: 'مكتمل', tone: BadgeTone.success),
      OrderStatus.processing => const StatusBadge(label: 'قيد المعالجة', tone: BadgeTone.warning),
      OrderStatus.pending => const StatusBadge(label: 'قيد الانتظار', tone: BadgeTone.warning),
      OrderStatus.shipped => const StatusBadge(label: 'تم الشحن', tone: BadgeTone.info),
      OrderStatus.cancelled => const StatusBadge(label: 'ملغى', tone: BadgeTone.error),
    };
  }
}

/// رسم بياني لاتجاه المبيعات آخر 7 أيام. القيم رقمية توضيحية حالياً
/// (تُستبدل ببيانات حقيقية مجمّعة من مجموعة orders في Firestore عند الربط
/// الفعلي). القيم تُعرض دوماً كنص، وليس بالاعتماد على اللون فقط، لتوافق
/// إتاحة الوصول على الجوال (لا يوجد hover على اللمس).
class _SalesTrendChart extends StatelessWidget {
  const _SalesTrendChart({required this.t});
  final AppLocalizations t;

  static const _weeklySales = <double>[3200, 4100, 3800, 5200, 4700, 6100, 5230];
  static const _days = ['سبت', 'أحد', 'إثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة'];

  @override
  Widget build(BuildContext context) {
    final maxY = _weeklySales.reduce((a, b) => a > b ? a : b) * 1.2;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('${_weeklySales.reduce((a, b) => a + b).toStringAsFixed(0)} ر.س',
                    style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)),
                const Spacer(),
                Text('مبيعات آخر 7 أيام', style: AppTextStyles.headlineSm()),
              ],
            ),
            const SizedBox(height: AppSpacing.stackMd),
            SizedBox(
              height: 160,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxY,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= _days.length) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(_days[i], style: AppTextStyles.labelSm()),
                          );
                        },
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) => spots
                          .map((s) => LineTooltipItem(
                                '${s.y.toStringAsFixed(0)} ر.س',
                                AppTextStyles.labelMd(color: Colors.white),
                              ))
                          .toList(),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (int i = 0; i < _weeklySales.length; i++) FlSpot(i.toDouble(), _weeklySales[i]),
                      ],
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: true, color: AppColors.primaryContainer.withValues(alpha: 0.5)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
