import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../../core/l10n/app_localizations.dart';
import '../components/categories_chip.dart';

class ProductFiltersDialog extends StatefulWidget {
  const ProductFiltersDialog({super.key});

  @override
  State<ProductFiltersDialog> createState() => _ProductFiltersDialogState();
}

class _ProductFiltersDialogState extends State<ProductFiltersDialog> {
  int _selectedRating = 4;
  String _selectedSort = 'Popularity';
  String? _selectedBrand;
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 3,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: AppDefaults.borderRadius,
              ),
              margin: const EdgeInsets.all(8),
            ),
            const _FilterHeader(),
            _SortBy(
              selectedValue: _selectedSort,
              onChanged: (value) {
                setState(() => _selectedSort = value ?? _selectedSort);
              },
            ),
            const _PriceRange(),
            _CategoriesSelector(
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) {
                setState(() {
                  _selectedCategory =
                      _selectedCategory == category ? null : category;
                });
              },
            ),
            _BrandSelector(
              selectedBrand: _selectedBrand,
              onBrandSelected: (brand) {
                setState(() {
                  _selectedBrand = _selectedBrand == brand ? null : brand;
                });
              },
            ),
            _RatingStar(
              totalStarsSelected: _selectedRating,
              onStarSelect: (v) {
                setState(() => _selectedRating = v);
              },
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(AppDefaults.padding),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'sort': _selectedSort,
                      'rating': _selectedRating,
                      'brand': _selectedBrand,
                      'category': _selectedCategory,
                    });
                  },
                  child: Text(l10n.applyFilters),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _RatingStar extends StatelessWidget {
  const _RatingStar({
    required this.totalStarsSelected,
    required this.onStarSelect,
  });

  final int totalStarsSelected;
  final void Function(int) onStarSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Semantics(
              label: l10n.ratingStar,
              child: Text(
                l10n.ratingStar,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Semantics(
            label: '${l10n.ratingStar}: $totalStarsSelected of 5',
            child: Row(
              children: List.generate(
                5,
                (index) {
                  final isSelected = index < totalStarsSelected;
                  return Semantics(
                    button: true,
                    selected: isSelected,
                    label: '${index + 1} star',
                    child: InkWell(
                      onTap: () => onStarSelect(index + 1),
                      child: Icon(
                        Icons.star_rounded,
                        color: isSelected
                            ? const Color(0xFFFFC107)
                            : AppColors.placeholder,
                        size: 32,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandSelector extends StatelessWidget {
  final String? selectedBrand;
  final ValueChanged<String> onBrandSelected;

  const _BrandSelector({
    required this.selectedBrand,
    required this.onBrandSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Semantics(
              label: l10n.brand,
              child: Text(
                l10n.brand,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            container: true,
            label: '${l10n.brand} filter',
            child: SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.start,
                spacing: 16,
                runSpacing: 16,
                children: [
                  CategoriesChip(
                    isActive: selectedBrand == null,
                    label: l10n.any,
                    onPressed: () => onBrandSelected(''),
                  ),
                  CategoriesChip(
                    isActive: selectedBrand == 'Square',
                    label: 'Square',
                    onPressed: () => onBrandSelected('Square'),
                  ),
                  CategoriesChip(
                    isActive: selectedBrand == 'Beximco Pharma',
                    label: 'Beximco Pharma',
                    onPressed: () => onBrandSelected('Beximco Pharma'),
                  ),
                  CategoriesChip(
                    isActive: selectedBrand == 'ACI Limited',
                    label: 'ACI Limited',
                    onPressed: () => onBrandSelected('ACI Limited'),
                  ),
                  CategoriesChip(
                    isActive: false,
                    label: l10n.seeAll,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoriesSelector extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const _CategoriesSelector({
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Semantics(
              label: l10n.categories,
              child: Text(
                l10n.categories,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            container: true,
            label: '${l10n.categories} filter',
            child: SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.start,
                runAlignment: WrapAlignment.spaceAround,
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 16,
                runSpacing: 16,
                children: [
                  CategoriesChip(
                    isActive: selectedCategory == l10n.officeSupplies,
                    label: l10n.officeSupplies,
                    onPressed: () => onCategorySelected(l10n.officeSupplies),
                  ),
                  CategoriesChip(
                    isActive: selectedCategory == l10n.gardening,
                    label: l10n.gardening,
                    onPressed: () => onCategorySelected(l10n.gardening),
                  ),
                  CategoriesChip(
                    isActive: selectedCategory == l10n.vegetables,
                    label: l10n.vegetables,
                    onPressed: () => onCategorySelected(l10n.vegetables),
                  ),
                  CategoriesChip(
                    isActive: selectedCategory == l10n.fishAndMeat,
                    label: l10n.fishAndMeat,
                    onPressed: () => onCategorySelected(l10n.fishAndMeat),
                  ),
                  CategoriesChip(
                    isActive: false,
                    label: l10n.seeAll,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRange extends StatefulWidget {
  const _PriceRange();

  @override
  State<_PriceRange> createState() => _PriceRangeState();
}

class _PriceRangeState extends State<_PriceRange> {
  RangeValues _currentRangeValues = const RangeValues(40, 80);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Semantics(
              label: l10n.priceRange,
              child: Text(
                l10n.priceRange,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ),
          ),
          Semantics(
            label:
                '${l10n.priceRange}: KES ${_currentRangeValues.start.round()} to KES ${_currentRangeValues.end.round()}',
            child: RangeSlider(
              max: 100,
              min: 0,
              labels: RangeLabels(
                _currentRangeValues.start.round().toString(),
                _currentRangeValues.end.round().toString(),
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _currentRangeValues = values;
                });
              },
              activeColor: AppColors.primary,
              inactiveColor: AppColors.gray,
              values: _currentRangeValues,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('\$0'), Text('\$50'), Text('\$100')],
            ),
          ),
        ],
      ),
    );
  }
}

class _SortBy extends StatelessWidget {
  final String selectedValue;
  final ValueChanged<String?> onChanged;

  const _SortBy({
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Row(
        children: [
          Semantics(
            label: l10n.sortBy,
            child: Text(
              l10n.sortBy,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
          const Spacer(),
          Semantics(
            label: '${l10n.sortBy}: $selectedValue',
            child: DropdownButton(
              value: selectedValue,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
              items: [
                DropdownMenuItem(
                    value: 'Popularity', child: Text(l10n.popularity)),
                DropdownMenuItem(value: 'Price', child: Text(l10n.price)),
              ],
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterHeader extends StatelessWidget {
  const _FilterHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 56,
          alignment: Alignment.centerLeft,
          child: SizedBox(
            height: 40,
            width: 40,
            child: Semantics(
              button: true,
              label: l10n.cancel,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: AppColors.scaffoldWithBoxBackground,
                ),
                child: const Icon(Icons.close, color: AppColors.primary),
              ),
            ),
          ),
        ),
        Text(
          l10n.filter,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        SizedBox(
          width: 56,
          child: Semantics(
            button: true,
            label: l10n.reset,
            child: TextButton(
              onPressed: () {
                Navigator.pop(context, 'reset');
              },
              child: Text(
                l10n.reset,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
