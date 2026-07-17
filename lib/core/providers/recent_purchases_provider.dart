import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';
import '../utils/logger.dart';

final recentPurchasesProvider =
    FutureProvider.family<int, String>((ref, productId) async {
  try {
    final firestore = FirebaseFirestore.instance;
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    final snapshot = await firestore
        .collection('orders')
        .where('createdAt', isGreaterThanOrEqualTo: thirtyDaysAgo)
        .get();

    int purchaseCount = 0;
    for (final doc in snapshot.docs) {
      final items = doc['items'] as List<dynamic>? ?? [];
      final hasProduct = items.any((item) {
        final itemData = item as Map<String, dynamic>;
        return itemData['productId'] == productId ||
            itemData['itemId'] == productId;
      });
      if (hasProduct) purchaseCount++;
    }

    Logger.info(
      'Loaded recent purchases for product $productId: $purchaseCount',
      'recentPurchasesProvider',
    );

    return purchaseCount;
  } catch (e, stack) {
    Logger.error(
      'Error loading recent purchases: $e\nStack: $stack',
      'recentPurchasesProvider',
    );
    return 0;
  }
});

final topProductsByPurchasesProvider = FutureProvider<List<String>>((ref) async {
  try {
    final firestore = FirebaseFirestore.instance;
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    final snapshot = await firestore
        .collection('orders')
        .where('createdAt', isGreaterThanOrEqualTo: thirtyDaysAgo)
        .get();

    final purchaseMap = <String, int>{};
    for (final doc in snapshot.docs) {
      final items = doc['items'] as List<dynamic>? ?? [];
      for (final item in items) {
        final itemData = item as Map<String, dynamic>;
        final productId = itemData['productId'] ?? itemData['itemId'] ?? '';
        if (productId.isNotEmpty) {
          purchaseMap[productId] = (purchaseMap[productId] ?? 0) + 1;
        }
      }
    }

    final topProducts = purchaseMap.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));

    final topProductIds =
        topProducts.take(10).map((e) => e.key).toList();

    Logger.info(
      'Loaded top products by purchases: ${topProductIds.length} products',
      'topProductsByPurchasesProvider',
    );

    return topProductIds;
  } catch (e, stack) {
    Logger.error(
      'Error loading top products: $e\nStack: $stack',
      'topProductsByPurchasesProvider',
    );
    return [];
  }
});
