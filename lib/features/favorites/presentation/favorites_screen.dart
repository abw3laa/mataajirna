import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/state_views.dart';
import '../../cart/presentation/cart_providers.dart';
import '../../catalog/presentation/catalog_providers.dart';
import 'favorites_providers.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoritesProvider);
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('المفضلة')),
      body: productsAsync.when(
        data: (allProducts) {
          final favorites = allProducts.where((p) => favoriteIds.contains(p.id)).toList();
          if (favorites.isEmpty) {
            return EmptyView(
              title: 'قائمة المفضلة فارغة',
              subtitle: 'اضغط على أيقونة القلب في أي منتج لإضافته هنا',
              icon: Icons.favorite_border_rounded,
              action: PrimaryButton(label: 'تصفّح المنتجات', onPressed: () => context.go('/home'), expand: false),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            itemCount: favorites.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.stackMd,
              crossAxisSpacing: AppSpacing.stackMd,
              childAspectRatio: 0.62,
            ),
            itemBuilder: (context, i) {
              final p = favorites[i];
              return ProductCard(
                product: p,
                onTap: () => context.push('/product/${p.id}'),
                onAddToCart: () => ref.read(cartProvider.notifier).add(p),
              );
            },
          );
        },
        loading: () => const LoadingView(),
        error: (e, _) => AppErrorView(
          title: 'حدث خطأ ما',
          message: e.toString(),
          retryLabel: 'إعادة المحاولة',
          onRetry: () => ref.invalidate(productsProvider),
        ),
      ),
    );
  }
}
