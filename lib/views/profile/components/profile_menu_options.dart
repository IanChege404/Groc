import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/firestore_auth_service.dart';
import 'profile_list_tile.dart';
import 'package:go_router/go_router.dart';

class ProfileMenuOptions extends StatelessWidget {
  const ProfileMenuOptions({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirestoreAuthService().logout();
    if (!context.mounted) {
      return;
    }
    context.go('/loginOrSignup');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.all(AppDefaults.padding),
      padding: const EdgeInsets.all(AppDefaults.padding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: AppDefaults.boxShadow,
        borderRadius: AppDefaults.borderRadius,
      ),
      child: Column(
        children: [
          ProfileListTile(
              title: l10n.myProfile,
              icon: AppIcons.profilePerson,
              onTap: () => context.push('/profileEdit')),
          const Divider(thickness: 0.1),
          ProfileListTile(
              title: l10n.notifications,
              icon: AppIcons.profileNotification,
              onTap: () => context.push('/notifications')),
          const Divider(thickness: 0.1),
          ProfileListTile(
              title: l10n.settings,
              icon: AppIcons.profileSetting,
              onTap: () => context.push('/settings')),
          const Divider(thickness: 0.1),
          ProfileListTile(
              title: l10n.paymentMethods,
              icon: AppIcons.profilePayment,
              onTap: () => context.push('/paymentMethod')),
          const Divider(thickness: 0.1),
          ProfileListTile(
            title: l10n.logout,
            icon: AppIcons.profileLogout,
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
