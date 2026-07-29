import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/currency/currency_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/state_views.dart';
import '../../../l10n/app_localizations.dart';
import 'orders_providers.dart';

class OrderDetailsScreen extends ConsumerWidget {
  const OrderDetailsScreen({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final ordersAsync = ref.watch(myOrdersProvider);
    final money = ref.watch(currencyFormatterProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.orderDetails)),
      body: ordersAsync.when(
        data: (orders) {
          final matches = orders.where((o) => o.id == orderId);
          final order = matches.isEmpty ? null : matches.first;
          if (order == null) {
            return EmptyView(title: t.somethingWentWrong, icon: Icons.error_outline_rounded);
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            children: [
              Text('${t.orderNumber}${order.id}', style: AppTextStyles.headlineSm(), textAlign: TextAlign.right),
              const SizedBox(height: AppSpacing.stackLg),
              for (final item in order.items)
                Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.stackSm),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Image.network(item.product.imageUrl, width: 48, height: 48, fit: BoxFit.cover),
                    ),
                    title: Text(item.product.name, textAlign: TextAlign.right),
                    subtitle: Text('الكمية: ${item.quantity}', textAlign: TextAlign.right),
                    trailing: Text(money.format(item.lineTotal), style: AppTextStyles.bodyMd(color: AppColors.primary)),
                  ),
                ),
              const SizedBox(height: AppSpacing.stackMd),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.marginMobile),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(money.format(order.total), style: AppTextStyles.headlineSm(color: AppColors.primary)),
                      Text(t.total, style: AppTextStyles.headlineSm()),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingView(),
        error: (e, _) => AppErrorView(
          title: t.somethingWentWrong, message: e.toString(), retryLabel: t.retry, onRetry: () {},
        ),
      ),
    );
  }
}
