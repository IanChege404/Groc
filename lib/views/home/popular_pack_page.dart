import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/components/app_back_button.dart';
import '../../core/components/bundle_tile_square.dart';
import '../../core/constants/constants.dart';
import '../../core/providers/catalog_provider.dart';
import '../../core/routes/app_routes.dart';

class PopularPackPage extends ConsumerWidget {
  const PopularPackPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bundlesAsync = ref.watch(featuredBundlesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Popular Packs'),
        leading: const AppBackButton(),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            bundlesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  Center(child: Text('Failed to load bundles: $error')),
              data: (bundles) {
                if (bundles.isEmpty) {
                  return const Center(child: Text('No bundles found'));
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
                decoration: const BoxDecoration(color: Colors.white60),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.createMyPack);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(AppIcons.shoppingBag),
                      const SizedBox(width: AppDefaults.padding),
                      const Text('Create Own Pack'),
                    ],
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
