class Coupon {
  const Coupon({required this.code, required this.discountPercent});
  final String code;
  final double discountPercent; // 0-100
}

/// تحقق وهمي من الكوبونات — يُستبدل لاحقاً بمستند `coupons/{code}` في
/// Firestore يتحقق من صلاحيته وتاريخ انتهائه على الخادم (لا يُثق بأي خصم
/// يحسبه العميل وحده في الإنتاج؛ الخادم يعيد حساب الإجمالي دوماً عند إنشاء
/// الطلب الفعلي عبر Cloud Function).
class CouponValidator {
  static const Map<String, double> _mockCoupons = {
    'SAVE10': 10,
    'SAVE20': 20,
    'WELCOME15': 15,
  };

  static Coupon? validate(String code) {
    final normalized = code.trim().toUpperCase();
    final percent = _mockCoupons[normalized];
    if (percent == null) return null;
    return Coupon(code: normalized, discountPercent: percent);
  }
}
