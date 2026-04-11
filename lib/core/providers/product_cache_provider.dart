import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../services/firestore_product_service.dart';

/// Cache products by ID to avoid redundant API calls
/// This is used by wishlist tiles and cart tiles to fetch product details
final productByIdProvider = FutureProvider.family<ProductModel?, String>((
  ref,
  productId,
) async {
  final service = FirestoreProductService();
  final response = await service.getProductById(productId);

  if (response.success && response.data != null) {
    return response.data!;
  }

  return null;
});
