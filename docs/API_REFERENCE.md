# API Reference

## Overview

Pro Grocery uses Firebase as its primary backend — no custom REST API server. All data operations go through Firebase SDKs directly from the Flutter client.

## Firebase Services Used

| Service | SDK Package | Purpose |
|---------|-------------|---------|
| Firebase Auth | `firebase_auth` | User authentication |
| Cloud Firestore | `cloud_firestore` | Primary database |
| Firebase Messaging | `firebase_messaging` | Push notifications |
| Firebase Core | `firebase_core` | Initialization |

## External APIs

### M-Pesa Daraja API

**Base URL:** `https://api.safaricom.co.ke/mpesa`

#### Initiate STK Push (Lipa Na M-Pesa Online)

```
POST /mpesa/stkpush/v1/processrequest
```

**Headers:**
```
Authorization: Basic {base64(consumer_key:consumer_secret)}
Content-Type: application/json
```

**Request Body:**
```json
{
  "BusinessShortCode": "174379",
  "Password": "{base64(shortcode + passkey + timestamp)}",
  "Timestamp": "20260407120000",
  "TransactionType": "CustomerPayBillOnline",
  "Amount": 50,
  "PartyA": "+254712345678",
  "PartyB": "174379",
  "PhoneNumber": "+254712345678",
  "CallBackURL": "https://your-domain.com/api/mpesa/callback",
  "AccountReference": "ORDER-123",
  "TransactionDesc": "Payment for order"
}
```

**Response:**
```json
{
  "MerchantRequestID": "...",
  "CheckoutRequestID": "ws_CO_...",
  "ResponseCode": "0",
  "ResponseDescription": "Success. Request accepted for validation",
  "CustomerMessage": "Success. Request accepted for validation"
}
```

#### Check Transaction Status

```
GET /mpesa/transactionstatus/v1/query
```

**Service:** `MpesaService` at `lib/core/services/mpesa_service.dart`

### Flutterwave API

**Base URL:** `https://api.flutterwave.com/v3`

#### Initialize Payment

```
POST /payments
```

**Headers:**
```
Authorization: Bearer {secret_key}
Content-Type: application/json
```

**Request Body:**
```json
{
  "tx_ref": "ORDER-123",
  "amount": 50,
  "currency": "KES",
  "redirect_url": "https://your-domain.com/payment/callback",
  "customer": {
    "email": "user@example.com",
    "phone_number": "+254712345678"
  },
  "customizations": {
    "title": "Pro Grocery",
    "description": "Payment for order"
  }
}
```

**Response:**
```json
{
  "status": "success",
  "data": {
    "link": "https://checkout.flutterwave.com/..."
  }
}
```

**Service:** `FlutterwaveService` at `lib/core/services/flutterwave_service.dart`

## Firestore Collections

### Public Collections (read: anyone, write: authenticated)

#### `products/{productId}`
```json
{
  "name": "string",
  "description": "string",
  "category": "string",
  "categoryId": "string (FK → categories)",
  "price": "number",
  "mainPrice": "number",
  "stock": "number",
  "image": "string (URL)",
  "images": ["string (URL)"],
  "rating": "number (0-5)",
  "reviewCount": "number",
  "weight": "string",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

#### `categories/{categoryId}`
```json
{
  "name": "string",
  "description": "string",
  "icon": "string (URL)",
  "color": "string (hex)",
  "createdAt": "timestamp"
}
```

#### `bundles/{bundleId}`
```json
{
  "name": "string",
  "description": "string",
  "image": "string (URL)",
  "images": ["string (URL)"],
  "itemNames": ["string"],
  "productIds": ["string (FK → products)"],
  "price": "number",
  "mainPrice": "number",
  "rating": "number",
  "reviewCount": "number",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

#### `recipes/{recipeId}`
```json
{
  "name": "string",
  "description": "string",
  "imageUrl": "string (URL)",
  "servings": "number",
  "prepTimeMinutes": "number",
  "cookTimeMinutes": "number",
  "difficulty": "easy | medium | hard",
  "ingredients": [{
    "productId": "string",
    "productName": "string",
    "quantity": "number",
    "unit": "string",
    "imageUrl": "string (optional)",
    "price": "number (optional)"
  }],
  "instructions": ["string"],
  "tags": ["string"],
  "rating": "number",
  "reviewCount": "number",
  "createdAt": "timestamp"
}
```

#### `offers/{offerId}`
```json
{
  "productId": "string (FK → products)",
  "productName": "string",
  "imageUrl": "string (URL)",
  "originalPrice": "number",
  "dealPrice": "number",
  "discountPercentage": "number",
  "stockLeft": "number",
  "totalStock": "number",
  "startTime": "timestamp",
  "endTime": "timestamp",
  "isActive": "boolean",
  "categoryId": "string (FK → categories)"
}
```

#### `coupons/{couponId}`
```json
{
  "code": "string (UPPERCASE)",
  "title": "string",
  "discount": "number",
  "discountType": "percentage | fixed",
  "expireDate": "timestamp",
  "isUsed": "boolean",
  "applicableCategories": ["string (FK → categories)"],
  "description": "string (optional)",
  "minPurchaseAmount": "number (optional)",
  "maxDiscount": "number (optional)",
  "imageUrl": "string (URL)",
  "createdAt": "timestamp"
}
```

#### `reviews/{reviewId}`
```json
{
  "userId": "string",
  "productId": "string",
  "rating": "number (1-5)",
  "comment": "string",
  "createdAt": "timestamp"
}
```

### User-Scoped Collections (read/write: owner only)

#### `users/{userId}`
```json
{
  "email": "string",
  "firstName": "string",
  "lastName": "string",
  "phone": "string",
  "photoUrl": "string",
  "createdAt": "timestamp"
}
```

**Subcollections under `users/{userId}/`:**
- `addresses/{addressId}` — Delivery addresses
- `payment_methods/{paymentMethodId}` — Saved payment methods
- `notifications/{notificationId}` — User notifications
- `wallet/{walletId}` — Wallet data
- `transactions/{transactionId}` — Transaction history
- `coupons/{couponId}` — Saved/redeemed coupons
- `settings/{settingsId}` — User preferences

#### `cart/{userId}/{itemId}`
```json
{
  "productId": "string",
  "quantity": "number",
  "addedAt": "timestamp"
}
```

#### `wishlist/{wishlistId}`
```json
{
  "userId": "string",
  "productId": "string",
  "addedAt": "timestamp"
}
```

#### `orders/{orderId}`
```json
{
  "userId": "string",
  "items": [{
    "productId": "string",
    "name": "string",
    "price": "number",
    "quantity": "number",
    "image": "string"
  }],
  "totalAmount": "number",
  "status": "pending | confirmed | shipped | delivered | cancelled",
  "paymentMethod": "mpesa | card | wallet",
  "shippingAddress": "object",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

#### `loyalty/{userId}`
```json
{
  "points": "number",
  "tier": "bronze | silver | gold | platinum",
  "history": [{
    "action": "string",
    "points": "number",
    "timestamp": "timestamp"
  }]
}
```

#### `reviews/{reviewId}`
```json
{
  "userId": "string",
  "productId": "string",
  "rating": "number",
  "comment": "string",
  "createdAt": "timestamp"
}
```

### Content Collections (public read, authenticated write)

#### `onboarding/{slideId}` — Onboarding carousel slides
#### `drawer_menu/{itemId}` — Navigation menu items
#### `top_questions/{questionId}` — FAQ quick links
#### `help_topics/{topicId}` — Help center topics
#### `app_content/{docId}` — Global app metadata (images, assets, FAQ, contact)

## Service API Methods

### FirestoreProductService
```dart
Future<List<ProductModel>> getProducts()
Future<List<ProductModel>> getProductsByCategory(String categoryId)
Future<ProductModel?> getProductById(String productId)
Future<List<CategoryModel>> getCategories()
Future<List<BundleModel>> getBundles()
```

### FirestoreAuthService
```dart
Future<User?> signInWithEmail(String email, String password)
Future<User?> signUpWithEmail(String email, String password)
Future<void> signOut()
Future<void> resetPassword(String email)
Future<User?> signInWithGoogle()
```

### MpesaService
```dart
Future<MpesaResponse> processPayment({
  required double amount,
  required String phoneNumber,
  required String orderId,
})
```

### FlutterwaveService
```dart
Future<FlutterwaveResponse> initializePayment({
  required double amount,
  required String email,
  required String phone,
  required String orderId,
})
```

### HiveService
```dart
Future<void> cacheData(String key, dynamic data, {Duration? ttl})
dynamic getCachedData(String key)
bool isStale(String key, {Duration? ttl})
Future<void> clearCache()
Future<void> clearAll()
```

## Firestore Security Rules Summary

| Collection | Read | Write |
|-----------|------|-------|
| `products` | Public | Authenticated |
| `categories` | Public | Authenticated |
| `bundles` | Public | Authenticated |
| `recipes` | Public | Authenticated |
| `offers` | Public | Authenticated |
| `coupons` | Authenticated | Authenticated |
| `reviews` | Public | Create: auth; Update/Delete: owner |
| `users/{userId}` | Owner only | Owner only |
| `cart/{userId}/*` | Owner only | Owner only |
| `wishlist/*` | Owner only | Owner only |
| `orders/*` | Owner only | Create: auth; Update: owner (immutable fields) |
| `loyalty/{userId}` | Owner only | Owner only |

Full rules: `firestore.rules`
