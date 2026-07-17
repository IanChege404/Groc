import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/components/app_back_button.dart';
import '../../core/components/product_tile_square.dart';
import '../../core/components/retryable_error_view.dart';
import '../../core/constants/constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/catalog_provider.dart';

class NewItemsPage extends ConsumerWidget {
  const NewItemsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final productsAsync = ref.watch(newProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newItems),
        leading: const AppBackButton(),
      ),
      body: SafeArea(
        child: productsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => RetryableErrorView(
            title: l10n.failedToLoadProducts,
            message: l10n.checkConnectionAndRetry,
            onRetry: () => ref.invalidate(newProductsProvider),
          ),
          data: (products) {
            if (products.isEmpty) {
              return Center(child: Text(l10n.noProductsFound));
            }
            return Semantics(
              container: true,
              label: '${products.length} ${l10n.newItems.toLowerCase()}',
              child: Padding(
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
              ),
            );
          },
        ),
      ),
    );
  }
}
