import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';

final reviewServiceProvider = Provider((ref) => ReviewService());

final productReviewsProvider = StreamProvider.family<List<ReviewModel>, String>(
  (ref, productId) {
    final reviewService = ref.watch(reviewServiceProvider);
    return reviewService.getProductReviews(productId);
  },
);

final productAverageRatingProvider =
    FutureProvider.family<double, String>((ref, productId) async {
  final reviewService = ref.watch(reviewServiceProvider);
  return reviewService.getProductAverageRating(productId);
});

final productReviewCountProvider =
    FutureProvider.family<int, String>((ref, productId) async {
  final reviewService = ref.watch(reviewServiceProvider);
  return reviewService.getProductReviewCount(productId);
});

final userReviewsProvider = StreamProvider.family<List<ReviewModel>, String>(
  (ref, userId) {
    final reviewService = ref.watch(reviewServiceProvider);
    return reviewService.getUserReviews(userId);
  },
);

final submitReviewProvider = FutureProvider.family<void, ReviewModel>(
  (ref, review) async {
    final reviewService = ref.watch(reviewServiceProvider);
    return reviewService.submitReview(review);
  },
);

/// Combined review stats for product display
final productReviewStatsProvider =
    StreamProvider.family<({double rating, int count}), String>(
  (ref, productId) async* {
    final reviewService = ref.watch(reviewServiceProvider);
    final reviews = await reviewService.getProductReviews(productId).first;

    if (reviews.isEmpty) {
      yield (rating: 0.0, count: 0);
    } else {
      double totalRating = 0;
      for (var review in reviews) {
        totalRating += review.rating;
      }
      final averageRating = totalRating / reviews.length;
      yield (rating: averageRating, count: reviews.length);
    }
  },
);
