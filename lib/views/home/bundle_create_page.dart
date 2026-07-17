import 'package:flutter/material.dart';

import '../../core/components/app_back_button.dart';
import '../../core/constants/constants.dart';
import '../../core/l10n/app_localizations.dart';
import 'components/bundle_create_bottom_action_bar.dart';
import 'components/bundle_create_food_categories.dart';
import 'components/product_grid_view.dart';

class BundleCreatePage extends StatelessWidget {
  const BundleCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(l10n.createMyBundle),
      ),
      body: const Column(
        children: [
          FoodCategories(),
          SizedBox(height: AppDefaults.padding / 2),
          ProductGridView(),
          BottomActionBar(),
        ],
      ),
    );
  }
}
