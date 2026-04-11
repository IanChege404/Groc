import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bundle_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../services/firestore_product_service.dart';

final firestoreProductServiceProvider = Provider<FirestoreProductService>((
  ref,
) {
  return FirestoreProductService();
});

final allProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final service = ref.watch(firestoreProductServiceProvider);
  final response = await service.getProducts(page: 1, pageSize: 40);
  if (!response.success) {
    throw Exception(response.message ?? 'Failed to fetch products');
  }
  return response.data ?? [];
});

final newProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final service = ref.watch(firestoreProductServiceProvider);
  final response = await service.getNewProducts(limit: 8);
  if (!response.success) {
    throw Exception(response.message ?? 'Failed to fetch new products');
  }
  return response.data ?? [];
});

final featuredBundlesProvider = FutureProvider<List<BundleModel>>((ref) async {
  final service = ref.watch(firestoreProductServiceProvider);
  final response = await service.getFeaturedBundles(limit: 8);
  if (!response.success) {
    throw Exception(response.message ?? 'Failed to fetch featured bundles');
  }
  return response.data ?? [];
});

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final service = ref.watch(firestoreProductServiceProvider);
  final response = await service.getCategories();
  if (!response.success) {
    throw Exception(response.message ?? 'Failed to fetch categories');
  }
  return response.data ?? [];
});

final productsByCategoryProvider =
    FutureProvider.family<List<ProductModel>, String>((ref, categoryId) async {
      final service = ref.watch(firestoreProductServiceProvider);
      final response = await service.getProductsByCategory(categoryId);
      if (!response.success) {
        throw Exception(
          response.message ?? 'Failed to fetch category products',
        );
      }
      return response.data ?? [];
    });

final searchProductsProvider =
    FutureProvider.family<List<ProductModel>, String>((ref, query) async {
      final service = ref.watch(firestoreProductServiceProvider);
      final response = await service.searchProducts(query);
      if (!response.success) {
        throw Exception(response.message ?? 'Failed to search products');
      }
      return response.data ?? [];
    });
