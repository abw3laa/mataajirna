import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/backend_config.dart';
import '../data/catalog_repository.dart';
import '../data/firestore_catalog_repository.dart';
import '../data/mock_catalog_repository.dart';
import '../domain/category.dart';
import '../domain/product.dart';

/// يبدّل تلقائياً بين Mock وFirestore حسب lib/core/config/backend_config.dart.
final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return kUseFirebase ? FirestoreCatalogRepository() : MockCatalogRepository();
});

final categoriesProvider = StreamProvider<List<ProductCategory>>((ref) {
  return ref.watch(catalogRepositoryProvider).watchCategories();
});

final selectedCategoryProvider = StateProvider<String>((ref) => 'all');
final searchQueryProvider = StateProvider<String>((ref) => '');

final productsProvider = StreamProvider<List<Product>>((ref) {
  final categoryId = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider);
  return ref.watch(catalogRepositoryProvider).watchProducts(categoryId: categoryId, query: query);
});

final productDetailsProvider = FutureProvider.family<Product?, String>((ref, id) {
  return ref.watch(catalogRepositoryProvider).getProduct(id);
});
