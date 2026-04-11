import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item_model.dart';
import '../services/firestore_product_service.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

final cartItemsProvider =
    StateNotifierProvider<CartNotifier, AsyncValue<List<CartItemModel>>>((ref) {
      final firestore = FirestoreService();
      final authState = ref.watch(authProvider);

      return CartNotifier(firestore: firestore, authState: authState);
    });

final cartTotalProvider = FutureProvider<double>((ref) async {
  final cartItems =
      ref.watch(cartItemsProvider).value ?? const <CartItemModel>[];
  final productService = FirestoreProductService();

  double total = 0;
  for (final item in cartItems) {
    final productResult = await productService.getProductById(item.productId);
    if (productResult.success && productResult.data != null) {
      final product = productResult.data!;
      total += product.price * item.quantity;
    }
  }
  return total;
});

final cartCountProvider = Provider((ref) {
  final cartState = ref.watch(cartItemsProvider);
  return cartState.maybeWhen(data: (items) => items.length, orElse: () => 0);
});

class CartNotifier extends StateNotifier<AsyncValue<List<CartItemModel>>> {
  final FirestoreService firestore;
  final AsyncValue<String?> authState;
  final _firestore = FirebaseFirestore.instance;

  // For managing real-time subscription
  dynamic _cartSubscription;

  CartNotifier({required this.firestore, required this.authState})
    : super(const AsyncValue.loading()) {
    _initializeCart();
  }

  Future<void> _initializeCart() async {
    try {
      final userId = authState.maybeWhen(
        data: (uid) => uid,
        orElse: () => null,
      );

      if (userId == null || userId.isEmpty) {
        state = const AsyncValue.data([]);
        return;
      }

      // Listen to real-time updates instead of one-time fetch
      _setupRealtimeListener(userId);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void _setupRealtimeListener(String userId) {
    // Cancel previous subscription if any
    _cartSubscription?.cancel();

    _cartSubscription = _firestore
        .collection('cart')
        .doc(userId)
        .collection('items')
        .snapshots()
        .listen(
          (snapshot) {
            try {
              final items = snapshot.docs
                  .map((doc) => CartItemModel.fromFirestore(doc))
                  .toList();
              state = AsyncValue.data(items);
            } catch (e) {
              state = AsyncValue.error(e, StackTrace.current);
            }
          },
          onError: (error) {
            state = AsyncValue.error(error, StackTrace.current);
          },
        );
  }

  Future<void> addToCart(CartItemModel item) async {
    try {
      final userId = authState.maybeWhen(
        data: (uid) => uid,
        orElse: () => null,
      );

      if (userId == null || userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      // Create a new item with the userId set
      final itemWithUserId = item.copyWith(userId: userId);
      await firestore.addToCart(itemWithUserId);
      // Real-time listener will automatically update state
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    try {
      final userId = authState.maybeWhen(
        data: (uid) => uid,
        orElse: () => null,
      );

      if (userId == null) {
        return;
      }

      await firestore.removeCartItem(userId, cartItemId);
      // Real-time listener will automatically update state
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateCartItemQuantity(String cartItemId, int quantity) async {
    try {
      final userId = authState.maybeWhen(
        data: (uid) => uid,
        orElse: () => null,
      );

      if (userId == null) {
        return;
      }

      await firestore.updateCartItemQuantity(userId, cartItemId, quantity);
      // Real-time listener will automatically update state
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> clearCart() async {
    try {
      final userId = authState.maybeWhen(
        data: (uid) => uid,
        orElse: () => null,
      );
      if (userId != null && userId.isNotEmpty) {
        await firestore.clearCart(userId);
        // Real-time listener will automatically update state
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
