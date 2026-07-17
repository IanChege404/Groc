# State Management Patterns

## Overview

Pro Grocery uses a **dual state management** approach:
- **Provider** (legacy): 20 providers for consumer-facing features
- **Riverpod** (modern): Emerging for service-level state

New features should use Riverpod. Existing Provider code will be migrated incrementally.

## Provider Pattern

### Creating a Provider

```dart
// lib/core/providers/cart_provider.dart
import 'package:flutter/foundation.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];
  
  List<CartItemModel> get items => List.unmodifiable(_items);
  
  double get totalAmount => _items.fold(0, (sum, item) => sum + item.price * item.quantity);
  
  int get itemCount => _items.length;

  void addToCart({required String productId, required double price, int quantity = 1}) {
    final existingIndex = _items.indexWhere((i) => i.productId == productId);
    if (existingIndex >= 0) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + quantity,
      );
    } else {
      _items.add(CartItemModel(
        productId: productId,
        price: price,
        quantity: quantity,
      ));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((i) => i.productId == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = _items[index].copyWith(quantity: quantity);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
```

### Registering Providers

In `main.dart`:
```dart
runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => CartProvider()),
      ChangeNotifierProvider(create: (_) => SettingsProvider()),
      // ... more providers
    ],
    child: const MyApp(),
  ),
)
```

### Consuming Providers

```dart
// In a widget
class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    
    return ListView.builder(
      itemCount: cart.items.length,
      itemBuilder: (context, index) {
        return CartItemTile(item: cart.items[index]);
      },
    );
  }
}

// Or with Consumer for selective rebuilds
Consumer<CartProvider>(
  builder: (context, cart, child) {
    return Text('${cart.itemCount} items');
  },
)
```

## Riverpod Pattern

### Creating a Provider

```dart
// lib/core/providers/catalog_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_product_service.dart';

final firestoreProductServiceProvider = Provider<FirestoreProductService>((ref) {
  return FirestoreProductService();
});

final productsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final service = ref.watch(firestoreProductServiceProvider);
  return service.getProducts();
});

final productByIdProvider = FutureProvider.family<ProductModel?, String>((ref, productId) async {
  final service = ref.watch(firestoreProductServiceProvider);
  return service.getProductById(productId);
});

// StateNotifier for mutable state
final cartItemsProvider = StateNotifierProvider<CartItemsNotifier, List<CartItemModel>>((ref) {
  return CartItemsNotifier();
});

class CartItemsNotifier extends StateNotifier<List<CartItemModel>> {
  CartItemsNotifier() : super([]);

  void add(String productId, double price) {
    state = [...state, CartItemModel(productId: productId, price: price, quantity: 1)];
  }

  void remove(String productId) {
    state = state.where((item) => item.productId != productId).toList();
  }

  void updateQuantity(String productId, int quantity) {
    state = [
      for (final item in state)
        if (item.productId == productId) item.copyWith(quantity: quantity) else item,
    ];
  }
}
```

### Consuming Riverpod Providers

```dart
// In a widget
class ProductListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    
    return productsAsync.when(
      data: (products) => ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) => ProductTile(products[index]),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}

// Selective rebuilds with .select()
final cartCountSelector = Provider<int>((ref) {
  return ref.watch(cartItemsProvider).length;
});

Consumer(builder: (context, ref, _) {
  final count = ref.watch(cartCountSelector);
  return Badge(count: count);
})
```

## Provider vs Riverpod Comparison

| Aspect | Provider | Riverpod |
|--------|----------|----------|
| State mutation | `notifyListeners()` | Immutable state objects |
| Testing | Requires `MultiProvider` wrapper | Injectable with `ProviderContainer` |
| Code generation | No | Optional (annotations) |
| Dependency injection | Manual | Automatic via ref |
| Selective rebuilds | `Selector` widget | `.select()` modifier |
| Async state | Manual loading/error | `.when()` pattern |
| Scope | Widget tree | Global/app-level |

## Best Practices

### Provider
1. Keep providers focused — one responsibility per provider
2. Use `ChangeNotifierProvider.value()` for already-created instances
3. Prefer `Consumer` over `Provider.of()` for selective rebuilds
4. Dispose resources in `ChangeNotifier.dispose()`
5. Don't nest providers unnecessarily

### Riverpod
1. Use `ref.watch()` for reactive dependencies
2. Use `ref.read()` for one-time reads (e.g., button press handlers)
3. Use `.family` for parameterized providers
4. Use `StateNotifier` for complex mutable state
5. Prefer `FutureProvider` over manual `AsyncValue` management

## State Debugging

### Provider
```dart
// Add to MaterialApp
MaterialApp(
  builder: (context, child) {
    return Navigator(
      onGenerateRoute: (settings) {
        // Use Flutter DevTools Provider tab
        return null;
      },
    );
  },
)
```

### Riverpod
```dart
// Use Riverpod DevTools
// Add devtools_riverpod to dev_dependencies
// Then use ProviderContainer for inspection
```

## Migration Guide: Provider → Riverpod

### Step 1: Create Riverpod provider alongside existing Provider
### Step 2: Migrate consumers one at a time
### Step 3: Remove old Provider once all consumers migrated
### Step 4: Update `main.dart` to use `ProviderScope` instead of `MultiProvider`

```dart
// Before (Provider)
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => CatalogProvider()),
  ],
  child: MyApp(),
)

// After (Riverpod)
ProviderScope(
  child: MyApp(),
)
```
