import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/components/app_back_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/models/order_model.dart';
import '../../../core/providers/order_provider.dart';
import 'components/return_initiation_dialog.dart';

class OrderDetailsPage extends ConsumerWidget {
  const OrderDetailsPage({super.key, required this.orderId});

  final String orderId;

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFF4044AA);
      case 'processing':
        return const Color(0xFF41A954);
      case 'shipped':
        return const Color(0xFFE19603);
      case 'delivery':
      case 'completed':
        return const Color(0xFF41AA55);
      case 'cancelled':
        return const Color(0xFFFF1F1F);
      default:
        return AppColors.primary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'processing':
        return Icons.autorenew;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivery':
        return Icons.directions_bike;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _statusLabel(AppLocalizations l10n, String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return l10n.orderStatusPending;
      case 'processing':
        return l10n.orderStatusProcessing;
      case 'shipped':
        return l10n.orderStatusShipped;
      case 'delivery':
        return l10n.orderStatusDelivery;
      case 'completed':
        return l10n.orderStatusCompleted;
      case 'cancelled':
        return l10n.orderStatusCancelled;
      default:
        return status;
    }
  }

  Widget _buildItemTile(
    BuildContext context,
    OrderItemModel item,
    String orderId,
    String orderStatus,
  ) {
    final lineTotal = item.quantity * item.priceAtTimeOfOrder;
    final isOrderCompleted = orderStatus.toLowerCase() == 'completed';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Qty: ${item.quantity}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                'KES ${lineTotal.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          if (isOrderCompleted) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => _showReturnDialog(context, item, orderId),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text('Request Return'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showReturnDialog(
    BuildContext context,
    OrderItemModel item,
    String orderId,
  ) {
    showDialog(
      context: context,
      builder: (context) => ReturnInitiationDialog(
        item: item,
        orderId: orderId,
        itemPrice: item.priceAtTimeOfOrder,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final orderState = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      backgroundColor: AppColors.cardColor,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(l10n.orderDetails),
      ),
      body: orderState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('${l10n.somethingWentWrong}: $error')),
        data: (order) {
          if (order == null) {
            return Center(child: Text(l10n.noResults));
          }

          final statusColor = _statusColor(order.status);
          final statusIcon = _statusIcon(order.status);
          final statusLabel = _statusLabel(l10n, order.status);

          return SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(AppDefaults.margin),
              padding: const EdgeInsets.all(AppDefaults.padding),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: AppDefaults.borderRadius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.orderIdLabel} #${order.id}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat.yMMMd().add_Hm().format(order.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        '${l10n.statusLabel}: ',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Semantics(
                        label: '${l10n.statusLabel}: $statusLabel',
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 16, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                statusLabel,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDefaults.padding),
                  Text(
                    l10n.productDetails,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...order.items.map((item) => _buildItemTile(context, item, order.id, order.status)),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Text(
                        l10n.totalAmount,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        'KES ${order.totalAmount.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        l10n.paidFrom,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        order.paymentMethod.toUpperCase(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
