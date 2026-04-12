import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/models/coupon_model.dart';

/// A compact chip that displays a coupon/discount code with copy-to-clipboard
class CouponChip extends StatelessWidget {
  final CouponModel coupon;
  final VoidCallback? onApply;

  const CouponChip({super.key, required this.coupon, this.onApply});

  @override
  Widget build(BuildContext context) {
    final expired = coupon.isExpired;
    final color = expired ? Colors.grey : AppColors.primary;

    return GestureDetector(
      onTap: expired ? null : onApply,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: expired ? Colors.grey.shade300 : color,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_offer_rounded,
              size: 14,
              color: expired ? Colors.grey : color,
            ),
            const SizedBox(width: 6),
            Text(
              coupon.code,
              style: TextStyle(
                color: expired ? Colors.grey : color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 1.0,
              ),
            ),
            if (!expired) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${coupon.discount.toStringAsFixed(0)}'
                  '${coupon.discountType == 'percentage' ? '%' : ' KES'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            if (expired)
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Text(
                  'Expired',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
