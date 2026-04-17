# Firestore Collections Contract

**Version:** 1.0  
**Last Updated:** April 15, 2026  
**Source:** `functions/src/seed_firestore.ts`

---

## Overview

This contract defines all Firestore collections seeded by the Pro Grocery app, their required fields, data types, references, and validation rules. Use this as the authoritative schema specification.

**Collection List** (in write order):
1. `categories`
2. `products`
3. `bundles`
4. `recipes`
5. `offers`
6. `coupons`
7. `onboarding`
8. `drawer_menu`
9. `top_questions`
10. `help_topics`
11. `app_content`

---

## Catalog Collections

### 1. `categories`

**Purpose:** Product category taxonomy used for filtering and navigation.

**Document ID:** Stable string (e.g., `category_dairy_eggs`)

| Field | Type | Required | Example | Notes |
|-------|------|----------|---------|-------|
| `name` | string | ✓ | "Dairy & Eggs" | Display name for UI |
| `description` | string | ✓ | "Fresh milk, yogurt..." | Brief category description |
| `icon` | string (URL) | ✓ | `https://res.cloudinary.com/...` | Cloudinary HTTPS URL |
| `color` | string | ✓ | `#E8F5E9` | Hex color for UI theming |
| `createdAt` | timestamp | ✓ | `Timestamp.now()` | Server timestamp |

**Validation Rules:**
- `name` and `description` must not be empty
- `icon` must be a valid HTTPS URL (from Cloudinary map)
- `color` must be a valid hex color

**Seeded Documents:** 5
- `category_dairy_eggs`
- `category_bakery`
- `category_frozen_foods`
- `category_pantry_staples`
- `category_meat_seafood`

**Referenced By:** `products`, `bundles`, `recipes`, `offers`, `coupons`

---

### 2. `products`

**Purpose:** Individual product catalog entries with pricing, inventory, and ratings.

**Document ID:** Stable string (e.g., `product_fresh_whole_milk_1litre`)

| Field | Type | Required | Example | Notes |
|-------|------|----------|---------|-------|
| `name` | string | ✓ | "Fresh Whole Milk" | Product display name |
| `description` | string | ✓ | "Fresh whole milk, pasteurized..." | Detailed product info |
| `category` | string | ✓ | "Dairy & Eggs" | Human-readable category name |
| `categoryId` | string | ✓ | `category_dairy_eggs` | **FK** to `categories.id` |
| `price` | number | ✓ | 3.2 | Current selling price |
| `mainPrice` | number | ✓ | 4.0 | Original/list price |
| `stock` | number | ✓ | 89 | Available inventory count |
| `image` | string (URL) | ✓ | `https://res.cloudinary.com/...` | Primary product image (Cloudinary) |
| `images` | array<string (URL)> | ✓ | `[...]` | List of product images |
| `rating` | number | ✓ | 4.5 | Average rating (0–5) |
| `reviewCount` | number | ✓ | 134 | Number of reviews |
| `weight` | string | ✓ | "1 Litre" | Product weight/size |
| `createdAt` | timestamp | ✓ | `Timestamp.now()` | Creation timestamp |
| `updatedAt` | timestamp | ✓ | `Timestamp.now()` | Last update timestamp |

**Validation Rules:**
- `categoryId` must reference existing `categories` document
- `price` ≤ `mainPrice`
- `stock` ≥ 0
- `image` and all `images[]` must be valid HTTPS URLs
- `rating` must be 0 ≤ n ≤ 5
- `weight` must not be empty

**Seeded Documents:** 9
- `product_perrys_ice_cream_banana_800gm`
- `product_vanilla_ice_cream_banana_500gm`
- `product_premium_meat_selection_1kg`
- `product_organic_onions_1kg`
- `product_fresh_tomatoes_1kg`
- `product_premium_cooking_oil_1litre`
- `product_sea_salt_premium_grade_500gm`
- `product_mixed_spice_collection_250gm`
- `product_fresh_whole_milk_1litre`

**Referenced By:** `bundles.productIds[]`, `recipes.ingredients[].productId`, `offers.productId`

---

### 3. `bundles`

**Purpose:** Curated product bundles/packs with discounted pricing.

**Document ID:** Stable string (e.g., `bundle_essential_cooking_pack`)

| Field | Type | Required | Example | Notes |
|-------|------|----------|---------|-------|
| `name` | string | ✓ | "Essential Cooking Pack" | Bundle display name |
| `description` | string | ✓ | "Everything you need for basic cooking..." | Bundle summary |
| `image` | string (URL) | ✓ | `https://res.cloudinary.com/...` | Primary bundle image |
| `images` | array<string (URL)> | ✓ | `[...]` | Bundle images |
| `itemNames` | array<string> | ✓ | `["Onion 1Kg", "Cooking Oil 1L", ...]` | Display names of bundled items |
| `productIds` | array<string> | ✓ | `["product_organic_onions_1kg", ...]` | **FK array** to `products.id` |
| `price` | number | ✓ | 12.5 | Bundle selling price |
| `mainPrice` | number | ✓ | 16.5 | Bundle original price |
| `rating` | number | ✓ | 4.6 | Average rating (0–5) |
| `reviewCount` | number | ✓ | 234 | Number of reviews |
| `createdAt` | timestamp | ✓ | `Timestamp.now()` | Creation timestamp |
| `updatedAt` | timestamp | ✓ | `Timestamp.now()` | Last update timestamp |

**Validation Rules:**
- `itemNames.length` must equal `productIds.length`
- Every element in `productIds` must reference existing `products` document
- `price` ≤ `mainPrice`
- `image` and all `images[]` must be valid HTTPS URLs
- `rating` must be 0 ≤ n ≤ 5

**Seeded Documents:** 4
- `bundle_essential_cooking_pack`
- `bundle_premium_spices`
- `bundle_frozen_dessert`
- `bundle_complete_breakfast`

---

## Content & Dynamic Collections

### 4. `recipes`

**Purpose:** Recipe/cooking guides with ingredient links to products.

**Document ID:** Stable string (e.g., `recipe_001`, `recipe_002`)

| Field | Type | Required | Example | Notes |
|-------|------|----------|---------|-------|
| `name` | string | ✓ | "Kenyan Beef Stew" | Recipe title |
| `description` | string | ✓ | "A hearty traditional..." | Recipe summary |
| `imageUrl` | string (URL) | ✓ | `https://res.cloudinary.com/...` | Recipe image |
| `servings` | number | ✓ | 4 | Default serving count |
| `prepTimeMinutes` | number | ✓ | 15 | Prep time in minutes |
| `cookTimeMinutes` | number | ✓ | 60 | Cook time in minutes |
| `difficulty` | enum | ✓ | `"medium"` | One of: `"easy"`, `"medium"`, `"hard"` |
| `ingredients` | array<object> | ✓ | (see below) | Array of ingredient objects |
| `instructions` | array<string> | ✓ | `["Cut beef...", ...]` | Step-by-step instructions |
| `tags` | array<string> | ✓ | `["kenyan", "beef", ...]` | Search/filter tags |
| `rating` | number | ✓ | 4.5 | Average rating (0–5) |
| `reviewCount` | number | ✓ | 24 | Number of reviews |
| `createdAt` | timestamp | ✓ | `Timestamp.now()` | Creation timestamp |

**Ingredient Object Structure:**

| Field | Type | Required | Example |
|-------|------|----------|---------|
| `productId` | string | ✓ | `product_premium_meat_selection_1kg` |
| `productName` | string | ✓ | "Premium Meat (500g)" |
| `quantity` | number | ✓ | 1 |
| `unit` | string | ✓ | `"pack"` |
| `imageUrl` | string (URL) | ✗ | `https://res.cloudinary.com/...` |
| `price` | number | ✗ | 15 |

**Validation Rules:**
- Every `ingredients[].productId` must reference existing `products` document
- `difficulty` must be exactly one of the enum values
- `prepTimeMinutes` ≥ 0, `cookTimeMinutes` ≥ 0
- `servings` ≥ 1
- `rating` must be 0 ≤ n ≤ 5

**Seeded Documents:** 2
- `recipe_001` – Kenyan Beef Stew
- `recipe_002` – Spiced Tomato Onion Mix

---

### 5. `offers` (Flash Deals)

**Purpose:** Time-limited promotional deals and flash sales.

**Document ID:** Stable string (e.g., `deal_001`, `deal_002`)

| Field | Type | Required | Example | Notes |
|-------|------|----------|---------|-------|
| `productId` | string | ✓ | `product_fresh_tomatoes_1kg` | **FK** to `products.id` |
| `productName` | string | ✓ | "Fresh Tomatoes 1kg" | Display name (cached for UI) |
| `imageUrl` | string (URL) | ✓ | `https://res.cloudinary.com/...` | Deal image |
| `originalPrice` | number | ✓ | 6.5 | Original product price |
| `dealPrice` | number | ✓ | 5 | Discounted price |
| `discountPercentage` | number | ✓ | 23 | Discount as percentage (0–100) |
| `stockLeft` | number | ✓ | 50 | Remaining stock for deal |
| `totalStock` | number | ✓ | 100 | Maximum deal stock |
| `startTime` | timestamp | ✓ | `Timestamp.fromDate(...)` | Deal start (UTC) |
| `endTime` | timestamp | ✓ | `Timestamp.fromDate(...)` | Deal end (UTC) |
| `isActive` | boolean | ✓ | `true` | Enable/disable deal |
| `categoryId` | string | ✓ | `category_pantry_staples` | **FK** to `categories.id` |

**Validation Rules:**
- `productId` must reference existing `products` document
- `categoryId` must reference existing `categories` document
- `dealPrice` < `originalPrice`
- `stockLeft` ≤ `totalStock`
- `startTime` < `endTime`
- `discountPercentage` must match: `(originalPrice - dealPrice) / originalPrice * 100`
- `imageUrl` must be valid HTTPS URL

**Seeded Documents:** 2
- `deal_001` – Fresh Tomatoes
- `deal_002` – Fresh Whole Milk

**Consumer:** Flutter provider `flashDealsProvider` filters by `isActive=true` and `endTime > now`

---

### 6. `coupons`

**Purpose:** Discount codes and promotional coupons for checkout.

**Document ID:** Stable string (e.g., `coupon_welcome_10`, `coupon_dairy_5`)

| Field | Type | Required | Example | Notes |
|-------|------|----------|---------|-------|
| `code` | string | ✓ | `"WELCOME10"` | Uppercase coupon code |
| `title` | string | ✓ | "10% Off Welcome Coupon" | Display title |
| `discount` | number | ✓ | 10 | Discount amount (percentage or fixed) |
| `discountType` | enum | ✓ | `"percentage"` | One of: `"percentage"`, `"fixed"` |
| `expireDate` | timestamp | ✓ | `Timestamp.fromDate(...)` | Expiry date (UTC) |
| `isUsed` | boolean | ✓ | `false` | User has not redeemed globally |
| `applicableCategories` | array<string> | ✓ | `["category_dairy_eggs"]` | **FK array** to `categories.id` |
| `description` | string | ✗ | "Get 10% off your first order" | Optional coupon description |
| `minPurchaseAmount` | number | ✗ | 20 | Minimum cart value required |
| `maxDiscount` | number | ✗ | 5 | Maximum discount cap |
| `imageUrl` | string (URL) | ✓ | `https://res.cloudinary.com/...` | Coupon card background |
| `createdAt` | timestamp | ✓ | `Timestamp.now()` | Creation timestamp |

**Validation Rules:**
- `code` must be uppercase alphanumeric
- `discountType` must be exactly `"percentage"` or `"fixed"`
- If `discountType="percentage"`: `discount` must be 0 ≤ n ≤ 100
- If `discountType="fixed"`: `discount` > 0
- `expireDate` must be in future
- Every element in `applicableCategories` must reference existing `categories` document
- `imageUrl` must be valid HTTPS URL
- If `minPurchaseAmount` is set, `maxDiscount` should also be set

**Seeded Documents:** 2
- `coupon_welcome_10` – 10% off with constraints
- `coupon_dairy_5` – 5 fixed discount on dairy

**Consumer:** `FirestoreService.getCouponByCode(code)` looks up by `code` field

---

## App Content & UI Collections

### 7. `onboarding`

**Purpose:** Onboarding carousel slides shown on first app launch.

**Document ID:** Stable string (e.g., `onboarding_001`, `onboarding_002`)

| Field | Type | Required | Example | Notes |
|-------|------|----------|---------|-------|
| `headline` | string | ✓ | "Browse all the category" | Slide header text |
| `description` | string | ✓ | "In aliquip aute exercitation..." | Slide body text |
| `imageUrl` | string (URL) | ✓ | `https://i.imgur.com/...` | Slide image |
| `order` | number | ✓ | 0 | Display order in carousel |
| `isActive` | boolean | ✓ | `true` | Enable/disable slide |
| `updatedAt` | timestamp | ✓ | `Timestamp.now()` | Last update |

**Validation Rules:**
- `order` must be sequential (0, 1, 2, ...)
- `imageUrl` must be valid HTTPS URL
- `headline` and `description` must not be empty

**Seeded Documents:** 3
- `onboarding_001` – Browse categories
- `onboarding_002` – Discounts & Offers
- `onboarding_003` – Fast Delivery

**Consumer:** Flutter page `OnboardingPage` reads from this collection

---

### 8. `drawer_menu`

**Purpose:** Navigation menu items displayed in app drawer.

**Document ID:** Stable string (e.g., `drawer_001`, `drawer_002`)

| Field | Type | Required | Example | Notes |
|-------|------|----------|---------|-------|
| `label` | string | ✓ | "Invite Friend" | Display text |
| `route` | string | ✗ | `"aboutUs"` | App route name (null if no navigation) |
| `order` | number | ✓ | 0 | Display order in menu |
| `isActive` | boolean | ✓ | `true` | Enable/disable menu item |
| `updatedAt` | timestamp | ✓ | `Timestamp.now()` | Last update |

**Validation Rules:**
- `label` must not be empty
- `order` must be sequential
- `route` must match app route names if provided

**Seeded Documents:** 9
- `drawer_001` – Invite Friend
- `drawer_002` – About Us
- `drawer_003` – FAQs
- `drawer_004` – Terms & Conditions
- `drawer_005` – Help Center
- `drawer_006` – Rate This App
- `drawer_007` – Privacy Policy
- `drawer_008` – Contact Us
- `drawer_009` – Logout

**Consumer:** Flutter page `DrawerPage` reads from this collection

---

### 9. `top_questions`

**Purpose:** FAQ quick links shown in Help Center.

**Document ID:** Stable string (e.g., `question_001`, `question_002`)

| Field | Type | Required | Example | Notes |
|-------|------|----------|---------|-------|
| `question` | string | ✓ | "How do I return my Items" | Question text |
| `order` | number | ✓ | 0 | Display order |
| `isActive` | boolean | ✓ | `true` | Enable/disable |
| `updatedAt` | timestamp | ✓ | `Timestamp.now()` | Last update |

**Validation Rules:**
- `question` must not be empty
- `order` must be sequential

**Seeded Documents:** 5
- `question_001` – Return policy
- `question_002` – Collection points
- `question_003` – What is Grocery
- `question_004` – Add delivery address
- `question_005` – Sticker price

**Consumer:** Flutter component `TopQuestions` in Help page

---

### 10. `help_topics`

**Purpose:** Help Center topic categories.

**Document ID:** Stable string (e.g., `topic_001`, `topic_002`)

| Field | Type | Required | Example | Notes |
|-------|------|----------|---------|-------|
| `label` | string | ✓ | "My Account" | Topic name |
| `order` | number | ✓ | 0 | Display order |
| `isActive` | boolean | ✓ | `true` | Enable/disable |
| `updatedAt` | timestamp | ✓ | `Timestamp.now()` | Last update |

**Validation Rules:**
- `label` must not be empty
- `order` must be sequential

**Seeded Documents:** 5
- `topic_001` – My Account
- `topic_002` – Payment and Wallet
- `topic_003` – Shipping & Delivery
- `topic_004` – Vouchers & Promotions
- `topic_005` – Ordering

**Consumer:** Flutter component `HelpTopics` in Help page

---

### 11. `app_content`

**Purpose:** Global app metadata, images, and static content.

**Document ID:** Fixed strings: `app_images`, `app_assets`, `faq`, `contact_us`

#### Document: `app_images`

| Field | Type | Required | Example |
|-------|------|----------|---------|
| `logo` | string (URL) | ✓ | `https://i.imgur.com/9EsY2t6.png` |
| `homeBanner` | string (URL) | ✓ | `https://i.imgur.com/8hBIsS5.png` |
| `illustration404` | string (URL) | ✓ | `https://i.imgur.com/SGTzEiC.png` |
| `introBackground1` | string (URL) | ✓ | `https://i.imgur.com/YQ9twZx.png` |
| `introBackground2` | string (URL) | ✓ | `https://i.imgur.com/3hgB1or.png` |
| `numberVerification` | string (URL) | ✓ | `https://i.imgur.com/tCCmY3I.png` |
| `verified` | string (URL) | ✓ | `https://i.imgur.com/vF1jB6b.png` |
| `couponBackgrounds` | array<string (URL)> | ✓ | `[url1, url2, url3, url4]` |
| `updatedAt` | timestamp | ✓ | `Timestamp.now()` |

#### Document: `app_assets`

| Field | Type | Required | Example |
|-------|------|----------|---------|
| `images` | array<string (URL)> | ✓ | `[Cloudinary URLs...]` |
| `directories` | object | ✓ | `{"fonts": "assets/fonts/", ...}` |
| `updatedAt` | timestamp | ✓ | `Timestamp.now()` |

#### Document: `faq`

| Field | Type | Required | Example |
|-------|------|----------|---------|
| `items` | array<object> | ✓ | (see below) |
| `updatedAt` | timestamp | ✓ | `Timestamp.now()` |

FAQ Item Object:
| Field | Type | Required |
|-------|------|----------|
| `title` | string | ✓ |
| `paragraph` | string | ✓ |

#### Document: `contact_us`

| Field | Type | Required | Example |
|-------|------|----------|---------|
| `phones` | array<string> | ✓ | `["+8801710000000", ...]` |
| `email` | string | ✓ | `"jonarban45@gmail.com"` |
| `address` | string | ✓ | `"26/C Mohammadpur, Dhaka..."` |
| `mapImageUrl` | string (URL) | ✓ | `https://i.imgur.com/nys3Bxw.png` |
| `updatedAt` | timestamp | ✓ | `Timestamp.now()` |

---

## Reset Behavior

The `--reset` flag in the seeder deletes these collections before writing:

1. `categories`
2. `products`
3. `bundles`
4. `recipes`
5. `offers`
6. `coupons`
7. `onboarding`
8. `drawer_menu`
9. `top_questions`
10. `help_topics`
11. `app_content`

**User-scoped data is NOT deleted:**
- `users/{userId}/*` (carts, addresses, payments, notifications, wallet, settings)
- `wishlist`
- `orders`

---

## Image Strategy

**All image URLs must be:**
1. **HTTPS URLs** (secure)
2. **From Cloudinary** (except onboarding, intro backgrounds, and core UI images which are hardcoded)
3. **Resolved from `.cloudinary-map.json`** at seed time

**Cloudinary URL format:**
```
https://res.cloudinary.com/{CLOUD_NAME}/image/upload/{FOLDER}/{PUBLIC_ID}
```

**Fallback:** For auth screens and onboarding images not yet in Cloudinary, some hardcoded URLs are allowed (e.g., `https://i.imgur.com/...`).

---

## Reference Integrity

Graph of foreign key references:

```
categories
├─ products.categoryId → categories.id
├─ bundles (no direct ref, but items are products)
├─ recipes (ingredients ref products)
├─ offers.categoryId → categories.id
└─ coupons.applicableCategories[] → categories.id

products
├─ bundles.productIds[] → products.id
├─ recipes.ingredients[].productId → products.id
└─ offers.productId → products.id
```

**Validation:** The seeder validates all references before writing. If a reference is missing, seeding aborts with a clear error.

---

## Notes for Developers

1. **Timestamps:** All `createdAt`, `updatedAt`, `expireDate`, `startTime`, `endTime` are server timestamps (prefer `Timestamp` objects over ISO strings for Firestore compatibility).

2. **String IDs:** All document IDs follow a stable naming convention (lowercase, underscores, semantic meaning):
   - Categories: `category_{descriptor}` (e.g., `category_dairy_eggs`)
   - Products: `product_{descriptor}_{weight}` (e.g., `product_fresh_whole_milk_1litre`)
   - Bundles: `bundle_{descriptor}` (e.g., `bundle_essential_cooking_pack`)
   - Recipes: `recipe_{number}` (e.g., `recipe_001`)
   - Offers: `deal_{number}` (e.g., `deal_001`)
   - Coupons: `coupon_{descriptor}` (e.g., `coupon_welcome_10`)
   - UI items: Incrementally named (e.g., `onboarding_001`, `drawer_001`)

3. **Nullability:** Fields marked `✗` are optional (null allowed). All others are required.

4. **Array Consistency:** When a collection has `itemNames` and `productIds`, lengths must match and correspond 1:1.

5. **Enum Validation:** Enums like `difficulty` and `discountType` must be exact string matches.

---

## Export/Audit

To export the current seeded data for audit:

```bash
firebase firestore:export build/firestore_backup_YYYY-MM-DD.zip
```

To view a single collection's schema:

```bash
firebase firestore:describe-index collections/{collectionName}
```

---

END OF CONTRACT
