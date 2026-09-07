import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/components/app_back_button.dart';
import '../../core/components/bundle_tile_square.dart';
import '../../core/components/retryable_error_view.dart';
import '../../core/constants/constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/catalog_provider.dart';
import 'package:go_router/go_router.dart';

class PopularPackPage extends ConsumerWidget {
  const PopularPackPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final bundlesAsync = ref.watch(featuredBundlesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.popularPacks),
        leading: const AppBackButton(),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            bundlesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => RetryableErrorView(
                title: l10n.failedToLoadBundles,
                message: l10n.checkConnectionAndRetry,
                onRetry: () => ref.invalidate(featuredBundlesProvider),
              ),
              data: (bundles) {
                if (bundles.isEmpty) {
                  return Center(child: Text(l10n.noBundlesFound));
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDefaults.padding,
                  ),
                  child: GridView.builder(
                    padding: const EdgeInsets.only(top: AppDefaults.padding),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 0.73,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: bundles.length,
                    itemBuilder: (context, index) {
                      return BundleTileSquare(data: bundles[index]);
                    },
                  ),
                );
              },
            ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.all(AppDefaults.padding * 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: 0.0),
                      Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: 0.80),
                    ],
                  ),
                ),
                child: Semantics(
                  button: true,
                  label: l10n.createOwnPack,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/createMyPack');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(AppIcons.shoppingBag),
                        const SizedBox(width: AppDefaults.padding),
                        Text(l10n.createOwnPack),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
