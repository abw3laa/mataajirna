import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/currency/currency_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../catalog/domain/product.dart';
import '../../../catalog/presentation/catalog_providers.dart';

const _pageSize = 20;

/// شاشة إدارة المنتجات — Pagination حقيقي (صفحة تلو الأخرى عبر cursor) بدل
/// تحميل كل المنتجات دفعة واحدة، مع سحب-للتحديث (Pull to Refresh).
class ManageProductsScreen extends ConsumerStatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  ConsumerState<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends ConsumerState<ManageProductsScreen> {
  final List<Product> _products = [];
  String? _cursor;
  bool _hasMore = true;
  bool _isLoadingFirst = true;
  bool _isLoadingMore = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadFirstPage();
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _isLoadingFirst = true;
      _error = null;
      _products.clear();
      _cursor = null;
      _hasMore = true;
    });
    try {
      final page = await ref.read(catalogRepositoryProvider).fetchProductsPage(limit: _pageSize);
      setState(() {
        _products.addAll(page.items);
        _cursor = page.nextCursor;
        _hasMore = page.hasMore;
      });
    } catch (e) {
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _isLoadingFirst = false);
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final page = await ref
          .read(catalogRepositoryProvider)
          .fetchProductsPage(limit: _pageSize, cursor: _cursor);
      setState(() {
        _products.addAll(page.items);
        _cursor = page.nextCursor;
        _hasMore = page.hasMore;
      });
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final money = ref.watch(currencyFormatterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.manageProducts),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push('/admin/products/new'),
          ),
        ],
      ),
      body: _isLoadingFirst
          ? const LoadingView()
          : _error != null
              ? AppErrorView(
                  title: t.somethingWentWrong,
                  message: _error.toString(),
                  retryLabel: t.retry,
                  onRetry: _loadFirstPage,
                )
              : _products.isEmpty
                  ? const EmptyView(title: 'لا توجد منتجات', icon: Icons.inventory_2_outlined)
                  : RefreshIndicator(
                      onRefresh: _loadFirstPage,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.marginMobile),
                        itemCount: _products.length + 1, // +1 لعنصر "تحميل المزيد"
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.stackSm),
                        itemBuilder: (context, i) {
                          if (i == _products.length) {
                            if (!_hasMore) return const SizedBox.shrink();
                            // نطلب الصفحة التالية تلقائياً عند الوصول لنهاية القائمة.
                            WidgetsBinding.instance.addPostFrameCallback((_) => _loadMore());
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: AppSpacing.stackMd),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final p = _products[i];
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
                                  Text(money.format(p.discountPrice ?? p.price),
                                      style: AppTextStyles.bodyMd().copyWith(fontWeight: FontWeight.w700)),
                                  IconButton(
                                    iconSize: 18,
                                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                                    onPressed: () async {
                                      await ref.read(catalogRepositoryProvider).deleteProduct(p.id);
                                      setState(() => _products.removeAt(i));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
