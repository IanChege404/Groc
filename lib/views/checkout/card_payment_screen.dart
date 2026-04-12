import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import '../../core/components/app_back_button.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/flutterwave_service.dart';
import '../../core/utils/logger.dart';

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
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Card Payment'),
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
                      color: Colors.grey.shade50,
                      borderRadius:
                          BorderRadius.circular(AppDefaults.radius),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total to pay:'),
                        Text(
                          'KES ${widget.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isProcessing ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                    ),
                    child: _isProcessing
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text('Processing...'),
                            ],
                          )
                        : const Text(
                            'Pay Now',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        'Secured by Flutterwave',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
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

    setState(() => _isProcessing = true);

    try {
      final txRef = 'groc_${widget.orderId}_${DateTime.now().millisecondsSinceEpoch}';

      final response = await _flutterwaveService.initiatePayment(
        txRef: txRef,
        amount: widget.amount,
        currency: 'KES',
        redirectUrl: 'https://groc.app/payment/callback',
        customerEmail: 'customer@groc.app',
        customerName: _cardHolderName,
        paymentTitle: 'Groc Order Payment',
        paymentDescription: 'Order #${widget.orderId}',
      );

      if (!mounted) return;

      if (response.isSuccessful) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.orderSuccessfull,
          (route) => route.settings.name == AppRoutes.entryPoint,
        );
      } else {
        Navigator.pushNamed(context, AppRoutes.orderFailed);
      }
    } catch (e) {
      Logger.error('Card payment error: $e', 'CardPaymentScreen');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}
