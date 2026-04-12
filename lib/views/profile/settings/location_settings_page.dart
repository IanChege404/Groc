import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/components/app_back_button.dart';
import '../../../core/components/retryable_error_view.dart';
import '../../../core/constants/constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/settings_provider.dart';

class LocationSettingsPage extends ConsumerStatefulWidget {
  const LocationSettingsPage({super.key});

  @override
  ConsumerState<LocationSettingsPage> createState() =>
      _LocationSettingsPageState();
}

class _LocationSettingsPageState extends ConsumerState<LocationSettingsPage> {
  static const _options = <String>['Current Location', 'Home', 'Work'];

  Future<void> _refresh(String userId) async {
    ref.invalidate(userSettingsProvider);
    await ref.refresh(userSettingsProvider.notifier).refresh(userId);
  }

  Future<void> _selectLocation(String userId, String value) async {
    await ref
        .read(userSettingsProvider.notifier)
        .updateLocationPreference(userId, value);
    ref.invalidate(userSettingsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final userIdAsync = ref.watch(authProvider);
    final settingsAsync = ref.watch(userSettingsProvider);

    return Scaffold(
      backgroundColor: AppColors.cardColor,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Location Settings'),
      ),
      body: userIdAsync.when(
        data: (userId) {
          if (userId == null || userId.isEmpty) {
            return RetryableErrorView(
              title: 'Sign in required',
              message: 'Please sign in again to manage your location settings.',
              onRetry: () => ref.invalidate(authProvider),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _refresh(userId),
            child: settingsAsync.when(
              data: (settings) {
                final selected = settings?.locationPreference ?? _options.first;
                return ListView(
                  padding: const EdgeInsets.all(AppDefaults.padding),
                  children: [
                    Text(
                      'Choose the default location used for deliveries and recommendations.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppDefaults.padding),
                    ..._options.map(
                      (option) => Card(
                        child: RadioListTile<String>(
                          value: option,
                          groupValue: selected,
                          title: Text(option),
                          subtitle: Text(
                            option == 'Current Location'
                                ? 'Uses your live location preference'
                                : 'Stored under users/$userId/settings',
                          ),
                          onChanged: (value) {
                            if (value != null) {
                              _selectLocation(userId, value);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => RetryableErrorView(
                title: 'Unable to load location settings',
                message:
                    'Check your connection and try again. ${error.toString()}',
                onRetry: () => _refresh(userId),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => RetryableErrorView(
          title: 'Unable to resolve your account',
          message: error.toString(),
          onRetry: () => ref.invalidate(authProvider),
        ),
      ),
    );
  }
}
