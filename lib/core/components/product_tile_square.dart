import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../constants/constants.dart';
import '../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final wishlistState = ref.read(wishlistItemsProvider);
    final isCurrentlyInWishlist = wishlistState.maybeWhen(
      data: (items) => items.any((item) => item.itemId == widget.data.id),
      orElse: () => false,
    );

    try {
      await _popController.forward();

      if (isCurrentlyInWishlist) {
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
        final newWishlistItem = WishlistModel(
          id: '',
          userId: '',
          itemId: widget.data.id,
          addedAt: DateTime.now(),
          itemType: WishlistItemType.product,
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
                  ? l10n.removedFromWishlist
                  : l10n.addedToWishlist,
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
            content: Text(l10n.failedToUpdateWishlist),
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
    final l10n = AppLocalizations.of(context)!;
    final wishlistState = ref.watch(wishlistItemsProvider);
    final isFavorite = wishlistState.maybeWhen(
      data: (items) => items.any((item) => item.itemId == widget.data.id),
      orElse: () => false,
    );

    final productLabel = l10n.productLabel(
      widget.data.name,
      widget.data.price.toStringAsFixed(2),
      widget.data.rating.toStringAsFixed(1),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding / 2),
      child: Semantics(
        button: true,
        label: productLabel,
        child: Material(
          borderRadius: AppDefaults.borderRadius,
          color: AppColors.scaffoldBackground,
          child: InkWell(
            borderRadius: AppDefaults.borderRadius,
            onTap: () => context.push(
              AppRoutes.productDetails,
              extra: {'product': widget.data},
            ),
            child: Container(
              width: 176,
              height: 280,
              padding: const EdgeInsets.all(AppDefaults.padding),
              decoration: BoxDecoration(
                border: Border.all(width: 0.1, color: AppColors.placeholder),
                borderRadius: AppDefaults.borderRadius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppDefaults.padding / 2),
                        child: AspectRatio(
                          aspectRatio: 1 / 1,
                          child: Semantics(
                            image: true,
                            label: '${widget.data.name} image',
                            child: NetworkImageWithLoader(
                              widget.data.images.isNotEmpty
                                  ? widget.data.images.first
                                  : widget.data.image,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: ScaleTransition(
                          scale: _popAnimation,
                          child: Semantics(
                            button: true,
                            label: isFavorite
                                ? l10n.removeFromWishlistLabel(widget.data.name)
                                : l10n.addToWishlistLabel(widget.data.name),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Flexible(
                    child: Text(
                      widget.data.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color:
                                Theme.of(context).textTheme.titleMedium?.color,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      widget.data.weight,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            '\$${widget.data.price.toStringAsFixed(2)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.color,
                                ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '\$${widget.data.mainPrice.toStringAsFixed(2)}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      decoration: TextDecoration.lineThrough,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
