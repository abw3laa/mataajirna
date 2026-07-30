import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/currency/currency_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/auth_providers.dart';
import '../domain/order.dart';
import 'orders_providers.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final isGuest = ref.watch(authStateProvider).value == null;

    if (isGuest) {
      return Scaffold(
        appBar: AppBar(title: Text(t.appName)),
        body: EmptyView(
          title: t.guestOrdersTitle,
          subtitle: t.guestOrdersSubtitle,
          icon: Icons.receipt_long_outlined,
          action: PrimaryButton(label: t.login, onPressed: () => context.push('/login'), expand: false),
        ),
      );
    }

    final ordersAsync = ref.watch(myOrdersProvider);
    final money = ref.watch(currencyFormatterProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.appName)),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const EmptyView(
                title: 'لا توجد طلبات بعد', icon: Icons.receipt_long_outlined);
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            children: [
              Text(t.myOrders,
                  style: AppTextStyles.displayLg(), textAlign: TextAlign.right),
              const SizedBox(height: AppSpacing.stackLg),
              for (final order in orders)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.stackMd),
                  child: Card(
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
                                  Text('${t.orderNumber}${order.id}',
                                      style: AppTextStyles.labelMd()),
                                  Text(_formatDate(order.createdAt),
                                      style: AppTextStyles.labelSm()),
                                ],
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          for (final item in order.items)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.sm),
                                    child: Image.network(item.product.imageUrl,
                                        width: 44,
                                        height: 44,
                                        fit: BoxFit.cover),
                                  ),
                                  const SizedBox(width: AppSpacing.stackSm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(item.product.name,
                                            style: AppTextStyles.bodyMd(),
                                            textAlign: TextAlign.right),
                                        Text('الكمية: ${item.quantity}',
                                            style: AppTextStyles.labelSm()),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(money.format(order.total),
                                      style: AppTextStyles.headlineSm(
                                          color: AppColors.primary)),
                                  Text(t.total, style: AppTextStyles.labelSm()),
                                ],
                              ),
                              OutlinedButton.icon(
                                onPressed: () =>
                                    context.push('/orders/${order.id}'),
                                icon: const Icon(Icons.arrow_back_rounded,
                                    size: 16),
                                label: Text(
                                    order.status == OrderStatus.completed
                                        ? t.reorder
                                        : t.trackOrder),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const LoadingView(),
        error: (e, _) => AppErrorView(
          title: t.somethingWentWrong,
          message: e.toString(),
          retryLabel: t.retry,
          onRetry: () => ref.invalidate(myOrdersProvider),
        ),
      ),
    );
  }

  Widget _statusBadge(OrderStatus status) {
    return switch (status) {
      OrderStatus.shipped => const StatusBadge(
          label: 'تم الشحن',
          tone: BadgeTone.info,
          icon: Icons.local_shipping_outlined),
      OrderStatus.pending =>
        const StatusBadge(label: 'قيد الانتظار', tone: BadgeTone.warning),
      OrderStatus.processing =>
        const StatusBadge(label: 'قيد المعالجة', tone: BadgeTone.warning),
      OrderStatus.completed => const StatusBadge(
          label: 'مكتمل',
          tone: BadgeTone.neutral,
          icon: Icons.check_circle_outline_rounded),
      OrderStatus.cancelled =>
        const StatusBadge(label: 'ملغى', tone: BadgeTone.error),
    };
  }

  String _formatDate(DateTime d) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
