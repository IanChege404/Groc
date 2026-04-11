import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wishlist_model.dart';
import '../services/firestore_service.dart';
import '../utils/logger.dart';
import 'auth_provider.dart';

final wishlistItemsProvider =
    StateNotifierProvider<WishlistNotifier, AsyncValue<List<WishlistModel>>>((
      ref,
    ) {
      final firestore = FirestoreService();
      final authState = ref.watch(authProvider);

      return WishlistNotifier(firestore: firestore, authState: authState);
    });

final wishlistCountProvider = Provider((ref) {
  final wishlistState = ref.watch(wishlistItemsProvider);
  return wishlistState.maybeWhen(
    data: (items) => items.length,
    orElse: () => 0,
  );
});

final isProductInWishlistProvider = FutureProvider.family<bool, String>((
  ref,
  productId,
) async {
  final wishlistState = ref.watch(wishlistItemsProvider);
  return wishlistState.maybeWhen(
    data: (items) => items.any((item) => item.productId == productId),
    orElse: () => false,
  );
});

class WishlistNotifier extends StateNotifier<AsyncValue<List<WishlistModel>>> {
  final FirestoreService firestore;
  final AsyncValue<String?> authState;
  final _firestore = FirebaseFirestore.instance;

  // For managing real-time subscription
  dynamic _wishlistSubscription;
  String? _currentUserId;

  WishlistNotifier({required this.firestore, required this.authState})
    : super(const AsyncValue.loading()) {
    _initializeWishlist();
  }

  Future<void> _initializeWishlist() async {
    try {
      final userId = authState.maybeWhen(
        data: (uid) => uid,
        orElse: () => null,
      );

      Logger.info(
        '_initializeWishlist - userId: $userId',
        'WishlistNotifier._initializeWishlist',
      );

      if (userId == null || userId.isEmpty) {
        Logger.info(
          'User not authenticated, setting empty wishlist',
          'WishlistNotifier._initializeWishlist',
        );
        _currentUserId = null;
        state = const AsyncValue.data([]);
        return;
      }

      // If userId has changed, re-setup the listener
      if (_currentUserId != userId) {
        Logger.info(
          'UserId changed: $_currentUserId -> $userId, re-setting up listener',
          'WishlistNotifier._initializeWishlist',
        );
        _currentUserId = userId;
        _setupRealtimeListener(userId);
      }
    } catch (e, stack) {
      Logger.error(
        'Error in _initializeWishlist: $e\nStack: $stack',
        'WishlistNotifier._initializeWishlist',
      );
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void _setupRealtimeListener(String userId) {
    Logger.info(
      'Setting up real-time listener for userId: $userId',
      'WishlistNotifier._setupRealtimeListener',
    );

    // Cancel previous subscription if any
    _wishlistSubscription?.cancel();

    _wishlistSubscription = _firestore
        .collection('wishlist')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen(
          (snapshot) {
            try {
              Logger.info(
                'Wishlist snapshot received with ${snapshot.docs.length} items',
                'WishlistNotifier._setupRealtimeListener',
              );
              final items = snapshot.docs
                  .map((doc) => WishlistModel.fromFirestore(doc))
                  .toList();
              Logger.info(
                'Loaded ${items.length} wishlist items',
                'WishlistNotifier._setupRealtimeListener',
              );
              state = AsyncValue.data(items);
            } catch (e, stack) {
              Logger.error(
                'Error processing wishlist snapshot: $e\nStack: $stack',
                'WishlistNotifier._setupRealtimeListener',
              );
              state = AsyncValue.error(e, StackTrace.current);
            }
          },
          onError: (error, stack) {
            Logger.error(
              'Wishlist listener error: $error\nStack: $stack',
              'WishlistNotifier._setupRealtimeListener',
            );
            state = AsyncValue.error(error, StackTrace.current);
          },
        );
  }

  Future<void> addToWishlist(WishlistModel item) async {
    try {
      final userId = authState.maybeWhen(
        data: (uid) => uid,
        orElse: () => null,
      );

      Logger.info(
        'Adding to wishlist - userId: $userId, productId: ${item.productId}',
        'WishlistNotifier.addToWishlist',
      );

      if (userId == null || userId.isEmpty) {
        Logger.error(
          'User not authenticated - userId is null/empty',
          'WishlistNotifier.addToWishlist',
        );
        throw Exception('User not authenticated');
      }

      // Ensure listener is set up for this userId
      if (_currentUserId != userId) {
        Logger.info(
          'UserId mismatch, setting up listener for: $userId',
          'WishlistNotifier.addToWishlist',
        );
        _currentUserId = userId;
        _setupRealtimeListener(userId);
      }

      // Create a new item with the userId set
      final itemWithUserId = item.copyWith(userId: userId);
      Logger.info(
        'Saving to Firestore - itemId: ${itemWithUserId.id}, userId: ${itemWithUserId.userId}',
        'WishlistNotifier.addToWishlist',
      );

      await firestore.addToWishlist(itemWithUserId);
      Logger.info(
        'Successfully saved to Firestore',
        'WishlistNotifier.addToWishlist',
      );
      // Real-time listener will automatically update state
    } catch (e, stack) {
      Logger.error(
        'Error adding to wishlist: $e\nStack: $stack',
        'WishlistNotifier.addToWishlist',
      );
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> removeFromWishlist(String wishlistItemId) async {
    try {
      final userId = authState.maybeWhen(
        data: (uid) => uid,
        orElse: () => null,
      );

      if (userId == null) {
        return;
      }

      await firestore.removeFromWishlist(userId, wishlistItemId);
      // Real-time listener will automatically update state
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> clearWishlist() async {
    try {
      final userId = authState.maybeWhen(
        data: (uid) => uid,
        orElse: () => null,
      );
      if (userId != null && userId.isNotEmpty) {
        await firestore.clearWishlist(userId);
        // Real-time listener will automatically update state
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
