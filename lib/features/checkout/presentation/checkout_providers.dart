import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/coupon.dart';
import '../../cart/presentation/cart_providers.dart';

final appliedCouponProvider = StateProvider<Coupon?>((ref) => null);

/// قيمة الخصم بالريال (على المجموع الفرعي، قبل الضريبة).
final couponDiscountProvider = Provider<double>((ref) {
  final coupon = ref.watch(appliedCouponProvider);
  if (coupon == null) return 0;
  final subtotal = ref.watch(cartSubtotalProvider);
  return subtotal * (coupon.discountPercent / 100);
});

/// الإجمالي النهائي بعد تطبيق الكوبون (إن وجد) — يحل محل cartTotalProvider
/// في شاشة الدفع تحديداً.
final checkoutTotalProvider = Provider<double>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);
  final discount = ref.watch(couponDiscountProvider);
  final taxable = subtotal - discount;
  final tax = taxable * kTaxRate;
  return taxable + tax;
});
