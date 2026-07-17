import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/constants.dart';
import '../../../core/services/firestore_auth_service.dart';

class SocialLogins extends ConsumerWidget {
  const SocialLogins({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _handleGoogleSignIn(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDefaults.padding * 2,
                  vertical: AppDefaults.padding,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(AppIcons.googleIconRounded, width: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Google',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppDefaults.margin),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showComingSoon(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).dividerColor),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDefaults.padding * 2,
                  vertical: AppDefaults.padding,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(AppIcons.appleIconRounded, width: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Apple',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      final authService = FirestoreAuthService();
      await authService.signInWithGoogle();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed in with Google')),
        );
        context.go('/entry_point');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign in failed: $e')),
        );
      }
    }
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Apple Sign-In coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
