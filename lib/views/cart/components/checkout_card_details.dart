import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../../core/l10n/app_localizations.dart';

class CardDetails extends StatefulWidget {
  const CardDetails({super.key});

  @override
  State<CardDetails> createState() => _CardDetailsState();
}

class _CardDetailsState extends State<CardDetails> {
  late TextEditingController cardNameController;
  late TextEditingController cardNumberController;
  late TextEditingController expirationDateController;
  late TextEditingController cvvController;

  @override
  void initState() {
    super.initState();
    cardNameController = TextEditingController();
    cardNumberController = TextEditingController();
    expirationDateController = TextEditingController();
    cvvController = TextEditingController();
  }

  @override
  void dispose() {
    cardNameController.dispose();
    cardNumberController.dispose();
    expirationDateController.dispose();
    cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name Field
          TextFormField(
            controller: cardNameController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(labelText: l10n.cardName),
            // validator: Validators.requiredWithFieldName('Card'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppDefaults.padding),

          // Number Field
          TextFormField(
            controller: cardNumberController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.cardNumber),
            // validator: Validators.requiredWithFieldName('Card Number'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppDefaults.padding),

          /* <---- Expiration Date And CVV -----> */
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: expirationDateController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.expirationDate),
                  // validator: Validators.requiredWithFieldName('Card'),
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: cvvController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.cvv),
                  // validator: Validators.requiredWithFieldName('Card'),
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDefaults.padding),

          Row(
            children: [
              Text(
                l10n.rememberCardDetails,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const Spacer(),
              Semantics(
                label: l10n.rememberCardDetails,
                toggled: true,
                child: CupertinoSwitch(value: true, onChanged: (v) {}),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
