import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

class PaymentDefaultCard extends StatelessWidget {
  const PaymentDefaultCard({
    super.key,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardHolderName,
    this.last4,
  });

  final String cardNumber;
  final String expiryDate;
  final String cardHolderName;
  final String? last4;

  @override
  Widget build(BuildContext context) {
    return CreditCardWidget(
      cardNumber: cardNumber,
      expiryDate: expiryDate,
      cardHolderName: cardHolderName,
      isHolderNameVisible: true,
      backgroundNetworkImage: 'https://i.imgur.com/uUDkwQx.png',
      cvvCode: '',
      showBackView: false,
      cardType: CardType.visa,
      onCreditCardWidgetChange: (v) {},
      isChipVisible: false,
    );
  }
}
