import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/constants.dart';

class PriceAndQuantityRow extends StatefulWidget {
  const PriceAndQuantityRow({
    super.key,
    required this.currentPrice,
    required this.orginalPrice,
    required this.quantity,
    this.maxQuantity,
  });

  final double currentPrice;
  final double orginalPrice;
  final int quantity;

  /// Caps quantity selection (e.g. available stock). Null means unlimited.
  final int? maxQuantity;

  @override
  State<PriceAndQuantityRow> createState() => PriceAndQuantityRowState();
}

class PriceAndQuantityRowState extends State<PriceAndQuantityRow> {
  int quantity = 1;

  onQuantityIncrease() {
    final max = widget.maxQuantity;
    if (max != null && quantity >= max) {
      return;
    }
    quantity++;
    setState(() {});
  }

  onQuantityDecrease() {
    if (quantity > 1) {
      quantity--;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    quantity = widget.quantity;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final max = widget.maxQuantity;
    final canIncrease = max == null || quantity < max;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        /* <---- Price -----> */
        if (widget.orginalPrice > widget.currentPrice)
          Text(
            '\$${widget.orginalPrice.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  fontWeight: FontWeight.bold,
                ),
          ),
        const SizedBox(width: AppDefaults.padding),
        Text(
          '\$${widget.currentPrice.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const Spacer(),

        /* <---- Quantity -----> */
        Row(
          children: [
            IconButton(
              onPressed: canIncrease ? onQuantityIncrease : null,
              icon: Opacity(
                opacity: canIncrease ? 1 : 0.4,
                child: SvgPicture.asset(AppIcons.addQuantity),
              ),
              constraints: const BoxConstraints(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '$quantity',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              onPressed: onQuantityDecrease,
              icon: SvgPicture.asset(AppIcons.removeQuantity),
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ],
    );
  }
}
