import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../constants/constants.dart';
import '../models/product_model.dart';
import '../models/wishlist_model.dart';
import '../providers/wishlist_provider.dart';
import '../routes/app_routes.dart';
import 'network_image.dart';

class ProductTileSquare extends ConsumerStatefulWidget {
  const ProductTileSquare({super.key, required this.data});

  final ProductModel data;

  @override
  ConsumerState<ProductTileSquare> createState() => _ProductTileSquareState();
}

class _ProductTileSquareState extends ConsumerState<ProductTileSquare>
    with TickerProviderStateMixin {
  late AnimationController _popController;
  late Animation<double> _popAnimation;

  @override
  void initState() {
    super.initState();
    _popController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _popAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _popController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _popController.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite() async {
    final wishlistState = ref.read(wishlistItemsProvider);
    final isCurrentlyInWishlist = wishlistState.maybeWhen(
      data: (items) => items.any((item) => item.productId == widget.data.id),
      orElse: () => false,
    );

    try {
      await _popController.forward();

      if (isCurrentlyInWishlist) {
        // Remove from wishlist
        final wishlistItem = wishlistState.maybeWhen(
          data: (items) =>
              items.firstWhere((item) => item.productId == widget.data.id),
          orElse: () => null,
        );
        if (wishlistItem != null) {
          await ref
              .read(wishlistItemsProvider.notifier)
              .removeFromWishlist(wishlistItem.id);
        }
      } else {
        // Add to wishlist
        final newWishlistItem = WishlistModel(
          id: '${widget.data.id}_${DateTime.now().millisecondsSinceEpoch}',
          userId: '', // Will be set by the provider
          productId: widget.data.id,
          addedAt: DateTime.now(),
        );
        await ref
            .read(wishlistItemsProvider.notifier)
            .addToWishlist(newWishlistItem);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCurrentlyInWishlist
                  ? 'Removed from wishlist'
                  : 'Added to wishlist',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      await _popController.reverse();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update wishlist: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    await _popController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final wishlistState = ref.watch(wishlistItemsProvider);
    final isFavorite = wishlistState.maybeWhen(
      data: (items) => items.any((item) => item.productId == widget.data.id),
      orElse: () => false,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding / 2),
      child: Material(
        borderRadius: AppDefaults.borderRadius,
        color: AppColors.scaffoldBackground,
        child: InkWell(
          borderRadius: AppDefaults.borderRadius,
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.productDetails,
            arguments: {'product': widget.data},
          ),
          child: Container(
            width: 176,
            height: 296,
            padding: const EdgeInsets.all(AppDefaults.padding),
            decoration: BoxDecoration(
              border: Border.all(width: 0.1, color: AppColors.placeholder),
              borderRadius: AppDefaults.borderRadius,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppDefaults.padding / 2),
                      child: AspectRatio(
                        aspectRatio: 1 / 1,
                        child: NetworkImageWithLoader(
                          widget.data.images.isNotEmpty
                              ? widget.data.images.first
                              : widget.data.image,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: ScaleTransition(
                        scale: _popAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).scaffoldBackgroundColor,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).shadowColor,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _toggleFavorite,
                              customBorder: const CircleBorder(),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SvgPicture.asset(
                                  isFavorite
                                      ? AppIcons.heartActive
                                      : AppIcons.heartOutlined,
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.data.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Text(widget.data.weight),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${widget.data.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '\$${widget.data.mainPrice.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
