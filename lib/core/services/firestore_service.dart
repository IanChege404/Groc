import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../models/wishlist_model.dart';
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

  Query<Map<String, dynamic>> _productsBaseQuery({String? category}) {
    Query<Map<String, dynamic>> query = _firestore.collection('products');
    if (category != null && category.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: category);
    }
    return query.orderBy('createdAt', descending: true);
  }

  // PRODUCTS
  Future<List<Map<String, dynamic>>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? category,
    String? search,
  }) async {
    try {
      final normalizedPage = page < 1 ? 1 : page;
      final hasSearch = search != null && search.trim().isNotEmpty;

      if (!hasSearch) {
        DocumentSnapshot<Map<String, dynamic>>? cursor;
        if (normalizedPage > 1) {
          for (int i = 1; i < normalizedPage; i++) {
            Query<Map<String, dynamic>> traversalQuery = _productsBaseQuery(
              category: category,
            ).limit(pageSize);
            if (cursor != null) {
              traversalQuery = traversalQuery.startAfterDocument(cursor);
            }

            final chunk = await traversalQuery.get();

            if (chunk.docs.isEmpty) {
              return [];
            }
            cursor = chunk.docs.last;
          }
        }

        Query<Map<String, dynamic>> query = _productsBaseQuery(
          category: category,
        ).limit(pageSize);
        if (cursor != null) {
          query = query.startAfterDocument(cursor);
        }

        final snapshot = await query.get();
        return snapshot.docs
            .map((doc) => <String, dynamic>{...(doc.data()), 'id': doc.id})
            .toList();
      }

      final searchLower = search.toLowerCase();
      final required = normalizedPage * pageSize;
      final products = <Map<String, dynamic>>[];
      DocumentSnapshot<Map<String, dynamic>>? cursor;

      while (products.length < required) {
        Query<Map<String, dynamic>> query = _productsBaseQuery(
          category: category,
        ).limit(pageSize);
        if (cursor != null) {
          query = query.startAfterDocument(cursor);
        }

        final snapshot = await query.get();
        if (snapshot.docs.isEmpty) {
          break;
        }

        cursor = snapshot.docs.last;

        products.addAll(
          snapshot.docs
              .map((doc) => <String, dynamic>{...(doc.data()), 'id': doc.id})
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
              ),
        );
      }

      final startIndex = (normalizedPage - 1) * pageSize;
      if (startIndex >= products.length) {
        return [];
      }
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
        return <String, dynamic>{...(doc.data() ?? {}), 'id': doc.id};
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
          .map((doc) => <String, dynamic>{...(doc.data()), 'id': doc.id})
          .toList();
    } catch (e) {
      Logger.error(
        'Error fetching categories: $e',
        'FirestoreService.getCategories',
      );
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
          .map((doc) => <String, dynamic>{...(doc.data()), 'id': doc.id})
          .toList();
    } catch (e) {
      Logger.error(
        'Error fetching wishlist: $e',
        'FirestoreService.getUserWishlist',
      );
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

  Future<void> removeFromCart(String cartItemId, {String? userId}) async {
    try {
      if (userId != null && userId.isNotEmpty) {
        await removeCartItem(userId, cartItemId);
        return;
      }

      final snapshot = await _firestore
          .collectionGroup('items')
          .where(FieldPath.documentId, isEqualTo: cartItemId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return;
      }

      await snapshot.docs.first.reference.delete();
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

  // USER PROFILE METHODS
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        return null;
      }

      return <String, dynamic>{...(doc.data() ?? {}), 'id': doc.id};
    } catch (e) {
      Logger.error('Error fetching profile: $e', 'FirestoreService.getUserProfile');
      return null;
    }
  }

  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).set(
            {
              ...data,
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
    } catch (e) {
      Logger.error(
        'Error updating profile: $e',
        'FirestoreService.updateUserProfile',
      );
      rethrow;
    }
  }

  // ADDRESS METHODS
  Future<List<Map<String, dynamic>>> getUserAddresses(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .orderBy('isDefault', descending: true)
          .orderBy('updatedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => <String, dynamic>{...(doc.data()), 'id': doc.id})
          .toList();
    } catch (e) {
      Logger.error(
        'Error fetching addresses: $e',
        'FirestoreService.getUserAddresses',
      );
      return [];
    }
  }

  Future<void> addUserAddress(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .doc();

      await docRef.set({
        ...data,
        'userId': userId,
        'isDefault': data['isDefault'] ?? false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (data['isDefault'] == true) {
        final otherAddresses = await _firestore
            .collection('users')
            .doc(userId)
            .collection('addresses')
            .get();

        for (final address in otherAddresses.docs) {
          if (address.id != docRef.id) {
            await address.reference.update({'isDefault': false});
          }
        }
      }
    } catch (e) {
      Logger.error(
        'Error adding address: $e',
        'FirestoreService.addUserAddress',
      );
      rethrow;
    }
  }

  Future<void> updateUserAddress(
    String userId,
    String addressId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .doc(addressId)
          .set(
            {
              ...data,
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
    } catch (e) {
      Logger.error(
        'Error updating address: $e',
        'FirestoreService.updateUserAddress',
      );
      rethrow;
    }
  }

  Future<void> deleteUserAddress(String userId, String addressId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .doc(addressId)
          .delete();
    } catch (e) {
      Logger.error(
        'Error deleting address: $e',
        'FirestoreService.deleteUserAddress',
      );
      rethrow;
    }
  }

  Future<void> setDefaultAddress(String userId, String addressId) async {
    try {
      final collection = _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses');

      final snapshot = await collection.get();
      for (final doc in snapshot.docs) {
        await doc.reference.update({'isDefault': doc.id == addressId});
      }
    } catch (e) {
      Logger.error(
        'Error setting default address: $e',
        'FirestoreService.setDefaultAddress',
      );
      rethrow;
    }
  }

  // PAYMENT METHOD METHODS
  Future<List<Map<String, dynamic>>> getPaymentMethods(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('payment_methods')
          .orderBy('isDefault', descending: true)
          .orderBy('updatedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => <String, dynamic>{...(doc.data()), 'id': doc.id})
          .toList();
    } catch (e) {
      Logger.error(
        'Error fetching payment methods: $e',
        'FirestoreService.getPaymentMethods',
      );
      return [];
    }
  }

  Future<void> addPaymentMethod(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('payment_methods')
          .doc();

      await docRef.set({
        ...data,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (data['isDefault'] == true) {
        final otherMethods = await _firestore
            .collection('users')
            .doc(userId)
            .collection('payment_methods')
            .get();
        for (final method in otherMethods.docs) {
          if (method.id != docRef.id) {
            await method.reference.update({'isDefault': false});
          }
        }
      }
    } catch (e) {
      Logger.error(
        'Error adding payment method: $e',
        'FirestoreService.addPaymentMethod',
      );
      rethrow;
    }
  }

  Future<void> deletePaymentMethod(String userId, String methodId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('payment_methods')
          .doc(methodId)
          .delete();
    } catch (e) {
      Logger.error(
        'Error deleting payment method: $e',
        'FirestoreService.deletePaymentMethod',
      );
      rethrow;
    }
  }

  // WISHLIST METHODS
  Future<List<WishlistModel>> getWishlistItems(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('wishlist')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => WishlistModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      Logger.error(
        'Error fetching wishlist items: $e',
        'FirestoreService.getWishlistItems',
      );
      return [];
    }
  }

  Future<void> addToWishlist(WishlistModel item) async {
    try {
      await _firestore
          .collection('wishlist')
          .doc(item.id)
          .set(item.toFirestore());
    } catch (e) {
      Logger.error('Error adding to wishlist: $e', 'FirestoreService.addToWishlist');
      rethrow;
    }
  }

  Future<void> removeFromWishlist(String userId, String wishlistItemId) async {
    try {
      await _firestore
          .collection('wishlist')
          .doc(wishlistItemId)
          .delete();
    } catch (e) {
      Logger.error(
        'Error removing from wishlist: $e',
        'FirestoreService.removeFromWishlist',
      );
      rethrow;
    }
  }

  Future<void> clearWishlist(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('wishlist')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      Logger.error('Error clearing wishlist: $e', 'FirestoreService.clearWishlist');
      rethrow;
    }
  }
}
