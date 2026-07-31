import 'dart:async';
import '../domain/review.dart';
import 'reviews_repository.dart';

class MockReviewsRepository implements ReviewsRepository {
  final _controller = StreamController<Map<String, List<Review>>>.broadcast();

  final Map<String, List<Review>> _reviews = {
    'p9': [
      Review(
        id: 'r1',
        productId: 'p9',
        userName: 'سارة خالد',
        rating: 5,
        comment: 'جودة الجلد ممتازة والتصميم أنيق جداً، أنصح بها بشدة.',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Review(
        id: 'r2',
        productId: 'p9',
        userName: 'أحمد عبدالله',
        rating: 4,
        comment: 'حقيبة عملية ومساحتها جيدة، فقط السعر مرتفع قليلاً.',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ],
    'p2': [
      Review(
        id: 'r3',
        productId: 'p2',
        userName: 'خالد العتيبي',
        rating: 5,
        comment: 'عزل الضوضاء رائع وجودة الصوت ممتازة.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ],
  };

  void _emit(String productId) {
    _controller.add({productId: List.unmodifiable(_reviews[productId] ?? const [])});
  }

  @override
  Stream<List<Review>> watchReviews(String productId) async* {
    yield _reviews[productId] ?? const [];
    yield* _controller.stream
        .where((m) => m.containsKey(productId))
        .map((m) => m[productId]!);
  }

  @override
  Future<void> addReview({
    required String productId,
    required String userName,
    required int rating,
    required String comment,
  }) async {
    final review = Review(
      id: 'r-${DateTime.now().millisecondsSinceEpoch}',
      productId: productId,
      userName: userName,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );
    _reviews.putIfAbsent(productId, () => []).insert(0, review);
    _emit(productId);
  }
}
