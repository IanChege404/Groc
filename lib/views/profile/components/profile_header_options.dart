import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../../core/l10n/app_localizations.dart';
import 'profile_squre_tile.dart';
import 'package:go_router/go_router.dart';

class ProfileHeaderOptions extends StatelessWidget {
  const ProfileHeaderOptions({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          Expanded(
            child: ProfileSqureTile(
              label: l10n.allOrders,
              icon: AppIcons.truckIcon,
              onTap: () {
                context.push('/myOrder');
              },
            ),
          ),
          Expanded(
            child: ProfileSqureTile(
              label: l10n.vouchers,
              icon: AppIcons.voucher,
              onTap: () {
                context.push('/coupon');
              },
            ),
          ),
          Expanded(
            child: ProfileSqureTile(
              label: l10n.address,
              icon: AppIcons.homeProfile,
              onTap: () {
                context.push('/deliveryAddress');
              },
            ),
          ),
        ],
      ),
    );
  }
}
