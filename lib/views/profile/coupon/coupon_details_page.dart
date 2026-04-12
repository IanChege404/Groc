import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/components/app_back_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/models/coupon_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/coupon_provider.dart';
import 'components/coupon_card.dart';

class CouponDetailsPage extends ConsumerWidget {
  const CouponDetailsPage({super.key, this.coupon});

  final CouponModel? coupon;

  Future<void> _collectCoupon(
    BuildContext context,
    WidgetRef ref,
    String userId,
    CouponModel coupon,
  ) async {
    final ok = await ref
        .read(userCouponsProvider.notifier)
        .applyCoupon(userId, coupon.code);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Coupon collected' : 'Unable to collect coupon'),
      ),
    );
  }

  void _showTerms(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppDefaults.padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Terms and Conditions',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppDefaults.padding),
              const Text(
                'Use this coupon before the expiry date, only once per account, and only on eligible products or categories.',
              ),
              const SizedBox(height: AppDefaults.padding),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveCoupon = coupon;
    final uid = ref.watch(authProvider).value;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Offer Details Page'),
      ),
      body: Column(
        children: [
          const SizedBox(height: AppDefaults.padding),
          if (effectiveCoupon != null)
            CouponCard(
              title: effectiveCoupon.title,
              discounts: effectiveCoupon.discountType == 'percentage'
                  ? '${effectiveCoupon.discount.toStringAsFixed(0)}%'
                  : 'KES ${effectiveCoupon.discount.toStringAsFixed(0)}',
              expire:
                  'Exp-${DateFormat('dd/MM/yyyy').format(effectiveCoupon.expireDate)}',
              color: const Color(0xFF402FBE),
              onTap: uid == null
                  ? () {}
                  : () => _collectCoupon(context, ref, uid, effectiveCoupon),
            )
          else
            const SizedBox.shrink(),
          Padding(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: Text(
              effectiveCoupon != null
                  ? '${effectiveCoupon.discount.toStringAsFixed(0)}% off only for you. To get this discount collect and apply the voucher.'
                  : 'Collect and apply the voucher to get your discount.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const CouponBenefits(),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(AppDefaults.padding),
              child: Text(
                effectiveCoupon != null
                    ? 'Exp ${DateFormat('dd/MM/yyyy').format(effectiveCoupon.expireDate)}'
                    : 'Expiration date unavailable',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDefaults.padding,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: uid == null || effectiveCoupon == null
                    ? null
                    : () async {
                        final ok = await ref
                            .read(userCouponsProvider.notifier)
                            .useCoupon(uid, effectiveCoupon.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok
                                    ? 'Coupon redeemed'
                                    : 'Unable to redeem coupon',
                              ),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(elevation: 0),
                child: const Text('Redeem Now'),
              ),
            ),
          ),
          TextButton(
            onPressed: () => _showTerms(context),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Text(
              'Terms and Condition',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: AppDefaults.padding),
        ],
      ),
    );
  }
}

class CouponBenefits extends StatelessWidget {
  const CouponBenefits({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppDefaults.padding),
      child: Column(
        children: [
          BenefitsTile(
            details: 'Redeemable At All Sulphurfree Bura And Black Coffee',
          ),
          BenefitsTile(
            details: 'Not Valid With Any Other Discount And Promotion',
          ),
          BenefitsTile(details: 'Vaild For Sulphurfree, Coffee, And Tea Only'),
          BenefitsTile(details: 'No Cash Value'),
        ],
      ),
    );
  }
}

class BenefitsTile extends StatelessWidget {
  const BenefitsTile({super.key, required this.details, this.onTap});

  final String details;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 20,
              height: 5,
              margin: const EdgeInsets.only(right: AppDefaults.padding),
              decoration: const BoxDecoration(color: AppColors.primary),
            ),
            Expanded(child: Text(details)),
          ],
        ),
      ),
    );
  }
}
