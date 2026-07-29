import '../domain/order.dart';
import '../../cart/domain/cart_item.dart';

abstract class OrdersRepository {
  /// طلبات المستخدم الحالي فقط — يفرضها الخادم عبر
  /// `where('userId', isEqualTo: auth.uid)` + Firestore Rules مطابقة.
  Stream<List<Order>> watchMyOrders();

  /// كل الطلبات — للوحة تحكم المدير فقط. الخادم يرفض هذا الاستعلام
  /// لأي مستخدم لا يحمل `role == admin` في الـ ID Token.
  Stream<List<Order>> watchAllOrders();

  Future<Order> placeOrder({required List<CartItem> items, required double total});

  /// تحديث حالة الطلب — عملية إدارية حساسة، يجب أن تمر عبر Cloud Function
  /// `updateOrderStatus` التي تتحقق من صلاحية admin قبل الكتابة.
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
}
