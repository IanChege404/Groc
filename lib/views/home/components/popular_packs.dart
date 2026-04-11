import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/components/bundle_tile_square.dart';
import '../../../core/components/title_and_action_button.dart';
import '../../../core/constants/constants.dart';
import '../../../core/providers/catalog_provider.dart';
import '../../../core/routes/app_routes.dart';

class PopularPacks extends ConsumerWidget {
  const PopularPacks({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bundlesAsync = ref.watch(featuredBundlesProvider);

    return bundlesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppDefaults.padding),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Text('Failed to load popular packs: $error'),
      ),
      data: (bundles) {
        if (bundles.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            TitleAndActionButton(
              title: 'Popular Packs',
              onTap: () => Navigator.pushNamed(context, AppRoutes.popularItems),
            ),
            SizedBox(
              height: 340,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: AppDefaults.padding),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    bundles.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(
                        right: AppDefaults.padding,
                      ),
                      child: BundleTileSquare(data: bundles[index]),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
