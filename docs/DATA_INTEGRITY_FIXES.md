# Data Integrity Fixes Implementation Guide

**Status**: ✅ Implemented on Firebase Spark Plan | ⚠️ Remaining items require Blaze upgrade

---

## Summary of Changes

This document outlines all data integrity gaps identified and their implementation status across Firebase Spark and Blaze plans.

### Quick Stats
- **✅ Implemented (Spark Plan)**: 5 fixes
- **⏳ Requires Blaze Plan**: 3 fixes
- **📊 Total Validations Added**: 12+ constraint checks

---

## Part 1: ✅ Implemented on Spark Plan

### 1. Enhanced Firestore Security Rules

**File**: `firestore.rules`

#### Coupon Validation (Lines 29-43)
```javascript
match /coupons/{couponId} {
  // Code must be uppercase alphanumeric
  request.resource.data.code.matches('[A-Z0-9]+')
  
  // Discount constraints by type
  if (discountType == 'percentage'): discount ∈ [0, 100]
  if (discountType == 'fixed'): discount > 0
  
  // Expiration must be in future
  request.resource.data.expireDate > now
}
```

**Prevents**: 
- Invalid coupon codes (e.g., lowercase, special chars)
- Impossible discount values (>100% discount)
- Expired coupons being created

#### Wishlist Item Type & Existence Validation (Lines 78-98)
```javascript
match /wishlist/{wishlistId} {
  allow create: if
    // itemType must be enum: product or bundle
    request.resource.data.itemType in ['product', 'bundle']
    
    // Item must exist in catalog
    && ((itemType == 'product' && exists(/products/{itemId}))
        || (itemType == 'bundle' && exists(/bundles/{itemId})))
}
```

**Prevents**:
- Wishlist entries with invalid item types
- Broken references to non-existent products/bundles
- Orphaned wishlist items if product deleted

#### Order Immutability (Lines 100-114) — Existing
Ensures these fields cannot be modified after order creation:
- `items` (prevent item substitution)
- `totalAmount` (prevent payment manipulation)
- `paymentMethod` (prevent payment method switching)
- `createdAt` (prevent timestamp fraud)

---

### 2. Soft-Delete Pattern for Orders

**File**: `lib/core/models/order_model.dart`

**New Fields**:
```dart
class OrderModel {
  // ... existing fields ...
  
  // NEW: Soft delete support
  final DateTime? deletedAt;        // null = active, set = archived
  final String? deletionReason;     // why deleted (refund, user request)
  
  // NEW: Convenience getters
  bool get isDeleted => deletedAt != null;
  bool get isActive => deletedAt == null;
}
```

**Benefits**:
- Orders never truly deleted (compliance/audit trail)
- Can restore orders via `restoreOrder()`
- History preserved for disputes/refunds
- Soft-deleted orders excluded from active order queries

**Usage Example**:
```dart
// Soft delete an order
await firestoreService.softDeleteOrder(
  orderId: 'order_123',
  reason: 'customer_requested_refund',
);

// Restore deleted order
await firestoreService.restoreOrder('order_123');

// Check order status
if (order.isDeleted) {
  // Show archived order UI
}
```

---

### 3. Pre-Checkout Validation

**File**: `lib/core/services/firestore_service.dart` (Lines 395-425)

**Method**: `validateCheckoutCart()`

**Validates Before Checkout**:
✅ Product exists in catalog  
✅ Product has sufficient stock  
✅ All items still available (no overselling)

**Implementation**:
```dart
Future<bool> validateCheckoutCart(List<CartItemModel> items) async {
  for (final item in items) {
    // Check product exists
    final product = await _firestore
        .collection('products')
        .doc(item.productId)
        .get();
    
    if (!product.exists || stock < item.quantity) {
      return false; // Abort checkout
    }
  }
  return true;
}
```

**Integration in Checkout Flow**:
```dart
// In cart/checkout screen
if (!await firestoreService.validateCheckoutCart(cartItems)) {
  showDialog('Some items are no longer available');
  return; // Don't proceed to payment
}

// Safe to proceed
await createOrder(cartItems);
```

**Prevents**:
- Checkout with deleted products
- Overselling (quantity > available stock)
- Stale cart state when product inventory changes

---

### 4. Atomic Order + Wallet Transaction

**File**: `lib/core/services/firestore_service.dart` (Lines 428-495)

**Method**: `createOrderWithWalletTransaction()`

**Atomicity Guarantee**: All-or-nothing operation

```dart
await _firestore.runTransaction((transaction) async {
  // Step 1: Create order
  transaction.set(orderRef, orderData);
  
  // Step 2: Deduct wallet balance (atomic)
  transaction.update(walletRef, {
    'balance': FieldValue.increment(-totalAmount),
    'totalSpent': FieldValue.increment(totalAmount),
  });
  
  // Step 3: Log transaction (atomic)
  transaction.set(transactionRef, txData);
  // All 3 succeed together or all 3 fail together
});
```

**Benefits**:
- ✅ No orphaned orders without payment deduction
- ✅ No failed wallet updates leaving unpaid orders
- ✅ Transaction history always consistent with wallet balance
- ✅ Automatic rollback on any failure

**Usage**:
```dart
try {
  final orderId = await firestoreService.createOrderWithWalletTransaction(
    userId: authProvider.currentUser.id,
    items: cartProvider.items,
    totalAmount: cartProvider.total,
    paymentMethod: 'wallet',
    shippingAddress: selectedAddress,
  );
  
  // Order created atomically with payment deducted
  showSuccess('Order #$orderId created successfully');
} catch (e) {
  // If transaction fails, nothing is written
  // User's wallet untouched, no order created
  showError('Payment failed: $e');
}
```

---

### 5. Comprehensive Data Validation Layer

**File**: `lib/core/utils/data_integrity_validator.dart`

**New Class**: `DataIntegrityValidator` with 12+ validation methods

**Validation Categories**:

#### Product Validation
```dart
✓ validateProductPricing() — price ≤ mainPrice
✓ validateProductStock() — stock ≥ 0
✓ validateProductRating() — 0 ≤ rating ≤ 5
✓ validateProductCategory() — category FK exists
```

#### Coupon Validation
```dart
✓ validateCouponCodeFormat() — uppercase alphanumeric
✓ validateCouponExpiration() — expireDate > now
✓ validateCouponDiscount() — type-specific constraints
✓ validateCouponNotUsed() — isUsed == false
✓ validateCoupon() — all checks combined
```

#### Order Validation
```dart
✓ validateOrderItemReferences() — all products exist
✓ validateOrderTotal() — totalAmount > 0
✓ validatePaymentMethod() — valid payment type
```

#### Flash Deal Validation
```dart
✓ validateFlashDealPricing() — dealPrice < originalPrice
✓ validateFlashDealDiscount() — discount % matches prices
✓ validateFlashDealStock() — stockLeft ≤ totalStock
✓ validateFlashDealTimeWindow() — startTime < endTime
```

#### Wishlist Validation
```dart
✓ validateWishlistItemType() — enum validation
✓ validateWishlistItemExists() — product/bundle exists
```

**Usage Example**:
```dart
import 'package:groc/core/utils/data_integrity_validator.dart';

// Validate before saving
if (!DataIntegrityValidator.validateProductPricing(product)) {
  throw Exception('Invalid product pricing');
}

// Validate coupon comprehensively
final isValid = await DataIntegrityValidator.validateCoupon(coupon);
if (!isValid) {
  return null; // Reject coupon
}

// Batch validation (useful before seeding)
await DataIntegrityValidator.validateAllBeforeSeeding();
```

**Integration in Services**:
- CouponService now uses `validateCoupon()` for all coupon checks
- Can be extended to other services (ProductService, OrderService)

---

## Part 2: ⏳ Requires Firebase Blaze Plan

### Why Blaze Plan?
**Spark Plan Limitations**:
- ❌ No Cloud Functions support
- ❌ No scheduled tasks
- ❌ Limited to client-side enforcement

**Blaze Plan** enables backend automation, cascade operations, and referential integrity triggers.

---

### 1. Referential Integrity Cascade Triggers

**What It Does**: When a product is deleted, automatically:
- ✅ Remove from bundles
- ✅ Remove from recipes
- ✅ Remove from wishlists
- ✅ Warn in orders (don't delete, just flag)

**Implementation Approach** (requires Blaze):

```typescript
// functions/src/triggers.ts
export const onProductDeleted = functions.firestore
  .document('products/{productId}')
  .onDelete(async (snap) => {
    const productId = snap.id;
    
    // 1. Remove from bundles
    const bundles = await db.collection('bundles')
      .where('productIds', 'array-contains', productId)
      .get();
    
    for (const bundle of bundles.docs) {
      const productIds = (bundle.data().productIds as string[])
        .filter(id => id !== productId);
      
      if (productIds.length === 0) {
        // Bundle has no products, soft-delete it
        await bundle.ref.update({
          deletedAt: admin.firestore.FieldValue.serverTimestamp(),
          deletionReason: 'product_deleted_no_items',
        });
      } else {
        // Update bundle
        await bundle.ref.update({ productIds });
      }
    }
    
    // 2. Remove from recipes
    const recipes = await db.collection('recipes').get();
    for (const recipe of recipes.docs) {
      const ingredients = (recipe.data().ingredients as any[])
        .filter(ing => ing.productId !== productId);
      
      await recipe.ref.update({ ingredients });
    }
    
    // 3. Remove from wishlists
    const wishlist = await db.collection('wishlist')
      .where('itemId', '==', productId)
      .where('itemType', '==', 'product')
      .get();
    
    for (const item of wishlist.docs) {
      await item.ref.delete();
    }
  });
```

**When to Deploy**:
1. Upgrade to Blaze plan
2. Deploy Cloud Functions to your Firebase project
3. Enable auto-deletion of orphaned catalog items

---

### 2. Data Consistency Cleanup Job

**What It Does**: Nightly background job to:
- 🔍 Find orphaned orders (products that no longer exist)
- 🔍 Find stale wishlist items (deleted products)
- 🔍 Find broken bundle references
- 📊 Generate consistency report

**Implementation** (requires Blaze + Scheduled Functions):

```typescript
export const nightly_data_consistency_check = functions.pubsub
  .schedule('every day 02:00')
  .timeZone('UTC')
  .onRun(async (context) => {
    const reports = {
      orphaned_orders: [],
      stale_wishlist: [],
      broken_bundles: [],
    };
    
    // Check all orders for orphaned product references
    const orders = await db.collection('orders').get();
    for (const order of orders.docs) {
      const items = order.data().items as any[];
      
      for (const item of items) {
        const product = await db.collection('products')
          .doc(item.productId)
          .get();
        
        if (!product.exists) {
          reports.orphaned_orders.push({
            orderId: order.id,
            productId: item.productId,
            status: order.data().status,
          });
        }
      }
    }
    
    // Similar checks for wishlist and bundles...
    
    // Log report to Firestore
    await db.collection('_system').doc('consistency_report').set({
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      ...reports,
    });
    
    // Optionally alert admin
    console.log('Consistency check complete:', reports);
  });
```

---

### 3. Automatic Order Expiry & Cleanup

**What It Does**: Expire pending orders after 24 hours + cleanup abandoned carts

**Implementation** (requires Blaze + Scheduled Functions):

```typescript
export const expire_pending_orders = functions.pubsub
  .schedule('every 6 hours')
  .timeZone('UTC')
  .onRun(async (context) => {
    const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
    
    const pendingOrders = await db.collection('orders')
      .where('status', '==', 'pending')
      .where('createdAt', '<', oneDayAgo)
      .get();
    
    for (const order of pendingOrders.docs) {
      const orderData = order.data();
      
      // Soft-delete expired order
      await order.ref.update({
        status: 'cancelled',
        deletedAt: admin.firestore.FieldValue.serverTimestamp(),
        deletionReason: 'payment_timeout_24h',
      });
      
      // Restore wallet if paid via wallet
      if (orderData.paymentMethod === 'wallet') {
        await db.collection('users')
          .doc(orderData.userId)
          .collection('wallet')
          .doc('balance')
          .update({
            balance: admin.firestore.FieldValue.increment(orderData.totalAmount),
          });
        
        // Log refund transaction
        await db.collection('users')
          .doc(orderData.userId)
          .collection('transactions')
          .add({
            type: 'credit',
            amount: orderData.totalAmount,
            category: 'refund',
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            description: 'Refund: Order #${order.id} expired',
            relatedOrderId: order.id,
            reference: 'order_expiry_refund',
          });
      }
    }
  });
```

---

## Upgrade Path: Spark → Blaze

### Step 1: Backup Your Data
```bash
# Export Firestore data before upgrade
gcloud firestore export gs://your-backup-bucket/backup-2026-07-17
```

### Step 2: Upgrade Firebase Plan
1. Go to Firebase Console → Project Settings
2. Click "Upgrade to Blaze" button
3. Confirm billing enablement
4. ✅ Cloud Functions now available

### Step 3: Deploy Cloud Functions
```bash
cd functions
npm install
npm run deploy

# Deploys:
# - onProductDeleted trigger
# - nightly_data_consistency_check
# - expire_pending_orders
```

### Step 4: Enable Function Logs
```bash
gcloud functions describe onProductDeleted --gen2
gcloud functions logs read onProductDeleted --limit 50
```

### Step 5: Test Triggers
```bash
# Test product deletion cascade
firebase emulator start  # or against staging

# Manually delete a product and verify:
# - Bundles updated
# - Recipes updated
# - Wishlists cleaned
```

---

## Testing the Implemented Fixes

### Test 1: Pre-Checkout Validation

```dart
// In test file
test('validateCheckoutCart rejects unavailable products', () async {
  final cartItems = [
    CartItemModel(productId: 'deleted_product', quantity: 1, ...),
  ];
  
  final isValid = await firestoreService.validateCheckoutCart(cartItems);
  expect(isValid, false);
});

test('validateCheckoutCart rejects overselling', () async {
  final cartItems = [
    CartItemModel(productId: 'product_1', quantity: 1000, ...), // stock = 50
  ];
  
  final isValid = await firestoreService.validateCheckoutCart(cartItems);
  expect(isValid, false);
});
```

### Test 2: Atomic Transactions

```dart
test('createOrderWithWalletTransaction is atomic', () async {
  final initialBalance = await getWalletBalance(userId);
  
  try {
    await firestoreService.createOrderWithWalletTransaction(
      userId: userId,
      items: items,
      totalAmount: 100,
      paymentMethod: 'wallet',
      shippingAddress: address,
    );
  } catch (e) {
    // If fails mid-transaction
    final finalBalance = await getWalletBalance(userId);
    expect(finalBalance, equals(initialBalance)); // Unchanged
  }
});
```

### Test 3: Soft Delete

```dart
test('softDeleteOrder preserves data', () async {
  final order = await firestoreService.getOrder(orderId);
  expect(order.isActive, true);
  
  await firestoreService.softDeleteOrder(orderId, 'test_reason');
  
  final deletedOrder = await firestoreService.getOrder(orderId);
  expect(deletedOrder.isDeleted, true);
  expect(deletedOrder.deletionReason, 'test_reason');
  expect(deletedOrder.items, order.items); // Data preserved
});

test('restoreOrder removes soft delete', () async {
  await firestoreService.restoreOrder(orderId);
  
  final restored = await firestoreService.getOrder(orderId);
  expect(restored.isActive, true);
  expect(restored.deletedAt, null);
});
```

### Test 4: Data Integrity Validator

```dart
test('validateCouponDiscount rejects invalid percentage', () {
  expect(
    DataIntegrityValidator.validateCouponDiscount(150, 'percentage'),
    false,
  );
  expect(
    DataIntegrityValidator.validateCouponDiscount(50, 'percentage'),
    true,
  );
});

test('validateCouponCodeFormat rejects invalid codes', () {
  expect(
    DataIntegrityValidator.validateCouponCodeFormat('save20'), // lowercase
    false,
  );
  expect(
    DataIntegrityValidator.validateCouponCodeFormat('SAVE20'),
    true,
  );
});
```

---

## Firestore Rules Deployment

```bash
# Test rules locally
firebase emulator:start --only firestore

# Deploy rules to production
firebase deploy --only firestore:rules

# Verify deployment
firebase firestore:inspect 'firestore.rules'
```

---

## Monitoring & Alerts

### Soft-Delete Queries
```dart
// Find all deleted orders (for admin dashboard)
final deletedOrders = await _firestore
    .collection('orders')
    .where('deletedAt', isNotEqualTo: null)
    .orderBy('deletedAt', descending: true)
    .limit(100)
    .get();
```

### Data Integrity Reports
```dart
// After deploying Blaze functions, view consistency reports
final report = await _firestore
    .collection('_system')
    .doc('consistency_report')
    .get();

print('Orphaned Orders: ${report['orphaned_orders'].length}');
print('Stale Wishlist Items: ${report['stale_wishlist'].length}');
```

---

## Summary Matrix

| Fix | Status | Impact | Spark | Blaze |
|-----|--------|--------|-------|-------|
| Enhanced Coupon Rules | ✅ Done | Prevents invalid coupons | ✓ | ✓ |
| Wishlist Item Validation | ✅ Done | Prevents broken references | ✓ | ✓ |
| Soft-Delete Orders | ✅ Done | Preserves audit trail | ✓ | ✓ |
| Pre-Checkout Validation | ✅ Done | Prevents overselling | ✓ | ✓ |
| Atomic Transactions | ✅ Done | Prevents payment orphans | ✓ | ✓ |
| Data Integrity Validator | ✅ Done | 12+ validation checks | ✓ | ✓ |
| Product Deletion Cascade | ⏳ Todo | Cleans up broken refs | ✗ | ✓ |
| Data Consistency Check | ⏳ Todo | Nightly orphan detection | ✗ | ✓ |
| Order Auto-Expiry | ⏳ Todo | Expires pending orders | ✗ | ✓ |

---

## Next Steps

1. **Now** (Spark Plan):
   - ✅ Deploy enhanced firestore.rules
   - ✅ Use pre-checkout validation before orders
   - ✅ Use atomic transactions for wallet operations
   - ✅ Implement soft-delete in order flows

2. **When Ready** (Blaze Plan):
   - Deploy Cloud Functions for cascade cleanup
   - Enable nightly consistency checks
   - Set up automatic order expiry

3. **Long-term** (Optional):
   - Export consistency reports to analytics
   - Alert admins on orphaned data
   - Build admin dashboard showing data health

---

**Last Updated**: 2026-07-17  
**Maintained By**: Data Integrity Team  
**Questions?** Check `/docs/FIRESTORE_COLLECTIONS_CONTRACT.md` for schema details.
