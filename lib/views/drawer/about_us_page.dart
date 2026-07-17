import 'package:flutter/material.dart';

import '../../core/components/app_back_button.dart';
import '../../core/constants/app_defaults.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('About Us'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Us',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppDefaults.padding),
            const Text(
                '''Pro Grocery is a mobile grocery marketplace built for African shoppers. We connect you with fresh produce, pantry staples, and household essentials from trusted local vendors, delivered straight to your door.\n\nWe started Pro Grocery to solve a simple problem: grocery shopping in busy African cities takes too much time and trust in delivery is low. So we built an app that supports the payment methods people already use — M-Pesa, mobile money, and cards — with real-time order tracking and a catalog that reflects local prices and products.\n\nToday, Pro Grocery serves customers across Kenya and neighbouring markets, with full support for English and Swahili, offline browsing when your connection drops, and a design built to work well on any phone, from entry-level to high-end.\n\nOur mission is to make everyday grocery shopping faster, more affordable, and more reliable for every household we serve.''')
          ],
        ),
      ),
    );
  }
}
