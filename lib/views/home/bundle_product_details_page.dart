import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/components/app_back_button.dart';
import '../../core/components/buy_now_row_button.dart';
import '../../core/components/price_and_quantity.dart';
import '../../core/components/product_images_slider.dart';
import '../../core/components/review_row_button.dart';
import '../../core/constants/constants.dart';
import '../../core/models/bundle_model.dart';
import '../../core/models/cart_item_model.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/routes/app_routes.dart';
import 'components/bundle_meta_data.dart';
import 'components/bundle_pack_details.dart';

class BundleProductDetailsPage extends ConsumerStatefulWidget {
  const BundleProductDetailsPage({super.key, this.bundle});

  final BundleModel? bundle;

  @override
  ConsumerState<BundleProductDetailsPage> createState() =>
      _BundleProductDetailsPageState();
}

class _BundleProductDetailsPageState
    extends ConsumerState<BundleProductDetailsPage> {
  late GlobalKey<PriceAndQuantityRowState> _quantityKey;

  @override
  void initState() {
    super.initState();
    _quantityKey = GlobalKey<PriceAndQuantityRowState>();
  }

  BundleModel? get _bundle => widget.bundle;

  int get _selectedQuantity => _quantityKey.currentState?.quantity ?? 1;

  void _showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  bool _isBundleInCart(List<CartItemModel> items) {
    final bundle = _bundle;
    if (bundle == null) {
      return false;
    }

    return items.any((item) => item.productId == bundle.id);
  }

  CartItemModel _buildCartItem({required int quantity}) {
    final bundle = _bundle!;
    return CartItemModel(
      id: '', // Deterministic ID (userId_productId) is set by the provider
      userId: '', // Will be set by the provider
      productId: bundle.id,
      quantity: quantity,
      priceAtTimeOfAdd: bundle.price,
      addedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _addBundleToCart({required int quantity}) async {
    final bundle = _bundle;
    if (bundle == null) {
      _showSnackBar('Bundle information is missing');
      return;
    }

    await ref
        .read(cartItemsProvider.notifier)
        .addToCart(_buildCartItem(quantity: quantity));
  }

  Future<void> _toggleCart() async {
    final bundle = _bundle;
    if (bundle == null) {
      _showSnackBar('Bundle information is missing');
      return;
    }

    final cartState = ref.read(cartItemsProvider);
    final existingItem = cartState.maybeWhen(
      data: (items) => items.where((i) => i.productId == bundle.id).firstOrNull,
      orElse: () => null,
    );

    if (existingItem != null) {
      await ref
          .read(cartItemsProvider.notifier)
          .removeFromCart(existingItem.id);
      if (mounted) {
        _showSnackBar('${bundle.name} removed from cart');
      }
      return;
    }

    try {
      await _addBundleToCart(quantity: _selectedQuantity);
      if (mounted) {
        _showSnackBar('${bundle.name} added to cart');
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
    final bundle = _bundle;
    if (bundle == null) {
      _showSnackBar('Bundle information is missing');
      return;
    }

    try {
      final cartState = ref.read(cartItemsProvider);
      final existingItem = cartState.maybeWhen(
        data: (items) =>
            items.where((item) => item.productId == bundle.id).firstOrNull,
        orElse: () => null,
      );

      if (existingItem == null) {
        await _addBundleToCart(quantity: _selectedQuantity);
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
    final bundle = _bundle;
    final hasBundle = bundle != null;
    final cartState = ref.watch(cartItemsProvider);
    final isInCart = cartState.maybeWhen(
      data: (items) => _isBundleInCart(items),
      orElse: () => false,
    );

    final currentBundle = bundle;
    final images = hasBundle && currentBundle!.images.isNotEmpty
        ? currentBundle.images
        : [currentBundle?.image ?? 'https://i.imgur.com/NOuZzbe.png'];

    if (!hasBundle) {
      return Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(),
          title: const Text('Bundle Details'),
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
                  'Bundle information is missing',
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
      appBar: AppBar(leading: const AppBackButton(), title: Text(bundle.name)),
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
            Padding(
              padding: const EdgeInsets.all(AppDefaults.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bundle.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  PriceAndQuantityRow(
                    key: _quantityKey,
                    currentPrice: bundle.price,
                    orginalPrice: bundle.mainPrice,
                    quantity: 1,
                  ),
                  const SizedBox(height: AppDefaults.padding / 2),
                  BundleMetaData(bundle: bundle),
                  PackDetails(bundle: bundle),
                  ReviewRowButton(
                    totalStars: (bundle.rating.round()).clamp(1, 5),
                  ),
                  const Divider(thickness: 0.1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
