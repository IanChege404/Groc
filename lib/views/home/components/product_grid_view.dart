import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/components/product_tile_square.dart';
import '../../../core/constants/constants.dart';
import '../../../core/providers/catalog_provider.dart';

class ProductGridView extends ConsumerWidget {
  const ProductGridView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(allProductsProvider);

    return Expanded(
      child: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Failed to load products: $error')),
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text('No products found'));
          }

          return GridView.builder(
            padding: const EdgeInsets.only(top: AppDefaults.padding),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductTileSquare(data: products[index]);
            },
          );
        },
      ),
    );
  }
}
