import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/coupon_model.dart';
import '../services/coupon_service.dart';
import 'auth_provider.dart';

/// Notifier for managing user coupons state
class UserCouponsNotifier extends StateNotifier<AsyncValue<List<CouponModel>>> {
  final CouponService _service = CouponService();
  final Ref _ref;
  StreamSubscription<List<CouponModel>>? _subscription;

  UserCouponsNotifier(this._ref) : super(const AsyncValue.loading()) {
    _ref.listen<AsyncValue<String?>>(authProvider, (_, next) {
      next.whenData((uid) {
        if (uid == null || uid.isEmpty) {
          state = const AsyncValue.data([]);
          return;
        }
        _loadCoupons(uid);
      });
    });

    _ref.read(authProvider).whenData((uid) {
      if (uid != null && uid.isNotEmpty) {
        _loadCoupons(uid);
      }
    });
  }

  /// Load coupons from service
  Future<void> _loadCoupons(String userId) async {
    try {
      state = const AsyncValue.loading();
      _subscription?.cancel();
      _subscription = _service
          .getUserCouponsStream(userId)
          .listen(
            (coupons) {
              state = AsyncValue.data(coupons);
            },
            onError: (error, stackTrace) {
              state = AsyncValue.error(error, stackTrace);
            },
          );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Apply a coupon code
  Future<bool> applyCoupon(String userId, String couponCode) async {
    try {
      final success = await _service.applyCoupon(userId, couponCode);
      if (success) {
        await _loadCoupons(userId);
      }
      return success;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  /// Use a coupon
  Future<bool> useCoupon(String userId, String couponId) async {
    try {
      final success = await _service.useCoupon(userId, couponId);
      if (success) {
        final current = state.whenData((list) => list);
        current.whenData((list) {
          final updated = list
              .map((c) => c.id == couponId ? c.copyWith(isUsed: true) : c)
              .toList();
          state = AsyncValue.data(updated);
        });
      }
      return success;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  /// Remove a coupon
  Future<void> removeCoupon(String userId, String couponId) async {
    try {
      await _service.removeCoupon(userId, couponId);
      final current = state.whenData((list) => list);
      current.whenData((list) {
        final updated = list.where((c) => c.id != couponId).toList();
        state = AsyncValue.data(updated);
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Refresh coupons
  Future<void> refresh(String userId) async {
    await _loadCoupons(userId);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// User coupons provider using StateNotifierProvider
final userCouponsProvider =
    StateNotifierProvider<UserCouponsNotifier, AsyncValue<List<CouponModel>>>((
      ref,
    ) {
      return UserCouponsNotifier(ref);
    });

/// Real-time user coupons stream provider
final userCouponsStreamProvider = StreamProvider.autoDispose
    .family<List<CouponModel>, String>((ref, userId) {
      return CouponService().getUserCouponsStream(userId);
    });

/// Valid coupons only provider
final validCouponsProvider = FutureProvider.autoDispose
    .family<List<CouponModel>, String>((ref, userId) async {
      return CouponService().getValidCoupons(userId);
    });

/// Validate coupon code provider
final validateCouponProvider = FutureProvider.autoDispose
    .family<CouponModel?, String>((ref, couponCode) async {
      return CouponService().validateCouponCode(couponCode);
    });
