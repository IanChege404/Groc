# Data Integrity - Developer Quick Start

**TL;DR**: 6 quick integration points for your code.

---

## 1️⃣ Pre-Checkout Validation

**Before**: User clicks checkout → payment might fail if product deleted

**After**: Validate cart first

```dart
// In your cart/checkout provider
Future<void> proceedToCheckout() async {
  final isValid = await _firestoreService.validateCheckoutCart(
    _cartItems,
  );
  
  if (!isValid) {
    showDialog('Some items are no longer available. Please review your cart.');
    return; // Stop checkout
  }
  
  // Safe to proceed
  await createOrder();
}
```

**2-line integration**: ✅

---

## 2️⃣ Atomic Order + Wallet Payment

**Before**: 
```dart
await createOrder(order);  // Success
await deductWallet(amount); // Fails → orphaned order
```

**After**: All-or-nothing operation

```dart
// Replace old createOrder() with:
try {
  final orderId = await _firestoreService.createOrderWithWalletTransaction(
    userId: currentUser.id,
    items: cartItems,
    totalAmount: total,
    paymentMethod: 'wallet',
    shippingAddress: selectedAddress,
  );
  
  showSuccess('Order #$orderId created!');
  clearCart();
} catch (e) {
  // If fails: nothing written, wallet untouched
  showError('Checkout failed: $e');
}
```

**3-line integration**: ✅

---

## 3️⃣ Soft-Delete Orders

**Before**: Order deleted → gone forever (audit nightmare)

**After**: Soft delete + audit trail

```dart
// In order management screen
Future<void> cancelOrder(String orderId) async {
  await _firestoreService.softDeleteOrder(
    orderId,
    'customer_requested', // or 'payment_timeout', 'admin_cancel', etc
  );
  
  // Order still queryable, but isDeleted = true
  notifyListeners();
}

// Restore if needed
Future<void> restoreOrder(String orderId) async {
  await _firestoreService.restoreOrder(orderId);
}
```

**For UI**: Use `order.isDeleted` to show archived badge

```dart
Card(
  color: order.isDeleted ? Colors.grey : Colors.white,
  child: Column(
    children: [
      Text(order.id),
      if (order.isDeleted) ...[
        Text('ARCHIVED', style: TextStyle(color: Colors.red)),
        Text('Reason: ${order.deletionReason}'),
      ],
    ],
  ),
)
```

**1-line integration**: ✅

---

## 4️⃣ Comprehensive Coupon Validation

**Before**: Manually check multiple conditions

**After**: One validation call

```dart
import 'package:groc/core/utils/data_integrity_validator.dart';

// Old way (error-prone)
if (coupon.isExpired) return null;
if (coupon.isUsed) return null;
if (coupon.discount > 100) return null; // What if type is 'fixed'?

// New way (comprehensive)
final isValid = await DataIntegrityValidator.validateCoupon(coupon);
if (!isValid) return null;
```

**1-line integration**: ✅

---

## 5️⃣ Individual Validation Methods

For granular control:

```dart
import 'package:groc/core/utils/data_integrity_validator.dart';

// Validate product before displaying
if (!DataIntegrityValidator.validateProductStock(product.stock)) {
  showUnavailable();
  return;
}

// Validate flash deal pricing
if (!DataIntegrityValidator.validateFlashDealPricing(
  originalPrice: 100,
  dealPrice: 150, // Wrong!
)) {
  // Log error, don't show deal
}

// Validate coupon code format before submission
if (!DataIntegrityValidator.validateCouponCodeFormat(userInput)) {
  showError('Code must be uppercase letters and numbers');
  return;
}

// Validate wishlist item before adding
final itemExists = await DataIntegrityValidator.validateWishlistItemExists(
  itemId: productId,
  itemType: 'product',
);
if (!itemExists) {
  showError('Product no longer available');
  return;
}
```

---

## 6️⃣ Query Soft-Deleted Orders

**For Admin Dashboard**:

```dart
// Show only active orders
final activeOrders = await _firestore
    .collection('orders')
    .where('deletedAt', isNull: true)
    .orderBy('createdAt', descending: true)
    .get();

// Show deleted orders (archive)
final deletedOrders = await _firestore
    .collection('orders')
    .where('deletedAt', isNotEqualTo: null)
    .orderBy('deletedAt', descending: true)
    .get();

// Show all (for audit log)
final allOrders = await _firestore
    .collection('orders')
    .orderBy('createdAt', descending: true)
    .get();
```

---

## Common Scenarios

### Scenario 1: User Checking Out with Wallet

```dart
// Step 1: Validate cart
if (!await validateCheckoutCart(cart)) {
  return showError('Please review your cart');
}

// Step 2: Create order + deduct wallet (atomic)
try {
  final orderId = await createOrderWithWalletTransaction(
    userId: user.id,
    items: cart.items,
    totalAmount: cart.total,
    paymentMethod: 'wallet',
    shippingAddress: user.defaultAddress,
  );
  
  showSuccess('Order #$orderId confirmed!');
  router.push('/orders/$orderId');
} on FirebaseException catch (e) {
  // Transaction failed, wallet intact
  showError('Payment failed: ${e.message}');
}
```

### Scenario 2: Admin Refunding an Order

```dart
// Soft-delete order with reason
await softDeleteOrder(
  orderId: 'order_abc123',
  reason: 'refund_issued',
);

// Manually restore wallet if paid via wallet
final order = await getOrder('order_abc123');
if (order.paymentMethod == 'wallet') {
  await _firestore
      .collection('users')
      .doc(order.userId)
      .collection('wallet')
      .doc('balance')
      .update({
        'balance': FieldValue.increment(order.totalAmount),
      });
}
```

**Note**: On Blaze plan, this will be automated via Cloud Functions.

### Scenario 3: User Adding to Wishlist

```dart
// Validate item exists before adding
final isValid = await DataIntegrityValidator.validateWishlistItemExists(
  itemId: productId,
  itemType: 'product',
);

if (!isValid) {
  showError('Item no longer available');
  return;
}

// Safe to add
await addToWishlist(
  userId: user.id,
  itemId: productId,
  itemType: 'product',
);
```

---

## Firestore Rules Changes

Your security rules are now stricter:

### Coupon Creation (You Can't Do This Anymore)
```javascript
// ❌ Invalid coupon code (lowercase)
await _firestore.collection('coupons').add({
  code: 'save20',  // REJECTED by rules (must be uppercase)
  ...
});

// ❌ Invalid discount (>100%)
await _firestore.collection('coupons').add({
  discountType: 'percentage',
  discount: 150,  // REJECTED by rules
  ...
});

// ✅ Valid coupon
await _firestore.collection('coupons').add({
  code: 'SAVE20',
  discount: 20,
  discountType: 'percentage',
  expireDate: Timestamp.fromDate(DateTime.now().add(Duration(days: 30))),
  ...
});
```

### Wishlist Item (You Can't Do This Anymore)
```javascript
// ❌ Invalid item type
await _firestore.collection('wishlist').add({
  userId: user.id,
  itemId: 'product_123',
  itemType: 'invalid_type',  // REJECTED by rules
  ...
});

// ❌ Item doesn't exist
await _firestore.collection('wishlist').add({
  userId: user.id,
  itemId: 'product_deleted_xyz',  // REJECTED if product doesn't exist
  itemType: 'product',
  ...
});

// ✅ Valid wishlist item
await _firestore.collection('wishlist').add({
  userId: user.id,
  itemId: 'product_fresh_milk_123',
  itemType: 'product',
  addedAt: Timestamp.now(),
  ...
});
```

---

## Testing Your Integration

### Unit Test Example

```dart
// test/services/firestore_service_test.dart

void main() {
  group('FirestoreService - Data Integrity', () {
    test('validateCheckoutCart rejects missing products', () async {
      final service = FirestoreService();
      
      final result = await service.validateCheckoutCart([
        CartItemModel(
          id: '1',
          userId: 'user1',
          productId: 'missing_product',
          quantity: 1,
          priceAtTimeOfAdd: 100,
          addedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ]);
      
      expect(result, false);
    });
    
    test('createOrderWithWalletTransaction is atomic', () async {
      // Mock setup...
      
      expect(
        () => service.createOrderWithWalletTransaction(...),
        throwsA(isA<FirebaseException>()),
      );
      
      // Verify wallet unchanged
      final wallet = await service.getWalletBalance('user1');
      expect(wallet, equals(initialBalance));
    });
  });
}
```

---

## When to Use Each Method

| Situation | Use Method |
|-----------|-----------|
| Before order creation | `validateCheckoutCart()` |
| Paying via wallet | `createOrderWithWalletTransaction()` |
| Cancelling order | `softDeleteOrder()` |
| Restoring order | `restoreOrder()` |
| Validating coupon | `DataIntegrityValidator.validateCoupon()` |
| Checking coupon code format | `validateCouponCodeFormat()` |
| Adding to wishlist | `validateWishlistItemExists()` |
| Showing active orders | `.where('deletedAt', isNull: true)` |

---

## Error Handling

```dart
Future<void> checkoutWithErrorHandling() async {
  try {
    // Validate
    if (!await validateCheckoutCart(cartItems)) {
      showDialog('Cart items unavailable');
      return;
    }
    
    // Process
    final orderId = await createOrderWithWalletTransaction(
      userId: user.id,
      items: cartItems,
      totalAmount: total,
      paymentMethod: 'wallet',
      shippingAddress: address,
    );
    
    showSuccess('Order created: #$orderId');
    
  } on FirebaseException catch (e) {
    if (e.code == 'permission-denied') {
      showError('You do not have permission');
    } else if (e.code == 'unavailable') {
      showError('Service temporarily unavailable');
    } else {
      showError('Error: ${e.message}');
    }
  } catch (e) {
    showError('Unexpected error: $e');
  }
}
```

---

## Debugging Tips

### Enable Detailed Logging

```dart
// Add to main.dart
import 'package:groc/core/utils/logger.dart';

void main() {
  // Enable debug logging
  Logger.setLevel(LogLevel.debug);
  
  runApp(MyApp());
}
```

### Check Firestore Rules Violations

```bash
# View Cloud Firestore security rule violations
firebase emulator:start --only firestore
# Open http://localhost:4000 to see violations in real-time
```

### Validate Data in Firestore Console

```javascript
// In Firebase Console Firestore, query:
db.collection('coupons')
  .where('code', '==', 'INVALID_CODE')
  .get()
  .then(snapshot => {
    // Should return empty or throw permission error
  });
```

---

## Common Errors & Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| `Permission Denied` on coupon create | Code not uppercase | Use `code.toUpperCase()` |
| `Wishlist create rejected` | Item doesn't exist | Call `validateWishlistItemExists()` first |
| `Transaction failed` | Concurrent wallet writes | Retry with exponential backoff (handled automatically) |
| `Product not found in checkout` | Product deleted while in cart | Call `validateCheckoutCart()` before payment |

---

## Migration from Old Code

### Before
```dart
// Old checkout
await createOrder(order);
await deductWallet(user.id, total);
clearCart();
```

### After
```dart
// New checkout
if (!await validateCheckoutCart(cartItems)) return;

final orderId = await createOrderWithWalletTransaction(
  userId: user.id,
  items: cartItems,
  totalAmount: total,
  paymentMethod: 'wallet',
  shippingAddress: selectedAddress,
);
clearCart();
```

**Risk Reduced**: From "potential data loss" to "atomic all-or-nothing"

---

**Questions?** See `/docs/DATA_INTEGRITY_FIXES.md` for technical details.

**Need Blaze Plan features?** See upgrade path in main document.
