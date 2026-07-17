import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/models/bundle_model.dart';

class PackDetails extends StatelessWidget {
  const PackDetails({super.key, required this.bundle});

  final BundleModel bundle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.12),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.packDetails,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          ...bundle.itemNames.asMap().entries.map(
                (entry) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.12,
                    ),
                    child: Text(
                      '${entry.key + 1}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  title: Text(entry.value),
                  subtitle: Text(l10n.includedInThisBundle),
                  trailing: Text(
                    bundle.productIds.length > entry.key
                        ? l10n.itemCount(entry.key + 1)
                        : '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
          const SizedBox(height: AppDefaults.padding),
        ],
      ),
    );
  }
}
