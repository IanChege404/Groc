import 'package:flutter/material.dart';

import '../../../../core/models/order_model.dart';

class OrderDetailsProductTile extends StatelessWidget {
  const OrderDetailsProductTile({super.key, required this.data});

  final OrderItemModel data;

  @override
  Widget build(BuildContext context) {
    final total = data.quantity * data.priceAtTimeOfOrder;

    return Row(
      children: [
        const Icon(Icons.shopping_bag_outlined),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.productName,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.black),
              ),
              const SizedBox(height: 8),
              Text('Qty: ${data.quantity}'),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\$${total.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ],
    );
  }
}
