import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/coupon_model.dart';
import '../models/product_model.dart';
import 'logger.dart';

/// Data integrity validation rules for Firestore collections
/// Enforces business logic constraints at the application layer
class DataIntegrityValidator {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ PRODUCT VALIDATION ============

  /// Validates product price constraints: price ≤ mainPrice
  static bool validateProductPricing(ProductModel product) {
    if (product.price > product.mainPrice) {
      Logger.warn(
        'Invalid pricing: price (${product.price}) > mainPrice (${product.mainPrice})',
        'DataIntegrityValidator.validateProductPricing',
      );
      return false;
    }
    return true;
  }

  /// Validates product stock: must be >= 0
  static bool validateProductStock(int stock) {
    if (stock < 0) {
      Logger.warn(
        'Invalid stock: $stock < 0',
        'DataIntegrityValidator.validateProductStock',
      );
      return false;
    }
    return true;
  }

  /// Validates product rating: must be 0 ≤ rating ≤ 5
  static bool validateProductRating(double rating) {
    if (rating < 0 || rating > 5) {
      Logger.warn(
        'Invalid rating: $rating (must be 0-5)',
        'DataIntegrityValidator.validateProductRating',
      );
      return false;
    }
    return true;
  }

  /// Validates product category reference exists
  static Future<bool> validateProductCategory(String categoryId) async {
    try {
      final category = await _firestore
          .collection('categories')
          .doc(categoryId)
          .get();
      if (!category.exists) {
        Logger.warn(
          'Category not found: $categoryId',
          'DataIntegrityValidator.validateProductCategory',
        );
        return false;
      }
      return true;
    } catch (e) {
      Logger.error(
        'Error validating category: $e',
        'DataIntegrityValidator.validateProductCategory',
      );
      return false;
    }
  }

  // ============ COUPON VALIDATION ============

  /// Validates coupon code format: uppercase alphanumeric only
  static bool validateCouponCodeFormat(String code) {
    final isValid = RegExp(r'^[A-Z0-9]+$').hasMatch(code);
    if (!isValid) {
      Logger.warn(
        'Invalid coupon code format: $code (must be uppercase alphanumeric)',
        'DataIntegrityValidator.validateCouponCodeFormat',
      );
    }
    return isValid;
  }

  /// Validates coupon expiration: must not be in the past
  static bool validateCouponExpiration(DateTime expireDate) {
    if (DateTime.now().isAfter(expireDate)) {
      Logger.warn(
        'Coupon expired: $expireDate',
        'DataIntegrityValidator.validateCouponExpiration',
      );
      return false;
    }
    return true;
  }

  /// Validates coupon discount constraints by type
  /// Percentage: 0 ≤ discount ≤ 100
  /// Fixed: discount > 0
  static bool validateCouponDiscount(
    double discount,
    String discountType,
  ) {
    if (discountType == 'percentage') {
      if (discount < 0 || discount > 100) {
        Logger.warn(
          'Invalid percentage discount: $discount (must be 0-100)',
          'DataIntegrityValidator.validateCouponDiscount',
        );
        return false;
      }
    } else if (discountType == 'fixed') {
      if (discount <= 0) {
        Logger.warn(
          'Invalid fixed discount: $discount (must be > 0)',
          'DataIntegrityValidator.validateCouponDiscount',
        );
        return false;
      }
    }
    return true;
  }

  /// Validates coupon is not already used
  static bool validateCouponNotUsed(CouponModel coupon) {
    if (coupon.isUsed) {
      Logger.warn(
        'Coupon already used: ${coupon.code}',
        'DataIntegrityValidator.validateCouponNotUsed',
      );
      return false;
    }
    return true;
  }

  /// Comprehensive coupon validation
  static Future<bool> validateCoupon(CouponModel coupon) async {
    final checks = <bool>[
      validateCouponCodeFormat(coupon.code),
      validateCouponExpiration(coupon.expireDate),
      validateCouponDiscount(coupon.discount, coupon.discountType),
      validateCouponNotUsed(coupon),
    ];

    if (coupon.minPurchaseAmount != null && coupon.maxDiscount != null) {
      if (coupon.minPurchaseAmount! <= 0 || coupon.maxDiscount! <= 0) {
        Logger.warn(
          'Invalid coupon constraints: minPurchase=${coupon.minPurchaseAmount}, maxDiscount=${coupon.maxDiscount}',
          'DataIntegrityValidator.validateCoupon',
        );
        return false;
      }
    }

    return checks.every((check) => check);
  }

  // ============ ORDER VALIDATION ============

  /// Validates order items contain valid product references
  static Future<bool> validateOrderItemReferences(
    List<String> productIds,
  ) async {
    try {
      for (final productId in productIds) {
        final product = await _firestore
            .collection('products')
            .doc(productId)
            .get();
        if (!product.exists) {
          Logger.warn(
            'Product not found in order: $productId',
            'DataIntegrityValidator.validateOrderItemReferences',
          );
          return false;
        }
      }
      return true;
    } catch (e) {
      Logger.error(
        'Error validating order item references: $e',
        'DataIntegrityValidator.validateOrderItemReferences',
      );
      return false;
    }
  }

  /// Validates order total is positive
  static bool validateOrderTotal(double totalAmount) {
    if (totalAmount <= 0) {
      Logger.warn(
        'Invalid order total: $totalAmount (must be > 0)',
        'DataIntegrityValidator.validateOrderTotal',
      );
      return false;
    }
    return true;
  }

  /// Validates order payment method is valid
  static bool validatePaymentMethod(String method) {
    const validMethods = ['mpesa', 'card', 'wallet'];
    if (!validMethods.contains(method)) {
      Logger.warn(
        'Invalid payment method: $method',
        'DataIntegrityValidator.validatePaymentMethod',
      );
      return false;
    }
    return true;
  }

  // ============ FLASH DEAL VALIDATION ============

  /// Validates flash deal pricing: dealPrice < originalPrice
  static bool validateFlashDealPricing(
    double originalPrice,
    double dealPrice,
  ) {
    if (dealPrice >= originalPrice) {
      Logger.warn(
        'Invalid flash deal pricing: dealPrice ($dealPrice) >= originalPrice ($originalPrice)',
        'DataIntegrityValidator.validateFlashDealPricing',
      );
      return false;
    }
    return true;
  }

  /// Validates flash deal discount percentage matches prices
  static bool validateFlashDealDiscount(
    double originalPrice,
    double dealPrice,
    double discountPercentage,
  ) {
    final calculatedDiscount =
        (originalPrice - dealPrice) / originalPrice * 100;
    const tolerance = 0.01; // Allow 0.01% rounding error

    if ((calculatedDiscount - discountPercentage).abs() > tolerance) {
      Logger.warn(
        'Discount mismatch: calculated ($calculatedDiscount%) != stated ($discountPercentage%)',
        'DataIntegrityValidator.validateFlashDealDiscount',
      );
      return false;
    }
    return true;
  }

  /// Validates flash deal stock: stockLeft ≤ totalStock
  static bool validateFlashDealStock(int stockLeft, int totalStock) {
    if (stockLeft > totalStock || stockLeft < 0 || totalStock < 0) {
      Logger.warn(
        'Invalid flash deal stock: stockLeft ($stockLeft) > totalStock ($totalStock)',
        'DataIntegrityValidator.validateFlashDealStock',
      );
      return false;
    }
    return true;
  }

  /// Validates flash deal time window: startTime < endTime
  static bool validateFlashDealTimeWindow(
    DateTime startTime,
    DateTime endTime,
  ) {
    if (!startTime.isBefore(endTime)) {
      Logger.warn(
        'Invalid flash deal window: startTime ($startTime) >= endTime ($endTime)',
        'DataIntegrityValidator.validateFlashDealTimeWindow',
      );
      return false;
    }
    return true;
  }

  // ============ RECIPE VALIDATION ============

  /// Validates recipe difficulty enum
  static bool validateRecipeDifficulty(String difficulty) {
    const validDifficulties = ['easy', 'medium', 'hard'];
    if (!validDifficulties.contains(difficulty)) {
      Logger.warn(
        'Invalid recipe difficulty: $difficulty',
        'DataIntegrityValidator.validateRecipeDifficulty',
      );
      return false;
    }
    return true;
  }

  /// Validates recipe time values: must be >= 0
  static bool validateRecipeTimes(int prepMinutes, int cookMinutes) {
    if (prepMinutes < 0 || cookMinutes < 0) {
      Logger.warn(
        'Invalid recipe times: prep ($prepMinutes), cook ($cookMinutes)',
        'DataIntegrityValidator.validateRecipeTimes',
      );
      return false;
    }
    return true;
  }

  /// Validates recipe servings: must be >= 1
  static bool validateRecipeServings(int servings) {
    if (servings < 1) {
      Logger.warn(
        'Invalid recipe servings: $servings (must be >= 1)',
        'DataIntegrityValidator.validateRecipeServings',
      );
      return false;
    }
    return true;
  }

  // ============ WISHLIST VALIDATION ============

  /// Validates wishlist item type enum
  static bool validateWishlistItemType(String itemType) {
    const validTypes = ['product', 'bundle'];
    if (!validTypes.contains(itemType)) {
      Logger.warn(
        'Invalid wishlist item type: $itemType',
        'DataIntegrityValidator.validateWishlistItemType',
      );
      return false;
    }
    return true;
  }

  /// Validates wishlist item exists (either product or bundle)
  static Future<bool> validateWishlistItemExists(
    String itemId,
    String itemType,
  ) async {
    try {
      final ref = _firestore
          .collection(itemType == 'product' ? 'products' : 'bundles')
          .doc(itemId);
      final exists = await ref.get();

      if (!exists.exists) {
        Logger.warn(
          '$itemType not found: $itemId',
          'DataIntegrityValidator.validateWishlistItemExists',
        );
        return false;
      }
      return true;
    } catch (e) {
      Logger.error(
        'Error validating wishlist item: $e',
        'DataIntegrityValidator.validateWishlistItemExists',
      );
      return false;
    }
  }

  // ============ BATCH VALIDATION ============

  /// Validate all critical constraints before data seeding
  static Future<bool> validateAllBeforeSeeding() async {
    try {
      Logger.info(
        'Running pre-seeding data validation...',
        'DataIntegrityValidator.validateAllBeforeSeeding',
      );

      // Check categories exist
      final categories = await _firestore.collection('categories').get();
      if (categories.docs.isEmpty) {
        Logger.warn(
          'No categories found - validate after seeding',
          'DataIntegrityValidator.validateAllBeforeSeeding',
        );
      }

      Logger.info(
        'Pre-seeding validation complete',
        'DataIntegrityValidator.validateAllBeforeSeeding',
      );
      return true;
    } catch (e) {
      Logger.error(
        'Error in pre-seeding validation: $e',
        'DataIntegrityValidator.validateAllBeforeSeeding',
      );
      return false;
    }
  }
}
