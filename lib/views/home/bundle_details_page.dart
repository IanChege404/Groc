import 'package:flutter/material.dart';

import '../../core/components/app_back_button.dart';
import '../../core/l10n/app_localizations.dart';

class BundleDetailsPage extends StatelessWidget {
  const BundleDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(l10n.bundleDetails),
      ),
    );
  }
}
