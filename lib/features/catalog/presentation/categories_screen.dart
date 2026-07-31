import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/category_chip.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/product_grid_skeleton.dart';
import '../../../core/widgets/state_views.dart';
import '../../../l10n/app_localizations.dart';
import '../../cart/presentation/cart_providers.dart';
import 'catalog_providers.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final categoriesAsync = ref.watch(categoriesProvider);
    final productsAsync = ref.watch(productsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () => context.go('/cart')),
        title: Text(t.categories),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: t.searchProducts,
                      prefixIcon: const Icon(Icons.search_rounded),
                    ),
                    onSubmitted: (v) =>
                        ref.read(searchQueryProvider.notifier).state = v,
                  ),
                ),
                const SizedBox(width: AppSpacing.stackSm),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: Text(t.filterSort),
                  style:
                      OutlinedButton.styleFrom(minimumSize: const Size(0, 56)),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 44,
            child: categoriesAsync.when(
              data: (categories) => ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.marginMobile),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.stackSm),
                    child: CategoryChip(
                      label: t.all,
                      selected: selectedCategory == 'all',
                      onTap: () => ref
                          .read(selectedCategoryProvider.notifier)
                          .state = 'all',
                    ),
                  ),
                  for (final c in categories)
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.stackSm),
                      child: CategoryChip(
                        label: c.name,
                        selected: selectedCategory == c.id,
                        onTap: () => ref
                            .read(selectedCategoryProvider.notifier)
                            .state = c.id,
                      ),
                    ),
                ],
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: AppSpacing.stackMd),
          Expanded(
            child: productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return const EmptyView(
                      title: 'لا توجد منتجات',
                      subtitle: 'جرّب تصنيفاً آخر أو كلمة بحث مختلفة');
                }
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.marginMobile,
                    0,
                    AppSpacing.marginMobile,
                    AppSpacing.marginMobile,
                  ),
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.stackMd,
                    crossAxisSpacing: AppSpacing.stackMd,
                    childAspectRatio: 0.62,
                  ),
                  itemBuilder: (context, i) {
                    final p = products[i];
                    return ProductCard(
                      product: p,
                      onTap: () => context.push('/product/${p.id}'),
                      onAddToCart: () => ref.read(cartProvider.notifier).add(p),
                    );
                  },
                );
              },
              loading: () => const ProductGridSkeleton(itemCount: 8, shrinkWrap: false),
              error: (e, _) => AppErrorView(
                title: t.somethingWentWrong,
                message: e.toString(),
                retryLabel: t.retry,
                onRetry: () => ref.invalidate(productsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
