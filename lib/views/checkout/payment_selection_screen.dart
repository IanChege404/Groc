import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/components/app_back_button.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/constants/payment_constants.dart';
import '../../core/routes/app_routes.dart';

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
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Select Payment Method'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AmountSummary(amount: widget.amount),
            const SizedBox(height: 24),
            const Text(
              'Choose how to pay',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _PaymentOption(
              method: PaymentConstants.mpesa,
              title: 'M-Pesa',
              subtitle: 'Pay via Safaricom M-Pesa STK Push',
              icon: Icons.phone_android,
              iconColor: Colors.green,
              selected: _selected == PaymentConstants.mpesa,
              onTap: () =>
                  setState(() => _selected = PaymentConstants.mpesa),
            ),
            const SizedBox(height: 10),
            _PaymentOption(
              method: PaymentConstants.card,
              title: 'Card Payment',
              subtitle: 'Visa, Mastercard via Flutterwave',
              icon: Icons.credit_card,
              iconColor: Colors.blue,
              selected: _selected == PaymentConstants.card,
              onTap: () =>
                  setState(() => _selected = PaymentConstants.card),
            ),
            const SizedBox(height: 10),
            _PaymentOption(
              method: PaymentConstants.wallet,
              title: 'Wallet Balance',
              subtitle: 'Pay using your Groc wallet',
              icon: Icons.account_balance_wallet,
              iconColor: AppColors.primary,
              selected: _selected == PaymentConstants.wallet,
              onTap: () =>
                  setState(() => _selected = PaymentConstants.wallet),
            ),
            const SizedBox(height: 10),
            _PaymentOption(
              method: PaymentConstants.cashOnDelivery,
              title: 'Cash on Delivery',
              subtitle: 'Pay when your order arrives',
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

  void _proceed(BuildContext context) {
    switch (_selected) {
      case PaymentConstants.mpesa:
        Navigator.pushNamed(
          context,
          AppRoutes.mpesaProcessing,
          arguments: {
            'amount': widget.amount,
            'orderId': widget.orderId,
            'phoneNumber': '',
          },
        );
        break;
      case PaymentConstants.card:
        Navigator.pushNamed(
          context,
          AppRoutes.cardPayment,
          arguments: {
            'amount': widget.amount,
            'orderId': widget.orderId,
          },
        );
        break;
      default:
        Navigator.pushNamed(context, AppRoutes.orderSuccessfull);
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
          const Text('Total Amount', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            'KES ${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppDefaults.radius),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade200,
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
                      color: selected ? AppColors.primary : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Radio<bool>(
              value: true,
              groupValue: selected,
              onChanged: (_) => onTap(),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
