import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/components/network_image.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/models/bundle_model.dart';
import '../../../core/models/product_model.dart';
import '../../../core/models/wishlist_model.dart';
import '../../../core/providers/product_cache_provider.dart';

class SingleWishlistItemTile extends ConsumerWidget {
  const SingleWishlistItemTile({
    super.key,
    required this.wishlistItem,
    required this.onRemove,
  });

  final WishlistModel wishlistItem;
  final VoidCallback onRemove;

  Widget _buildProductTile(BuildContext context, ProductModel product) {
    return Container(
      margin: const EdgeInsets.all(AppDefaults.padding / 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.24),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: NetworkImageWithLoader(product.image),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppDefaults.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ksh ${product.price}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: IconButton(
              icon: const Icon(Icons.favorite),
              color: Colors.red,
              onPressed: onRemove,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBundleTile(BuildContext context, BundleModel bundle) {
    final bundleImage = bundle.images.isNotEmpty
        ? bundle.images.first
        : bundle.image;

    return Container(
      margin: const EdgeInsets.all(AppDefaults.padding / 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.24),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: NetworkImageWithLoader(bundleImage),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppDefaults.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bundle.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ksh ${bundle.price}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: IconButton(
              icon: const Icon(Icons.favorite),
              color: Colors.red,
              onPressed: onRemove,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (wishlistItem.itemType == WishlistItemType.product) {
      final productAsync = ref.watch(productByIdProvider(wishlistItem.itemId));
      return productAsync.when(
        loading: () => const SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => const SizedBox(
          height: 120,
          child: Center(child: Text('Product not found')),
        ),
        data: (product) {
          if (product == null) {
            return const SizedBox(
              height: 120,
              child: Center(child: Text('Product not found')),
            );
          }

          return _buildProductTile(context, product);
        },
      );
    }

    if (wishlistItem.itemType == WishlistItemType.bundle) {
      final bundleAsync = ref.watch(bundleByIdProvider(wishlistItem.itemId));
      return bundleAsync.when(
        loading: () => const SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => const SizedBox(
          height: 120,
          child: Center(child: Text('Bundle not found')),
        ),
        data: (bundle) {
          if (bundle == null) {
            return const SizedBox(
              height: 120,
              child: Center(child: Text('Bundle not found')),
            );
          }

          return _buildBundleTile(context, bundle);
        },
      );
    }

    final productAsync = ref.watch(productByIdProvider(wishlistItem.itemId));
    final bundleAsync = ref.watch(bundleByIdProvider(wishlistItem.itemId));

    final product = productAsync.valueOrNull;
    if (product != null) {
      return _buildProductTile(context, product);
    }

    final bundle = bundleAsync.valueOrNull;
    if (bundle != null) {
      return _buildBundleTile(context, bundle);
    }

    final isLoading = productAsync.isLoading || bundleAsync.isLoading;
    if (isLoading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return const SizedBox(
      height: 120,
      child: Center(child: Text('Item not found')),
    );
  }
}
