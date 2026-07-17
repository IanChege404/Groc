import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/components/network_image.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/l10n/app_localizations.dart';

class OrderFailedPage extends StatelessWidget {
  const OrderFailedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          const Spacer(flex: 2),
          Padding(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: AspectRatio(
                aspectRatio: 1 / 1,
                child: Semantics(
                  label: l10n.orderFailedTitle,
                  child: const NetworkImageWithLoader(
                    'https://i.imgur.com/vPVGf8C.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: Column(
              children: [
                Text(
                  l10n.orderFailedTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDefaults.padding,
                  ),
                  child: Text(
                    l10n.orderFailedDesc,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(AppDefaults.padding * 2),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/cartPage'),
                child: Text(l10n.tryAgain),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDefaults.padding * 2,
            ),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => context.go('/entry_point'),
                child: Text(l10n.goToHome),
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
