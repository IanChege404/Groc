import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/models/order_model.dart';
import 'order_preview_tile.dart';
import 'package:go_router/go_router.dart';

class CompletedTab extends StatelessWidget {
  const CompletedTab({super.key, required this.orders});

  final List<OrderModel> orders;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (orders.isEmpty) {
      return Center(child: Text(l10n.noCompletedOrders));
    }

    return ListView(
      padding: const EdgeInsets.only(top: 8),
      children: orders
          .map(
            (order) => OrderPreviewTile(
              orderID: order.id,
              date: _formatDate(order.createdAt),
              status: order.status,
              onTap: () =>
                  context.push('/orderDetails', extra: {'orderId': order.id}),
            ),
          )
          .toList(),
    );
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    return '$day/$month/$year';
  }
}
