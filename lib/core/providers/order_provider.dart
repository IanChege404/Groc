import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

final ordersProvider =
    StateNotifierProvider<OrderNotifier, AsyncValue<List<OrderModel>>>((ref) {
      final firestore = FirestoreService();
      final authState = ref.watch(authProvider);

      return OrderNotifier(firestore: firestore, authState: authState);
    });

final orderDetailProvider = FutureProvider.family<OrderModel?, String>((
  ref,
  orderId,
) async {
  final firestore = FirestoreService();
  return firestore.getOrder(orderId);
});

class OrderNotifier extends StateNotifier<AsyncValue<List<OrderModel>>> {
  final FirestoreService firestore;
  final AsyncValue<String?> authState;

  OrderNotifier({required this.firestore, required this.authState})
    : super(const AsyncValue.loading()) {
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final userId = authState.maybeWhen(
        data: (uid) => uid,
        orElse: () => null,
      );

      if (userId == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final orders = await firestore.getUserOrders(userId);
      state = AsyncValue.data(orders);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> createOrder(OrderModel order) async {
    try {
      await firestore.createOrder(order);
      await _loadOrders();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await firestore.updateOrderStatus(orderId, status);
      await _loadOrders();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await firestore.updateOrderStatus(orderId, 'cancelled');
      await _loadOrders();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
