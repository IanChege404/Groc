import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bundle_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../network/api_client.dart';

class FirestoreProductService {
  static final FirestoreProductService _instance =
      FirestoreProductService._internal();

  factory FirestoreProductService() {
    return _instance;
  }

  FirestoreProductService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all products with pagination
  Future<ApiResponse<List<ProductModel>>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? category,
    String? search,
  }) async {
    try {
      Query query = _firestore.collection('products');

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      if (search != null && search.isNotEmpty) {
        query = query
            .where('name', isGreaterThanOrEqualTo: search)
            .where('name', isLessThan: '${search}z');
      }

      final snapshot = await query
          .limit((page - 1) * pageSize + pageSize)
          .get();

      final products = snapshot.docs
          .skip((page - 1) * pageSize)
          .take(pageSize)
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();

      return ApiResponse.success(data: products);
    } catch (e) {
      return ApiResponse.error('Failed to fetch products: $e');
    }
  }

  /// Get product by ID
  Future<ApiResponse<ProductModel>> getProductById(String id) async {
    try {
      final doc = await _firestore.collection('products').doc(id).get();

      if (!doc.exists) {
        return ApiResponse.error('Product not found');
      }

      final product = ProductModel.fromFirestore(doc);
      return ApiResponse.success(data: product);
    } catch (e) {
      return ApiResponse.error('Failed to fetch product: $e');
    }
  }

  /// Get new products (for Home screen)
  Future<ApiResponse<List<ProductModel>>> getNewProducts({
    int limit = 10,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final products = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();

      return ApiResponse.success(data: products);
    } catch (e) {
      return ApiResponse.error('Failed to fetch new products: $e');
    }
  }

  /// Get popular/trending products (for Home screen)
  Future<ApiResponse<List<ProductModel>>> getPopularProducts({
    int limit = 10,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      final products = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();

      return ApiResponse.success(data: products);
    } catch (e) {
      return ApiResponse.error('Failed to fetch popular products: $e');
    }
  }

  /// Search products by name
  Future<ApiResponse<List<ProductModel>>> searchProducts(String query) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .limit(20)
          .get();

      final products = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();

      return ApiResponse.success(data: products);
    } catch (e) {
      return ApiResponse.error('Failed to search products: $e');
    }
  }

  /// Get all categories
  Future<ApiResponse<List<CategoryModel>>> getCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();

      final categories = snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();

      return ApiResponse.success(data: categories);
    } catch (e) {
      return ApiResponse.error('Failed to fetch categories: $e');
    }
  }

  /// Get products by category
  Future<ApiResponse<List<ProductModel>>> getProductsByCategory(
    String categoryName,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: categoryName)
          .get();

      final products = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();

      return ApiResponse.success(data: products);
    } catch (e) {
      return ApiResponse.error('Failed to fetch category products: $e');
    }
  }

  /// Get all bundles
  Future<ApiResponse<List<BundleModel>>> getBundles() async {
    try {
      final snapshot = await _firestore.collection('bundles').get();

      final bundles = snapshot.docs
          .map((doc) => BundleModel.fromFirestore(doc))
          .toList();

      return ApiResponse.success(data: bundles);
    } catch (e) {
      return ApiResponse.error('Failed to fetch bundles: $e');
    }
  }

  /// Get featured bundles (popular packs)
  Future<ApiResponse<List<BundleModel>>> getFeaturedBundles({
    int limit = 10,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('bundles')
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      final bundles = snapshot.docs
          .map((doc) => BundleModel.fromFirestore(doc))
          .toList();

      return ApiResponse.success(data: bundles);
    } catch (e) {
      return ApiResponse.error('Failed to fetch featured bundles: $e');
    }
  }

  /// Add product to wishlist
  Future<ApiResponse<void>> addToWishlist(
    String userId,
    String productId,
  ) async {
    try {
      await _firestore.collection('wishlist').doc('${userId}_$productId').set({
        'userId': userId,
        'productId': productId,
        'addedAt': FieldValue.serverTimestamp(),
      });
      return ApiResponse.success(data: null);
    } catch (e) {
      return ApiResponse.error('Failed to add to wishlist: $e');
    }
  }

  /// Remove product from wishlist
  Future<ApiResponse<void>> removeFromWishlist(
    String userId,
    String productId,
  ) async {
    try {
      await _firestore
          .collection('wishlist')
          .doc('${userId}_$productId')
          .delete();
      return ApiResponse.success(data: null);
    } catch (e) {
      return ApiResponse.error('Failed to remove from wishlist: $e');
    }
  }

  /// Get user wishlist
  Future<ApiResponse<List<String>>> getWishlist(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('wishlist')
          .where('userId', isEqualTo: userId)
          .get();

      final wishlistProductIds = snapshot.docs
          .map((doc) => doc['productId'] as String)
          .toList();

      return ApiResponse.success(data: wishlistProductIds);
    } catch (e) {
      return ApiResponse.error('Failed to fetch wishlist: $e');
    }
  }

  /// Check if product is in user's wishlist
  Future<bool> isProductInWishlist(String userId, String productId) async {
    try {
      final doc = await _firestore
          .collection('wishlist')
          .doc('${userId}_$productId')
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }
}
