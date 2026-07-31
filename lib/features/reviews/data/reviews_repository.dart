import '../domain/review.dart';

abstract class ReviewsRepository {
  Stream<List<Review>> watchReviews(String productId);

  /// إضافة تقييم — يجب أن يمر عبر تحقق من تسجيل الدخول (والخادم يتحقق من
  /// عدم تكرار تقييم المستخدم نفسه لنفس المنتج أكثر من مرة، ومن أنه اشترى
  /// المنتج فعلاً إن أردت فرض "تقييم موثّق" لاحقاً).
  Future<void> addReview({
    required String productId,
    required String userName,
    required int rating,
    required String comment,
  });
}
