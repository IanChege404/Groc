import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/components/network_image.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/l10n/app_localizations.dart';

class OrderSuccessfullPage extends StatelessWidget {
  const OrderSuccessfullPage({super.key});

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
                  label: l10n.orderPlacedSuccess,
                  child: const NetworkImageWithLoader(
                    'https://i.imgur.com/Fj9gVGy.png',
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
                  l10n.orderPlacedSuccess,
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
                    l10n.orderPlacedSuccessDesc,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                // Order confirmation details card
                Container(
                  padding: const EdgeInsets.all(AppDefaults.padding),
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.1, color: const Color(0xFFE0E0E0)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.orderConfirmation,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${l10n.orderIdLabel}: #12345',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${l10n.totalAmount}: KES 5,420.00',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${l10n.estimatedDelivery}: 3-5 business days',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
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
      ),
    );
  }
}
