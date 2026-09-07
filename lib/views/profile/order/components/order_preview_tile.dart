import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/order_status_utils.dart';

class OrderPreviewTile extends StatelessWidget {
  const OrderPreviewTile({
    super.key,
    required this.orderID,
    required this.date,
    required this.status,
    required this.onTap,
  });

  final String orderID;
  final String date;
  final String status;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final normalizedStatus = _normalizedStatus();
    final sliderValue = _orderSliderValue();
    final statusColor = _orderColor();
    final statusLabel = _statusLabel(l10n);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDefaults.padding,
        vertical: AppDefaults.padding / 2,
      ),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppDefaults.borderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppDefaults.borderRadius,
          child: Container(
            padding: const EdgeInsets.all(AppDefaults.padding),
            decoration: BoxDecoration(borderRadius: AppDefaults.borderRadius),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(l10n.orderIdLabel),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        orderID,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(date),
                  ],
                ),
                const SizedBox(height: 8),
                Semantics(
                  label: '${l10n.statusLabel}: $statusLabel',
                  child: Row(
                    children: [
                      Text(l10n.statusLabel),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: sliderValue / 3,
                            minHeight: 6,
                            backgroundColor:
                                AppColors.placeholder.withValues(alpha: 0.2),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(statusColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStep(
                      context,
                      label: l10n.orderStatusPending,
                      isActive: normalizedStatus == 'pending',
                      color: statusColor,
                    ),
                    _buildStep(
                      context,
                      label: l10n.orderStatusProcessing,
                      isActive: normalizedStatus == 'processing',
                      color: statusColor,
                    ),
                    _buildStep(
                      context,
                      label: l10n.orderStatusShipped,
                      isActive: normalizedStatus == 'shipped',
                      color: statusColor,
                    ),
                    _buildStep(
                      context,
                      label: normalizedStatus == 'cancelled'
                          ? l10n.orderStatusCancelled
                          : normalizedStatus == 'delivery'
                              ? l10n.orderStatusDelivery
                              : l10n.orderStatusCompleted,
                      isActive: normalizedStatus == 'delivery' ||
                          normalizedStatus == 'completed' ||
                          normalizedStatus == 'cancelled',
                      color: statusColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(
    BuildContext context, {
    required String label,
    required bool isActive,
    required Color color,
  }) {
    return Opacity(
      opacity: isActive ? 1 : 0.4,
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isActive ? color : null,
              fontWeight: isActive ? FontWeight.bold : null,
            ),
      ),
    );
  }

  String _normalizedStatus() => OrderStatusHelper.normalizeStatus(status);

  double _orderSliderValue() => OrderStatusHelper.progressValue(status);

  Color _orderColor() => OrderStatusHelper.colorFromStatus(status);

  String _statusLabel(AppLocalizations l10n) =>
      OrderStatusHelper.labelFromStatus(status, l10n);
}
