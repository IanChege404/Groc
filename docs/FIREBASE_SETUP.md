# Firebase Setup Guide

## Quick Start

1. Create Firebase project at https://console.firebase.google.com
2. Create Firestore Database (Spark Plan = Free)
3. Download google-services.json (Android) and GoogleService-Info.plist (iOS)
4. Copy files to android/app/ and ios/Runner/
5. Update firebase_options.dart with your project details

## Firestore Collections Schema

### products
```
{
  id: auto-generated,
  name: string,
  description: string,
  price: number,
  discountPrice: number,
  rating: number,
  reviewCount: number,
  image: string (URL),
  images: [strings] (URLs),
  categoryId: string,
  stock: number,
  attributes: {key: value},
  createdAt: timestamp,
  updatedAt: timestamp
}
```

### categories
```
{
  id: auto-generated,
  name: string,
  description: string,
  icon: string (URL),
  color: string (hex)
}
```

### users
```
{
  id: userId (Firebase Auth UID),
  email: string,
  firstName: string,
  lastName: string,
  phone: string,
  photoUrl: string,
  createdAt: timestamp
}
```

### wishlist
```
{
  id: userId_productId,
  userId: string,
  productId: string,
  addedAt: timestamp
}
```

### orders
```
{
  id: auto-generated,
  userId: string,
  productIds: [strings],
  totalAmount: number,
  status: string (pending/completed/cancelled),
  paymentMethod: string (mpesa/card),
  shippingAddress: object,
  createdAt: timestamp,
  updatedAt: timestamp
}
```

### cart
```
/cart/{userId}/{itemId}
{
  productId: string,
  quantity: number,
  addedAt: timestamp
}
```

## Migration from REST API

Old: ApiClient.get('/products')
New: FirestoreProductService().getProducts()

All services maintain same return type (ApiResponse<T>)
