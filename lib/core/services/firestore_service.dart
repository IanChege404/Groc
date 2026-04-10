import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../utils/logger.dart';

/// Firestore database service singleton
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  late FirebaseFirestore _firestore;

  factory FirestoreService() {
    return _instance;
  }

  FirestoreService._internal() {
    _firestore = FirebaseFirestore.instance;
  }

  // PRODUCTS
  Future<List<Map<String, dynamic>>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? category,
    String? search,
  }) async {
    try {
      Query query = _firestore.collection('products');
      if (category != null && category.isNotEmpty) {
        query = query.where('categoryId', isEqualTo: category);
      }
      QuerySnapshot snapshot = await query
          .orderBy('createdAt', descending: true)
          .limit(pageSize * page)
          .get();

      List<Map<String, dynamic>> products = snapshot.docs
          .map(
            (doc) => <String, dynamic>{
              ...(doc.data() as Map<String, dynamic>? ?? {}),
              'id': doc.id,
            },
          )
          .toList();

      if (search != null && search.isNotEmpty) {
        final searchLower = search.toLowerCase();
        products = products
            .where(
              (p) =>
                  ((p['name'] as String?)?.toLowerCase().contains(
                        searchLower,
                      ) ??
                      false) ||
                  ((p['description'] as String?)?.toLowerCase().contains(
                        searchLower,
                      ) ??
                      false),
            )
            .toList();
      }

      final startIndex = (page - 1) * pageSize;
      final endIndex = startIndex + pageSize;
      return products.sublist(startIndex, endIndex.clamp(0, products.length));
    } catch (e) {
      Logger.error(
        'Error fetching products: $e',
        'FirestoreService.getProducts',
      );
      return [];
    }
  }

  Future<Map<String, dynamic>?> getProductById(String id) async {
    try {
      final doc = await _firestore.collection('products').doc(id).get();
      if (doc.exists) {
        return <String, dynamic>{
          ...(doc.data() as Map<String, dynamic>? ?? {}),
          'id': doc.id,
        };
      }
      return null;
    } catch (e) {
      Logger.error('Error: $e', 'FirestoreService');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .orderBy('name')
          .get();
      return snapshot.docs
          .map(
            (doc) => <String, dynamic>{
              ...(doc.data() as Map<String, dynamic>? ?? {}),
              'id': doc.id,
            },
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUserWishlist(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('wishlist')
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs
          .map(
            (doc) => <String, dynamic>{
              ...(doc.data() as Map<String, dynamic>? ?? {}),
              'id': doc.id,
            },
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  // CART METHODS
  Future<List<CartItemModel>> getCartItems(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('cart')
          .doc(userId)
          .collection('items')
          .get();

      return snapshot.docs
          .map((doc) => CartItemModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      Logger.error(
        'Error fetching cart items: $e',
        'FirestoreService.getCartItems',
      );
      return [];
    }
  }

  Future<void> addToCart(CartItemModel item) async {
    try {
      await _firestore
          .collection('cart')
          .doc(item.userId)
          .collection('items')
          .doc(item.id)
          .set(item.toFirestore());
    } catch (e) {
      Logger.error('Error adding to cart: $e', 'FirestoreService.addToCart');
      rethrow;
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    try {
      // Note: You'll need to pass userId or extract from cartItemId structure
      // For now, this is a placeholder - in practice, you'd need more context
      Logger.error(
        'removeFromCart requires userId context',
        'FirestoreService.removeFromCart',
      );
    } catch (e) {
      Logger.error(
        'Error removing from cart: $e',
        'FirestoreService.removeFromCart',
      );
      rethrow;
    }
  }

  Future<void> removeCartItem(String userId, String itemId) async {
    try {
      await _firestore
          .collection('cart')
          .doc(userId)
          .collection('items')
          .doc(itemId)
          .delete();
    } catch (e) {
      Logger.error(
        'Error removing cart item: $e',
        'FirestoreService.removeCartItem',
      );
      rethrow;
    }
  }

  Future<void> updateCartItemQuantity(
    String userId,
    String itemId,
    int quantity,
  ) async {
    try {
      await _firestore
          .collection('cart')
          .doc(userId)
          .collection('items')
          .doc(itemId)
          .update({
            'quantity': quantity,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      Logger.error(
        'Error updating cart item quantity: $e',
        'FirestoreService.updateCartItemQuantity',
      );
      rethrow;
    }
  }

  Future<void> clearCart(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('cart')
          .doc(userId)
          .collection('items')
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      Logger.error('Error clearing cart: $e', 'FirestoreService.clearCart');
      rethrow;
    }
  }

  // ORDER METHODS
  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    } catch (e) {
      Logger.error(
        'Error fetching user orders: $e',
        'FirestoreService.getUserOrders',
      );
      return [];
    }
  }

  Future<OrderModel?> getOrder(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        return OrderModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      Logger.error('Error fetching order: $e', 'FirestoreService.getOrder');
      return null;
    }
  }

  Future<void> createOrder(OrderModel order) async {
    try {
      await _firestore
          .collection('orders')
          .doc(order.id)
          .set(order.toFirestore());
    } catch (e) {
      Logger.error('Error creating order: $e', 'FirestoreService.createOrder');
      rethrow;
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      Logger.error(
        'Error updating order status: $e',
        'FirestoreService.updateOrderStatus',
      );
      rethrow;
    }
  }

  Future<void> updateOrderTracking(
    String orderId,
    String trackingNumber,
  ) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'trackingNumber': trackingNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      Logger.error(
        'Error updating tracking: $e',
        'FirestoreService.updateOrderTracking',
      );
      rethrow;
    }
  }
}
