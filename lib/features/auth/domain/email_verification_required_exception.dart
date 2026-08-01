/// يُطلَق عند الحاجة لتأكيد البريد الإلكتروني قبل إكمال تسجيل الدخول/التسجيل.
/// **ليس خطأً حقيقياً** — لهذا له نوع مستقل بدل استخدام StateError عام، كي
/// تستطيع الواجهة عرضه بأسلوب "معلومة" (أزرق/أخضر) بدل أسلوب "خطأ" (أحمر).
class EmailVerificationRequiredException implements Exception {
  const EmailVerificationRequiredException(this.message);
  final String message;

  @override
  String toString() => message;
}
