# Phase 4 Features - Quick Start Guide

Get up and running with Phase 4 features in minutes.

---

## 🚀 Setup (5 minutes)

### 1. Add API Key
```bash
# Edit .env.development
ANTHROPIC_API_KEY=sk-ant-your-actual-key-here
```

### 2. Get Dependencies
```bash
flutter pub get
```

### 3. Build Generated Code (if needed)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Run App
```bash
flutter run
```

✅ Done! All 5 features are now active.

---

## 📍 Feature Locations

### 1. Social Proof Widgets
**Where to use:**
```dart
// In any product card or listing
SocialProofWidget(
  reviewCount: product.reviewCount,
  rating: product.rating,
  recentPurchases: 45,
)

// Compact version
CompactSocialProof(
  reviewCount: 128,
  rating: 4.5,
)
```

**Already integrated in:**
- Product details pages
- Search results
- Bundle listings

---

### 2. AI Search
**User Access:**
- Search page → Click sparkle icon → AI Search
- Or: `/aiSearch` route

**Developer Usage:**
```dart
// Navigate to AI search
Navigator.pushNamed(context, AppRoutes.aiSearch);

// With initial query
Navigator.pushNamed(
  context,
  AppRoutes.aiSearch,
  arguments: {'query': 'organic vegetables'},
);

// Using search provider
ref.watch(aiSearchProvider('tomatoes'))
```

**Note:** Works with or without API key (fallback to basic search)

---

### 3. Wishlist Sharing
**User Access:**
- Wishlist page → Click share button (top-right) → Copy code

**Share Code Format:**
- 8 characters, uppercase
- Example: `ABC12345`
- Expires after 30 days

**Developer Usage:**
```dart
// Generate share link
final shareCode = await ref.read(
  createWishlistShareLinkProvider(
    (itemIds: ['prod1', 'prod2'], customName: 'My Wishlist'),
  ),
);

// Import shared wishlist
await ref.read(importSharedWishlistProvider(shareCode));

// Get share link details
final shareData = await ref.read(
  getSharedWishlistProvider(shareCode).future,
);
```

---

### 4. Bundle Editing
**User Access:**
- Profile → My Bundles
- Click bundle to edit
- Update name, description, price, items

**Developer Usage:**
```dart
// Navigate to edit
Navigator.pushNamed(
  context,
  AppRoutes.bundleEdit,
  arguments: {'bundle': bundleModel},
);

// Update bundle (in page)
ref.read(updateBundleDetailsProvider(
  (bundleId, {'name': 'New Name', 'price': 1500.0}),
));

// Add product to bundle
ref.read(addProductToBundleProvider(
  (bundleId, productId, productName, price),
));

// Delete bundle
ref.read(deleteBundleProvider(bundleId));
```

---

### 5. Referral System
**User Access:**
- Profile → Referral Program
- View your code, share with friends
- Click "Enter Referral Code" to use someone's code

**Rewards:**
- Referrer: 500 KES per successful referral
- Referee: 200 KES on first purchase

**Developer Usage:**
```dart
// Get user's referral code
final code = await ref.read(userReferralCodeProvider.future);

// Get referral summary
final summary = await ref.read(referralSummaryProvider.future);
// Returns: totalReferrals, completedReferrals, totalEarnings

// Create referral (when user signs up with code)
await ref.read(createReferralProvider(
  (refereeId, referralCode, email),
));

// Mark referral complete (when they make first purchase)
ref.read(completeReferralProvider(referralId));

// Get leaderboard
final topReferrers = await ref.read(topReferrersProvider.future);
```

---

## 🛠️ Integration Examples

### Example 1: Add Social Proof to Product Card
```dart
Card(
  child: Column(
    children: [
      // Product image, name, price...
      const SizedBox(height: 8),
      CompactSocialProof(
        reviewCount: product.reviewCount,
        rating: product.rating,
      ),
    ],
  ),
)
```

### Example 2: AI Search in Custom Widget
```dart
TextButton.icon(
  icon: Icon(Icons.sparkles_rounded),
  label: Text('Smart Search'),
  onPressed: () {
    Navigator.pushNamed(context, AppRoutes.aiSearch);
  },
)
```

### Example 3: Referral Widget in Settings
```dart
FutureBuilder(
  future: ref.read(userReferralCodeProvider.future),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return Text('Your code: ${snapshot.data}');
    }
    return CircularProgressIndicator();
  },
)
```

### Example 4: Bundle Management
```dart
// List all bundles
final bundles = await ref.read(allBundlesProvider.future);

// Edit one
Navigator.pushNamed(
  context,
  AppRoutes.bundleEdit,
  arguments: {'bundle': bundles.first},
);
```

---

## 📱 Testing on Device

### Test Referral System
1. Create two test accounts
2. Get referral code from Account A
3. Sign up Account B with code
4. Account B makes purchase
5. Check both wallets for rewards

### Test Wishlist Sharing
1. Add items to wishlist
2. Share via code
3. Log out
4. Sign in as new user
5. Import wishlist using code

### Test AI Search
1. Go to search page
2. Tap AI search icon
3. Search: "healthy breakfast"
4. Verify semantic results (not just keyword match)

### Test Bundle Editing
1. Profile → My Bundles
2. Create a new bundle
3. Edit the bundle (change name, price)
4. Add/remove products
5. Delete bundle

### Test Social Proof
1. View any product
2. Check rating and review count display
3. Recent purchases should show activity

---

## 🔍 Debugging

### AI Search Not Working?
```dart
// Check API key
print(String.fromEnvironment('ANTHROPIC_API_KEY'));

// Check logs
flutter logs | grep -i anthropic
```

### Share Code Validation Failing?
```dart
// Check share code format (8 chars, uppercase)
// Check expiry date in Firestore
// Check that user exists
```

### Referral Rewards Not Appearing?
```dart
// Check referral status is 'completed'
// Verify both user documents exist
// Check wallet balance field exists
```

### Bundle Edit Not Saving?
```dart
// Check Firebase rules allow write
// Verify user is authenticated
// Check Firestore collection exists
```

---

## 📊 Firestore Structure

### Collections Created
```
// Share codes
wishlist_shares/
  {shareCode}/
    ├── userId
    ├── itemIds
    ├── expiresAt
    └── accessCount

// Referrals
referrals/
  {referralId}/
    ├── referrerId
    ├── refereeId
    ├── referralCode
    ├── status (pending|completed|cancelled)
    ├── rewardAmount
    └── completedAt
```

### User Document Updates
```
users/{userId}
  ├── referralCode: "ABC12345"
  ├── referralCount: 5
  └── walletBalance: 2500
```

---

## 🚨 Common Issues

| Issue | Solution |
|-------|----------|
| API key not found | Add to .env.development and restart |
| Share code invalid | Check 8-char uppercase format |
| Rewards not awarding | Check referral status = completed |
| Bundle not updating | Verify user auth & Firebase permissions |
| Social proof not showing | Check product has reviewCount field |

---

## 📚 Additional Resources

- **Full Docs**: `PHASE4_IMPLEMENTATION.md`
- **File List**: `PHASE4_FILES_CREATED.md`
- **Architecture**: `CLAUDE.md`

---

## ✅ Checklist Before Shipping

- [ ] API key configured in .env
- [ ] All 5 features tested on device
- [ ] Dark mode verified
- [ ] Responsive design checked
- [ ] Error messages clear
- [ ] Analytics events added (if needed)
- [ ] No console errors
- [ ] Firebase rules updated for new collections
- [ ] User documentation ready
- [ ] QA approved

---

## 💡 Pro Tips

1. **Share Code** - Use uppercase letters for clarity
2. **AI Search** - Works better with descriptive queries
3. **Referral Code** - Show in-app onboarding
4. **Bundles** - Pre-create templates for users
5. **Social Proof** - Use compact version on cards

---

## 🎯 Next Steps

1. **Review**: Read `PHASE4_IMPLEMENTATION.md`
2. **Test**: Run all features locally
3. **Deploy**: Push to staging
4. **QA**: Test on real devices
5. **Launch**: Deploy to production

---

**Ready to go!** 🚀

Questions? Check the docs or contact the team.
