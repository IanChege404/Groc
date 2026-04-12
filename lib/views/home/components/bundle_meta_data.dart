import 'package:flutter/material.dart';

import '../../../core/models/bundle_model.dart';

class BundleMetaData extends StatelessWidget {
  const BundleMetaData({super.key, required this.bundle});

  final BundleModel bundle;

  String _formatCurrency(double value) => 'Ksh ${value.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itemCount = bundle.itemNames.length;
    final savings = (bundle.mainPrice - bundle.price).clamp(
      0.0,
      double.infinity,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text(
                '$itemCount',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text('Items', style: theme.textTheme.bodyLarge),
            ],
          ),
          Column(
            children: [
              Text(
                '${bundle.reviewCount}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text('Reviews', style: theme.textTheme.bodyLarge),
            ],
          ),
          Column(
            children: [
              Text(
                _formatCurrency(savings),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text('Save', style: theme.textTheme.bodyLarge),
            ],
          ),
        ],
      ),
    );
  }
}
