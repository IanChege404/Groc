import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/l10n/app_localizations.dart';

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

/// Returns the available delivery options for the current locale.
List<DeliveryOption> getDeliveryOptions(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  return [
    DeliveryOption(
      method: DeliveryMethod.standard,
      title: l10n.standardDelivery,
      description: l10n.standardDeliveryDesc,
      eta: l10n.standardDeliveryEta,
      price: 'KES 150',
      icon: Icons.local_shipping,
    ),
    DeliveryOption(
      method: DeliveryMethod.express,
      title: l10n.expressDelivery,
      description: l10n.expressDeliveryDesc,
      eta: l10n.expressDeliveryEta,
      price: 'KES 350',
      icon: Icons.speed,
    ),
    DeliveryOption(
      method: DeliveryMethod.bodaSameDay,
      title: l10n.bodaBodaSameDay,
      description: l10n.bodaBodaSameDayDesc,
      eta: l10n.bodaBodaSameDayEta,
      price: 'KES 200',
      icon: Icons.two_wheeler,
    ),
    DeliveryOption(
      method: DeliveryMethod.storePickup,
      title: l10n.storePickup,
      description: l10n.storePickupDesc,
      eta: l10n.storePickupEta,
      price: l10n.free,
      icon: Icons.store,
    ),
  ];
}

class _DeliveryMethodScreenState extends State<DeliveryMethodScreen> {
  late DeliveryMethod _selectedMethod;
  late List<DeliveryOption> _deliveryOptions;

  @override
  void initState() {
    super.initState();
    _selectedMethod = DeliveryMethod.standard;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _deliveryOptions = getDeliveryOptions(context);
  }

  void _continuePressed() {
    widget.onMethodSelected?.call(_selectedMethod);

    if (Navigator.canPop(context)) {
      Navigator.pop(context, _selectedMethod);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          l10n.deliveryMethod,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        leading: BackButton(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppDefaults.spacingMd),
                itemCount: _deliveryOptions.length,
                itemBuilder: (context, index) {
                  final option = _deliveryOptions[index];
                  final isSelected = _selectedMethod == option.method;

                  return Semantics(
                    label: '${option.title}, ${option.price}',
                    selected: isSelected,
                    child: GestureDetector(
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
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    option.icon,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 28,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppDefaults.spacingMd),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      option.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      option.description,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    option.price,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.outline,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDefaults.spacingMd),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _continuePressed,
                  child: Text(l10n.continueButton),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
