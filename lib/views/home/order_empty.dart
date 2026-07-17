import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/components/network_image.dart';
import '../../core/constants/constants.dart';
import '../../core/l10n/app_localizations.dart';

class OrderEmpty extends StatelessWidget {
  const OrderEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        const Spacer(flex: 2),
        Padding(
          padding: const EdgeInsets.all(AppDefaults.padding),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: AspectRatio(
              aspectRatio: 1 / 1,
              child: Semantics(
                label: l10n.translate('noOrdersYet'),
                child: const NetworkImageWithLoader(
                  'https://i.imgur.com/EMI82tU.png',
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
                l10n.noOrdersYet,
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
                  l10n.noOrdersYetDescription,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(AppDefaults.padding),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppDefaults.padding),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/entry_point'),
                    child: Text(l10n.continueShopping),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDefaults.padding,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => context.go('/myOrder'),
                    child: Text(l10n.trackMyOrder),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
