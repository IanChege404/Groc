import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/components/app_back_button.dart';
import '../../../core/components/app_settings_tile.dart';
import '../../../core/constants/constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/settings_provider.dart';

class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authProvider).value;
    final settings = ref.watch(userSettingsProvider).value;

    final notificationsEnabled = settings?.notificationsEnabled ?? true;
    final pushEnabled = settings?.pushNotificationsEnabled ?? true;
    final emailEnabled = settings?.emailNotificationsEnabled ?? false;

    Future<void> save({bool? notifications, bool? push, bool? email}) async {
      if (userId == null || userId.isEmpty) return;
      await ref
          .read(userSettingsProvider.notifier)
          .updateNotificationSettings(
            userId,
            notificationsEnabled: notifications,
            pushNotificationsEnabled: push,
            emailNotificationsEnabled: email,
          );
    }

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Change Notification Settings'),
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
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
              const SizedBox(height: AppDefaults.padding),
              AppSettingsListTile(
                label: 'App Notification',
                trailing: Transform.scale(
                  scale: 0.7,
                  child: CupertinoSwitch(
                    value: notificationsEnabled,
                    onChanged: (value) => save(notifications: value),
                  ),
                ),
              ),
              AppSettingsListTile(
                label: 'Phone Number Notification',
                trailing: Transform.scale(
                  scale: 0.7,
                  child: CupertinoSwitch(
                    value: pushEnabled,
                    onChanged: (value) => save(push: value),
                  ),
                ),
              ),
              AppSettingsListTile(
                label: 'Offer Notification',
                trailing: Transform.scale(
                  scale: 0.7,
                  child: CupertinoSwitch(
                    value: emailEnabled,
                    onChanged: (value) => save(email: value),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
