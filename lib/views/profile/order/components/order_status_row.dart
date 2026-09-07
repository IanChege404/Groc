import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/enums/dummy_order_status.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/order_status_utils.dart';
import 'order_details_vertical_step_indicator.dart';

class OrderStatusRow extends StatelessWidget {
  const OrderStatusRow({
    super.key,
    required this.status,
    required this.date,
    required this.time,
    this.isActive = false,
    this.isStart = false,
    this.isEnd = false,
  });

  final OrderStatus status;
  final String date;
  final String time;
  final bool isStart;
  final bool isActive;
  final bool isEnd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment:
          isStart ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: isActive ? _orderColor() : Theme.of(context).dividerColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: SvgPicture.asset(_orderIcon()),
        ),
        VerticalStepIndicator(
          isStart: isStart,
          isActive: isActive,
          isEnd: isEnd,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _orderStatus(l10n),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(date, style: Theme.of(context).textTheme.bodySmall),
                  Text(time, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _orderColor() => OrderStatusHelper.colorFromEnum(status);

  String _orderStatus(AppLocalizations l10n) =>
      OrderStatusHelper.labelFromEnum(status, l10n);

  String _orderIcon() => OrderStatusHelper.iconFromEnum(status);
}
