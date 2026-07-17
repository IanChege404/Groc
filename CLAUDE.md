# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Pro Grocery** is a production-ready Flutter e-commerce template focused on African markets. It features M-Pesa integration, Swahili localization (237+ strings), WCAG 2.1 Level AA accessibility compliance, dark mode support, and responsive design for mobile/tablet/desktop platforms.

**Tech Stack:**
- Flutter 3.9+ | Dart 3.5+
- Firebase (Authentication, Firestore, Cloud Messaging)
- State Management: Provider (legacy) + Riverpod (modern providers)
- Routing: GoRouter 13.0+
- Payments: M-Pesa Daraja, Flutterwave
- Offline: Hive local cache
- Admin: Next.js 14 + TypeScript + Tailwind CSS

## Common Commands

### Development
```bash
# Get dependencies
flutter pub get

# Run the app (default debug build)
flutter run

# Run on specific device
flutter run -d <device-id>

# Run on web platform
flutter run -d web

# Run with hot reload enabled (automatic on `flutter run`)
flutter run
```

### Code Quality
```bash
# Analyze code for issues and lint violations
dart analyze lib

# Format all Dart files in lib/
dart format lib

# Check formatting without applying changes
dart format --set-exit-if-changed lib

# Run all quality checks (analyzer + format check)
dart analyze lib && dart format --set-exit-if-changed lib
```

### Testing
```bash
# Run all tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/path/to/test.dart

# Run tests matching a pattern
flutter test --name "pattern"

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # View coverage locally
```

### Building
```bash
# Build Android APK (release)
flutter build apk --release

# Build Android App Bundle for Play Store
flutter build appbundle --release

# Build iOS (requires macOS)
flutter build ios --release

# Build Web
flutter build web --release

# Build for desktop platforms
flutter build windows --release
flutter build macos --release
flutter build linux --release
```

### Development Environment Setup
```bash
# Build generated code (if needed for providers/models)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch for changes and rebuild generated code
flutter pub run build_runner watch

# Clean build artifacts
flutter clean

# Regenerate platform code (if native code breaks)
bash scripts/rebuild_scaffold.sh
```

## Architecture Overview

### State Management Pattern
The app uses **dual state management**:

1. **Provider** (legacy): Used in consumer-facing screens (cart, auth, settings)
   - Located in: `lib/core/providers/`
   - Examples: `AuthProvider`, `CartProvider`, `SettingsProvider`
   - Directly mutates state

2. **Riverpod** (modern): Emerging pattern for service-level state
   - Examples: `CatalogProvider`, `UserDataProvider` 
   - Functional/immutable approach with `.family` and `.select()` modifiers
   - Enables fine-grained reactivity

**Future direction:** Gradually migrate from Provider to Riverpod (immutable, more testable, better TypeScript-like safety).

### Service Layer Architecture
Services encapsulate business logic and Firestore integration:

- **Auth Services**: `firestore_auth_service.dart`, `auth_service.dart`
- **Data Services**: `firestore_product_service.dart`, `firestore_service.dart`
- **Payment Services**: `mpesa_service.dart`, `flutterwave_service.dart`
- **Infrastructure**: `firebase_service.dart`, `fcm_service.dart`, `hive_service.dart`
- **Notifications**: `notification_service.dart`

Services are **stateless helpers** that handle API/Firestore calls, not state containers. Providers subscribe to service methods.

### Routing Architecture
**GoRouter** (13.0+) manages navigation with type-safe deep linking:

- Route definitions: `lib/core/routes/app_router.dart`
- Nested navigation for tabbed UX (home screen with sub-routes)
- Deep link support for notifications and external links
- Automatic handling of auth state redirects

### Component Library Pattern
Reusable UI components follow naming convention: `Afri*` (e.g., `AfriButton`, `AfriTextField`)

Location: `lib/core/components/`

30+ production-tested components with:
- Responsive sizing based on screen width
- Built-in animation support (deletion, pop effects)
- Theme-aware coloring (light/dark mode)
- Accessibility semantic labels
- Haptic feedback for interactive elements

### Localization Structure
**Arb (App Resource Bundle) format** for translations:

- `lib/core/l10n/app_en.arb` — English strings (237+ entries)
- `lib/core/l10n/app_sw.arb` — Swahili translations
- Generated: `lib/core/l10n/app_localizations.dart` (auto-generated, do not edit)
- Locale provider: `lib/core/l10n/locale_provider.dart` manages current locale

To add a new string:
1. Add entry to `app_en.arb`: `{ "myKey": "My English Text" }`
2. Add to `app_sw.arb`: `{ "myKey": "My Swahili Text" }`
3. Run `flutter gen-l10n` (or rebuild via `flutter run`)
4. Use: `AppLocalizations.of(context)!.myKey`

### Theme & Dark Mode
- Light theme: `lib/core/themes/app_themes.dart`
- Dark theme: `lib/core/themes/app_theme_dark.dart`
- Design tokens (colors, typography, spacing): `lib/core/constants/`
- Dark mode toggle: Managed by `LocaleProvider` (not system theme, user preference stored in SharedPreferences)

## Firebase & Firestore Integration

### Authentication
- Email/password via `FirebaseAuth`
- Social login (Google) via `google_sign_in`
- Custom user model in Firestore: `/users/{userId}` collection
- Auth state changes trigger provider updates via stream listeners

### Firestore Data Structure
Key collections:
- `/products` — Product catalog with images, ratings, pricing
- `/users/{userId}` — User profiles, preferences, loyalty points
- `/orders/{orderId}` — Order history and status tracking
- `/coupons` — Active promotional codes
- `/notifications/{userId}` — FCM token storage

Security rules: `firestore.rules` (role-based access)

### Offline Support
**Hive** local cache (key-value store):
- Automatically caches API responses
- 30-minute TTL for products/orders (configurable via `HiveService.isStale()`)
- Falls back to cache if network unavailable
- Cleared on logout

## Payment Integration

### M-Pesa (Safaricom Daraja API)
Service: `lib/core/services/mpesa_service.dart`

- Sandbox credentials in `.env.development`
- Production credentials in `.env.production` (never commit)
- Processing screen: `lib/views/cart/m_pesa_processing_screen.dart`
- Callback webhook for payment status (handled by backend)

### Flutterwave
Service: `lib/core/services/flutterwave_service.dart`

- API keys via environment variables
- Supports multiple payment methods (card, mobile money, bank transfer)
- Webhook for payment confirmation

## Accessibility & Compliance

### WCAG 2.1 Level AA
- 48×48 dp minimum touch targets on all buttons
- 4.5:1 color contrast ratio
- Semantic labels on all interactive elements
- Full keyboard navigation support
- Screen reader compatibility (TalkBack/VoiceOver)

Audit checklist: `docs/ACCESSIBILITY_AUDIT.md`

### Responsive Design
Tested breakpoints:
- Small phone: 360px (1 column layout)
- Medium phone: 390px (2 column grid)
- Large phone: 414px (2 column, optimized spacing)
- Tablet: 768px+ (3-4 column grid)

Responsive utilities: `lib/core/utils/responsive_utils.dart`

## Key Files & Patterns

### Models & Data Classes
- User model: `lib/core/models/user_model.dart`
- Product model: `lib/core/models/product_model.dart`
- Order model: `lib/core/models/order_model.dart`
- Immutable data classes using `@immutable` or `freezed` package (where generated)

### Enums
Located in `lib/core/enums/`:
- `user_role.dart` — Admin, customer, vendor
- `payment_method.dart` — M-Pesa, card, wallet
- `order_status.dart` — Pending, confirmed, shipped, delivered

### Mixins
`lib/core/mixins/` — Reusable behavior across widgets:
- Input validation mixin
- Theme-aware color mixin
- Responsive sizing mixin

### Utils & Helpers
- `responsive_utils.dart` — Screen size detection
- `animation_utils.dart` — Reusable animations (fade, slide, pop)
- `validators.dart` — Form validation helpers
- `logger.dart` — Structured logging (respects environment)

### Admin Dashboard
- Located in `admin/` directory (separate Next.js app)
- Manages products, orders, users
- Uses TypeScript + Tailwind CSS
- Deploys to Vercel: `vercel --prod`

## Development Workflow

### PR Checklist
Before submitting a pull request:
1. Run `dart analyze lib` — no issues
2. Run `dart format --set-exit-if-changed lib` — all formatted
3. Run `flutter test --coverage` — all tests pass
4. Test on multiple devices/screen sizes
5. Verify dark mode and accessibility (keyboard nav, screen readers)
6. Update `.arb` files if UI strings changed
7. Ensure environment-specific configs don't leak into commits

### Debugging
- Enable Flutter DevTools: `flutter run` → press `D` key in terminal
- View logs: `flutter logs`
- Network debugging: Add `_NetworkLogger` interceptor in `lib/core/network/`
- State debugging: Use Riverpod DevTools or Provider inspection

### Adding a New Feature
1. Create service class in `lib/core/services/` (if API calls needed)
2. Create provider in `lib/core/providers/` (if state required)
3. Create screen/page in `lib/views/{feature}/`
4. Add route in `lib/core/routes/app_router.dart`
5. Add localization strings in `.arb` files
6. Write tests covering service and UI logic
7. Verify responsive design and accessibility

### Git Workflow
- `main` branch — production releases (tagged with version)
- `develop` branch — staging for next release
- Feature branches — branch from `develop`, PR back to `develop`
- All PRs require passing CI (analyze + test + build)

## Common Gotchas & Solutions

### State Management Conflicts
**Issue**: Provider and Riverpod widgets listening to same data.
**Solution**: Gradually migrate feature to single state manager; prefer Riverpod for new features.

### FCM Token Expiration
**Issue**: Push notifications stop working after app update or long inactivity.
**Solution**: Refresh FCM token on app startup (handled in `main.dart`); `FcmService.saveTokenToFirestore()` updates backend.

### Hive Box Lock
**Issue**: "Box is already open" error when testing or running multiple instances.
**Solution**: Close boxes in test teardown; ensure `HiveService.close()` called on logout.

### Localization String Missing
**Issue**: `AppLocalizations.of(context)!.someKey` throws NoSuchMethodError.
**Solution**: Add key to **both** `app_en.arb` and `app_sw.arb`, then run `flutter gen-l10n`.

### Dark Mode Theme Not Applying
**Issue**: UI uses hardcoded colors instead of theme colors.
**Solution**: Use `Theme.of(context).colorScheme.*` or `AppColors` tokens (defined in theme files).

## Testing Strategy

### Unit Tests
- Service logic: `test/services/`
- Models/utils: `test/utils/`
- No Firebase/Firestore mocking needed (use emulator in CI)

### Widget Tests
- Component behavior: `test/components/`
- Screen navigation: `test/views/`
- Provider state changes: Use `ProviderContainer` for testing

### Integration Testing
- End-to-end flows (not automated in CI, manual testing recommended)
- Device-specific testing on 4 breakpoints

## Documentation References

- **README.md** — Features, setup, customization guide
- **CONTRIBUTING.md** — Contribution guidelines
- **docs/ACCESSIBILITY_AUDIT.md** — WCAG compliance checklist
- **docs/RESPONSIVE_TESTING.md** — Testing across device sizes
- **docs/FIREBASE_SETUP.md** — Firebase initialization steps
- **docs/FIRESTORE_COLLECTIONS_CONTRACT.md** — Data schema reference
- **docs/SEED_EXECUTION_GUIDE.md** — Seeding Firestore with data

## Environment Configuration

The app loads config from `.env.{APP_ENV}` files (loaded via `flutter_dotenv`):

```env
# .env.development
APP_ENV=development
API_BASE_URL=http://localhost:8000/api
MPESA_CONSUMER_KEY=your_sandbox_key
MPESA_CONSUMER_SECRET=your_sandbox_secret
# ... more keys
```

**Never commit `.env` files** with real credentials. Use `.env.example` as a template.

## Performance Considerations

- Images cached via `CachedNetworkImage` with 30-day expiry
- Products cached in Hive (30-min TTL)
- Lazy loading for product grids (using `GridView.builder`)
- Provider/Riverpod selectors to prevent unnecessary rebuilds
- Animations use `SingleTickerProviderStateMixin` (no memory leaks)

## Code Quality Standards

- **0 Lint Issues**: Enforced via `analysis_options.yaml` and CI
- **Null Safety**: Full null safety compliance (no `!` unless necessary)
- **Formatting**: Enforced via `dart format` in CI
- **Naming Conventions**: camelCase for variables/methods, PascalCase for classes, UPPER_SNAKE_CASE for constants
- **Comments**: Only for non-obvious logic; prefer self-documenting code

---

**Last Updated:** 2026-06-30
