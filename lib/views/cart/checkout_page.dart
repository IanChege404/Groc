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
import '../../core/services/firestore_service.dart';
import 'components/checkout_address_selector.dart';
import 'components/checkout_payment_systems.dart';
import 'package:go_router/go_router.dart';

/// Kenyan phone numbers in E.164 format, e.g. +254712345678
final RegExp _kenyanPhoneRegExp = RegExp(r'^\+254[17]\d{8}$');

const double _deliveryFeeStandard = 150;

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  PaymentMethodType _selectedPayment = PaymentMethodType.mpesa;
  String? _selectedAddressId;
  String _selectedAddressFull = '';
  double? _selectedLatitude;
  double? _selectedLongitude;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(l10n.checkout),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AddressSelector(
              selectedAddressId: _selectedAddressId,
              onAddressSelected: (id, label, full, {latitude, longitude}) {
                setState(() {
                  _selectedAddressId = id;
                  _selectedAddressFull = full;
                  _selectedLatitude = latitude;
                  _selectedLongitude = longitude;
                });
              },
            ),
            PaymentSystem(
              selectedMethod: _selectedPayment,
              onMethodChanged: (method) {
                setState(() => _selectedPayment = method);
              },
            ),
            PayNowButton(
              selectedPayment: _selectedPayment,
              selectedAddressFull: _selectedAddressFull,
              selectedLatitude: _selectedLatitude,
              selectedLongitude: _selectedLongitude,
              deliveryFee: _deliveryFeeStandard,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class PayNowButton extends ConsumerStatefulWidget {
  const PayNowButton({
    super.key,
    required this.selectedPayment,
    required this.selectedAddressFull,
    this.selectedLatitude,
    this.selectedLongitude,
    required this.deliveryFee,
  });

  final PaymentMethodType selectedPayment;
  final String selectedAddressFull;
  final double? selectedLatitude;
  final double? selectedLongitude;
  final double deliveryFee;

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

  String get _paymentMethodName {
    switch (widget.selectedPayment) {
      case PaymentMethodType.mpesa:
        return 'mpesa';
      case PaymentMethodType.card:
        return 'card';
      case PaymentMethodType.stripe:
        return 'stripe';
      case PaymentMethodType.paypal:
        return 'paypal';
      case PaymentMethodType.cod:
        return 'cash_on_delivery';
    }
  }

  Future<void> _onPayNow() async {
    if (_isSubmitting) return;

    final l10n = AppLocalizations.of(context)!;
    final authState = ref.read(authProvider);
    final cartState = ref.read(cartItemsProvider);

    final userId = authState.maybeWhen(data: (uid) => uid, orElse: () => null);
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseLogIn)),
      );
      return;
    }

    final cartItems = cartState.maybeWhen(
      data: (items) => items,
      orElse: () => const <dynamic>[],
    );

    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cartIsEmpty)),
      );
      return;
    }

    if (widget.selectedAddressFull.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a delivery address')),
      );
      return;
    }

    final phoneNumber = FirebaseAuth.instance.currentUser?.phoneNumber;
    if (widget.selectedPayment == PaymentMethodType.mpesa &&
        (phoneNumber == null || !_kenyanPhoneRegExp.hasMatch(phoneNumber))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invalidPhoneNumber)),
      );
      return;
    }

    final subtotal = cartItems.fold<double>(
      0,
      (sum, item) => sum + (item.priceAtTimeOfAdd * item.quantity),
    );
    final totalAmount = subtotal + widget.deliveryFee;

    final confirmed = await _confirmPayment(
      widget.selectedPayment == PaymentMethodType.mpesa
          ? totalAmount
          : totalAmount,
      phoneNumber ?? '',
    );
    if (!confirmed || !mounted) return;

    setState(() => _isSubmitting = true);

    final orderId = 'ord_${DateTime.now().microsecondsSinceEpoch}';

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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Product "${item.productId}" not found. Please try again.'),
            action: SnackBarAction(label: l10n.retry, onPressed: _onPayNow),
          ),
        );
        setState(() => _isSubmitting = false);
        return;
      }
    }

    final order = OrderModel(
      id: orderId,
      userId: userId,
      items: orderItems,
      totalAmount: totalAmount,
      status: 'pending',
      paymentMethod: _paymentMethodName,
      shippingAddress: widget.selectedAddressFull,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      latitude: widget.selectedLatitude,
      longitude: widget.selectedLongitude,
    );

    try {
      await ref.read(ordersProvider.notifier).createOrder(order);

      if (!mounted) return;

      switch (widget.selectedPayment) {
        case PaymentMethodType.mpesa:
          context.push('/mpesaProcessing', extra: {
            'amount': totalAmount,
            'phoneNumber': phoneNumber,
            'orderId': orderId,
          });
          break;
        case PaymentMethodType.card:
          context.push('/cardPayment', extra: {
            'amount': totalAmount,
            'orderId': orderId,
          });
          break;
        case PaymentMethodType.stripe:
          context.push('/stripePayment', extra: {
            'amount': totalAmount,
            'orderId': orderId,
          });
          break;
        case PaymentMethodType.paypal:
          context.push('/paypalPayment', extra: {
            'amount': totalAmount,
            'orderId': orderId,
          });
          break;
        case PaymentMethodType.cod:
          await FirestoreService().updateOrderStatus(orderId, 'confirmed');
          if (!mounted) return;
          context.go('/orderSuccessfull', extra: {
            'orderId': orderId,
            'totalAmount': 'KES ${totalAmount.toStringAsFixed(2)}',
          });
          break;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.orderCreationFailed),
          action: SnackBarAction(label: l10n.retry, onPressed: _onPayNow),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
