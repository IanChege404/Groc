import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/components/network_image.dart';
import '../../../core/components/review_stars.dart';
import '../../../core/constants/constants.dart';
import '../../../core/models/review_model.dart';

class ReviewTile extends StatelessWidget {
  final ReviewModel review;

  const ReviewTile({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: ClipOval(
              child: AspectRatio(
                aspectRatio: 1 / 1,
                child: review.userImage.isNotEmpty
                    ? NetworkImageWithLoader(review.userImage)
                    : Container(
                        color: Theme.of(context).colorScheme.secondary,
                        child: Center(
                          child: Text(
                            review.userName[0].toUpperCase(),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(width: AppDefaults.padding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      review.userName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const Spacer(),
                    Text(review.formattedDate,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 4),
                ReviewStars(starsGiven: review.rating.toInt()),
                const SizedBox(height: 8),
                if (review.title.isNotEmpty)
                  Text(
                    review.title,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                const SizedBox(height: 4),
                Text(review.comment),
                const SizedBox(height: AppDefaults.padding),
                Row(
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(AppIcons.heartOutlined),
                        const SizedBox(width: AppDefaults.padding / 2),
                        Text('${review.helpfulCount} Helpful'),
                      ],
                    ),
                    const SizedBox(width: AppDefaults.padding),
                    Row(
                      children: [
                        SvgPicture.asset(AppIcons.reply),
                        const SizedBox(width: AppDefaults.padding / 2),
                        const Text('Reply'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
