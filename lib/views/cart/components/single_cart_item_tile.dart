import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/components/network_image.dart';
import '../../../core/constants/constants.dart';
import '../../../core/models/cart_item_model.dart';
import '../../../core/providers/product_cache_provider.dart';

class SingleCartItemTile extends ConsumerStatefulWidget {
  const SingleCartItemTile({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
    this.productName,
    this.productImage,
  });

  final CartItemModel item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;
  final String? productName;
  final String? productImage;

  @override
  ConsumerState<SingleCartItemTile> createState() => _SingleCartItemTileState();
}

class _SingleCartItemTileState extends ConsumerState<SingleCartItemTile>
    with TickerProviderStateMixin {
  late AnimationController _deleteController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _deleteController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.5, 0),
    ).animate(CurvedAnimation(parent: _deleteController, curve: Curves.easeIn));

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _deleteController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _deleteController.dispose();
    super.dispose();
  }

  Future<void> _triggerDelete() async {
    setState(() => _isDeleting = true);
    await _deleteController.forward();
    if (mounted) {
      widget.onRemove();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item removed from cart')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // If product details are provided, render directly
    if (widget.productName != null && widget.productImage != null) {
      return _buildCartItemTile(
        context,
        widget.productName!,
        widget.productImage!,
      );
    }

    // Otherwise, load product details asynchronously using cached provider
    final productAsync = ref.watch(productByIdProvider(widget.item.productId));

    return productAsync.when(
      loading: () => _buildCartItemTile(
        context,
        'Loading...',
        'https://i.imgur.com/4YEHvGc.png',
      ),
      error: (_, __) => _buildCartItemTile(
        context,
        widget.item.productId,
        'https://i.imgur.com/4YEHvGc.png',
      ),
      data: (product) {
        if (product == null) {
          return _buildCartItemTile(
            context,
            widget.item.productId,
            'https://i.imgur.com/4YEHvGc.png',
          );
        }

        return _buildCartItemTile(context, product.name, product.image);
      },
    );
  }

  Widget _buildCartItemTile(
    BuildContext context,
    String productName,
    String productImage,
  ) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDefaults.padding,
            vertical: AppDefaults.padding / 2,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  /// Thumbnail
                  SizedBox(
                    width: 70,
                    child: AspectRatio(
                      aspectRatio: 1 / 1,
                      child: NetworkImageWithLoader(
                        productImage,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  /// Quantity and Name
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              productName,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                            ),
                            Text(
                              'Qty: ${widget.item.quantity}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: widget.onIncrease,
                            icon: SvgPicture.asset(AppIcons.addQuantity),
                            constraints: const BoxConstraints(),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${widget.item.quantity}',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                            ),
                          ),
                          IconButton(
                            onPressed: widget.item.quantity > 1
                                ? widget.onDecrease
                                : null,
                            icon: SvgPicture.asset(AppIcons.removeQuantity),
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),

                  /// Price and Delete labelLarge
                  Column(
                    children: [
                      IconButton(
                        constraints: const BoxConstraints(),
                        onPressed: _isDeleting ? null : _triggerDelete,
                        icon: SvgPicture.asset(AppIcons.delete),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '\$${(widget.item.priceAtTimeOfAdd * widget.item.quantity).toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(thickness: 0.1),
            ],
          ),
        ),
      ),
    );
  }
}
