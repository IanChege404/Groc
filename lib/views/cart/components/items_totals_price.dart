import 'package:flutter/material.dart';

import '../../../core/components/dotted_divider.dart';
import '../../../core/constants/constants.dart';
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
    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Column(
        children: [
          ItemRow(title: 'Total Item', value: '$totalItems'),
          ItemRow(
            title: 'Subtotal',
            value: '\$ ${subtotal.toStringAsFixed(2)}',
          ),
          ItemRow(
            title: 'Shipping',
            value: '\$ ${shipping.toStringAsFixed(2)}',
          ),
          const DottedDivider(),
          ItemRow(
            title: 'Total Price',
            value: '\$ ${totalPrice.toStringAsFixed(2)}',
          ),
        ],
      ),
    );
  }
}
