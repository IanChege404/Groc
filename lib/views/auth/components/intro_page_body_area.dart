import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class IntroPageBodyArea extends StatelessWidget {
  const IntroPageBodyArea({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Column(
        children: [
          const Spacer(flex: 1),
          Padding(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.welcomeToOur,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                    ),
                  ),
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.eGrocery,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(flex: 5),
          Padding(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => context.push('/loginOrSignup'),
                    child: Text(l10n.continueWithEmailOrPhone),
                  ),
                ),
                const SizedBox(height: AppDefaults.padding),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => context.push('/signup'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                    ),
                    child: Text(l10n.createAccount),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
