import 'package:flutter/material.dart';

import '../../core/components/app_back_button.dart';
import 'components/faq_item.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Privacy Policy'),
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            TitleAndParagraph(
              isTitleHeadline: false,
              title: 'Last updated: July 2026',
              paragraph:
                  '''Pro Grocery ("we", "our", "us") respects your privacy. This policy explains what information we collect through the app, why we collect it, and the choices you have.''',
            ),
            TitleAndParagraph(
              isTitleHeadline: false,
              title: '1. Information We Collect',
              paragraph:
                  '''Account details you provide (name, phone number, email, delivery address); order history and payment method selection (M-Pesa, card, or wallet); device and usage data (app version, crash logs, approximate location for delivery); and push-notification tokens used to send order updates.''',
            ),
            TitleAndParagraph(
              isTitleHeadline: false,
              title: '2. How We Use Your Information',
              paragraph:
                  '''To process and deliver your orders, confirm M-Pesa/Flutterwave payments, send order status notifications, provide customer support, personalize product recommendations, and improve app performance and reliability.''',
            ),
            TitleAndParagraph(
              isTitleHeadline: false,
              title: '3. Payment Information',
              paragraph:
                  '''We do not store your M-Pesa PIN or full card numbers. Payments are processed through Safaricom Daraja and Flutterwave, which handle sensitive payment data under their own security standards. We only retain transaction references needed to confirm your order.''',
            ),
            TitleAndParagraph(
              isTitleHeadline: false,
              title: '4. Data Sharing',
              paragraph:
                  '''We share only what is necessary with delivery partners (your name, phone number, and delivery address) and payment processors (transaction amount and reference). We do not sell your personal information to third parties.''',
            ),
            TitleAndParagraph(
              isTitleHeadline: false,
              title: '5. Data Storage & Security',
              paragraph:
                  '''Your data is stored securely in Firebase (Firestore) with role-based access rules. Frequently accessed data such as your cart and recent orders may be cached on your device for offline use and is cleared when you log out.''',
            ),
            TitleAndParagraph(
              isTitleHeadline: false,
              title: '6. Your Choices',
              paragraph:
                  '''You can review and update your profile information at any time from Settings, manage notification preferences, request deletion of your account and associated data, and control location permissions from your device settings.''',
            ),
            TitleAndParagraph(
              isTitleHeadline: false,
              title: '7. Contact Us',
              paragraph:
                  '''If you have questions about this Privacy Policy or how your data is handled, reach us via the Contact Us page in the app menu.''',
            ),
          ],
        ),
      ),
    );
  }
}
