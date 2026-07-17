import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/components/app_back_button.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/constants/app_icons.dart';
import '../../core/components/app_settings_tile.dart';
import '../../core/services/firestore_auth_service.dart';
import '../../core/utils/store_review_launcher.dart';
import 'package:go_router/go_router.dart';

class DrawerPage extends StatelessWidget {
  const DrawerPage({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirestoreAuthService().logout();
    if (!context.mounted) {
      return;
    }
    context.go('/intro_login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Menu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Column(
          children: [
            AppSettingsListTile(
              label: 'Invite Friend',
              trailing: SvgPicture.asset(AppIcons.right),
              onTap: () => context.push('/referral'),
            ),
            AppSettingsListTile(
                label: 'About Us',
                trailing: SvgPicture.asset(AppIcons.right),
                onTap: () => context.push('/aboutUs')),
            AppSettingsListTile(
                label: 'FAQs',
                trailing: SvgPicture.asset(AppIcons.right),
                onTap: () => context.push('/faq')),
            AppSettingsListTile(
                label: 'Terms & Conditions',
                trailing: SvgPicture.asset(AppIcons.right),
                onTap: () => context.push('/termsAndConditions')),
            AppSettingsListTile(
                label: 'Help Center',
                trailing: SvgPicture.asset(AppIcons.right),
                onTap: () => context.push('/help')),
            AppSettingsListTile(
              label: 'Rate This App',
              trailing: SvgPicture.asset(AppIcons.right),
              onTap: () => StoreReviewLauncher.openStoreListing(),
            ),
            AppSettingsListTile(
              label: 'Privacy Policy',
              trailing: SvgPicture.asset(AppIcons.right),
              onTap: () => context.push('/privacyPolicy'),
            ),
            AppSettingsListTile(
                label: 'Contact Us',
                trailing: SvgPicture.asset(AppIcons.right),
                onTap: () => context.push('/contactUs')),
            const SizedBox(height: AppDefaults.padding * 3),
            AppSettingsListTile(
              label: 'Logout',
              trailing: SvgPicture.asset(AppIcons.right),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}
