import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/components/app_back_button.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/models/order_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/order_provider.dart';
import '../../core/routes/app_routes.dart';
import 'components/checkout_address_selector.dart';
import 'components/checkout_card_details.dart';
import 'components/checkout_payment_systems.dart';

class CheckoutPage extends ConsumerWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AddressSelector(),
            const PaymentSystem(),
            const CardDetails(),
            PayNowButton(ref: ref),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class PayNowButton extends ConsumerStatefulWidget {
  const PayNowButton({super.key, required this.ref});

  final WidgetRef ref;

  @override
  ConsumerState<PayNowButton> createState() => _PayNowButtonState();
}

class _PayNowButtonState extends ConsumerState<PayNowButton> {
  bool _isSubmitting = false;

  Future<void> _onPayNow() async {
    if (_isSubmitting) {
      return;
    }

    final authState = ref.read(authProvider);
    final cartState = ref.read(cartItemsProvider);

    final userId = authState.maybeWhen(data: (uid) => uid, orElse: () => null);
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to continue')),
      );
      return;
    }

    final cartItems = cartState.maybeWhen(
      data: (items) => items,
      orElse: () => const <dynamic>[],
    );

    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Your cart is empty')));
      return;
    }

    final totalAmount = cartItems.fold<double>(
      0,
      (sum, item) => sum + (item.priceAtTimeOfAdd * item.quantity),
    );

    final orderId = 'ord_${DateTime.now().microsecondsSinceEpoch}';
    final order = OrderModel(
      id: orderId,
      userId: userId,
      items: cartItems
          .map(
            (item) => OrderItemModel(
              productId: item.productId,
              quantity: item.quantity,
              priceAtTimeOfOrder: item.priceAtTimeOfAdd,
              productName: item.productId,
            ),
          )
          .toList(),
      totalAmount: totalAmount,
      status: 'pending',
      paymentMethod: 'mpesa',
      shippingAddress: 'Office Address',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref.read(ordersProvider.notifier).createOrder(order);

      if (!mounted) {
        return;
      }

      final phoneNumber = FirebaseAuth.instance.currentUser?.phoneNumber;
      if (phoneNumber == null || phoneNumber.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Phone number is required for M-Pesa checkout. Update your account phone number and try again.',
            ),
          ),
        );
        await ref.read(ordersProvider.notifier).cancelOrder(orderId);
        return;
      }

      Navigator.pushNamed(
        context,
        AppRoutes.mpesaProcessing,
        arguments: {
          'amount': totalAmount,
          'phoneNumber': phoneNumber,
          'orderId': orderId,
        },
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create order: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _onPayNow,
          child: Text(_isSubmitting ? 'Processing...' : 'Pay Now'),
        ),
      ),
    );
  }
}
