import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/components/app_back_button.dart';
import '../../core/components/retryable_error_view.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/bundle_management_provider.dart';
import 'components/bundle_meta_data.dart';
import 'components/bundle_pack_details.dart';

class BundleDetailsPage extends ConsumerWidget {
  const BundleDetailsPage({super.key, this.bundleId});

  final String? bundleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    if (bundleId == null) {
      return Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(),
          title: Text(l10n.bundleDetails),
        ),
        body: Center(
          child: Text(l10n.bundleInformationMissing),
        ),
      );
    }

    final bundleAsync = ref.watch(bundleByIdProvider(bundleId!));

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(l10n.bundleDetails),
      ),
      body: bundleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => RetryableErrorView(
          title: l10n.failedToLoadBundles,
          message: l10n.checkConnectionAndRetry,
          onRetry: () => ref.invalidate(bundleByIdProvider(bundleId!)),
        ),
        data: (bundle) {
          if (bundle == null) {
            return Center(child: Text(l10n.noBundlesFound));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bundle.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  bundle.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                BundleMetaData(bundle: bundle),
                const Divider(),
                PackDetails(bundle: bundle),
              ],
            ),
          );
        },
      ),
    );
  }
}
