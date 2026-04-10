import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/routes/app_routes.dart';

/// Language Selection Screen
///
/// Allows user to choose between English and Swahili at onboarding
/// or from settings. Selection is persisted via LocaleProvider.
class LanguageSelectScreen extends StatefulWidget {
  const LanguageSelectScreen({super.key});

  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen> {
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    _selectedLanguage = localeProvider.locale.languageCode;
  }

  Future<void> _continuePressed() async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    await localeProvider.setLocale(_selectedLanguage);

    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDefaults.spacingLg,
            vertical: AppDefaults.spacingLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Afri-Commerce Logo (small)
              Padding(
                padding: const EdgeInsets.only(bottom: AppDefaults.spacingXl),
                child: Text(
                  'Afri-Commerce',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),

              // Headline: Choose Your Language
              Padding(
                padding: const EdgeInsets.only(bottom: AppDefaults.spacingSm),
                child: Text(
                  _selectedLanguage == 'en'
                      ? 'Choose Your Language'
                      : 'Chagua Lugha Yako',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),

              // Language List
              Expanded(
                child: ListView(
                  children: [
                    _buildLanguageOption(
                      context,
                      flag: '🇬🇧',
                      language: 'English',
                      nativeName: 'English',
                      languageCode: 'en',
                    ),
                    const SizedBox(height: AppDefaults.spacingMd),
                    _buildLanguageOption(
                      context,
                      flag: '🇹🇿',
                      language: 'Swahili',
                      nativeName: 'Kiswahili',
                      languageCode: 'sw',
                    ),
                  ],
                ),
              ),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _continuePressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppDefaults.borderRadius,
                    ),
                  ),
                  child: Text(
                    _selectedLanguage == 'en' ? 'Continue' : 'Endelea',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String flag,
    required String language,
    required String nativeName,
    required String languageCode,
  }) {
    final isSelected = _selectedLanguage == languageCode;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = languageCode;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariantLight)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDefaults.spacingMd,
          vertical: AppDefaults.spacingMd,
        ),
        child: Row(
          children: [
            // Flag
            Text(flag, style: const TextStyle(fontSize: 48)),
            const SizedBox(width: AppDefaults.spacingMd),

            // Language names
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(language, style: Theme.of(context).textTheme.bodyLarge),
                  Text(
                    nativeName,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            // Radio selector
            // ignore: deprecated_member_use
            Radio<String>(
              value: languageCode,
              groupValue: _selectedLanguage, // ignore: deprecated_member_use
              onChanged: (value) { // ignore: deprecated_member_use
                if (value != null) {
                  setState(() {
                    _selectedLanguage = value;
                  });
                }
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
