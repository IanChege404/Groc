# Checkout Address Modernization — Map-Based Location Picker

## Overview
Modernize the address input flow in the checkout process by adding Google Maps integration with place autocomplete, device GPS, draggable pin location selection, and reverse geocoding to auto-fill address fields.

## Scope
- Simple Checkout path (active route `/checkoutPage`)
- New address form (`/newAddress`)
- Address list page (`/deliveryAddress`)

---

## Phase 1: Dependencies & Configuration

### 1.1 Add packages to `pubspec.yaml`
```yaml
google_maps_flutter: ^2.10.0
geolocator: ^13.0.2
geocoding: ^3.0.0
```

### 1.2 Platform Configuration

**Android** (`android/app/src/main/AndroidManifest.xml`):
- Add `ACCESS_FINE_LOCATION` and `ACCESS_COARSE_LOCATION` permissions
- Add Google Maps API key as `<meta-data>` in `<application>`:
  ```xml
  <meta-data android:name="com.google.android.geo.API_KEY"
             android:value="${GOOGLE_MAPS_API_KEY}"/>
  ```
- Note: The key will be loaded from a `local.properties` or `secrets.properties` file (not committed) for security

**iOS** (`ios/Runner/Info.plist`):
- Add `NSLocationWhenInUseUsageDescription` and `NSLocationAlwaysUsageDescription` keys

### 1.3 Environment variables
- Add `GOOGLE_MAPS_API_KEY` to `.env.example` (placeholder only, not committed)
- Load via `flutter_dotenv` at app startup

---

## Phase 2: AddressModel

### 2.1 Create `lib/core/models/address_model.dart`
- Typed model class replacing raw `Map<String, dynamic>`
- Fields: `id`, `label`, `phone`, `line1`, `line2`, `city`, `state`, `zipCode`, `isDefault`, `userId`, `latitude`, `longitude`, `createdAt`, `updatedAt`
- `factory AddressModel.fromFirestore(DocumentSnapshot)` — parses existing + new fields
- `Map<String, dynamic> toFirestore()` — serializes for Firestore write
- `String get fullAddress` — assembled display string
- `copyWith()` method for immutability

### 2.2 Backward compatibility
- All new fields (`latitude`, `longitude`) are nullable — existing documents without them still parse correctly
- No Firestore migration needed

---

## Phase 3: Location Picker Screen

### 3.1 Create `lib/views/profile/address/map_location_picker.dart`
A full-screen Google Maps widget that:
- Displays a Google Map centered on the user's last known location or Nairobi (default)
- Shows a draggable pin in the center of the map
- As the user drags the map, the pin stays centered and the address updates
- "Current Location" FAB button — uses `geolocator` to get device GPS, centers map there
- Search bar at top — `Google Places Autocomplete` text field (using `google_maps_flutter` + HTTP API)
- Bottom sheet showing the selected address with an "Use This Location" button
- On confirm: returns `MapLocation` with `latitude`, `longitude`, and reverse-geocoded address components

### 3.2 Create `lib/core/models/map_location.dart`
- Simple data class: `latitude`, `longitude`, `street`, `city`, `state`, `zipCode`, `country`, `formattedAddress`

### 3.3 Reverse Geocoding
- Use `geocoding` package's `placemarkFromCoordinates()` to convert lat/lng → address components
- Auto-populate: `street` → `line1`, `city` → `city`, `state` → `state`, `postalCode` → `zipCode`

---

## Phase 4: Update New Address Form

### 4.1 Modify `lib/views/profile/address/new_address_page.dart`
- Add a "Pick Location on Map" button at the top of the form
- Tapping it opens `MapLocationPicker` as a full-screen modal
- On return, auto-fills address fields from the selected location
- User can still manually edit/override any field
- Add `latitude` and `longitude` to the saved Firestore document
- Show a small map preview (static) showing the selected location below the address fields

### 4.2 UX Flow
```
New Address Page
  ┌─────────────────────────────┐
  │  [🗺 Pick Location on Map]  │  ← Prominent button
  │                             │
  │  Full Name: [_________]     │
  │  Phone:     [_________]     │
  │                             │
  │  ┌─ Map Preview ─────────┐ │  ← Shows selected location
  │  │   📍 (lat, lng)       │ │
  │  └───────────────────────┘ │
  │                             │
  │  Address Line 1: [auto-fill]│  ← Pre-filled from geocoding
  │  Address Line 2: [_________]│
  │  City:     [auto-fill]      │
  │  State:    [auto-fill]      │
  │  Zip Code: [auto-fill]      │
  │                             │
  │  ☐ Make Default Address     │
  │                             │
  │  [    Save Address    ]     │
  └─────────────────────────────┘
```

---

## Phase 5: Update Firestore Service

### 5.1 Modify `lib/core/services/firestore_service.dart`
- `addUserAddress()` — accept optional `latitude`/`longitude` in the data map
- `updateUserAddress()` — same
- No schema changes needed — Firestore is schemaless, new fields just appear

---

## Phase 6: Update Checkout Address Selector

### 6.1 Modify `lib/views/cart/components/checkout_address_selector.dart`
- Auto-select the default address on load (currently user must manually select)
- Use `userAddressesProvider` instead of raw `FutureBuilder` for consistency
- Show address preview with a small map thumbnail (static Google Maps image) if lat/lng exists

### 6.2 Modify `lib/views/cart/checkout_page.dart`
- Pass `latitude`/`longitude` through to the order model
- Update `PayNowButton` to include lat/lng in the order creation

---

## Phase 7: Order Model Update

### 7.1 Modify `lib/core/models/order_model.dart`
- Add nullable `latitude` and `longitude` fields to `OrderModel`
- Update `fromFirestore`, `toFirestore`, and `copyWith`

---

## Phase 8: Localization

### 8.1 Add strings to `lib/core/l10n/en.arb` and `lib/core/l10n/sw.arb`
- `pickLocationOnMap` / `Chagua Eneo kwenye Ramani`
- `useThisLocation` / `Tumia Eneo Hili`
- `currentLocation` / `Eneo la Sasa`
- `searchAddress` / `Tafuta Anwani`
- `locationPermissionDenied` / `Ruhusa ya Eneo Imekataliwa`
- `enableLocationServices` / "Washa Huduma za Eneo"
- `dragToAdjust` / `Sogea Kubadilisha`

---

## Files to Create
| File | Purpose |
|---|---|
| `lib/core/models/address_model.dart` | Typed address model with lat/lng |
| `lib/core/models/map_location.dart` | Map picker result data class |
| `lib/views/profile/address/map_location_picker.dart` | Full-screen Google Maps picker |
| `lib/views/profile/address/components/map_preview_widget.dart` | Small static map preview for address form |

## Files to Modify
| File | Change |
|---|---|
| `pubspec.yaml` | Add `google_maps_flutter`, `geolocator`, `geocoding` |
| `.env.example` | Add `GOOGLE_MAPS_API_KEY` placeholder |
| `android/app/src/main/AndroidManifest.xml` | Add location permissions + Maps API key meta-data |
| `ios/Runner/Info.plist` | Add location usage descriptions |
| `lib/views/profile/address/new_address_page.dart` | Add map picker button, map preview, lat/lng save |
| `lib/views/cart/components/checkout_address_selector.dart` | Auto-select default, use provider |
| `lib/views/cart/checkout_page.dart` | Pass lat/lng to order |
| `lib/core/models/order_model.dart` | Add lat/lng fields |
| `lib/core/services/firestore_service.dart` | Handle lat/lng in address CRUD |
| `lib/core/l10n/en.arb` | Add map/location strings |
| `lib/core/l10n/sw.arb` | Add Swahili translations |
| `lib/views/profile/address/address_page.dart` | Show map preview on address cards |

---

## Execution Order
1. Add dependencies + platform config
2. Create `AddressModel`
3. Create `MapLocation` model
4. Create `MapLocationPicker` screen
5. Create `MapPreviewWidget`
6. Update `NewAddressPage` to integrate map picker
7. Update `FirestoreService` for lat/lng
8. Update `OrderModel` for lat/lng
9. Update `AddressSelector` (auto-select default, use provider)
10. Update `CheckoutPage` to pass lat/lng
11. Update `AddressPage` to show map previews
12. Add localization strings
13. Run `dart analyze lib` and `dart format lib`

## Verification
- `dart analyze lib` — zero issues
- `dart format --set-exit-if-changed lib` — all formatted
- Manual: Add address via map picker → verify lat/lng saved to Firestore
- Manual: Checkout flow → verify default address auto-selected
- Manual: Verify existing addresses (without lat/lng) still display correctly

## Notes
- Google Maps API key must be obtained by the user (free tier: $200/month credit)
- The map picker works on both Android and iOS
- No changes to the wizard checkout path (it's WIP)
- Lat/lng fields are nullable — fully backward compatible
