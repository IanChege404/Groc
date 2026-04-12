import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../constants/constants.dart';

class BuyNowRow extends StatefulWidget {
  const BuyNowRow({
    super.key,
    required this.onCartButtonTap,
    required this.onBuyButtonTap,
    this.isInCart = false,
  });

  final void Function() onCartButtonTap;
  final void Function() onBuyButtonTap;
  final bool isInCart;

  @override
  State<BuyNowRow> createState() => _BuyNowRowState();
}

class _BuyNowRowState extends State<BuyNowRow> {
  bool _isAnimating = false;

  Future<void> _onCartTap() async {
    setState(() => _isAnimating = true);
    widget.onCartButtonTap();
    await Future.delayed(const Duration(milliseconds: 170));
    if (mounted) {
      setState(() => _isAnimating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartBackground = widget.isInCart
        ? AppColors.primary.withValues(alpha: 0.14)
        : Colors.transparent;
    final cartBorderColor = widget.isInCart
        ? AppColors.primary
        : Theme.of(context).dividerColor;
    final cartIconColor = widget.isInCart
        ? AppColors.primary
        : Theme.of(context).iconTheme.color;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDefaults.padding),
      child: Row(
        children: [
          AnimatedScale(
            scale: _isAnimating ? 1.12 : 1,
            duration: const Duration(milliseconds: 170),
            curve: Curves.easeOutBack,
            child: OutlinedButton(
              onPressed: _onCartTap,
              style: OutlinedButton.styleFrom(
                backgroundColor: cartBackground,
                side: BorderSide(color: cartBorderColor),
              ),
              child: SvgPicture.asset(
                AppIcons.shoppingCart,
                colorFilter: cartIconColor != null
                    ? ColorFilter.mode(cartIconColor, BlendMode.srcIn)
                    : null,
              ),
            ),
          ),
          const SizedBox(width: AppDefaults.padding),
          Expanded(
            child: ElevatedButton(
              onPressed: widget.onBuyButtonTap,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(AppDefaults.padding * 1.2),
              ),
              child: const Text('Buy Now'),
            ),
          ),
        ],
      ),
    );
  }
}
