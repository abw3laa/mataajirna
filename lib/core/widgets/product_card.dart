import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../currency/currency_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../../features/catalog/domain/product.dart';
import 'status_badge.dart';

class ProductCard extends ConsumerWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final money = ref.watch(currencyFormatterProvider);
    final hasDiscount = product.discountPrice != null && product.discountPrice! < product.price;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
                      imageUrl: product.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: AppColors.surfaceContainer),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.surfaceContainer,
                        child: const Icon(Icons.image_not_supported_outlined),
                      ),
                    ),
                  ),
                ),
                if (product.badgeLabel != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: StatusBadge(label: product.badgeLabel!, tone: product.badgeTone),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.stackMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.categoryName, style: AppTextStyles.labelSm()),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMd().copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSpacing.stackSm),
                  Row(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        onTap: product.inStock ? onAddToCart : null,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: product.inStock
                              ? AppColors.primary
                              : AppColors.surfaceContainerHigh,
                          child: Icon(
                            Icons.add_shopping_cart_rounded,
                            size: 16,
                            color: product.inStock ? Colors.white : AppColors.outline,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            money.format(hasDiscount ? product.discountPrice! : product.price),
                            style: AppTextStyles.bodyMd(color: AppColors.primary)
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                          if (hasDiscount)
                            Text(
                              money.format(product.price),
                              style: AppTextStyles.labelSm().copyWith(
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                    ],
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
