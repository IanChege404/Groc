import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/components/app_back_button.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/models/order_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/order_provider.dart';
import '../../core/services/firestore_product_service.dart';
import 'components/checkout_address_selector.dart';
import 'components/checkout_card_details.dart';
import 'components/checkout_payment_systems.dart';
import 'package:go_router/go_router.dart';

/// Kenyan phone numbers in E.164 format, e.g. +254712345678
final RegExp _kenyanPhoneRegExp = RegExp(r'^\+254[17]\d{8}$');

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

  Future<bool> _confirmPayment(double amount, String phoneNumber) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.confirmPaymentTitle),
        content: Text(
          l10n.confirmPaymentMessage(amount.toStringAsFixed(0), phoneNumber),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _onPayNow() async {
    if (_isSubmitting) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
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

    final phoneNumber = FirebaseAuth.instance.currentUser?.phoneNumber;
    if (phoneNumber == null || !_kenyanPhoneRegExp.hasMatch(phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invalidPhoneNumber)),
      );
      return;
    }

    final totalAmount = cartItems.fold<double>(
      0,
      (sum, item) => sum + (item.priceAtTimeOfAdd * item.quantity),
    );

    final confirmed = await _confirmPayment(totalAmount, phoneNumber);
    if (!confirmed || !mounted) {
      return;
    }

    final orderId = 'ord_${DateTime.now().microsecondsSinceEpoch}';

    // Fetch product details for each cart item
    final List<OrderItemModel> orderItems = [];
    final productService = FirestoreProductService();
    for (final item in cartItems) {
      final productResult = await productService.getProductById(item.productId);
      if (productResult.success && productResult.data != null) {
        final product = productResult.data!;
        orderItems.add(OrderItemModel(
          productId: item.productId,
          quantity: item.quantity,
          priceAtTimeOfOrder: item.priceAtTimeOfAdd,
          productName: product.name,
          image: product.image,
        ));
      } else {
        // Fallback if product fetch fails
        orderItems.add(OrderItemModel(
          productId: item.productId,
          quantity: item.quantity,
          priceAtTimeOfOrder: item.priceAtTimeOfAdd,
          productName: 'Unknown Product',
          image: '',
        ));
      }
    }

    final order = OrderModel(
      id: orderId,
      userId: userId,
      items: orderItems,
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

      context.push('/mpesaProcessing', extra: {
        'amount': totalAmount,
        'phoneNumber': phoneNumber,
        'orderId': orderId,
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.orderCreationFailed),
          action: SnackBarAction(label: l10n.retry, onPressed: _onPayNow),
        ),
      );
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
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _onPayNow,
          child: _isSubmitting
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(l10n.processingPayment),
                  ],
                )
              : Text(l10n.payNow),
        ),
      ),
    );
  }
}
