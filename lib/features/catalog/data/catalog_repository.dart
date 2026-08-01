import '../domain/category.dart';
import '../domain/product.dart';

abstract class CatalogRepository {
  Stream<List<ProductCategory>> watchCategories();
  Stream<List<Product>> watchProducts({String? categoryId, String? query});
  Future<Product?> getProduct(String id);

  /// جلب صفحة واحدة من المنتجات (Pagination حقيقي) — تُستخدم في شاشة إدارة
  /// المنتجات بدل تحميل كل المستندات دفعة واحدة. `cursor` هو معرّف آخر
  /// عنصر في الصفحة السابقة (null للصفحة الأولى)؛ يُعاد استخدامه لجلب
  /// الصفحة التالية عبر `startAfter` في Firestore.
  Future<ProductsPage> fetchProductsPage({int limit = 20, String? cursor});

  /// عمليات الكتابة التالية يجب أن تُرفض من الخادم (Firestore Rules /
  /// Cloud Functions) إن لم يكن المستدعي يحمل صلاحية admin — بغض النظر
  /// عمّا يظهر في واجهة العميل.
  Future<void> upsertProduct(Product product);
  Future<void> deleteProduct(String id);
}

class ProductsPage {
  const ProductsPage({required this.items, required this.nextCursor, required this.hasMore});
  final List<Product> items;
  final String? nextCursor;
  final bool hasMore;
}
