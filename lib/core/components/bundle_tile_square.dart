import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../constants/constants.dart';
import '../models/bundle_model.dart';
import '../models/wishlist_model.dart';
import '../providers/wishlist_provider.dart';
import '../routes/app_routes.dart';
import 'network_image.dart';

class BundleTileSquare extends ConsumerStatefulWidget {
  const BundleTileSquare({super.key, required this.data});

  final BundleModel data;

  @override
  ConsumerState<BundleTileSquare> createState() => _BundleTileSquareState();
}

class _BundleTileSquareState extends ConsumerState<BundleTileSquare>
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
      data: (items) => items.any((item) => item.itemId == widget.data.id),
      orElse: () => false,
    );

    try {
      await _popController.forward();

      if (isCurrentlyInWishlist) {
        // Remove from wishlist
        final wishlistItem = wishlistState.maybeWhen(
          data: (items) =>
              items.firstWhere((item) => item.itemId == widget.data.id),
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
          id: '', // Deterministic ID is set by the provider
          userId: '', // Will be set by the provider
          itemId: widget.data.id,
          addedAt: DateTime.now(),
          itemType: WishlistItemType.bundle,
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
      data: (items) => items.any((item) => item.itemId == widget.data.id),
      orElse: () => false,
    );

    return Material(
      color: AppColors.scaffoldBackground,
      borderRadius: AppDefaults.borderRadius,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.bundleProduct,
            arguments: {'bundle': widget.data},
          );
        },
        borderRadius: AppDefaults.borderRadius,
        child: Container(
          width: 176,
          height: 320,
          padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.data.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.data.itemNames.join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
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
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
