import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/constants/app_text_styles.dart';

/// Delivery Method Selection Screen
///
/// Allows user to choose between different delivery options:
/// - Standard Delivery (2-4 days)
/// - Express Delivery (Next day)
/// - Boda Boda Same-Day (Today)
/// - Store Pickup (Free)
class DeliveryMethodScreen extends StatefulWidget {
  final Function(DeliveryMethod)? onMethodSelected;

  const DeliveryMethodScreen({super.key, this.onMethodSelected});

  @override
  State<DeliveryMethodScreen> createState() => _DeliveryMethodScreenState();
}

enum DeliveryMethod { standard, express, bodaSameDay, storePickup }

class DeliveryOption {
  final DeliveryMethod method;
  final String title;
  final String description;
  final String eta;
  final String price;
  final IconData icon;

  DeliveryOption({
    required this.method,
    required this.title,
    required this.description,
    required this.eta,
    required this.price,
    required this.icon,
  });
}

class _DeliveryMethodScreenState extends State<DeliveryMethodScreen> {
  late DeliveryMethod _selectedMethod;
  late List<DeliveryOption> _deliveryOptions;

  @override
  void initState() {
    super.initState();
    _selectedMethod = DeliveryMethod.standard; // Default selection
    // Initialize options after build
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeDeliveryOptions(context);
  }

  void _initializeDeliveryOptions(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    
    _deliveryOptions = [
      DeliveryOption(
        method: DeliveryMethod.standard,
        title: isEnglish ? 'Standard Delivery' : 'Kuletwa Kawaida',
        description: isEnglish ? '2–4 business days' : 'Siku 2–4 za biashara',
        eta: isEnglish ? '2–4 days' : 'Siku 2-4',
        price: 'KES 150',
        icon: Icons.local_shipping,
      ),
      DeliveryOption(
        method: DeliveryMethod.express,
        title: isEnglish ? 'Express Delivery' : 'Kuletwa Haraka',
        description: isEnglish ? 'Delivered next day' : 'Kuletwa siku ijayo',
        eta: isEnglish ? 'Next day' : 'Siku ijayo',
        price: 'KES 350',
        icon: Icons.speed,
      ),
      DeliveryOption(
        method: DeliveryMethod.bodaSameDay,
        title: isEnglish ? 'Boda Boda Same-Day' : 'Sarakasi Siku Moja',
        description: isEnglish ? 'Today (Nairobi & Kampala only)' : 'Leo (Nairobi & Kampala tu)',
        eta: isEnglish ? 'Today' : 'Leo',
        price: 'KES 200',
        icon: Icons.two_wheeler,
      ),
      DeliveryOption(
        method: DeliveryMethod.storePickup,
        title: isEnglish ? 'Store Pickup' : 'Mkutano katika Duka',
        description: isEnglish ? 'Pick up at our store' : 'Chukua katika duka letu',
        eta: isEnglish ? '2–3 hours' : 'Saa 2-3',
        price: isEnglish ? 'FREE' : 'BURE',
        icon: Icons.store,
      ),
    ];
  }

  void _continuePressed() {
    widget.onMethodSelected?.call(_selectedMethod);
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final title = isEnglish ? 'Delivery Method' : 'Njia ya Kuletwa';
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        leading: BackButton(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Delivery Options List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppDefaults.spacingMd),
                itemCount: _deliveryOptions.length,
                itemBuilder: (context, index) {
                  final option = _deliveryOptions[index];
                  final isSelected = _selectedMethod == option.method;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMethod = option.method;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppDefaults.spacingMd,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDarkMode
                                    ? AppColors.surfaceVariantDark
                                    : AppColors.surfaceVariantLight)
                              : Theme.of(context).colorScheme.surface,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.all(AppDefaults.spacingMd),
                        child: Row(
                          children: [
                            // Icon
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  option.icon,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 28,
                                ),
                              ),
                            ),

                            const SizedBox(width: AppDefaults.spacingMd),

                            // Text Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.title,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    option.description,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),

                            // Price & Radio
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  option.price,
                                  style: AppTextStyles.price.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // ignore: deprecated_member_use
                                Radio<DeliveryMethod>(
                                  value: option.method,
                                  groupValue: _selectedMethod, // ignore: deprecated_member_use
                                  onChanged: (value) { // ignore: deprecated_member_use
                                    if (value != null) {
                                      setState(() {
                                        _selectedMethod = value;
                                      });
                                    }
                                  },
                                  activeColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Continue Button
            Padding(
              padding: const EdgeInsets.all(AppDefaults.spacingMd),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _continuePressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppDefaults.borderRadius,
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
