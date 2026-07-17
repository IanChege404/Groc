import 'package:flutter/material.dart';

import '../../../core/components/dotted_divider.dart';
import '../../../core/constants/constants.dart';
import '../../../core/l10n/app_localizations.dart';
import 'item_row.dart';

class ItemTotalsAndPrice extends StatelessWidget {
  const ItemTotalsAndPrice({
    super.key,
    required this.totalItems,
    required this.subtotal,
    this.shipping = 0,
  });

  final int totalItems;
  final double subtotal;
  final double shipping;

  double get totalPrice => subtotal + shipping;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Column(
        children: [
          ItemRow(title: l10n.totalItems, value: '$totalItems'),
          ItemRow(
            title: l10n.subtotal,
            value: 'KES ${subtotal.toStringAsFixed(2)}',
          ),
          ItemRow(
            title: l10n.shipping,
            value: 'KES ${shipping.toStringAsFixed(2)}',
          ),
          const DottedDivider(),
          ItemRow(
            title: l10n.totalPrice,
            value: 'KES ${totalPrice.toStringAsFixed(2)}',
          ),
        ],
      ),
    );
  }
}
