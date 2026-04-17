# Firestore Seed Execution Guide

**Last Updated:** April 15, 2026  
**Status:** Ready for Execution

## Overview

This guide walks through the complete data migration pipeline: sync images to Cloudinary, validate credentials, and seed all static + catalog data to Firestore. Designed for Spark Plan (no Storage limits).

---

## Prerequisites

1. **Environment Variables** (in `.env.development` or `.env.production`)
   ```bash
   CLOUDINARY_CLOUD_NAME=your_cloud_name
   CLOUDINARY_API_KEY=your_api_key
   CLOUDINARY_API_SECRET=your_api_secret
   CLOUDINARY_FOLDER=pro-grocery          # Optional; defaults to pro-grocery
   ```

2. **Repo Structure**
   - Local images in `assets/images/`
   - Cloudinary map output: `.cloudinary-map.json` (generated)
   - Seeder: `functions/src/seed_firestore.ts` (built to `functions/lib/seed_firestore.js`)
   - Firebase project initialized

3. **Node.js** >= 20 (for `functions/`)
4. **Dart** (for local image sync scripts)

---

## Step 1: Validate Cloudinary Credentials

Before syncing any images, confirm credentials are correct and working.

```bash
cd /home/devmahnx/Dev/Pro_Grocery
source .env.development   # Load environment variables
dart run bin/validate_cloudinary.dart
```

**Expected Output:**
```
✓ CLOUDINARY_CLOUD_NAME = your_cloud_name
✓ CLOUDINARY_API_KEY = xxx**** (32 chars)
✓ CLOUDINARY_API_SECRET = xxx**** (40 chars)
✓ All environment variables present
✓ API_KEY has no whitespace issues
✓ API_SECRET has no whitespace issues
✓ Signature generated successfully: ...
✓ Upload successful (200)
✓ Credentials are valid and working!
Remote URL: https://res.cloudinary.com/.../test_validation
```

If validation fails, check:
- Credentials match (not from different key pairs)
- No trailing spaces in `.env` file
- Status is "Active" in Cloudinary dashboard
- Cloud name matches between `.env` and dashboard

---

## Step 2: Sync Local Images to Cloudinary

Upload all images in `assets/images/` to Cloudinary and generate a mapping file.

```bash
cd /home/devmahnx/Dev/Pro_Grocery
./scripts/cloudinary_sync.sh
```

**Flags:**
- `--validate` – Report on credentials only (no sync)
- `--debug` – Show environment variable values during run
- `--env-file=.env.production` – Use production env instead of development
- (default) – Sync and generate `.cloudinary-map.json`

**Expected Output:**
```
Found 8 local images in assets/images.
Upload: assets/images/app_logo.png -> https://res.cloudinary.com/.../app_logo.png
Upload: assets/images/coupon_background_1.png -> https://res.cloudinary.com/.../coupon_background_1.png
...
Sync complete
- Uploaded: 8
- Reused: 0
- Map file: /absolute/path/to/.cloudinary-map.json
```

**Output:** `.cloudinary-map.json` in repo root with entries:
```json
{
  "generatedAt": "2026-04-15T...",
  "cloudName": "your_cloud_name",
  "folder": "pro-grocery",
  "entries": [
    {"fileName": "app_logo.png", "secureUrl": "https://res.cloudinary.com/.../app_logo.png"},
    ...
  ]
}
```

---

## Step 3: Dry-Run Seed Validation

Before writing to Firestore, validate the seed structure, reference integrity, and image coverage.

```bash
npm --prefix functions run seed:firestore -- \
  --dry-run \
  --map-file=/home/devmahnx/Dev/Pro_Grocery/.cloudinary-map.json
```

**Expected Output:**
```
Seed preview:
  - categories:     5
  - products:       9
  - bundles:        4
  - recipes:        2
  - offers:         2
  - coupons:        2
  - onboarding:     3
  - drawer_menu:    9
  - top_questions:  5
  - help_topics:    5
  - app_content:    4
  - map file:       /home/devmahnx/Dev/Pro_Grocery/.cloudinary-map.json
  - mode:           dry-run
```

If any validation error occurs, it will fail with a clear message (e.g., "Missing Cloudinary URL for..." or "references unknown productId").

---

## Step 4: Write Seed to Firestore (No Reset)

Seed all collections without clearing existing data. Safe for incremental updates.

```bash
npm --prefix functions run seed:firestore -- \
  --map-file=/home/devmahnx/Dev/Pro_Grocery/.cloudinary-map.json
```

**Expected Output:**
```
Seed preview:
  - categories:     5
  - products:       9
  - bundles:        4
  - recipes:        2
  - offers:         2
  - coupons:        2
  - onboarding:     3
  - drawer_menu:    9
  - top_questions:  5
  - help_topics:    5
  - app_content:    4
  - map file:       /home/devmahnx/Dev/Pro_Grocery/.cloudinary-map.json
  - mode:           write
Writing categories ...
Writing products ...
Writing bundles ...
Writing recipes ...
Writing offers ...
Writing coupons ...
Writing onboarding ...
Writing drawer_menu ...
Writing top_questions ...
Writing help_topics ...
Writing app_content ...
Seeding completed successfully.
```

**Verify in Firebase Console:**
- Navigate to **Firestore Database**
- Confirm collections exist: `categories`, `products`, `bundles`, `recipes`, `offers`, `coupons`, `onboarding`, `drawer_menu`, `top_questions`, `help_topics`, `app_content`
- Spot-check a product or recipe to confirm image URLs are valid https:// links

---

## Step 5: Deterministic Reset + Full Reseed

Use `--reset` when you need to wipe all seed data and start fresh (e.g., testing, data corrections, switching Cloudinary accounts).

```bash
npm --prefix functions run seed:firestore -- \
  --reset \
  --map-file=/home/devmahnx/Dev/Pro_Grocery/.cloudinary-map.json
```

**Expected Output:**
```
Reset enabled: deleting all seeded collections ...
  - deleted 5 docs from categories
  - deleted 9 docs from products
  - deleted 4 docs from bundles
  - deleted 2 docs from recipes
  - deleted 2 docs from offers
  - deleted 2 docs from coupons
  - deleted 3 docs from onboarding
  - deleted 9 docs from drawer_menu
  - deleted 5 docs from top_questions
  - deleted 5 docs from help_topics
  - deleted 4 docs from app_content
Writing categories ...
Writing products ...
Writing bundles ...
Writing recipes ...
Writing offers ...
Writing coupons ...
Writing onboarding ...
Writing drawer_menu ...
Writing top_questions ...
Writing help_topics ...
Writing app_content ...
Seeding completed successfully.
```

---

## Step 6: Verify Runtime Behavior

### Test in Flutter App

1. **Clear app cache** and restart
2. **Onboarding Screen** – Images and text load from Firestore (`onboarding` collection)
3. **Home Page**
   - Categories load from `categories` collection
   - "Our New Items" loads fresh products from `products`
   - "Popular Packs" loads bundles from `bundles`
4. **Deals Screen** – Flash deals fetch from `offers`
5. **Recipes Screen** – Recipes load with ingredient product links from `recipes`
6. **Drawer Menu** – Items and routes load from `drawer_menu`
7. **Help Page** – Top questions and help topics load from `top_questions` and `help_topics`
8. **Coupon Apply** – Code lookup resolves from `coupons` (e.g., code: `WELCOME10`)

---

## Troubleshooting

### Build Errors
```bash
npm --prefix functions run build
# If tsc fails, check:
# - Node version: node --version (should be >= 20)
# - Dependencies: npm --prefix functions install
```

### Map File Not Found
```bash
# Error: "Cloudinary map file not found"
# Ensure you've run Step 2 (cloudinary sync) and map file exists:
ls -la /home/devmahnx/Dev/Pro_Grocery/.cloudinary-map.json
```

### Reference Validation Failures
```bash
# Error: "Product product_xyz references unknown categoryId: category_abc"
# Check seed_firestore.ts:
# - categorySeeds has the referenced category ID
# - productSeeds productId matches exactly (case-sensitive)
```

### Image URL Failures
```bash
# Error: "Missing Cloudinary URL for required image: coupon_background_1.png"
# The image wasn't uploaded or filename is misspelled.
# Re-run cloudinary_sync and check .cloudinary-map.json entries.
```

### Firebase Auth Issues
```bash
# Error: "Permission denied" during write
# Ensure your Firebase credentials are set:
firebase login
firebase use your-project-id  # or set GOOGLE_APPLICATION_CREDENTIALS env var
```

---

## Full End-to-End Example

```bash
#!/bin/bash
set -euo pipefail
cd /home/devmahnx/Dev/Pro_Grocery

# 1. Validate credentials
source .env.development
dart run bin/validate_cloudinary.dart

# 2. Sync images
./scripts/cloudinary_sync.sh

# 3. Dry-run
npm --prefix functions run seed:firestore -- \
  --dry-run \
  --map-file=/home/devmahnx/Dev/Pro_Grocery/.cloudinary-map.json

# 4. Full reseed (destructive - use cautiously)
npm --prefix functions run seed:firestore -- \
  --reset \
  --map-file=/home/devmahnx/Dev/Pro_Grocery/.cloudinary-map.json

echo "✓ Seeding complete. Verify in Firebase Console and app."
```

---

## Collection Specifications

See [FIRESTORE_COLLECTIONS_CONTRACT.md](FIRESTORE_COLLECTIONS_CONTRACT.md) for detailed schema, field types, and reference rules for all seeded collections.

---

## Next Steps

1. **Flutter Providers** (optional) – Create Firestore-backed providers for onboarding, drawer, help content to replace local constants
2. **Admin UI** (optional) – Build CMS for editing coupons, offers, FAQs, etc. without reseeding
3. **CI/CD** (optional) – Automate seed stage in deployment pipeline

