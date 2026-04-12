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
import '../../core/routes/app_routes.dart';

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

  ProductModel? get _product => widget.product;

  int get _selectedQuantity => _quantityKey.currentState?.quantity ?? 1;

  void _showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  bool _isProductInCart(List<CartItemModel> items) {
    final product = _product;
    if (product == null) {
      return false;
    }

    return items.any((item) => item.productId == product.id);
  }

  CartItemModel _buildCartItem({required int quantity}) {
    final product = _product!;
    return CartItemModel(
      id: '', // Deterministic ID (userId_productId) is set by the provider
      userId: '', // Will be set by the provider
      productId: product.id,
      quantity: quantity,
      priceAtTimeOfAdd: product.price,
      addedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _addProductToCart({required int quantity}) async {
    final product = _product;
    if (product == null) {
      _showSnackBar('Product information is missing');
      return;
    }

    await ref
        .read(cartItemsProvider.notifier)
        .addToCart(_buildCartItem(quantity: quantity));
  }

  Future<void> _toggleCart() async {
    final product = _product;
    if (product == null) {
      _showSnackBar('Product information is missing');
      return;
    }

    final cartState = ref.read(cartItemsProvider);
    final existingItem = cartState.maybeWhen(
      data: (items) =>
          items.where((i) => i.productId == product.id).firstOrNull,
      orElse: () => null,
    );

    if (existingItem != null) {
      await ref
          .read(cartItemsProvider.notifier)
          .removeFromCart(existingItem.id);
      if (mounted) {
        _showSnackBar('${product.name} removed from cart');
      }
      return;
    }

    try {
      await _addProductToCart(quantity: _selectedQuantity);
      if (mounted) {
        _showSnackBar('${product.name} added to cart');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          'Failed to add item to cart: $e',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  Future<void> _buyNow() async {
    final product = _product;
    if (product == null) {
      _showSnackBar('Product information is missing');
      return;
    }

    try {
      final cartState = ref.read(cartItemsProvider);
      final existingItem = cartState.maybeWhen(
        data: (items) =>
            items.where((item) => item.productId == product.id).firstOrNull,
        orElse: () => null,
      );

      if (existingItem == null) {
        await _addProductToCart(quantity: _selectedQuantity);
      }

      if (!mounted) {
        return;
      }

      Navigator.pushNamed(context, AppRoutes.checkoutPage);
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          'Unable to start checkout: $e',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final cartState = ref.watch(cartItemsProvider);
    final isInCart = cartState.maybeWhen(
      data: (items) => _isProductInCart(items),
      orElse: () => false,
    );

    final hasProduct = product != null;
    final currentProduct = product;
    final images = hasProduct && currentProduct!.images.isNotEmpty
        ? currentProduct.images
        : [currentProduct?.image ?? 'https://i.imgur.com/3o6ons9.png'];

    if (!hasProduct) {
      return Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(),
          title: const Text('Product Details'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 56,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Product information is missing',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(leading: const AppBackButton(), title: Text(product.name)),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
          child: BuyNowRow(
            onBuyButtonTap: _buyNow,
            onCartButtonTap: _toggleCart,
            isInCart: isInCart,
          ),
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
                      product.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Weight: ${product.weight}'),
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
                currentPrice: product.price,
                orginalPrice: product.mainPrice,
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
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(product.description),
                ],
              ),
            ),

            /// Review Row
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDefaults.padding,
                // vertical: AppDefaults.padding,
              ),
              child: Column(
                children: [
                  Divider(thickness: 0.1),
                  ReviewRowButton(
                    totalStars: (product.rating.round()).clamp(1, 5),
                  ),
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
