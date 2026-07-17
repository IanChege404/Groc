import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/components/product_tile_square.dart';
import '../../../core/components/retryable_error_view.dart';
import '../../../core/components/title_and_action_button.dart';
import '../../../core/constants/constants.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/catalog_provider.dart';
import 'package:go_router/go_router.dart';

class OurNewItem extends ConsumerWidget {
  const OurNewItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final productsAsync = ref.watch(newProductsProvider);

    return productsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppDefaults.padding),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: RetryableErrorView(
          title: l10n.failedToLoadNewItems,
          message: l10n.checkConnectionAndRetry,
          onRetry: () => ref.invalidate(newProductsProvider),
        ),
      ),
      data: (products) {
        if (products.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            TitleAndActionButton(
              title: l10n.ourNewItem,
              onTap: () => context.push('/newItems'),
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
