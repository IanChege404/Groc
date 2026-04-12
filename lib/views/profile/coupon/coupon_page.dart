import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/components/app_back_button.dart';
import '../../../core/constants/constants.dart';
import '../../../core/models/coupon_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/coupon_provider.dart';
import 'components/coupon_card.dart';
import 'coupon_details_page.dart';

class CouponAndOffersPage extends ConsumerStatefulWidget {
  const CouponAndOffersPage({super.key});

  @override
  ConsumerState<CouponAndOffersPage> createState() =>
      _CouponAndOffersPageState();
}

class _CouponAndOffersPageState extends ConsumerState<CouponAndOffersPage> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _redeemNow() async {
    final uid = ref.read(authProvider).value;
    if (uid == null || uid.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please sign in first')));
      return;
    }

    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter coupon code')));
      return;
    }

    final ok = await ref
        .read(userCouponsProvider.notifier)
        .applyCoupon(uid, code);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Coupon redeemed successfully'
              : 'Invalid or already-used coupon',
        ),
      ),
    );

    if (ok) {
      _codeController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final couponsAsync = ref.watch(userCouponsProvider);
    final uidAsync = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Offer And Promos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      hintText: 'Enter coupon code',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _redeemNow,
                  child: const Text('Redeem Now'),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDefaults.padding,
              ),
              child: couponsAsync.when(
                data: (coupons) => Text(
                  'You Have ${coupons.length} Coupons to use',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                loading: () => const Text('Loading coupons...'),
                error: (_, __) => const Text('Unable to load coupons'),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: uidAsync.when(
              data: (uid) {
                if (uid == null || uid.isEmpty) {
                  return const Center(
                    child: Text('Please sign in to view coupons'),
                  );
                }

                return couponsAsync.when(
                  data: (coupons) {
                    if (coupons.isEmpty) {
                      return const Center(child: Text('No coupons available'));
                    }

                    return ListView.builder(
                      itemCount: coupons.length,
                      itemBuilder: (_, index) =>
                          _CouponItem(coupon: coupons[index]),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('Error: $error')),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}

class _CouponItem extends StatelessWidget {
  const _CouponItem({required this.coupon});

  final CouponModel coupon;

  @override
  Widget build(BuildContext context) {
    final discountText = coupon.discountType == 'percentage'
        ? '${coupon.discount.toStringAsFixed(0)}%'
        : 'KES ${coupon.discount.toStringAsFixed(0)}';

    return CouponCard(
      title: coupon.title,
      discounts: discountText,
      expire: 'Exp-${DateFormat('dd/MM/yyyy').format(coupon.expireDate)}',
      color: coupon.canBeUsed ? const Color(0xFF398FE9) : Colors.grey,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CouponDetailsPage(coupon: coupon)),
        );
      },
    );
  }
}
