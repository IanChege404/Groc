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

  CartNotifier({required this.firestore, required this.authState})
    : super(const AsyncValue.loading()) {
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      final userId = authState.maybeWhen(
        data: (uid) => uid,
        orElse: () => null,
      );

      if (userId == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final items = await firestore.getCartItems(userId);
      state = AsyncValue.data(items);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> addToCart(CartItemModel item) async {
    try {
      await firestore.addToCart(item);
      await _loadCart();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
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
      await _loadCart();
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
      await _loadCart();
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
      if (userId != null) {
        await firestore.clearCart(userId);
        await _loadCart();
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
