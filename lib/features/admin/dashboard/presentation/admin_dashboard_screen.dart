import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    final t = AppLocalizations.of(context)!;
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
