import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../cart/domain/cart_item.dart';
import '../../catalog/domain/product.dart';
import '../domain/order.dart';
import 'orders_repository.dart';

/// التنفيذ الحقيقي المرتبط بمجموعة `orders` في Firestore.
///
/// - `watchMyOrders`: يُفلتر بـ `userId == uid` الحالي (مطابق لقواعد الأمان).
/// - `watchAllOrders`: يُعيد كل الطلبات — Firestore Rules ترفضه لغير المدير.
/// - `placeOrder`: ⚠️ **لا يكتب على Firestore مباشرة إطلاقاً**. يستدعي
///   Cloud Function `createOrder` فقط، والتي تعيد حساب كل سعر من مستندات
///   `products` الحقيقية على الخادم وتتحقق من الكوبون بنفسها، ثم تكتب
///   المستند بصلاحيات Admin SDK. هذا يمنع أي تلاعب بالسعر من العميل —
///   Firestore Rules نفسها ترفض أي `create` مباشر على orders (`allow create: if false`).
/// - `updateOrderStatus`: يُستدعى عبر Cloud Function `updateOrderStatus`
///   لضمان تسجيل سجل التدقيق statusHistory والتحقق من صلاحية admin على الخادم.
class FirestoreOrdersRepository implements OrdersRepository {
  FirestoreOrdersRepository({FirebaseFirestore? firestore, FirebaseAuth? auth, FirebaseFunctions? functions})
      : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;

  @override
  Stream<List<Order>> watchMyOrders() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(const []);
    return _db
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(50) // حد أقصى معقول يمنع تحميل آلاف المستندات دفعة واحدة
        .snapshots()
        .map((snap) => snap.docs.map(_orderFromDoc).toList());
  }

  @override
  Stream<List<Order>> watchAllOrders() {
    return _db
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) => snap.docs.map(_orderFromDoc).toList());
  }

  @override
  Future<Order> placeOrder({required List<CartItem> items, String? couponCode, String? address}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('يجب تسجيل الدخول لإنشاء طلب.');
    }

    final callable = _functions.httpsCallable('createOrder');
    final result = await callable.call<Map<String, dynamic>>({
      'items': items
          .map((i) => {
                'productId': i.product.id,
                'quantity': i.quantity,
                'selectedColor': i.selectedColor,
              })
          .toList(),
      'couponCode': couponCode,
      'address': address,
    });

    final data = result.data;
    return Order(
      id: data['orderId'] as String,
      customerName: user.displayName ?? user.email ?? '',
      userId: user.uid,
      items: items,
      total: (data['total'] as num).toDouble(),
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
      address: address,
    );
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final callable = _functions.httpsCallable('updateOrderStatus');
    await callable.call<Map<String, dynamic>>({'orderId': orderId, 'status': status.name});
  }

  Order _orderFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final itemsData = (data['items'] as List?) ?? const [];
    return Order(
      id: doc.id,
      customerName: data['customerName'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      total: (data['total'] as num?)?.toDouble() ?? 0,
      status: OrderStatusX.fromString(data['status'] as String? ?? 'pending'),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      address: data['address'] as String?,
      items: itemsData.map((raw) {
        final m = raw as Map<String, dynamic>;
        return CartItem(
          product: Product(
            id: m['productId'] as String? ?? '',
            name: m['name'] as String? ?? '',
            description: '',
            price: (m['unitPrice'] as num?)?.toDouble() ?? 0,
            categoryId: '',
            categoryName: '',
            imageUrl: m['imageUrl'] as String? ?? '',
            inStock: true,
          ),
          quantity: m['quantity'] as int? ?? 1,
          selectedColor: m['selectedColor'] as String?,
        );
      }).toList(),
    );
  }
}
