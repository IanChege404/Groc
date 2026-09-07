import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/components/network_image.dart';
import '../../core/constants/constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/services/firestore_auth_service.dart';

class LoginOrSignUpPage extends StatelessWidget {
  const LoginOrSignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          Spacer(flex: 2),
          _AppLogoAndHeadline(),
          Spacer(),
          _Footer(),
          Spacer(),
        ],
      ),
    );
  }
}

class _Footer extends StatefulWidget {
  const _Footer();

  @override
  State<_Footer> createState() => _FooterState();
}

class _FooterState extends State<_Footer> {
  bool _isGoogleLoading = false;

  Future<void> _handleGoogleSignIn() async {
    if (_isGoogleLoading) return;
    setState(() => _isGoogleLoading = true);

    try {
      final authService = FirestoreAuthService();
      final result = await authService.signInWithGoogle();
      if (!mounted) return;

      if (result.success) {
        context.go('/entry_point');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.message ??
                  AppLocalizations.of(context)!.googleSignInFailed,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.googleSignInFailed)),
      );
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: Semantics(
              button: true,
              label: l10n.loginWithEmail,
              child: ElevatedButton(
                onPressed: () => context.push('/login'),
                child: Text(l10n.loginWithEmail),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDefaults.margin),
        Text(
          l10n.orContinueWith,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppDefaults.margin),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              button: true,
              label: 'Google',
              child: IconButton(
                onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                icon: _isGoogleLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : SvgPicture.asset(AppIcons.googleIcon),
                iconSize: 48,
              ),
            ),
            Semantics(
              button: true,
              label: 'Apple',
              child: IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.appleSignInComingSoon)),
                  );
                },
                icon: SvgPicture.asset(AppIcons.appleIcon),
                iconSize: 48,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AppLogoAndHeadline extends StatelessWidget {
  const _AppLogoAndHeadline();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: AspectRatio(
            aspectRatio: 1 / 1,
            child: Semantics(
              image: true,
              label: '${l10n.appName} logo',
              child: const NetworkImageWithLoader(AppImages.roundedLogo),
            ),
          ),
        ),
        Text(
          l10n.welcomeToOur,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          l10n.eGrocery,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        )
      ],
    );
  }
}
