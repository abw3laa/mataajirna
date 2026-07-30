import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import '../../cart/domain/cart_item.dart';
import '../../catalog/domain/product.dart';
import '../domain/order.dart';
import 'orders_repository.dart';

/// التنفيذ الحقيقي المرتبط بمجموعة `orders` في Firestore.
///
/// - `watchMyOrders`: يُفلتر بـ `userId == uid` الحالي (مطابق لقواعد الأمان).
/// - `watchAllOrders`: يُعيد كل الطلبات — Firestore Rules ترفضه لغير المدير.
/// - `updateOrderStatus`: يُفضَّل استدعاؤه عبر Cloud Function `updateOrderStatus`
///   (راجع firebase/functions/index.js) بدل كتابة مباشرة، لضمان تسجيل سجل
///   التدقيق statusHistory. النسخة هنا تكتب مباشرة على المستند لتبسيط
///   المثال؛ Firestore Rules ترفض الكتابة أصلاً لغير المدير في الحالتين.
class FirestoreOrdersRepository implements OrdersRepository {
  FirestoreOrdersRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  @override
  Stream<List<Order>> watchMyOrders() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(const []);
    return _db
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_orderFromDoc).toList());
  }

  @override
  Stream<List<Order>> watchAllOrders() {
    return _db
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_orderFromDoc).toList());
  }

  @override
  Future<Order> placeOrder({required List<CartItem> items, required double total}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('يجب تسجيل الدخول لإنشاء طلب.');
    }
    final docRef = _db.collection('orders').doc();
    final order = Order(
      id: docRef.id,
      customerName: user.displayName ?? '',
      userId: user.uid,
      items: items,
      total: total,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
    );
    await docRef.set({
      'customerName': order.customerName,
      'userId': order.userId,
      'total': order.total,
      'status': order.status.name,
      'createdAt': FieldValue.serverTimestamp(),
      'items': items
          .map((i) => {
                'productId': i.product.id,
                'name': i.product.name,
                'imageUrl': i.product.imageUrl,
                'unitPrice': i.unitPrice,
                'quantity': i.quantity,
                'selectedColor': i.selectedColor,
              })
          .toList(),
    });
    return order;
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _db.collection('orders').doc(orderId).update({
      'status': status.name,
      'statusHistory': FieldValue.arrayUnion([
        {
          'status': status.name,
          'changedBy': _auth.currentUser?.uid,
          'changedAt': DateTime.now().toIso8601String(),
        }
      ]),
    });
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
