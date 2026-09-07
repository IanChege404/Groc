import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../../core/l10n/app_localizations.dart';
import 'checkout_payment_card_tile.dart';

enum PaymentMethodType { mpesa, card, cod, stripe, paypal }

class PaymentSystem extends StatelessWidget {
  const PaymentSystem({
    super.key,
    required this.selectedMethod,
    required this.onMethodChanged,
  });

  final PaymentMethodType selectedMethod;
  final ValueChanged<PaymentMethodType> onMethodChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final options = [
      (
        type: PaymentMethodType.mpesa,
        label: l10n.mPesa,
        icon: AppIcons.cashOnDelivery
      ),
      (
        type: PaymentMethodType.card,
        label: l10n.debitCard,
        icon: AppIcons.masterCard
      ),
      (
        type: PaymentMethodType.stripe,
        label: l10n.stripePayment,
        icon: AppIcons.masterCard
      ),
      (
        type: PaymentMethodType.paypal,
        label: l10n.paypalPayment,
        icon: AppIcons.paypal
      ),
      (
        type: PaymentMethodType.cod,
        label: l10n.cashOnDelivery,
        icon: AppIcons.paypal
      ),
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDefaults.padding,
            vertical: AppDefaults.padding / 2,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.selectPaymentSystem,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final option in options)
                PaymentCardTile(
                  label: option.label,
                  icon: option.icon,
                  onTap: () => onMethodChanged(option.type),
                  isActive: selectedMethod == option.type,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
