import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/category_chip.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/state_views.dart';
import '../../../l10n/app_localizations.dart';
import '../../cart/presentation/cart_providers.dart';
import 'catalog_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final categoriesAsync = ref.watch(categoriesProvider);
    final productsAsync = ref.watch(productsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.menu_rounded), onPressed: () => Scaffold.of(context).openDrawer()),
        title: Text(t.appName),
        actions: [
          IconButton(icon: const Icon(Icons.shopping_bag_outlined), onPressed: () => context.go('/cart')),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(productsProvider),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.marginMobile),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
              child: TextField(
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: t.searchProducts,
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLowest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.full), borderSide: const BorderSide(color: AppColors.outlineVariant)),
                ),
                onSubmitted: (v) => ref.read(searchQueryProvider.notifier).state = v,
              ),
            ),
            const SizedBox(height: AppSpacing.stackLg),
            SizedBox(
              height: 44,
              child: categoriesAsync.when(
                data: (categories) => ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.stackSm),
                      child: CategoryChip(
                        label: t.all,
                        selected: selectedCategory == 'all',
                        onTap: () => ref.read(selectedCategoryProvider.notifier).state = 'all',
                      ),
                    ),
                    for (final c in categories)
                      Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.stackSm),
                        child: CategoryChip(
                          label: c.name,
                          selected: selectedCategory == c.id,
                          onTap: () => ref.read(selectedCategoryProvider.notifier).state = c.id,
                        ),
                      ),
                  ],
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: AppSpacing.stackLg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
              child: _PromoBanner(t: t),
            ),
            const SizedBox(height: AppSpacing.stackLg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
              child: Text(t.newArrivals, style: AppTextStyles.headlineSm(), textAlign: TextAlign.right),
            ),
            const SizedBox(height: AppSpacing.stackMd),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
              child: productsAsync.when(
                data: (products) {
                  if (products.isEmpty) {
                    return EmptyView(title: t.somethingWentWrong, subtitle: null, icon: Icons.search_off_rounded);
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                loading: () => const Padding(padding: EdgeInsets.only(top: 40), child: LoadingView()),
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
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({required this.t});
  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryContainer]),
      ),
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.full)),
              child: Text(t.specialOffer, style: AppTextStyles.labelSm(color: AppColors.primary)),
            ),
          ),
          Text(
            'خصم يصل إلى 50%\nعلى الإلكترونيات',
            textAlign: TextAlign.right,
            style: AppTextStyles.headlineMd(color: Colors.white),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
              minimumSize: const Size(120, 40),
            ),
            onPressed: () {},
            child: Text(t.shopNow),
          ),
        ],
      ),
    );
  }
}
