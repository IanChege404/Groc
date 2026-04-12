import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/components/network_image.dart';
import '../../../core/components/retryable_error_view.dart';
import '../../../core/constants/constants.dart';
import '../../../core/providers/user_provider.dart';
import 'profile_header_options.dart';

class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        /// Background
        Image.asset('assets/images/profile_page_background.png'),

        /// Content
        Column(
          children: [
            AppBar(
              title: const Text('Profile'),
              elevation: 0,
              backgroundColor: Colors.transparent,
              titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            _UserData(ref: ref),
            const ProfileHeaderOptions(),
          ],
        ),
      ],
    );
  }
}

class _UserData extends ConsumerWidget {
  final WidgetRef ref;

  const _UserData({required this.ref});

  /// Shimmer/skeleton loader for user data
  Widget _buildLoadingState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Row(
        children: [
          const SizedBox(width: AppDefaults.padding),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppDefaults.padding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 20, width: 150, color: Colors.grey[300]),
                const SizedBox(height: 8),
                Container(height: 16, width: 100, color: Colors.grey[300]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return userProfileAsync.when(
      data: (user) => Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Row(
          children: [
            const SizedBox(width: AppDefaults.padding),
            SizedBox(
              width: 100,
              height: 100,
              child: ClipOval(
                child: AspectRatio(
                  aspectRatio: 1 / 1,
                  child: user.photoUrl?.isNotEmpty ?? false
                      ? NetworkImageWithLoader(user.photoUrl!)
                      : Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey[600],
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
                  Text(
                    user.fullName.isNotEmpty ? user.fullName : 'User Profile',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ID: ${user.id}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      loading: () => _buildLoadingState(context),
      error: (error, stackTrace) => SizedBox(
        height: 180,
        child: RetryableErrorView(
          title: 'Could not load profile',
          message: 'Please check your connection and try again.',
          onRetry: () => ref.invalidate(userProfileProvider),
        ),
      ),
    );
  }
}
