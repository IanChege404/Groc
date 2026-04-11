import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/components/app_back_button.dart';
import '../../core/components/product_tile_square.dart';
import '../../core/constants/constants.dart';
import '../../core/providers/catalog_provider.dart';

class NewItemsPage extends ConsumerWidget {
  const NewItemsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(newProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Item'),
        leading: const AppBackButton(),
      ),
      body: SafeArea(
        child: productsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              Center(child: Text('Failed to load products: $error')),
          data: (products) {
            if (products.isEmpty) {
              return const Center(child: Text('No products found'));
            }
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDefaults.padding,
              ),
              child: GridView.builder(
                padding: const EdgeInsets.only(top: AppDefaults.padding),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 0.64,
                  mainAxisSpacing: 16,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ProductTileSquare(data: products[index]);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
