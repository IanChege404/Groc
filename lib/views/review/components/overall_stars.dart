import 'package:flutter/material.dart';

import '../../../core/components/review_stars.dart';
import '../../../core/constants/constants.dart';

class OverallStars extends StatelessWidget {
  const OverallStars({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppDefaults.padding),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            '4.5',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '320 Reviews',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const ReviewStars(starsGiven: 4),
      ],
    );
  }
}
