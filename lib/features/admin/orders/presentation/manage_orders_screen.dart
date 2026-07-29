import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/currency/currency_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../orders/domain/order.dart';
import '../../../orders/presentation/orders_providers.dart';

class ManageOrdersScreen extends ConsumerWidget {
  const ManageOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final ordersAsync = ref.watch(allOrdersProvider);
    final filter = ref.watch(ordersFilterProvider);
    final money = ref.watch(currencyFormatterProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.manageOrders)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(t.manageOrders, style: AppTextStyles.displayLg(), textAlign: TextAlign.right),
                const SizedBox(height: 4),
                Text(t.manageOrdersSubtitle, style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant), textAlign: TextAlign.right),
                const SizedBox(height: AppSpacing.stackMd),
                Row(
                  children: [
                    _filterChip(context, ref, null, t.all),
                    const SizedBox(width: 8),
                    _filterChip(context, ref, OrderStatus.processing, t.statusProcessing),
                    const SizedBox(width: 8),
                    _filterChip(context, ref, OrderStatus.completed, t.statusCompleted),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                final filtered = filter == null ? orders : orders.where((o) => o.status == filter).toList();
                if (filtered.isEmpty) return EmptyView(title: 'لا توجد طلبات', icon: Icons.receipt_long_outlined);
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.stackMd),
                  itemBuilder: (context, i) {
                    final order = filtered[i];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.marginMobile),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                _statusBadge(order.status),
                                const Spacer(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('${t.orderNumber}${order.id}', style: AppTextStyles.bodyMd().copyWith(fontWeight: FontWeight.w700)),
                                    Text('${t.customer}: ${order.customerName}', style: AppTextStyles.labelSm()),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(money.format(order.total), style: AppTextStyles.headlineSm(color: AppColors.primary)),
                                Text(t.total, style: AppTextStyles.labelMd()),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.stackMd),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(onPressed: () {}, child: Text(t.viewDetails)),
                                ),
                                const SizedBox(width: AppSpacing.stackSm),
                                Expanded(
                                  child: DropdownButtonFormField<OrderStatus>(
                                    value: order.status,
                                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                                    items: [
                                      for (final s in OrderStatus.values)
                                        DropdownMenuItem(value: s, child: Text(_statusLabel(s, t))),
                                    ],
                                    onChanged: (s) {
                                      if (s == null) return;
                                      // ⚠️ في الإنتاج: يستدعي Cloud Function `updateOrderStatus`
                                      // التي تتحقق من صلاحية admin في الخادم قبل التحديث الفعلي.
                                      ref.read(ordersRepositoryProvider).updateOrderStatus(order.id, s);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const LoadingView(),
              error: (e, _) => AppErrorView(title: t.somethingWentWrong, message: e.toString(), retryLabel: t.retry, onRetry: () => ref.invalidate(allOrdersProvider)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(BuildContext context, WidgetRef ref, OrderStatus? status, String label) {
    final selected = ref.watch(ordersFilterProvider) == status;
    return Expanded(
      child: OutlinedButton(
        onPressed: () => ref.read(ordersFilterProvider.notifier).state = status,
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? AppColors.primary : Colors.transparent,
          foregroundColor: selected ? Colors.white : AppColors.onSurface,
        ),
        child: Text(label),
      ),
    );
  }

  Widget _statusBadge(OrderStatus status) {
    return switch (status) {
      OrderStatus.processing => const StatusBadge(label: 'قيد المعالجة', tone: BadgeTone.warning, icon: Icons.local_shipping_outlined),
      OrderStatus.pending => const StatusBadge(label: 'قيد الانتظار', tone: BadgeTone.warning),
      OrderStatus.completed => const StatusBadge(label: 'مكتمل', tone: BadgeTone.success, icon: Icons.check_circle_outline_rounded),
      OrderStatus.shipped => const StatusBadge(label: 'تم الشحن', tone: BadgeTone.info),
      OrderStatus.cancelled => const StatusBadge(label: 'ملغى', tone: BadgeTone.error),
    };
  }

  String _statusLabel(OrderStatus s, AppLocalizations t) => switch (s) {
        OrderStatus.pending => t.statusPending,
        OrderStatus.processing => t.statusProcessing,
        OrderStatus.shipped => t.statusShipped,
        OrderStatus.completed => t.statusCompleted,
        OrderStatus.cancelled => 'ملغى',
      };
}
