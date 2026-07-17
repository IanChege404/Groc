import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/components/app_back_button.dart';
import '../../core/components/retryable_error_view.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/bundle_management_provider.dart';
import 'package:go_router/go_router.dart';

class MyBundlesPage extends ConsumerWidget {
  const MyBundlesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final bundlesAsync = ref.watch(allBundlesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(l10n.myBundles),
        elevation: 0,
      ),
      body: bundlesAsync.when(
        data: (bundles) {
          if (bundles.isEmpty) {
            return Semantics(
              container: true,
              label: '${l10n.noBundlesYet}. ${l10n.createFirstBundleToSave}',
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDefaults.padding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noBundlesYet,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.createFirstBundleToSave,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          context.push('/createMyPack');
                        },
                        child: Text(l10n.createBundle),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Semantics(
            container: true,
            label: '${bundles.length} ${l10n.myBundles.toLowerCase()}',
            child: ListView.builder(
              padding: const EdgeInsets.all(AppDefaults.padding),
              itemCount: bundles.length,
              itemBuilder: (context, index) {
                final bundle = bundles[index];
                return Semantics(
                  button: true,
                  label:
                      '${bundle.name}, ${bundle.itemNames.length} ${l10n.itemCount(bundle.itemNames.length)}, KES ${bundle.price.toStringAsFixed(0)}',
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        context.push('/bundleEdit', extra: {'bundle': bundle});
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(AppDefaults.padding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        bundle.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        l10n.itemCount(bundle.itemNames.length),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_rounded),
                                  onPressed: () {
                                    context.push('/bundleEdit',
                                        extra: {'bundle': bundle});
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.price,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'KES ${bundle.price.toStringAsFixed(0)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green,
                                          ),
                                    ),
                                  ],
                                ),
                                if (bundle.discountPrice != null)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        l10n.discountPrice,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'KES ${bundle.discountPrice?.toStringAsFixed(0)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blue,
                                            ),
                                      ),
                                    ],
                                  ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      l10n.rating,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(Icons.star_rounded,
                                            color: Colors.amber, size: 16),
                                        const SizedBox(width: 2),
                                        Text(
                                          '${bundle.rating}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => RetryableErrorView(
          title: l10n.errorLoadingData,
          message: l10n.checkConnectionAndRetry,
          onRetry: () => ref.invalidate(allBundlesProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/createMyPack');
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
