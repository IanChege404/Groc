import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as p;

import '../../../core/components/app_back_button.dart';
import '../../../core/components/app_settings_tile.dart';
import '../../../core/constants/constants.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/settings_provider.dart';

class LanguageSettingsPage extends ConsumerWidget {
  const LanguageSettingsPage({super.key});

  Future<void> _setLanguage(
    BuildContext context,
    WidgetRef ref,
    String code,
  ) async {
    final localeProvider = p.Provider.of<LocaleProvider>(
      context,
      listen: false,
    );
    await localeProvider.setLocale(code);

    final userId = ref.read(authProvider).value;
    if (userId != null && userId.isNotEmpty) {
      await ref
          .read(userSettingsProvider.notifier)
          .updateLanguage(userId, code);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Language updated')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCode = p.Provider.of<LocaleProvider>(
      context,
    ).locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Language Settings'),
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
              label: 'English',
              trailing: selectedCode == 'en'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () => _setLanguage(context, ref, 'en'),
            ),
            AppSettingsListTile(
              label: 'Swahili',
              trailing: selectedCode == 'sw'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () => _setLanguage(context, ref, 'sw'),
            ),
          ],
        ),
      ),
    );
  }
}
