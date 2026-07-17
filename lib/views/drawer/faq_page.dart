import 'package:flutter/material.dart';

import '../../core/components/app_back_button.dart';
import 'components/faq_item.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('FAQ'),
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            TitleAndParagraph(
                title: '1. How long does delivery take?',
                paragraph:
                    '''Most orders arrive within 45–90 minutes in supported delivery zones. During peak hours or bad weather, delivery may take a little longer — you can track your rider's progress in real time from the Order Tracking screen.'''),
            TitleAndParagraph(
                title: '2. What payment methods are supported?',
                paragraph:
                    '''We support M-Pesa (via Safaricom Daraja), Flutterwave for card payments, and Pro Grocery Wallet. You can save a preferred payment method in Settings for faster checkout next time.'''),
            TitleAndParagraph(
                title: '3. What is the refund policy?',
                paragraph:
                    '''If an item arrives damaged, missing, or incorrect, open the order from My Orders and select "Report an Issue" within 24 hours of delivery. Approved refunds are credited to your Pro Grocery Wallet instantly, or reversed to your original payment method within 3–5 business days.'''),
            TitleAndParagraph(
                title: '4. Can I cancel or edit an order after placing it?',
                paragraph:
                    '''Orders can be cancelled or edited free of charge before a rider is assigned. Once your order is being prepared or is out for delivery, cancellation may no longer be possible — contact Help Center for assistance.'''),
            TitleAndParagraph(
                title: '5. Do you deliver outside city centers?',
                paragraph:
                    '''Delivery zones are expanding regularly. Enter your address at checkout to see instantly whether your location is covered — we'll notify you when we launch in new areas.'''),
          ],
        ),
      ),
    );
  }
}
