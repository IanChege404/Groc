import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/providers/review_provider.dart';
import 'overall_stars.dart';
import 'stars_row.dart';

class ReviewOverview extends ConsumerWidget {
  final String productId;

  const ReviewOverview({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingAsync = ref.watch(productAverageRatingProvider(productId));
    final reviewsAsync = ref.watch(productReviewsProvider(productId));

    return ratingAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppDefaults.padding),
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Text('Error loading reviews: $error'),
      ),
      data: (rating) {
        return reviewsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppDefaults.padding),
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Padding(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: Text('Error: $error'),
          ),
          data: (reviews) {
            final ratingDistribution = _calculateRatingDistribution(reviews);
            return Padding(
              padding: const EdgeInsets.all(AppDefaults.padding),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Column(
                      children: [
                        Text(
                          rating.toStringAsFixed(1),
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text('${reviews.length} reviews',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDefaults.padding),
                  Expanded(
                    child: Column(
                      children: [
                        StarsRow(
                          label: '5 Stars',
                          maxValue: reviews.length.toString(),
                          totalPercentage:
                              ratingDistribution[5]?.toDouble() ?? 0,
                        ),
                        StarsRow(
                          label: '4 Stars',
                          maxValue: reviews.length.toString(),
                          totalPercentage:
                              ratingDistribution[4]?.toDouble() ?? 0,
                        ),
                        StarsRow(
                          label: '3 Stars',
                          maxValue: reviews.length.toString(),
                          totalPercentage:
                              ratingDistribution[3]?.toDouble() ?? 0,
                        ),
                        StarsRow(
                          label: '2 Stars',
                          maxValue: reviews.length.toString(),
                          totalPercentage:
                              ratingDistribution[2]?.toDouble() ?? 0,
                        ),
                        StarsRow(
                          label: '1 Stars',
                          maxValue: reviews.length.toString(),
                          totalPercentage:
                              ratingDistribution[1]?.toDouble() ?? 0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Map<int, int> _calculateRatingDistribution(dynamic reviews) {
    final distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var review in reviews) {
      final stars = review.rating.toInt();
      if (distribution.containsKey(stars)) {
        distribution[stars] = distribution[stars]! + 1;
      }
    }
    return distribution;
  }
}
