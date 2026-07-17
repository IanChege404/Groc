# Component Library

## Overview

Pro Grocery includes 23+ reusable UI components in `lib/core/components/`. All components follow the `Afri*` naming convention, support light/dark themes, meet WCAG 2.1 AA accessibility requirements (48×48dp touch targets, semantic labels), and are responsive.

## Component Index

| Component | File | Purpose | Touch Target |
|-----------|------|---------|-------------|
| `AfriButton` | `afri_button.dart` | Primary action button with haptic feedback | 48×48dp |
| `AfriChip` | `afri_chip.dart` | Filter/tag chip with selection state | 48×48dp |
| `AfriEmptyState` | `afri_empty_state.dart` | Empty state placeholder with illustration | N/A |
| `AfriErrorState` | `afri_error_state.dart` | Error state with retry action | 48×48dp |
| `AfriTextField` | `afri_text_field.dart` | Form input with validation, labels, errors | 56dp height |
| `AppBackButton` | `app_back_button.dart` | Navigation back button | 48×48dp |
| `AppRadio` | `app_radio.dart` | Custom radio button | 48×48dp |
| `AppSettingsTile` | `app_settings_tile.dart` | Settings row with icon, label, action | 48dp height |
| `BundleTileSquare` | `bundle_tile_square.dart` | Bundle product card with pricing | 48×48dp |
| `BuyNowRowButton` | `buy_now_row_button.dart` | Row with price + Buy Now button | 48×48dp |
| `DottedDivider` | `dotted_divider.dart` | Dotted line separator | N/A |
| `NetworkImage` | `network_image.dart` | Cached image with loading/error states | N/A |
| `PriceAndQuantity` | `price_and_quantity.dart` | Price display with quantity selector | 48×48dp |
| `ProductImagesSlider` | `product_images_slider.dart` | Image carousel with wishlist + dots | 48×48dp |
| `ProductTileSquare` | `product_tile_square.dart` | Product card with favorites, rating, price | 48×48dp |
| `ReferralCard` | `referral_card.dart` | Referral program card | 48×48dp |
| `RetryableErrorView` | `retryable_error_view.dart` | Error view with retry button | 48×48dp |
| `ReviewRowButton` | `review_row_button.dart` | Review action with theme support | 48×48dp |
| `ReviewStars` | `review_stars.dart` | Interactive 5-star rating with animations | 44dp per star |
| `Skeleton` | `skeleton.dart` | Loading skeleton placeholder | N/A |
| `SocialProofWidget` | `social_proof_widget.dart` | Social proof notification popup | N/A |
| `TitleAndActionButton` | `title_and_action_button.dart` | Section header with "View All" button | 48×48dp |
| `WishlistShareWidget` | `wishlist_share_widget.dart` | Wishlist sharing interface | 48×48dp |

## Usage Examples

### AfriButton
```dart
AfriButton(
  label: 'Add to Cart',
  onPressed: () => cartProvider.addToCart(product),
  isLoading: false,
  isEnabled: true,
)
```

### ProductTileSquare
```dart
ProductTileSquare(
  product: productModel,
  onTap: () => context.push('/productDetails', extra: {'product': product}),
  onFavorite: () => wishlistProvider.toggle(product.id),
)
```

### ReviewStars
```dart
ReviewStars(
  rating: product.rating,
  interactive: true,
  onRatingChanged: (rating) => submitRating(rating),
)
```

### AfriTextField
```dart
AfriTextField(
  label: 'Email',
  hintText: 'Enter your email',
  keyboardType: TextInputType.emailAddress,
  validator: Validators.email,
  isRequired: true,
)
```

### Skeleton (Loading)
```dart
Skeleton(
  width: double.infinity,
  height: 200,
  borderRadius: BorderRadius.circular(12),
)
```

### TitleAndActionButton
```dart
TitleAndActionButton(
  title: 'Our New Items',
  actionLabel: 'View All',
  onAction: () => context.push('/newItems'),
)
```

### PriceAndQuantity
```dart
PriceAndQuantity(
  price: product.price,
  quantity: quantity,
  onQuantityChanged: (qty) => updateQuantity(qty),
  minQuantity: 1,
  maxQuantity: product.stock,
)
```

## Theming

All components read from the current theme:

```dart
// Components use Theme.of(context) for colors
Container(
  color: Theme.of(context).colorScheme.surface,
  child: Text(
    'Label',
    style: Theme.of(context).textTheme.bodyLarge,
  ),
)
```

Never hardcode colors in component code — always use theme tokens.

## Accessibility Requirements

Every interactive component must:
1. **Touch targets:** Minimum 48×48dp (buttons, icons, inputs)
2. **Semantic labels:** `Semantics(label: 'Add to Cart', child: ...)`
3. **Contrast:** Text ≥ 4.5:1, large text ≥ 3:1
4. **Focus indicators:** Visible focus ring for keyboard navigation
5. **Screen reader support:** `Semantics` wrapper for custom widgets

## Adding New Components

1. Create file: `lib/core/components/afri_{name}.dart`
2. Follow naming: `Afri{Name}` for public components
3. Accept `Key? key` as first parameter
4. Use `Theme.of(context)` for all colors
5. Add `Semantics` wrapper for accessibility
6. Ensure 48×48dp minimum touch target
7. Support both light and dark mode
8. Add to this documentation
