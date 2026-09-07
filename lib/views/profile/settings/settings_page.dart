import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/components/app_back_button.dart';
import '../../../core/constants/constants.dart';
import '../../../core/components/app_settings_tile.dart';
import '../../../core/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(l10n.settings),
      ),
      backgroundColor: AppColors.cardColor,
      body: Container(
        margin: const EdgeInsets.all(AppDefaults.padding),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDefaults.padding,
          vertical: AppDefaults.padding * 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.scaffoldBackground,
          borderRadius: AppDefaults.borderRadius,
        ),
        child: Column(
          children: [
            AppSettingsListTile(
                label: l10n.language,
                trailing: SvgPicture.asset(AppIcons.right),
                onTap: () => context.push('/settingsLanguage')),
            AppSettingsListTile(
                label: l10n.notificationSettings,
                trailing: SvgPicture.asset(AppIcons.right),
                onTap: () => context.push('/settingsNotifications')),
            AppSettingsListTile(
                label: l10n.changePassword,
                trailing: SvgPicture.asset(AppIcons.right),
                onTap: () => context.push('/changePassword')),
            AppSettingsListTile(
                label: l10n.changePhoneNumber,
                trailing: SvgPicture.asset(AppIcons.right),
                onTap: () => context.push('/changePhoneNumber')),
            AppSettingsListTile(
                label: l10n.editHomeAddress,
                trailing: SvgPicture.asset(AppIcons.right),
                onTap: () => context.push('/deliveryAddress')),
            AppSettingsListTile(
                label: l10n.location,
                trailing: SvgPicture.asset(AppIcons.right),
                onTap: () => context.push('/settingsLocation')),
            AppSettingsListTile(
                label: l10n.profileSetting,
                trailing: SvgPicture.asset(AppIcons.right),
                onTap: () => context.push('/profileEdit')),
            AppSettingsListTile(
                label: l10n.deactivateAccount,
                trailing: SvgPicture.asset(AppIcons.right),
                onTap: () => context.push('/intro_login')),
          ],
        ),
      ),
    );
  }
}
