import '../models/product_model.dart';

enum SortOption { popularity, priceLowToHigh, priceHighToLow, newest, rating }

class ProductFilterState {
  final SortOption sortBy;
  final double priceMin;
  final double priceMax;
  final String? category;
  final String? brand;
  final double minRating;

  const ProductFilterState({
    this.sortBy = SortOption.popularity,
    this.priceMin = 0,
    this.priceMax = double.infinity,
    this.category,
    this.brand,
    this.minRating = 0,
  });

  ProductFilterState copyWith({
    SortOption? sortBy,
    double? priceMin,
    double? priceMax,
    String? category,
    String? brand,
    double? minRating,
    bool clearCategory = false,
    bool clearBrand = false,
  }) {
    return ProductFilterState(
      sortBy: sortBy ?? this.sortBy,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      category: clearCategory ? null : (category ?? this.category),
      brand: clearBrand ? null : (brand ?? this.brand),
      minRating: minRating ?? this.minRating,
    );
  }

  bool get isActive =>
      sortBy != SortOption.popularity ||
      priceMin > 0 ||
      priceMax < double.infinity ||
      category != null ||
      brand != null ||
      minRating > 0;

  List<ProductModel> apply(List<ProductModel> products) {
    var result = List<ProductModel>.from(products);

    // Filter by category
    if (category != null && category!.isNotEmpty) {
      result = result
          .where(
            (p) => p.category.toLowerCase() == category!.toLowerCase(),
          )
          .toList();
    }

    // Filter by price range
    result = result.where((p) => p.price >= priceMin && p.price <= priceMax).toList();

    // Filter by rating
    if (minRating > 0) {
      result = result.where((p) => p.rating >= minRating).toList();
    }

    // Sort
    switch (sortBy) {
      case SortOption.priceLowToHigh:
        result.sort((a, b) => a.price.compareTo(b.price));
      case SortOption.priceHighToLow:
        result.sort((a, b) => b.price.compareTo(a.price));
      case SortOption.newest:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case SortOption.rating:
        result.sort((a, b) => b.rating.compareTo(a.rating));
      case SortOption.popularity:
        result.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    }

    return result;
  }

  static const ProductFilterState defaultFilter = ProductFilterState();
}
