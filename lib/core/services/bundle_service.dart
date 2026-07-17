import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bundle_model.dart';
import '../utils/logger.dart';

class BundleService {
  final _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'bundles';

  /// Create a new bundle
  Future<String> createBundle(BundleModel bundle) async {
    try {
      final docRef = await _firestore
          .collection(_collectionName)
          .add(bundle.toFirestore());

      Logger.info(
        'Bundle created with ID: ${docRef.id}',
        'BundleService.createBundle',
      );

      return docRef.id;
    } catch (e, stack) {
      Logger.error(
        'Error creating bundle: $e\nStack: $stack',
        'BundleService.createBundle',
      );
      rethrow;
    }
  }

  /// Get bundle by ID
  Future<BundleModel?> getBundleById(String bundleId) async {
    try {
      final doc =
          await _firestore.collection(_collectionName).doc(bundleId).get();

      if (!doc.exists) {
        Logger.warning(
          'Bundle not found: $bundleId',
          'BundleService.getBundleById',
        );
        return null;
      }

      return BundleModel.fromFirestore(doc);
    } catch (e, stack) {
      Logger.error(
        'Error getting bundle: $e\nStack: $stack',
        'BundleService.getBundleById',
      );
      rethrow;
    }
  }

  /// Update bundle details (name, description, image, price)
  Future<void> updateBundleDetails({
    required String bundleId,
    String? name,
    String? description,
    String? image,
    List<String>? images,
    double? price,
    double? discountPrice,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': Timestamp.now(),
      };

      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (image != null) updates['image'] = image;
      if (images != null) updates['images'] = images;
      if (price != null) updates['price'] = price;
      if (discountPrice != null) updates['discountPrice'] = discountPrice;

      await _firestore
          .collection(_collectionName)
          .doc(bundleId)
          .update(updates);

      Logger.info(
        'Bundle details updated: $bundleId',
        'BundleService.updateBundleDetails',
      );
    } catch (e, stack) {
      Logger.error(
        'Error updating bundle details: $e\nStack: $stack',
        'BundleService.updateBundleDetails',
      );
      rethrow;
    }
  }

  /// Update bundle items (products in the bundle)
  Future<void> updateBundleItems({
    required String bundleId,
    required List<String> productIds,
    required List<String> itemNames,
    required double newPrice,
  }) async {
    try {
      await _firestore.collection(_collectionName).doc(bundleId).update({
        'productIds': productIds,
        'itemNames': itemNames,
        'price': newPrice,
        'updatedAt': Timestamp.now(),
      });

      Logger.info(
        'Bundle items updated: $bundleId - ${productIds.length} products',
        'BundleService.updateBundleItems',
      );
    } catch (e, stack) {
      Logger.error(
        'Error updating bundle items: $e\nStack: $stack',
        'BundleService.updateBundleItems',
      );
      rethrow;
    }
  }

  /// Add a product to an existing bundle
  Future<void> addProductToBundle(
    String bundleId,
    String productId,
    String productName,
    double productPrice,
  ) async {
    try {
      final bundle = await getBundleById(bundleId);
      if (bundle == null) throw Exception('Bundle not found');

      final updatedProductIds = [...bundle.productIds, productId];
      final updatedItemNames = [...bundle.itemNames, productName];
      final newPrice = bundle.price + productPrice;

      await updateBundleItems(
        bundleId: bundleId,
        productIds: updatedProductIds,
        itemNames: updatedItemNames,
        newPrice: newPrice,
      );

      Logger.info(
        'Product added to bundle: $bundleId',
        'BundleService.addProductToBundle',
      );
    } catch (e, stack) {
      Logger.error(
        'Error adding product to bundle: $e\nStack: $stack',
        'BundleService.addProductToBundle',
      );
      rethrow;
    }
  }

  /// Remove a product from bundle
  Future<void> removeProductFromBundle(
    String bundleId,
    String productId,
    double productPrice,
  ) async {
    try {
      final bundle = await getBundleById(bundleId);
      if (bundle == null) throw Exception('Bundle not found');

      final updatedProductIds =
          bundle.productIds.where((id) => id != productId).toList();
      final productIndex = bundle.productIds.indexOf(productId);
      final updatedItemNames = bundle.itemNames
          .asMap()
          .entries
          .where((e) => e.key != productIndex)
          .map((e) => e.value)
          .toList();

      final newPrice = (bundle.price - productPrice).clamp(0.0, double.infinity);

      if (updatedProductIds.isEmpty) {
        await deleteBundle(bundleId);
        return;
      }

      await updateBundleItems(
        bundleId: bundleId,
        productIds: updatedProductIds,
        itemNames: updatedItemNames,
        newPrice: newPrice,
      );

      Logger.info(
        'Product removed from bundle: $bundleId',
        'BundleService.removeProductFromBundle',
      );
    } catch (e, stack) {
      Logger.error(
        'Error removing product from bundle: $e\nStack: $stack',
        'BundleService.removeProductFromBundle',
      );
      rethrow;
    }
  }

  /// Update bundle rating and review count
  Future<void> updateBundleRating(
    String bundleId,
    double newRating,
    int newReviewCount,
  ) async {
    try {
      await _firestore.collection(_collectionName).doc(bundleId).update({
        'rating': newRating,
        'reviewCount': newReviewCount,
        'updatedAt': Timestamp.now(),
      });

      Logger.info(
        'Bundle rating updated: $bundleId - $newRating stars',
        'BundleService.updateBundleRating',
      );
    } catch (e, stack) {
      Logger.error(
        'Error updating bundle rating: $e\nStack: $stack',
        'BundleService.updateBundleRating',
      );
      rethrow;
    }
  }

  /// Delete bundle
  Future<void> deleteBundle(String bundleId) async {
    try {
      await _firestore.collection(_collectionName).doc(bundleId).delete();

      Logger.info(
        'Bundle deleted: $bundleId',
        'BundleService.deleteBundle',
      );
    } catch (e, stack) {
      Logger.error(
        'Error deleting bundle: $e\nStack: $stack',
        'BundleService.deleteBundle',
      );
      rethrow;
    }
  }

  /// Get all bundles (paginated)
  Future<List<BundleModel>> getAllBundles({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      var query = _firestore
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => BundleModel.fromFirestore(doc)).toList();
    } catch (e, stack) {
      Logger.error(
        'Error getting all bundles: $e\nStack: $stack',
        'BundleService.getAllBundles',
      );
      return [];
    }
  }

  /// Search bundles by name
  Future<List<BundleModel>> searchBundles(String searchTerm) async {
    try {
      final lowerSearchTerm = searchTerm.toLowerCase();
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('name', isGreaterThanOrEqualTo: searchTerm)
          .where('name', isLessThan: searchTerm + 'z')
          .get();

      return snapshot.docs.map((doc) => BundleModel.fromFirestore(doc)).toList();
    } catch (e, stack) {
      Logger.error(
        'Error searching bundles: $e\nStack: $stack',
        'BundleService.searchBundles',
      );
      return [];
    }
  }
}
