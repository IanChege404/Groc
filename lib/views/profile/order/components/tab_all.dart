import 'package:flutter/material.dart';

import '../../../../core/models/order_model.dart';
import '../../../../core/routes/app_routes.dart';
import 'order_preview_tile.dart';

class AllTab extends StatelessWidget {
  const AllTab({super.key, required this.orders});

  final List<OrderModel> orders;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(child: Text('No orders yet'));
    }

    return ListView(
      padding: const EdgeInsets.only(top: 8),
      children: orders
          .map(
            (order) => OrderPreviewTile(
              orderID: order.id,
              date: _formatDate(order.createdAt),
              status: order.status,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.orderDetails,
                arguments: {'orderId': order.id},
              ),
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
