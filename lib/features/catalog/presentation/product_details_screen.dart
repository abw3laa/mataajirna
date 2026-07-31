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
import '../../../core/widgets/status_badge.dart';
import '../../../l10n/app_localizations.dart';
import '../../cart/presentation/cart_providers.dart';
import 'catalog_providers.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  const ProductDetailsScreen({super.key, required this.productId});
  final String productId;

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  int _quantity = 1;
  int _colorIndex = 0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final productAsync = ref.watch(productDetailsProvider(widget.productId));
    final money = ref.watch(currencyFormatterProvider);

    return Scaffold(
      body: productAsync.when(
        data: (product) {
          if (product == null) {
            return EmptyView(
                title: t.somethingWentWrong, icon: Icons.error_outline_rounded);
          }
          final hasDiscount = product.discountPrice != null;
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Stack(
                        children: [
                          Hero(
                            tag: 'product-image-${product.id}',
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: CachedNetworkImage(
                                  imageUrl: product.imageUrl, fit: BoxFit.cover),
                            ),
                          ),
                          SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.stackMd),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _RoundIconButton(
                                      icon: Icons.favorite_border_rounded,
                                      onTap: () {}),
                                  _RoundIconButton(
                                      icon: Icons.arrow_back_rounded,
                                      onTap: () => context.pop()),
                                ],
                              ),
                            ),
                          ),
                          if (product.badgeLabel != null)
                            Positioned(
                              top: 70,
                              right: 16,
                              child: StatusBadge(
                                  label: product.badgeLabel!,
                                  tone: product.badgeTone),
                            ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.marginMobile),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        money.format(hasDiscount
                                            ? product.discountPrice!
                                            : product.price),
                                        style: AppTextStyles.headlineSm(
                                            color: AppColors.primary)),
                                    if (hasDiscount)
                                      Text(money.format(product.price),
                                          style: AppTextStyles.labelMd()
                                              .copyWith(
                                                  decoration: TextDecoration
                                                      .lineThrough)),
                                  ],
                                ),
                                const Spacer(),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(product.name,
                                          style: AppTextStyles.headlineSm(),
                                          textAlign: TextAlign.right),
                                      const SizedBox(height: 4),
                                      Text(product.categoryName,
                                          style: AppTextStyles.bodyMd(
                                              color:
                                                  AppColors.onSurfaceVariant)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.stackMd),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(product.inStock ? t.inStock : t.outOfStock,
                                    style: AppTextStyles.labelMd(
                                        color: product.inStock
                                            ? AppColors.success
                                            : AppColors.error)),
                                const SizedBox(width: 6),
                                Icon(
                                  product.inStock
                                      ? Icons.check_circle_outline_rounded
                                      : Icons.cancel_outlined,
                                  size: 18,
                                  color: product.inStock
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ],
                            ),
                            if (product.colors.isNotEmpty) ...[
                              const Divider(height: 32),
                              Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(t.color,
                                      style: AppTextStyles.labelMd())),
                              const SizedBox(height: AppSpacing.stackSm),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  for (int i = 0;
                                      i < product.colors.length;
                                      i++)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: GestureDetector(
                                        onTap: () =>
                                            setState(() => _colorIndex = i),
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(int.parse(product
                                                .colors[i]
                                                .replaceFirst('#', '0xFF'))),
                                            border: Border.all(
                                              color: _colorIndex == i
                                                  ? AppColors.primary
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                          ),
                                          child: _colorIndex == i
                                              ? const Icon(Icons.check_rounded,
                                                  size: 16, color: Colors.white)
                                              : null,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                            const Divider(height: 32),
                            Align(
                                alignment: Alignment.centerRight,
                                child: Text(t.productDescription,
                                    style: AppTextStyles.labelMd())),
                            const SizedBox(height: AppSpacing.stackSm),
                            Text(product.description,
                                style: AppTextStyles.bodyMd(),
                                textAlign: TextAlign.right),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.marginMobile),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    border: Border(
                        top: BorderSide(color: AppColors.outlineVariant)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.outlineVariant),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () =>
                                  setState(() => _quantity = (_quantity + 1)),
                              icon: const Icon(Icons.add_rounded, size: 18),
                            ),
                            Text('$_quantity', style: AppTextStyles.bodyMd()),
                            IconButton(
                              onPressed: _quantity > 1
                                  ? () => setState(() => _quantity--)
                                  : null,
                              icon: const Icon(Icons.remove_rounded, size: 18),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.stackMd),
                      Expanded(
                        child: PrimaryButton(
                          label: t.addToCart,
                          icon: Icons.shopping_bag_outlined,
                          onPressed: product.inStock
                              ? () {
                                  for (var i = 0; i < _quantity; i++) {
                                    ref.read(cartProvider.notifier).add(
                                          product,
                                          color: product.colors.isNotEmpty
                                              ? product.colors[_colorIndex]
                                              : null,
                                        );
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${t.addToCart} ✓')),
                                  );
                                }
                              : null,
                        ),
                      ),
                    ],
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
          onRetry: () =>
              ref.invalidate(productDetailsProvider(widget.productId)),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: CircleAvatar(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        child: Icon(icon, color: AppColors.onSurface, size: 20),
      ),
    );
  }
}
