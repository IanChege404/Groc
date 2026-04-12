import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/providers/loyalty_provider.dart';

/// A compact badge that displays the user's available loyalty points
class LoyaltyBadge extends ConsumerWidget {
  const LoyaltyBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = ref.watch(loyaltyPointsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.secondary, size: 16),
          const SizedBox(width: 4),
          Text(
            '$points pts',
            style: const TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
