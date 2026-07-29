import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/currency/currency_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/state_views.dart';
import '../../../l10n/app_localizations.dart';
import 'cart_providers.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final items = ref.watch(cartProvider);
    final money = ref.watch(currencyFormatterProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    final tax = ref.watch(cartTaxProvider);
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.appName)),
      body: items.isEmpty
          ? EmptyView(
              title: t.emptyCart,
              subtitle: t.emptyCartSubtitle,
              icon: Icons.shopping_cart_outlined,
              action: PrimaryButton(label: t.shopNow, onPressed: () => context.go('/home'), expand: false),
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              children: [
                Text(t.myCart, style: AppTextStyles.displayLg(), textAlign: TextAlign.right),
                const SizedBox(height: 4),
                Text(t.itemsInCart(items.fold<int>(0, (s, i) => s + i.quantity)),
                    style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant), textAlign: TextAlign.right),
                const SizedBox(height: AppSpacing.stackLg),
                for (final item in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.stackMd),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.stackMd),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                              onPressed: () => ref.read(cartProvider.notifier).remove(item.product.id),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(item.product.name,
                                      style: AppTextStyles.bodyMd().copyWith(fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.right),
                                  if (item.selectedColor != null) ...[
                                    const SizedBox(height: 2),
                                    Text('${t.color}: ${item.selectedColor}', style: AppTextStyles.labelSm()),
                                  ],
                                  const SizedBox(height: AppSpacing.stackSm),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(money.format(item.lineTotal),
                                          style: AppTextStyles.bodyMd(color: AppColors.primary)
                                              .copyWith(fontWeight: FontWeight.w700)),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceContainer,
                                          borderRadius: BorderRadius.circular(AppRadius.full),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              iconSize: 18,
                                              icon: const Icon(Icons.remove_rounded),
                                              onPressed: () => ref
                                                  .read(cartProvider.notifier)
                                                  .updateQuantity(item.product.id, item.quantity - 1),
                                            ),
                                            Text('${item.quantity}', style: AppTextStyles.bodyMd()),
                                            IconButton(
                                              iconSize: 18,
                                              icon: const Icon(Icons.add_rounded),
                                              onPressed: () => ref
                                                  .read(cartProvider.notifier)
                                                  .updateQuantity(item.product.id, item.quantity + 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.stackSm),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              child: CachedNetworkImage(
                                imageUrl: item.product.imageUrl,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.marginMobile),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(t.orderSummary, style: AppTextStyles.headlineSm(), textAlign: TextAlign.right),
                        const SizedBox(height: AppSpacing.stackMd),
                        _summaryRow(t.subtotal, money.format(subtotal)),
                        const SizedBox(height: AppSpacing.stackSm),
                        _summaryRow(t.shipping, t.free),
                        const SizedBox(height: AppSpacing.stackSm),
                        _summaryRow('${t.tax} (15%)', money.format(tax)),
                        const Divider(height: 32),
                        _summaryRow(t.total, money.format(total), emphasize: true),
                        const SizedBox(height: AppSpacing.stackLg),
                        PrimaryButton(
                          label: t.checkout,
                          icon: Icons.arrow_back_rounded,
                          onPressed: () => context.push('/checkout'),
                        ),
                        const SizedBox(height: AppSpacing.stackSm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Text(t.securePayment, style: AppTextStyles.labelSm()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _summaryRow(String label, String value, {bool emphasize = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(value,
            style: emphasize
                ? AppTextStyles.headlineSm(color: AppColors.primary)
                : AppTextStyles.bodyMd()),
        Text(label,
            style: emphasize
                ? AppTextStyles.headlineSm()
                : AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}
