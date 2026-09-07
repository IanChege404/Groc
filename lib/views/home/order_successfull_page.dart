import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/components/network_image.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/l10n/app_localizations.dart';

class OrderSuccessfullPage extends StatelessWidget {
  const OrderSuccessfullPage({
    super.key,
    this.orderId,
    this.totalAmount,
    this.estimatedDelivery,
  });

  final String? orderId;
  final String? totalAmount;
  final String? estimatedDelivery;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final extra = GoRouterState.of(context).extra;
    Map<String, dynamic>? extras;
    if (extra is Map<String, dynamic>) {
      extras = extra;
    }

    final displayOrderId =
        orderId ?? extras?['orderId'] as String? ?? '#------';
    final displayAmount =
        totalAmount ?? extras?['totalAmount'] as String? ?? 'KES 0.00';
    final displayDelivery = estimatedDelivery ?? '3-5 business days';

    return Scaffold(
      body: SafeArea(
        child: Column(
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
                  Container(
                    padding: const EdgeInsets.all(AppDefaults.padding),
                    decoration: BoxDecoration(
                      border: Border.all(
                          width: 0.1, color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.orderConfirmation,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${l10n.orderIdLabel}: $displayOrderId',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${l10n.totalAmount}: $displayAmount',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${l10n.estimatedDelivery}: $displayDelivery',
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
      ),
    );
  }
}
