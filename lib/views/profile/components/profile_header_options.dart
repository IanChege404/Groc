import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import 'profile_squre_tile.dart';
import 'package:go_router/go_router.dart';

class ProfileHeaderOptions extends StatelessWidget {
  const ProfileHeaderOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDefaults.padding),
      padding: const EdgeInsets.all(AppDefaults.padding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppDefaults.borderRadius,
        boxShadow: AppDefaults.boxShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ProfileSqureTile(
            label: 'All Order',
            icon: AppIcons.truckIcon,
            onTap: () {
              context.push('/myOrder');
            },
          ),
          ProfileSqureTile(
            label: 'Voucher',
            icon: AppIcons.voucher,
            onTap: () {
              context.push('/coupon');
            },
          ),
          ProfileSqureTile(
            label: 'Address',
            icon: AppIcons.homeProfile,
            onTap: () {
              context.push('/deliveryAddress');
            },
          ),
        ],
      ),
    );
  }
}
