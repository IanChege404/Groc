import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/components/app_back_button.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/constants/payment_constants.dart';
import '../../core/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class PaymentSelectionScreen extends ConsumerStatefulWidget {
  final double amount;
  final String orderId;

  const PaymentSelectionScreen({
    super.key,
    required this.amount,
    required this.orderId,
  });

  @override
  ConsumerState<PaymentSelectionScreen> createState() =>
      _PaymentSelectionScreenState();
}

class _PaymentSelectionScreenState
    extends ConsumerState<PaymentSelectionScreen> {
  String _selected = PaymentConstants.mpesa;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(l10n.selectPaymentMethod),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AmountSummary(amount: widget.amount),
            const SizedBox(height: 24),
            Text(
              l10n.chooseHowToPay,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _PaymentOption(
              method: PaymentConstants.mpesa,
              title: 'M-Pesa',
              subtitle: l10n.payViaMpesaStkPush,
              icon: Icons.phone_android,
              iconColor: Colors.green,
              selected: _selected == PaymentConstants.mpesa,
              onTap: () => setState(() => _selected = PaymentConstants.mpesa),
            ),
            const SizedBox(height: 10),
            _PaymentOption(
              method: PaymentConstants.card,
              title: 'Card Payment',
              subtitle: l10n.visaMastercardViaFlutterwave,
              icon: Icons.credit_card,
              iconColor: Colors.blue,
              selected: _selected == PaymentConstants.card,
              onTap: () => setState(() => _selected = PaymentConstants.card),
            ),
            const SizedBox(height: 10),
            _PaymentOption(
              method: PaymentConstants.wallet,
              title: l10n.walletBalance,
              subtitle: l10n.payUsingYourWallet,
              icon: Icons.account_balance_wallet,
              iconColor: AppColors.primary,
              selected: _selected == PaymentConstants.wallet,
              onTap: () => setState(() => _selected = PaymentConstants.wallet),
            ),
            const SizedBox(height: 10),
            _PaymentOption(
              method: PaymentConstants.cashOnDelivery,
              title: l10n.cashOnDelivery,
              subtitle: l10n.cashOnDeliveryDesc,
              icon: Icons.local_shipping,
              iconColor: Colors.orange,
              selected: _selected == PaymentConstants.cashOnDelivery,
              onTap: () => setState(
                () => _selected = PaymentConstants.cashOnDelivery,
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => _proceed(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
              ),
              child: Text(
                'Continue with ${_methodLabel(_selected)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _methodLabel(String method) {
    switch (method) {
      case PaymentConstants.mpesa:
        return 'M-Pesa';
      case PaymentConstants.card:
        return 'Card';
      case PaymentConstants.wallet:
        return 'Wallet';
      case PaymentConstants.cashOnDelivery:
        return 'Cash on Delivery';
      default:
        return method;
    }
  }

  void _showPhoneEntryDialog() {
    final phoneController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phone Number Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please enter your phone number for M-Pesa payment'),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: '+254712345678',
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (phoneController.text.isNotEmpty) {
                Navigator.pop(context);
                // Retry payment with entered phone number
                _proceedWithPhone(phoneController.text);
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _proceedWithPhone(String phoneNumber) async {
    if (!mounted) return;
    context.push('/mpesaProcessing', extra: {
      'amount': widget.amount,
      'orderId': widget.orderId,
      'phoneNumber': phoneNumber,
    });
  }

  void _proceed(BuildContext context) async {
    switch (_selected) {
      case PaymentConstants.mpesa:
        // Fetch phone number from Firebase auth or user profile
        final user = FirebaseAuth.instance.currentUser;
        final phoneNumber = user?.phoneNumber ?? '';

        if (phoneNumber.isEmpty) {
          // Show dialog to request phone number
          if (!mounted) return;
          _showPhoneEntryDialog();
          return;
        }

        if (!mounted) return;
        context.push('/mpesaProcessing', extra: {
          'amount': widget.amount,
          'orderId': widget.orderId,
          'phoneNumber': phoneNumber,
        });
        break;
      case PaymentConstants.card:
        context.push('/cardPayment', extra: {
          'amount': widget.amount,
          'orderId': widget.orderId,
        });
        break;
      default:
        context.push('/orderSuccessfull');
    }
  }
}

class _AmountSummary extends StatelessWidget {
  final double amount;

  const _AmountSummary({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDefaults.radius),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.totalAmountLabel,
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
          const SizedBox(height: 4),
          Text(
            'KES ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String method;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.method,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title - $subtitle',
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.06)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppDefaults.radius),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : Theme.of(context).colorScheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? AppColors.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected
                    ? AppColors.primary
                    : Theme.of(context).colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
