import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../../core/l10n/app_localizations.dart';
import 'checkout_payment_card_tile.dart';

class PaymentSystem extends StatefulWidget {
  const PaymentSystem({super.key});

  @override
  State<PaymentSystem> createState() => _PaymentSystemState();
}

class _PaymentSystemState extends State<PaymentSystem> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final options = [
      (label: l10n.mPesa, icon: AppIcons.masterCard),
      (label: l10n.debitCard, icon: AppIcons.paypal),
      (label: l10n.cashOnDelivery, icon: AppIcons.cashOnDelivery),
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
              for (var i = 0; i < options.length; i++)
                PaymentCardTile(
                  label: options[i].label,
                  icon: options[i].icon,
                  onTap: () => setState(() => _selectedIndex = i),
                  isActive: _selectedIndex == i,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
