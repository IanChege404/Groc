import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDefaults.padding,
        vertical: AppDefaults.padding / 2,
      ),
      child: Material(
        color: Colors.white,
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
                    const Text('Order ID:'),
                    const SizedBox(width: 5),
                    Text(
                      orderID,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.black),
                    ),
                    const Spacer(),
                    Text(date),
                  ],
                ),
                Row(
                  children: [
                    const Text('Status'),
                    Expanded(
                      child: RangeSlider(
                        values: RangeValues(0, _orderSliderValue()),
                        max: 3,
                        divisions: 3,
                        onChanged: (v) {},
                        activeColor: _orderColor(),
                        inactiveColor: AppColors.placeholder.withValues(
                          alpha: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Opacity(
                            opacity: _normalizedStatus() == 'pending' ? 1 : 0,
                            child: Text(
                              'Pending',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: _orderColor()),
                            ),
                          ),
                          Opacity(
                            opacity: _normalizedStatus() == 'processing'
                                ? 1
                                : 0,
                            child: Text(
                              'Processing',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: _orderColor()),
                            ),
                          ),
                          Opacity(
                            opacity: _normalizedStatus() == 'shipped' ? 1 : 0,
                            child: Text(
                              'Shipped',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: _orderColor()),
                            ),
                          ),
                          Opacity(
                            opacity:
                                _normalizedStatus() == 'delivery' ||
                                    _normalizedStatus() == 'completed' ||
                                    _normalizedStatus() == 'cancelled'
                                ? 1
                                : 0,
                            child: Text(
                              _normalizedStatus() == 'cancelled'
                                  ? 'Cancelled'
                                  : _normalizedStatus() == 'delivery'
                                  ? 'Delivery'
                                  : 'Completed',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: _orderColor()),
                            ),
                          ),
                        ],
                      ),
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

  String _normalizedStatus() {
    return status.toLowerCase().trim();
  }

  double _orderSliderValue() {
    switch (_normalizedStatus()) {
      case 'pending':
        return 0;
      case 'processing':
        return 1;
      case 'shipped':
        return 2;
      case 'delivery':
      case 'completed':
        return 3;
      case 'cancelled':
        return 3;
      default:
        return 0;
    }
  }

  Color _orderColor() {
    switch (_normalizedStatus()) {
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
}
