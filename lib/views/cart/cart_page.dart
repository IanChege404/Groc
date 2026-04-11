import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/components/app_back_button.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/routes/app_routes.dart';
import '../../core/providers/cart_provider.dart';
import 'components/coupon_code_field.dart';
import 'components/items_totals_price.dart';
import 'components/single_cart_item_tile.dart';
import 'empty_cart_page.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key, this.isHomePage = false});

  final bool isHomePage;

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartItemsProvider);

    return Scaffold(
      appBar: widget.isHomePage
          ? null
          : AppBar(
              leading: const AppBackButton(),
              title: const Text('Cart Page'),
            ),
      body: SafeArea(
        child: cartState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDefaults.padding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Failed to load cart: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Refresh the cart data
                      ref.invalidate(cartItemsProvider);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return const EmptyCartPage();
            }

            final totalItems = items.fold<int>(
              0,
              (sum, item) => sum + item.quantity,
            );
            final subtotal = items.fold<double>(
              0,
              (sum, item) => sum + (item.priceAtTimeOfAdd * item.quantity),
            );

            return RefreshIndicator(
              onRefresh: () async {
                // Refresh the cart data
                ref.invalidate(cartItemsProvider);
                // Wait a moment for the refresh to complete
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    ...items.map(
                      (item) => SingleCartItemTile(
                        key: ValueKey(item.id),
                        item: item,
                        onIncrease: () => ref
                            .read(cartItemsProvider.notifier)
                            .updateCartItemQuantity(item.id, item.quantity + 1),
                        onDecrease: () => ref
                            .read(cartItemsProvider.notifier)
                            .updateCartItemQuantity(item.id, item.quantity - 1),
                        onRemove: () => ref
                            .read(cartItemsProvider.notifier)
                            .removeFromCart(item.id),
                      ),
                    ),
                    const CouponCodeField(),
                    ItemTotalsAndPrice(
                      totalItems: totalItems,
                      subtotal: subtotal,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(AppDefaults.padding),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.checkoutPage,
                            );
                          },
                          child: const Text('Checkout'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
