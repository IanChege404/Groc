import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/components/product_tile_square.dart';
import '../../../core/components/retryable_error_view.dart';
import '../../../core/constants/constants.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/catalog_provider.dart';

class ProductGridView extends ConsumerWidget {
  const ProductGridView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final productsAsync = ref.watch(allProductsProvider);

    return Expanded(
      child: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => RetryableErrorView(
          title: l10n.failedToLoadProducts,
          message: l10n.checkConnectionAndRetry,
          onRetry: () => ref.invalidate(allProductsProvider),
        ),
        data: (products) {
          if (products.isEmpty) {
            return Center(child: Text(l10n.noProductsFound));
          }

          return Semantics(
            container: true,
            label: l10n.productsCount(products.length),
            child: GridView.builder(
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
            ),
          );
        },
      ),
    );
  }
}
