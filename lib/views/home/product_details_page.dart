import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/components/app_back_button.dart';
import '../../core/components/buy_now_row_button.dart';
import '../../core/components/price_and_quantity.dart';
import '../../core/components/product_images_slider.dart';
import '../../core/components/review_row_button.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/models/cart_item_model.dart';
import '../../core/models/product_model.dart';
import '../../core/providers/cart_provider.dart';

class ProductDetailsPage extends ConsumerStatefulWidget {
  const ProductDetailsPage({super.key, this.product});

  final ProductModel? product;

  @override
  ConsumerState<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends ConsumerState<ProductDetailsPage> {
  late GlobalKey<PriceAndQuantityRowState> _quantityKey;

  @override
  void initState() {
    super.initState();
    _quantityKey = GlobalKey<PriceAndQuantityRowState>();
  }

  Future<void> _addToCart() async {
    if (widget.product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product information is missing')),
      );
      return;
    }

    final quantity = _quantityKey.currentState?.quantity ?? 1;

    final cartItem = CartItemModel(
      id: '', // Deterministic ID (userId_productId) is set by the provider
      userId: '', // Will be set by the provider
      productId: widget.product!.id,
      quantity: quantity,
      priceAtTimeOfAdd: widget.product!.price,
      addedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await ref.read(cartItemsProvider.notifier).addToCart(cartItem);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.product!.name} added to cart'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add item to cart: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.product?.images.isNotEmpty == true
        ? widget.product!.images
        : [widget.product?.image ?? 'https://i.imgur.com/3o6ons9.png'];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(widget.product?.name ?? 'Product Details'),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
          child: BuyNowRow(onBuyButtonTap: () {}, onCartButtonTap: _addToCart),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProductImagesSlider(images: images),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(AppDefaults.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product?.name ?? 'Product details unavailable',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Weight: ${widget.product?.weight ?? '-'}'),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDefaults.padding,
              ),
              child: PriceAndQuantityRow(
                key: _quantityKey,
                currentPrice: widget.product?.price ?? 0,
                orginalPrice: widget.product?.mainPrice ?? 0,
                quantity: 1,
              ),
            ),
            const SizedBox(height: 8),

            /// Product Details
            Padding(
              padding: const EdgeInsets.all(AppDefaults.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product Details',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product?.description ?? 'No description available.',
                  ),
                ],
              ),
            ),

            /// Review Row
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDefaults.padding,
                // vertical: AppDefaults.padding,
              ),
              child: Column(
                children: [
                  Divider(thickness: 0.1),
                  ReviewRowButton(totalStars: 5),
                  Divider(thickness: 0.1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
