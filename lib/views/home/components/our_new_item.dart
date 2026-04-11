import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/components/product_tile_square.dart';
import '../../../core/components/title_and_action_button.dart';
import '../../../core/constants/constants.dart';
import '../../../core/providers/catalog_provider.dart';
import '../../../core/routes/app_routes.dart';

class OurNewItem extends ConsumerWidget {
  const OurNewItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(newProductsProvider);

    return productsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppDefaults.padding),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Text('Failed to load new items: $error'),
      ),
      data: (products) {
        if (products.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            TitleAndActionButton(
              title: 'Our New Item',
              onTap: () => Navigator.pushNamed(context, AppRoutes.newItems),
            ),
            SizedBox(
              height: 340,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: AppDefaults.padding),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    products.length,
                    (index) => ProductTileSquare(data: products[index]),
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
