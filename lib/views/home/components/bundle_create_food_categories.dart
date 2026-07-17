import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/catalog_provider.dart';
import 'package:go_router/go_router.dart';

import 'app_chip.dart';

class FoodCategories extends ConsumerWidget {
  const FoodCategories({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppDefaults.padding),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Text(l10n.failedToLoadCategories),
      ),
      data: (categories) {
        if (categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return Semantics(
          container: true,
          label: l10n.categories,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
            child: Row(
              children: [
                ...categories.map(
                  (category) => Semantics(
                    button: true,
                    label: category.name,
                    child: AppChip(
                      isActive: false,
                      label: category.name,
                      onPressed: () {
                        context.push('/categoryDetails', extra: {
                          'categoryId': category.id,
                          'categoryName': category.name,
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
