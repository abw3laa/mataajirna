import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/currency/currency_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/star_rating.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../cart/presentation/cart_providers.dart';
import '../../favorites/presentation/favorites_providers.dart';
import '../../reviews/presentation/reviews_providers.dart';
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
          final isFavorite = ref.watch(favoritesProvider).contains(product.id);
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
                                      icon: isFavorite
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      iconColor: isFavorite ? AppColors.accent : null,
                                      onTap: () => ref
                                          .read(favoritesProvider.notifier)
                                          .toggle(product.id)),
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
                                      const SizedBox(height: 4),
                                      _AverageRatingLabel(productId: product.id),
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
                            const Divider(height: 32),
                            _ReviewsSection(productId: product.id),
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

class _AverageRatingLabel extends ConsumerWidget {
  const _AverageRatingLabel({required this.productId});
  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(productReviewsProvider(productId));
    final reviews = reviewsAsync.valueOrNull ?? const [];
    if (reviews.isEmpty) return const SizedBox.shrink();
    final avg = reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
    return StarRating(rating: avg, size: 14);
  }
}

class _ReviewsSection extends ConsumerWidget {
  const _ReviewsSection({required this.productId});
  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(productReviewsProvider(productId));
    final isGuest = ref.watch(authStateProvider).value == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            TextButton(
              onPressed: () {
                if (isGuest) {
                  context.push('/login');
                } else {
                  _showAddReviewSheet(context, ref);
                }
              },
              child: const Text('أضف تقييمك'),
            ),
            const Spacer(),
            Text('التقييمات', style: AppTextStyles.headlineSm()),
          ],
        ),
        const SizedBox(height: AppSpacing.stackSm),
        reviewsAsync.when(
          data: (reviews) {
            if (reviews.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.stackMd),
                child: Text('لا توجد تقييمات بعد — كن أول من يقيّم هذا المنتج',
                    style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                    textAlign: TextAlign.center),
              );
            }
            final avg = reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StarRating(rating: avg, size: 20),
                    const SizedBox(width: 8),
                    Text('(${reviews.length} تقييم)', style: AppTextStyles.labelMd()),
                  ],
                ),
                const SizedBox(height: AppSpacing.stackMd),
                for (final review in reviews)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.stackMd),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.stackMd),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              StarRating(rating: review.rating.toDouble(), size: 14),
                              const Spacer(),
                              Text(review.userName,
                                  style: AppTextStyles.bodyMd().copyWith(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(review.comment, style: AppTextStyles.bodyMd(), textAlign: TextAlign.right),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.stackLg),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  void _showAddReviewSheet(BuildContext context, WidgetRef ref) {
    int rating = 5;
    final commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.marginMobile,
            right: AppSpacing.marginMobile,
            top: AppSpacing.marginMobile,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.marginMobile,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('أضف تقييمك', style: AppTextStyles.headlineSm(), textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.stackMd),
                  StarRatingInput(value: rating, onChanged: (v) => setSheetState(() => rating = v)),
                  const SizedBox(height: AppSpacing.stackMd),
                  AppTextField(hint: 'اكتب رأيك في المنتج...', controller: commentController, maxLines: 3),
                  const SizedBox(height: AppSpacing.stackLg),
                  PrimaryButton(
                    label: 'إرسال التقييم',
                    onPressed: () async {
                      final user = ref.read(authStateProvider).value;
                      await ref.read(reviewsRepositoryProvider).addReview(
                            productId: productId,
                            userName: user?.name ?? 'مستخدم',
                            rating: rating,
                            comment: commentController.text,
                          );
                      if (context.mounted) Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap, this.iconColor});
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: CircleAvatar(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        child: Icon(icon, color: iconColor ?? AppColors.onSurface, size: 20),
      ),
    );
  }
}
