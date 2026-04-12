import '../models/coupon_model.dart';
import '../utils/logger.dart';
import 'firestore_service.dart';

class CouponService {
  static final CouponService _instance = CouponService._internal();
  late FirestoreService _firestoreService;

  factory CouponService() {
    return _instance;
  }

  CouponService._internal() {
    _firestoreService = FirestoreService();
  }

  /// Get user's coupons
  Future<List<CouponModel>> getUserCoupons(String userId) async {
    try {
      return await _firestoreService.getUserCoupons(userId);
    } catch (e) {
      Logger.error(
        'Error getting user coupons: $e',
        'CouponService.getUserCoupons',
      );
      return [];
    }
  }

  /// Get user's coupons stream (real-time)
  Stream<List<CouponModel>> getUserCouponsStream(String userId) {
    return _firestoreService.getUserCouponsStream(userId);
  }

  /// Validate coupon code
  Future<CouponModel?> validateCouponCode(String code) async {
    try {
      final coupon = await _firestoreService.getCouponByCode(code);

      if (coupon == null) {
        Logger.warning(
          'Coupon not found: $code',
          'CouponService.validateCouponCode',
        );
        return null;
      }

      if (coupon.isExpired) {
        Logger.warning(
          'Coupon expired: $code',
          'CouponService.validateCouponCode',
        );
        return null;
      }

      if (coupon.isUsed) {
        Logger.warning(
          'Coupon already used: $code',
          'CouponService.validateCouponCode',
        );
        return null;
      }

      return coupon;
    } catch (e) {
      Logger.error(
        'Error validating coupon code: $e',
        'CouponService.validateCouponCode',
      );
      return null;
    }
  }

  /// Apply coupon (add to user's coupons)
  Future<bool> applyCoupon(String userId, String couponCode) async {
    try {
      final coupon = await validateCouponCode(couponCode);
      if (coupon == null) return false;

      // Check if user already has this coupon
      final userCoupons = await getUserCoupons(userId);
      if (userCoupons.any((c) => c.id == coupon.id)) {
        Logger.warning(
          'User already has this coupon: $couponCode',
          'CouponService.applyCoupon',
        );
        return false;
      }

      await _firestoreService.addCouponToUser(userId, coupon);
      Logger.info('Coupon applied: $couponCode', 'CouponService.applyCoupon');
      return true;
    } catch (e) {
      Logger.error('Error applying coupon: $e', 'CouponService.applyCoupon');
      rethrow;
    }
  }

  /// Use a coupon
  Future<bool> useCoupon(String userId, String couponId) async {
    try {
      final coupons = await getUserCoupons(userId);
      final coupon = coupons.firstWhere(
        (c) => c.id == couponId,
        orElse: () => throw Exception('Coupon not found'),
      );

      if (coupon.isUsed) {
        Logger.warning('Coupon already used', 'CouponService.useCoupon');
        return false;
      }

      if (coupon.isExpired) {
        Logger.warning('Coupon expired', 'CouponService.useCoupon');
        return false;
      }

      await _firestoreService.markCouponAsUsed(userId, couponId);
      Logger.info('Coupon used: $couponId', 'CouponService.useCoupon');
      return true;
    } catch (e) {
      Logger.error('Error using coupon: $e', 'CouponService.useCoupon');
      rethrow;
    }
  }

  /// Remove coupon from user
  Future<void> removeCoupon(String userId, String couponId) async {
    try {
      await _firestoreService.removeCoupon(userId, couponId);
      Logger.info('Coupon removed', 'CouponService.removeCoupon');
    } catch (e) {
      Logger.error('Error removing coupon: $e', 'CouponService.removeCoupon');
      rethrow;
    }
  }

  /// Get valid coupons only
  Future<List<CouponModel>> getValidCoupons(String userId) async {
    try {
      final coupons = await getUserCoupons(userId);
      return coupons.where((c) => c.canBeUsed).toList();
    } catch (e) {
      Logger.error(
        'Error getting valid coupons: $e',
        'CouponService.getValidCoupons',
      );
      return [];
    }
  }

  /// Calculate discount amount
  double calculateDiscount(CouponModel coupon, double orderTotal) {
    if (coupon.isExpired || coupon.isUsed) return 0.0;

    double discount = 0.0;

    if (coupon.discountType == 'percentage') {
      discount = (orderTotal * coupon.discount) / 100;
      if (coupon.maxDiscount != null) {
        discount = discount.clamp(0.0, coupon.maxDiscount!.toDouble());
      }
    } else if (coupon.discountType == 'fixed') {
      discount = coupon.discount.clamp(0.0, orderTotal);
    }

    return discount;
  }

  /// Check if coupon is applicable to category
  bool isCouponApplicable(CouponModel coupon, String categoryId) {
    if (coupon.applicableCategories.isEmpty) return true;
    return coupon.applicableCategories.contains(categoryId);
  }
}
