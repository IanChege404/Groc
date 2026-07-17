import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/components/app_back_button.dart';
import '../../core/constants/constants.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Contact Us'),
      ),
      backgroundColor: AppColors.cardColor,
      body: Container(
        margin: const EdgeInsets.all(AppDefaults.padding),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDefaults.padding,
          vertical: AppDefaults.padding * 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.scaffoldBackground,
          borderRadius: AppDefaults.borderRadius,
        ),
        child: Column(
          children: [
            const SizedBox(height: AppDefaults.padding),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Contact Us',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            const SizedBox(height: AppDefaults.padding * 2),

            /// Number
            InkWell(
              onTap: () => launchUrl(Uri.parse('tel:+254700123456')),
              child: Row(
                children: [
                  SvgPicture.asset(AppIcons.contactPhone),
                  const SizedBox(width: AppDefaults.padding),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '+254 700 123 456',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: AppDefaults.padding / 2),
                      Text(
                        'Mon–Sat, 8:00 AM–8:00 PM (EAT)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDefaults.padding),
            InkWell(
              onTap: () =>
                  launchUrl(Uri.parse('mailto:support@progrocery.app')),
              child: Row(
                children: [
                  SvgPicture.asset(AppIcons.contactEmail),
                  const SizedBox(width: AppDefaults.padding),
                  Text(
                    'support@progrocery.app',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDefaults.padding),
            InkWell(
              onTap: () => launchUrl(
                Uri.parse(
                  'https://www.google.com/maps/search/?api=1&query=Westlands+Nairobi+Kenya',
                ),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(AppIcons.contactMap),
                  const SizedBox(width: AppDefaults.padding),
                  Expanded(
                    child: Text(
                      'Ring Road, Westlands\nNairobi, Kenya',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
