import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/currency/currency_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../catalog/presentation/catalog_providers.dart';

class ManageProductsScreen extends ConsumerWidget {
  const ManageProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final productsAsync = ref.watch(productsProvider);
    final money = ref.watch(currencyFormatterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.manageProducts),
        actions: [IconButton(icon: const Icon(Icons.add_rounded), onPressed: () => context.push('/admin/products/new'))],
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) return EmptyView(title: 'لا توجد منتجات', icon: Icons.inventory_2_outlined);
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.stackSm),
            itemBuilder: (context, i) {
              final p = products[i];
              return Card(
                child: ListTile(
                  onTap: () => context.push('/admin/products/${p.id}'),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Image.network(p.imageUrl, width: 48, height: 48, fit: BoxFit.cover),
                  ),
                  title: Text(p.name, textAlign: TextAlign.right),
                  subtitle: Text(
                    p.inStock ? t.inStock : t.outOfStock,
                    style: TextStyle(color: p.inStock ? AppColors.success : AppColors.error),
                    textAlign: TextAlign.right,
                  ),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(money.format(p.discountPrice ?? p.price), style: AppTextStyles.bodyMd().copyWith(fontWeight: FontWeight.w700)),
                      IconButton(
                        iconSize: 18,
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                        onPressed: () => ref.read(catalogRepositoryProvider).deleteProduct(p.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const LoadingView(),
        error: (e, _) => AppErrorView(title: t.somethingWentWrong, message: e.toString(), retryLabel: t.retry, onRetry: () => ref.invalidate(productsProvider)),
      ),
    );
  }
}
