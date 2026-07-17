# Testing Strategy

## Overview

Pro Grocery uses a three-tier testing approach: unit tests, widget tests, and manual integration testing.

## Test Structure

```
test/
├── widget_test.dart              # Default widget test
├── services/                     # Service unit tests
├── utils/                        # Utility function tests
├── components/                   # Widget component tests
├── views/                        # Screen-level widget tests
└── accessibility_test.dart       # Accessibility compliance tests
```

## Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart

# Run tests matching a pattern
flutter test --name "login"

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Unit Tests

### Service Tests
Test business logic services in isolation (no Firebase required).

```dart
// test/services/cart_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:grocery/core/providers/cart_provider.dart';

void main() {
  group('CartProvider', () {
    late CartProvider cartProvider;

    setUp(() {
      cartProvider = CartProvider();
    });

    test('adds item to cart', () {
      cartProvider.addToCart(productId: 'p1', quantity: 1);
      expect(cartProvider.items.length, 1);
    });

    test('removes item from cart', () {
      cartProvider.addToCart(productId: 'p1', quantity: 1);
      cartProvider.removeFromCart('p1');
      expect(cartProvider.items.length, 0);
    });

    test('calculates total correctly', () {
      cartProvider.addToCart(productId: 'p1', quantity: 2, price: 5.0);
      expect(cartProvider.totalAmount, 10.0);
    });
  });
}
```

### Utility Tests
```dart
// test/utils/validators_test.dart
void main() {
  group('Email validation', () {
    test('rejects invalid email', () {
      expect(Validators.email('invalid'), isNotNull);
    });
    test('accepts valid email', () {
      expect(Validators.email('user@example.com'), isNull);
    });
  });
}
```

### Model Tests
```dart
// test/models/product_model_test.dart
void main() {
  group('ProductModel', () {
    test('fromJson parses correctly', () {
      final json = {
        'name': 'Milk',
        'price': 3.2,
        'rating': 4.5,
        'stock': 10,
      };
      final product = ProductModel.fromJson(json);
      expect(product.name, 'Milk');
      expect(product.price, 3.2);
    });
  });
}
```

## Widget Tests

### Component Tests
```dart
// test/components/afri_button_test.dart
void main() {
  testWidgets('AfriButton displays label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AfriButton(
          label: 'Add to Cart',
          onPressed: () {},
        ),
      ),
    );
    expect(find.text('Add to Cart'), findsOneWidget);
  });

  testWidgets('AfriButton calls onPressed', (tester) async {
    bool pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: AfriButton(
          label: 'Buy',
          onPressed: () => pressed = true,
        ),
      ),
    );
    await tester.tap(find.text('Buy'));
    expect(pressed, isTrue);
  });
}
```

### Screen Tests
```dart
// test/views/home_page_test.dart
void main() {
  testWidgets('HomePage shows categories', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(),
      ),
    );
    expect(find.text('Categories'), findsOneWidget);
  });
}
```

## Accessibility Testing

### Automated Accessibility Checks
```bash
flutter test test/accessibility_test.dart
```

Tests verify:
- All buttons have minimum 48x48dp touch targets
- Contrast ratios meet WCAG 2.1 AA (4.5:1 for text)
- All interactive elements have semantic labels
- Focus order is logical (top-to-bottom, left-to-right)

### Manual Accessibility Testing

**Android (TalkBack):**
1. Enable Settings → Accessibility → TalkBack
2. Navigate using 2-finger swipe left/right
3. Double-tap to activate
4. Verify all screens are readable top-to-bottom

**iOS (VoiceOver):**
1. Enable Settings → Accessibility → VoiceOver
2. Navigate using 1-finger swipe left/right
3. Double-tap to activate
4. Use Rotor for shortcuts

## Responsive Testing

Test across 4 device sizes:

| Device | Width | Key Checks |
|--------|-------|------------|
| Small Phone | 360px | 2-col grid, text fits, buttons tappable |
| Medium Phone | 390px | 2-col grid, proper spacing |
| Large Phone | 414px | 2-col optimized, full layout |
| Tablet | 768px+ | 3-4 col grid, side-by-side layouts |

```bash
# Use Flutter DevTools Device Preview
flutter run → press D → Device Preview
```

## Dark Mode Testing

For each screen, verify:
- [ ] Text contrast ≥ 4.5:1 on dark backgrounds
- [ ] Shadows visible with adjusted opacity
- [ ] Images render without white flash
- [ ] Input fields visible and focused states clear
- [ ] Icons distinct from background (≥ 3:1)

## Performance Testing

```bash
# Profile app performance
flutter run --profile

# Check for jank in Flutter DevTools
# Look for: >16ms frame times, memory leaks, unnecessary rebuilds
```

Checklist:
- [ ] 60fps animations (no dropped frames)
- [ ] App launch < 3 seconds
- [ ] Smooth scrolling (no jank)
- [ ] No memory leaks in Provider state
- [ ] Images cached properly (no re-downloads)

## CI/CD Testing

GitHub Actions runs on every PR:

```yaml
# .github/workflows/ci.yml
- dart analyze lib          # Lint check
- flutter test              # All tests
- flutter test --coverage   # Coverage report
- flutter build apk --debug # Build verification
```

## Code Coverage Goals

| Area | Target |
|------|--------|
| Services | 80%+ |
| Models | 90%+ |
| Utils | 85%+ |
| Components | 70%+ |
| Views | 50%+ (widget tests) |
| Overall | 60%+ |

## Writing New Tests

### Guidelines
1. One test file per source file
2. Use `group()` for logical grouping
3. Use descriptive test names: `test('returns null for invalid email')`
4. Always `setUp()` fresh instances
5. Mock external dependencies (Firebase, network)
6. Test both success and error paths

### Test Naming Convention
```
test/
├── {category}/
│   └── {source_file}_test.dart
```

Example: `lib/core/services/mpesa_service.dart` → `test/services/mpesa_service_test.dart`
