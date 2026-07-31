import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_reviews_repository.dart';
import '../data/reviews_repository.dart';
import '../domain/review.dart';

final reviewsRepositoryProvider = Provider<ReviewsRepository>((ref) => MockReviewsRepository());

final productReviewsProvider = StreamProvider.family<List<Review>, String>((ref, productId) {
  return ref.watch(reviewsRepositoryProvider).watchReviews(productId);
});

final productAverageRatingProvider = Provider.family<double, String>((ref, productId) {
  final reviewsAsync = ref.watch(productReviewsProvider(productId));
  final reviews = reviewsAsync.valueOrNull ?? const [];
  if (reviews.isEmpty) return 0;
  return reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
});
