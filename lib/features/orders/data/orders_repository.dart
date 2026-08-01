import '../domain/order.dart';
import '../../cart/domain/cart_item.dart';

abstract class OrdersRepository {
  /// طلبات المستخدم الحالي فقط — يفرضها الخادم عبر
  /// `where('userId', isEqualTo: auth.uid)` + Firestore Rules مطابقة.
  Stream<List<Order>> watchMyOrders();

  /// كل الطلبات — للوحة تحكم المدير فقط. الخادم يرفض هذا الاستعلام
  /// لأي مستخدم لا يحمل `role == admin` في الـ ID Token.
  Stream<List<Order>> watchAllOrders();

  /// ⚠️ لاحظ أن هذا لا يستقبل `total` من العميل إطلاقاً. الخادم (Cloud
  /// Function `createOrder`) هو من يعيد حساب كل سعر من مستندات `products`
  /// الحقيقية، ويتحقق من صلاحية `couponCode` بنفسه، ثم يكتب الطلب. هذا يمنع
  /// أي تلاعب بالسعر عبر تعديل الطلب الشبكي من العميل.
  Future<Order> placeOrder({required List<CartItem> items, String? couponCode, String? address});

  /// تحديث حالة الطلب — عملية إدارية حساسة، يجب أن تمر عبر Cloud Function
  /// `updateOrderStatus` التي تتحقق من صلاحية admin قبل الكتابة.
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
}
