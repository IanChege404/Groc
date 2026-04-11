import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../core/providers/catalog_provider.dart';
import '../../../core/routes/app_routes.dart';
import 'app_chip.dart';

class FoodCategories extends ConsumerWidget {
  const FoodCategories({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppDefaults.padding),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Text('Failed to load categories: $error'),
      ),
      data: (categories) {
        if (categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
          child: Row(
            children: [
              ...categories.map(
                (category) => AppChip(
                  isActive: false,
                  label: category.name,
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.categoryDetails,
                      arguments: {
                        'categoryId': category.id,
                        'categoryName': category.name,
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
