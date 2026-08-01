import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/widgets/status_badge.dart';
import '../domain/category.dart';
import '../domain/product.dart';
import 'catalog_repository.dart';

/// التنفيذ الحقيقي المرتبط بمجموعتَي `products` و`categories` في Firestore.
///
/// القراءة عامة للجميع (مطابق لقواعد `firebase/firestore.rules`)، بينما
/// الكتابة (`upsertProduct`/`deleteProduct`) تُقبل من الخادم فقط لمن يحمل
/// `role == admin` — التحقق الفعلي في Firestore Rules، وليس في هذا الكود.
class FirestoreCatalogRepository implements CatalogRepository {
  FirestoreCatalogRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  @override
  Stream<List<ProductCategory>> watchCategories() {
    return _db.collection('categories').orderBy('order').snapshots().map(
          (snap) => snap.docs.map((d) => _categoryFromDoc(d)).toList(),
        );
  }

  @override
  Stream<List<Product>> watchProducts({String? categoryId, String? query}) {
    Query<Map<String, dynamic>> ref = _db.collection('products');
    if (categoryId != null && categoryId != 'all') {
      ref = ref.where('categoryId', isEqualTo: categoryId);
    }
    return ref.snapshots().map((snap) {
      var products = snap.docs.map((d) => _productFromDoc(d)).toList();
      // فلترة البحث النصي تتم على العميل هنا (بسيطة). لكتالوج كبير، استخدم
      // خدمة بحث مخصصة (Algolia/Typesense) بدل Firestore مباشرة.
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim();
        products = products
            .where((p) => p.name.contains(q) || p.description.contains(q))
            .toList();
      }
      return products;
    });
  }

  @override
  Future<Product?> getProduct(String id) async {
    final doc = await _db.collection('products').doc(id).get();
    if (!doc.exists) return null;
    return _productFromDoc(doc);
  }

  @override
  Future<ProductsPage> fetchProductsPage({int limit = 20, String? cursor}) async {
    Query<Map<String, dynamic>> query = _db
        .collection('products')
        .orderBy(FieldPath.documentId)
        .limit(limit);
    if (cursor != null) {
      query = query.startAfter([cursor]);
    }
    final snap = await query.get();
    final items = snap.docs.map(_productFromDoc).toList();
    return ProductsPage(
      items: items,
      nextCursor: items.isEmpty ? null : snap.docs.last.id,
      hasMore: items.length == limit,
    );
  }

  @override
  Future<void> upsertProduct(Product product) async {
    await _db.collection('products').doc(product.id).set({
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'discountPrice': product.discountPrice,
      'categoryId': product.categoryId,
      'categoryName': product.categoryName,
      'imageUrl': product.imageUrl,
      'gallery': product.gallery,
      'colors': product.colors,
      'inStock': product.inStock,
      'badgeLabel': product.badgeLabel,
      'badgeTone': product.badgeTone.name,
      'updatedAt': FieldValue.serverTimestamp(),
      // من عدّل هذا المستند — تلتقطه Cloud Function `onProductWrite` لتسجيله
      // في سجل التدقيق (auditLogs). Firestore Rules تفرض أن يطابق دائماً
      // uid المدير الحالي (لا يمكن انتحال هوية مدير آخر هنا).
      'updatedBy': _auth.currentUser?.uid,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _db.collection('products').doc(id).delete();
  }

  ProductCategory _categoryFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return ProductCategory(
      id: doc.id,
      name: data['name'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
    );
  }

  Product _productFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Product(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      discountPrice: (data['discountPrice'] as num?)?.toDouble(),
      categoryId: data['categoryId'] as String? ?? '',
      categoryName: data['categoryName'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      gallery: (data['gallery'] as List?)?.cast<String>() ?? const [],
      colors: (data['colors'] as List?)?.cast<String>() ?? const [],
      inStock: data['inStock'] as bool? ?? true,
      badgeLabel: data['badgeLabel'] as String?,
      badgeTone: BadgeTone.values.firstWhere(
        (t) => t.name == data['badgeTone'],
        orElse: () => BadgeTone.primary,
      ),
    );
  }
}
