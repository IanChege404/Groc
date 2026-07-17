import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class SocialProofWidget extends StatelessWidget {
  final int reviewCount;
  final double rating;
  final int recentPurchases;
  final bool showPurchaseCount;

  const SocialProofWidget({
    super.key,
    required this.reviewCount,
    required this.rating,
    this.recentPurchases = 0,
    this.showPurchaseCount = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RatingBadge(rating: rating),
          const SizedBox(width: 12),
          _ReviewCount(count: reviewCount),
          if (showPurchaseCount && recentPurchases > 0) ...[
            const SizedBox(width: 12),
            _PurchaseCount(count: recentPurchases),
          ],
        ],
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;

  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star_rounded,
          size: 16,
          color: Colors.amber,
        ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ],
    );
  }
}

class _ReviewCount extends StatelessWidget {
  final int count;

  const _ReviewCount({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.rate_review_outlined,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ],
    );
  }
}

class _PurchaseCount extends StatelessWidget {
  final int count;

  const _PurchaseCount({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.shopping_bag_outlined,
          size: 16,
          color: Colors.green,
        ),
        const SizedBox(width: 4),
        Text(
          '$count bought',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ],
    );
  }
}

class CompactSocialProof extends StatelessWidget {
  final int reviewCount;
  final double rating;

  const CompactSocialProof({
    super.key,
    required this.reviewCount,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star_rounded,
          size: 14,
          color: Colors.amber,
        ),
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(1),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(width: 6),
        Text(
          '($reviewCount)',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
