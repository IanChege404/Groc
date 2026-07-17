import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/constants/app_defaults.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/models/order_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/order_provider.dart';
import 'components/checkout_address_selector.dart';
import 'components/checkout_card_details.dart';
import 'components/checkout_payment_systems.dart';
import 'components/items_totals_price.dart';
import 'delivery_method_screen.dart';
import 'package:go_router/go_router.dart';

/// Kenyan phone numbers in E.164 format, e.g. +254712345678
final RegExp _kenyanPhoneRegExp = RegExp(r'^\+254[17]\d{8}$');

class CheckoutWizard extends ConsumerStatefulWidget {
  const CheckoutWizard({super.key});

  @override
  ConsumerState<CheckoutWizard> createState() => _CheckoutWizardState();
}

class _CheckoutWizardState extends ConsumerState<CheckoutWizard> {
  int _currentStep = 0;
  bool _isSubmitting = false;
  DeliveryMethod _selectedDeliveryMethod = DeliveryMethod.standard;

  static const _stepLabels = ['Address', 'Delivery', 'Review', 'Payment'];

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDefaults.padding,
        vertical: AppDefaults.spacingMd,
      ),
      child: Row(
        children: List.generate(_stepLabels.length, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Row(
              children: [
                if (index > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.3),
                    ),
                  ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? Theme.of(context).colorScheme.primary
                            : isActive
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withValues(alpha: 0.2),
                      ),
                      child: Center(
                        child: isCompleted
                            ? Icon(
                                Icons.check,
                                size: 16,
                                color: Theme.of(context).colorScheme.onPrimary,
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isActive
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _stepLabels[index],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight:
                                isActive ? FontWeight.bold : FontWeight.normal,
                            color: isActive
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
                if (index < _stepLabels.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAddressStep() {
    return const SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppDefaults.padding),
      child: AddressSelector(),
    );
  }

  Widget _buildDeliveryStep() {
    return DeliveryMethodInline(
      selectedMethod: _selectedDeliveryMethod,
      onMethodChanged: (method) {
        setState(() => _selectedDeliveryMethod = method);
      },
    );
  }

  Widget _buildReviewStep() {
    final cartState = ref.watch(cartItemsProvider);
    final cartItems = cartState.maybeWhen(
      data: (items) => items,
      orElse: () => <dynamic>[],
    );

    final totalItems = cartItems.length;
    final subtotal = cartItems.fold<double>(
      0,
      (sum, item) => sum + (item.priceAtTimeOfAdd * item.quantity),
    );

    final deliveryPrice = _getDeliveryPrice();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Review',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppDefaults.spacingMd),
          // Cart items summary
          if (cartItems.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppDefaults.padding),
              child: Center(child: Text('No items in cart')),
            )
          else
            ...cartItems.map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.productId),
                subtitle: Text('Qty: ${item.quantity}'),
                trailing: Text(
                  'KES ${(item.priceAtTimeOfAdd * item.quantity).toStringAsFixed(2)}',
                ),
              ),
            ),
          const Divider(),
          // Address summary
          Text(
            'Delivery Address',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Office Address\n1749 Custom Road, Chhatak',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppDefaults.spacingMd),
          // Delivery method summary
          Text(
            'Delivery Method',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            _getDeliveryMethodLabel(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppDefaults.spacingMd),
          // Totals
          ItemTotalsAndPrice(
            totalItems: totalItems,
            subtotal: subtotal,
            shipping: deliveryPrice,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStep() {
    return const SingleChildScrollView(
      child: Column(
        children: [
          PaymentSystem(),
          CardDetails(),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildAddressStep();
      case 1:
        return _buildDeliveryStep();
      case 2:
        return _buildReviewStep();
      case 3:
        return _buildPaymentStep();
      default:
        return const SizedBox.shrink();
    }
  }

  String _getDeliveryMethodLabel() {
    switch (_selectedDeliveryMethod) {
      case DeliveryMethod.standard:
        return 'Standard Delivery (2–4 days) - KES 150';
      case DeliveryMethod.express:
        return 'Express Delivery (Next day) - KES 350';
      case DeliveryMethod.bodaSameDay:
        return 'Boda Boda Same-Day (Today) - KES 200';
      case DeliveryMethod.storePickup:
        return 'Store Pickup (2–3 hours) - Free';
    }
  }

  double _getDeliveryPrice() {
    switch (_selectedDeliveryMethod) {
      case DeliveryMethod.standard:
        return 150;
      case DeliveryMethod.express:
        return 350;
      case DeliveryMethod.bodaSameDay:
        return 200;
      case DeliveryMethod.storePickup:
        return 0;
    }
  }

  String _getDeliveryAddressLabel() {
    switch (_selectedDeliveryMethod) {
      case DeliveryMethod.storePickup:
        return 'Store Pickup';
      default:
        return 'Office Address';
    }
  }

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
    if (_isSubmitting) return;

    final l10n = AppLocalizations.of(context)!;
    final authState = ref.read(authProvider);
    final cartState = ref.read(cartItemsProvider);

    final userId = authState.maybeWhen(data: (uid) => uid, orElse: () => null);
    if (userId == null || userId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to continue')),
      );
      return;
    }

    final cartItems = cartState.maybeWhen(
      data: (items) => items,
      orElse: () => <dynamic>[],
    );

    if (cartItems.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }

    final phoneNumber = FirebaseAuth.instance.currentUser?.phoneNumber;
    if (phoneNumber == null || !_kenyanPhoneRegExp.hasMatch(phoneNumber)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invalidPhoneNumber)),
      );
      return;
    }

    final totalAmount = cartItems.fold<double>(
          0,
          (sum, item) => sum + (item.priceAtTimeOfAdd * item.quantity),
        ) +
        _getDeliveryPrice();

    final confirmed = await _confirmPayment(totalAmount, phoneNumber);
    if (!confirmed || !mounted) return;

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
      shippingAddress: _getDeliveryAddressLabel(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() => _isSubmitting = true);

    try {
      await ref.read(ordersProvider.notifier).createOrder(order);

      if (!mounted) return;

      context.push('/mpesaProcessing', extra: {
        'amount': totalAmount,
        'phoneNumber': phoneNumber,
        'orderId': orderId,
      });
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
    final isFirstStep = _currentStep == 0;
    final isLastStep = _currentStep == 3;

    return Column(
      children: [
        _buildStepIndicator(),
        Expanded(child: _buildCurrentStep()),
        Padding(
          padding: const EdgeInsets.all(AppDefaults.padding),
          child: Row(
            children: [
              if (!isFirstStep)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _prevStep,
                    child: const Text('Back'),
                  ),
                ),
              if (!isFirstStep) const SizedBox(width: AppDefaults.padding),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLastStep
                      ? (_isSubmitting ? null : _onPayNow)
                      : _nextStep,
                  child: isLastStep && _isSubmitting
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(l10n.processingPayment),
                          ],
                        )
                      : Text(isLastStep ? l10n.payNow : 'Next'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// Inline delivery method selection (not a full-screen scaffold)
class DeliveryMethodInline extends StatelessWidget {
  final DeliveryMethod selectedMethod;
  final ValueChanged<DeliveryMethod> onMethodChanged;

  const DeliveryMethodInline({
    super.key,
    required this.selectedMethod,
    required this.onMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = getDeliveryOptions(context);

    return ListView.builder(
      padding: const EdgeInsets.all(AppDefaults.spacingMd),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = selectedMethod == option.method;
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return GestureDetector(
          onTap: () => onMethodChanged(option.method),
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppDefaults.spacingMd),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDarkMode
                        ? const Color(0xFF2C2C2E)
                        : const Color(0xFFF5F5F5))
                    : Theme.of(context).colorScheme.surface,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(AppDefaults.spacingMd),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        option.icon,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDefaults.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          option.description,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        option.price,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
