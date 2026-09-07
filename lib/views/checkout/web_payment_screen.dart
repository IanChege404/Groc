import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/components/app_back_button.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/services/paypal_service.dart';
import '../../core/services/stripe_service.dart';
import '../../core/utils/logger.dart';

enum WebPaymentProvider { stripe, paypal }

class WebPaymentScreen extends ConsumerStatefulWidget {
  final WebPaymentProvider provider;
  final double amount;
  final String orderId;

  const WebPaymentScreen({
    super.key,
    required this.provider,
    required this.amount,
    required this.orderId,
  });

  @override
  ConsumerState<WebPaymentScreen> createState() => _WebPaymentScreenState();
}

class _WebPaymentScreenState extends ConsumerState<WebPaymentScreen> {
  final _stripeService = StripeService();
  final _paypalService = PaypalService();

  bool _isProcessing = false;

  String get _title {
    return widget.provider == WebPaymentProvider.stripe ? 'Stripe' : 'PayPal';
  }

  Future<String?> _createCheckoutUrl() async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'customer@groc.app';

    if (widget.provider == WebPaymentProvider.stripe) {
      final response = await _stripeService.createCheckoutSession(
        orderId: widget.orderId,
        amount: widget.amount,
        currency: 'KES',
        customerEmail: email,
      );
      if (!response.isSuccess) {
        throw Exception(response.error ?? 'Stripe error');
      }
      return response.url;
    }

    final response = await _paypalService.createOrder(
      orderId: widget.orderId,
      amount: widget.amount,
      currency: 'KES',
      returnUrl: 'https://groc.app/payment/success?order_id=${widget.orderId}',
    );
    if (!response.isSuccess) {
      throw Exception(response.error ?? 'PayPal error');
    }
    return response.approveUrl;
  }

  Future<void> _processPayment() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final l10n = AppLocalizations.of(context)!;

    try {
      final url = await _createCheckoutUrl();
      if (!mounted || url == null || url.isEmpty) return;

      final uri = Uri.parse(url);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.paymentLaunchFailed)),
        );
        setState(() => _isProcessing = false);
        return;
      }

      await Future<void>.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      context.go('/orderSuccessfull', extra: {
        'orderId': widget.orderId,
        'totalAmount': 'KES ${widget.amount.toStringAsFixed(2)}',
      });
    } catch (e) {
      Logger.error('$_title payment error: $e', 'WebPaymentScreen');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.paymentInitiationFailed),
          action: SnackBarAction(label: l10n.retry, onPressed: _processPayment),
        ),
      );
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(_title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Icon(
              widget.provider == WebPaymentProvider.stripe
                  ? Icons.credit_card
                  : Icons.account_balance_wallet,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.payWith(widget.provider == WebPaymentProvider.stripe
                  ? 'Stripe'
                  : 'PayPal'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'KES ${widget.amount.toStringAsFixed(2)}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.secureHostedPaymentHint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isProcessing ? null : _processPayment,
              child: _isProcessing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 10),
                        Text(l10n.processingPaymentLabel),
                      ],
                    )
                  : Text(
                      l10n.payNowButton,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
