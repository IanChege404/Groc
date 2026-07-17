import 'package:flutter/material.dart';

import '../../core/components/app_back_button.dart';
import 'components/faq_item.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Terms And Condition'),
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            TitleAndParagraph(
                isTitleHeadline: false,
                title: 'Terms of Service\nLast revised: July 2026',
                paragraph:
                    '''Welcome to Pro Grocery. By creating an account or placing an order through our app, you agree to the terms below. Please read them carefully before using the service.'''),
            TitleAndParagraph(
                isTitleHeadline: false,
                title: '1. Agreement to Terms',
                paragraph:
                    '''These Terms govern your access to and use of the Pro Grocery mobile app. By registering an account, you confirm you are at least 18 years old and able to enter a binding agreement. If you do not agree with any part of these terms, please do not use the app.'''),
            TitleAndParagraph(
                isTitleHeadline: false,
                title: '2. Your Account',
                paragraph:
                    '''You are responsible for keeping your login credentials and M-Pesa/payment details secure. Notify us immediately if you suspect unauthorized access to your account. We may suspend accounts used for fraudulent orders, abuse of promotions, or violation of these Terms.'''),
            TitleAndParagraph(
                isTitleHeadline: false,
                title: '3. Orders & Pricing',
                paragraph:
                    '''Product prices, availability, and delivery fees are shown at checkout and may change without prior notice. We reserve the right to cancel an order if an item becomes unavailable after purchase, in which case you will receive a full refund to your Wallet or original payment method.'''),
            TitleAndParagraph(
                isTitleHeadline: false,
                title: '4. Payments',
                paragraph:
                    '''Payments made via M-Pesa or card are processed by Safaricom Daraja and Flutterwave respectively. Pro Grocery does not store your M-Pesa PIN or full card details. All transactions are subject to the terms of these third-party payment processors.'''),
            TitleAndParagraph(
                isTitleHeadline: false,
                title: '5. Delivery',
                paragraph:
                    '''Estimated delivery times are provided for guidance and are not guaranteed. Pro Grocery is not liable for delays caused by circumstances outside our control, including traffic, weather, or incorrect delivery information provided by the customer.'''),
            TitleAndParagraph(
                isTitleHeadline: false,
                title: '6. Limitation of Liability',
                paragraph:
                    '''Pro Grocery provides the app "as is." To the extent permitted by law, we are not liable for indirect or incidental damages arising from use of the app, beyond the value of the affected order.'''),
            TitleAndParagraph(
                isTitleHeadline: false,
                title: '7. Changes to These Terms',
                paragraph:
                    '''We may update these Terms from time to time. Continued use of the app after changes are published constitutes acceptance of the updated Terms. Material changes will be highlighted in-app.'''),
          ],
        ),
      ),
    );
  }
}
