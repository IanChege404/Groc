import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/components/network_image.dart';
import '../../../core/constants/app_defaults.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productByIdProvider(wishlistItem.productId));

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

        return Container(
          margin: const EdgeInsets.all(AppDefaults.padding / 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
          ),
          child: Row(
            children: [
              // Product Image
              SizedBox(
                width: 100,
                height: 100,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: NetworkImageWithLoader(product.image),
                ),
              ),
              // Product Details
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
              // Remove Button
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
      },
    );
  }
}
