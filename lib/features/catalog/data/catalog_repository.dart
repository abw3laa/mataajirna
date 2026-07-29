import '../domain/category.dart';
import '../domain/product.dart';

abstract class CatalogRepository {
  Stream<List<ProductCategory>> watchCategories();
  Stream<List<Product>> watchProducts({String? categoryId, String? query});
  Future<Product?> getProduct(String id);

  /// عمليات الكتابة التالية يجب أن تُرفض من الخادم (Firestore Rules /
  /// Cloud Functions) إن لم يكن المستدعي يحمل صلاحية admin — بغض النظر
  /// عمّا يظهر في واجهة العميل.
  Future<void> upsertProduct(Product product);
  Future<void> deleteProduct(String id);
}
