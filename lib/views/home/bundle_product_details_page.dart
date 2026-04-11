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

  Future<void> _addToCart() async {
    if (widget.bundle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bundle information is missing')),
      );
      return;
    }

    final quantity = _quantityKey.currentState?.quantity ?? 1;

    final cartItem = CartItemModel(
      id: '', // Deterministic ID (userId_productId) is set by the provider
      userId: '', // Will be set by the provider
      productId: widget.bundle!.id,
      quantity: quantity,
      priceAtTimeOfAdd: widget.bundle!.price,
      addedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await ref.read(cartItemsProvider.notifier).addToCart(cartItem);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.bundle!.name} added to cart'),
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
    final images = widget.bundle?.images.isNotEmpty == true
        ? widget.bundle!.images
        : [widget.bundle?.image ?? 'https://i.imgur.com/NOuZzbe.png'];

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(widget.bundle?.name ?? 'Bundle Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProductImagesSlider(images: images),
            /* <---- Product Data -----> */
            Padding(
              padding: const EdgeInsets.all(AppDefaults.padding),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.bundle?.name ?? 'Bundle Pack',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  PriceAndQuantityRow(
                    key: _quantityKey,
                    currentPrice: widget.bundle?.price ?? 0,
                    orginalPrice: widget.bundle?.mainPrice ?? 0,
                    quantity: 1,
                  ),
                  const SizedBox(height: AppDefaults.padding / 2),
                  const BundleMetaData(),
                  const PackDetails(),
                  ReviewRowButton(
                    totalStars: widget.bundle?.rating.toInt() ?? 0,
                  ),
                  const Divider(thickness: 0.1),
                  BuyNowRow(onBuyButtonTap: () {}, onCartButtonTap: _addToCart),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
