import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/review_provider.dart';
import 'review_tile.dart';

class ReviewLists extends ConsumerWidget {
  final String productId;

  const ReviewLists({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(productReviewsProvider(productId));

    return Expanded(
      child: reviewsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (reviews) {
          if (reviews.isEmpty) {
            return const Center(child: Text('No reviews yet'));
          }
          return ListView.separated(
            itemBuilder: (context, index) {
              final review = reviews[index];
              return ReviewTile(review: review);
            },
            itemCount: reviews.length,
            separatorBuilder: (context, index) => const Divider(
              thickness: 0.1,
              height: 0,
            ),
          );
        },
      ),
    );
  }
}
