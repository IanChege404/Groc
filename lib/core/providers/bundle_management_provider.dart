import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bundle_model.dart';
import '../services/bundle_service.dart';
import '../utils/logger.dart';

final bundleServiceProvider = Provider((ref) {
  return BundleService();
});

final bundleByIdProvider =
    FutureProvider.family<BundleModel?, String>((ref, bundleId) async {
  try {
    final service = ref.read(bundleServiceProvider);
    return await service.getBundleById(bundleId);
  } catch (e) {
    Logger.error('Error getting bundle: $e', 'bundleByIdProvider');
    return null;
  }
});

final allBundlesProvider = FutureProvider<List<BundleModel>>((ref) async {
  try {
    final service = ref.read(bundleServiceProvider);
    return await service.getAllBundles();
  } catch (e) {
    Logger.error('Error getting all bundles: $e', 'allBundlesProvider');
    return [];
  }
});

final searchBundlesProvider =
    FutureProvider.family<List<BundleModel>, String>((ref, searchTerm) async {
  try {
    if (searchTerm.isEmpty) return [];
    final service = ref.read(bundleServiceProvider);
    return await service.searchBundles(searchTerm);
  } catch (e) {
    Logger.error('Error searching bundles: $e', 'searchBundlesProvider');
    return [];
  }
});

final updateBundleDetailsProvider =
    FutureProvider.family<void, (String bundleId, Map<String, dynamic> updates)>(
        (ref, params) async {
  try {
    final (bundleId, updates) = params;
    final service = ref.read(bundleServiceProvider);

    await service.updateBundleDetails(
      bundleId: bundleId,
      name: updates['name'] as String?,
      description: updates['description'] as String?,
      image: updates['image'] as String?,
      images: updates['images'] as List<String>?,
      price: updates['price'] as double?,
      discountPrice: updates['discountPrice'] as double?,
    );

    // Refresh the bundle data
    ref.invalidate(bundleByIdProvider(bundleId));
    ref.invalidate(allBundlesProvider);

    Logger.info('Bundle updated: $bundleId', 'updateBundleDetailsProvider');
  } catch (e) {
    Logger.error('Error updating bundle: $e', 'updateBundleDetailsProvider');
    rethrow;
  }
});

final updateBundleItemsProvider = FutureProvider.family<
    void,
    (
      String bundleId,
      List<String> productIds,
      List<String> itemNames,
      double newPrice,
    )>((ref, params) async {
  try {
    final (bundleId, productIds, itemNames, newPrice) = params;
    final service = ref.read(bundleServiceProvider);

    await service.updateBundleItems(
      bundleId: bundleId,
      productIds: productIds,
      itemNames: itemNames,
      newPrice: newPrice,
    );

    // Refresh the bundle data
    ref.invalidate(bundleByIdProvider(bundleId));
    ref.invalidate(allBundlesProvider);

    Logger.info('Bundle items updated: $bundleId', 'updateBundleItemsProvider');
  } catch (e) {
    Logger.error('Error updating bundle items: $e', 'updateBundleItemsProvider');
    rethrow;
  }
});

final addProductToBundleProvider = FutureProvider.family<
    void,
    (
      String bundleId,
      String productId,
      String productName,
      double productPrice,
    )>((ref, params) async {
  try {
    final (bundleId, productId, productName, productPrice) = params;
    final service = ref.read(bundleServiceProvider);

    await service.addProductToBundle(
      bundleId,
      productId,
      productName,
      productPrice,
    );

    // Refresh the bundle data
    ref.invalidate(bundleByIdProvider(bundleId));
    ref.invalidate(allBundlesProvider);

    Logger.info('Product added to bundle: $bundleId', 'addProductToBundleProvider');
  } catch (e) {
    Logger.error(
      'Error adding product to bundle: $e',
      'addProductToBundleProvider',
    );
    rethrow;
  }
});

final removeProductFromBundleProvider = FutureProvider.family<
    void,
    (
      String bundleId,
      String productId,
      double productPrice,
    )>((ref, params) async {
  try {
    final (bundleId, productId, productPrice) = params;
    final service = ref.read(bundleServiceProvider);

    await service.removeProductFromBundle(
      bundleId,
      productId,
      productPrice,
    );

    // Refresh the bundle data
    ref.invalidate(bundleByIdProvider(bundleId));
    ref.invalidate(allBundlesProvider);

    Logger.info(
      'Product removed from bundle: $bundleId',
      'removeProductFromBundleProvider',
    );
  } catch (e) {
    Logger.error(
      'Error removing product from bundle: $e',
      'removeProductFromBundleProvider',
    );
    rethrow;
  }
});

final deleteBundleProvider = FutureProvider.family<void, String>((
  ref,
  bundleId,
) async {
  try {
    final service = ref.read(bundleServiceProvider);
    await service.deleteBundle(bundleId);

    // Refresh the bundle list
    ref.invalidate(allBundlesProvider);

    Logger.info('Bundle deleted: $bundleId', 'deleteBundleProvider');
  } catch (e) {
    Logger.error('Error deleting bundle: $e', 'deleteBundleProvider');
    rethrow;
  }
});
