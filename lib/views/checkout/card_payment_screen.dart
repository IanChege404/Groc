import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import '../../core/components/app_back_button.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/services/flutterwave_service.dart';
import '../../core/utils/logger.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CardPaymentScreen extends ConsumerStatefulWidget {
  final double amount;
  final String orderId;

  const CardPaymentScreen({
    super.key,
    required this.amount,
    required this.orderId,
  });

  @override
  ConsumerState<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends ConsumerState<CardPaymentScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _flutterwaveService = FlutterwaveService();

  String _cardNumber = '';
  String _expiryDate = '';
  String _cardHolderName = '';
  String _cvvCode = '';
  bool _isCvvFocused = false;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(l10n.cardPayment),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CreditCardWidget(
              cardNumber: _cardNumber,
              expiryDate: _expiryDate,
              cardHolderName: _cardHolderName,
              cvvCode: _cvvCode,
              showBackView: _isCvvFocused,
              onCreditCardWidgetChange: (_) {},
              customCardTypeIcons: const [],
            ),
            Padding(
              padding: const EdgeInsets.all(AppDefaults.padding),
              child: Column(
                children: [
                  CreditCardForm(
                    formKey: _formKey,
                    cardNumber: _cardNumber,
                    expiryDate: _expiryDate,
                    cardHolderName: _cardHolderName,
                    cvvCode: _cvvCode,
                    onCreditCardModelChange: (model) {
                      setState(() {
                        _cardNumber = model.cardNumber;
                        _expiryDate = model.expiryDate;
                        _cardHolderName = model.cardHolderName;
                        _cvvCode = model.cvvCode;
                        _isCvvFocused = model.isCvvFocused;
                      });
                    },
                    obscureCvv: true,
                    obscureNumber: false,
                    isHolderNameVisible: true,
                    isCardNumberVisible: true,
                    isExpiryDateVisible: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    inputConfiguration: const InputConfiguration(
                      cardNumberDecoration: InputDecoration(
                        labelText: 'Card Number',
                        hintText: 'XXXX XXXX XXXX XXXX',
                      ),
                      expiryDateDecoration: InputDecoration(
                        labelText: 'Expiry Date',
                        hintText: 'XX/XX',
                      ),
                      cvvCodeDecoration: InputDecoration(
                        labelText: 'CVV',
                        hintText: 'XXX',
                      ),
                      cardHolderDecoration: InputDecoration(
                        labelText: 'Card Holder Name',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Amount summary
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppDefaults.radius),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.totalToPay),
                        Text(
                          'KES ${widget.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isProcessing ? null : _processPayment,
                    child: _isProcessing
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
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
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock,
                          size: 14,
                          color: Theme.of(context).colorScheme.outline),
                      const SizedBox(width: 4),
                      Text(
                        l10n.securedByFlutterwave,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final l10n = AppLocalizations.of(context)!;
    setState(() => _isProcessing = true);

    try {
      final txRef =
          'groc_${widget.orderId}_${DateTime.now().millisecondsSinceEpoch}';

      final response = await _flutterwaveService.initiatePayment(
        txRef: txRef,
        amount: widget.amount,
        currency: 'KES',
        redirectUrl: 'https://groc.app/payment/callback',
        customerEmail:
            FirebaseAuth.instance.currentUser?.email ?? 'customer@groc.app',
        customerName: _cardHolderName,
        paymentTitle: 'Groc Order Payment',
        paymentDescription: 'Order #${widget.orderId}',
      );

      if (!mounted) return;

      if (response.isSuccessful && response.paymentLink != null) {
        final uri = Uri.parse(response.paymentLink!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        if (!mounted) return;
        context.go('/orderSuccessfull', extra: {
          'orderId': widget.orderId,
          'totalAmount': 'KES ${widget.amount.toStringAsFixed(2)}',
        });
      } else {
        context.go('/orderFailed');
      }
    } catch (e) {
      Logger.error('Card payment error: $e', 'CardPaymentScreen');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.paymentFailedError(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}
