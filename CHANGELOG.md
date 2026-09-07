# Changelog

All notable changes to Pro Grocery will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Admin dashboard authentication middleware (T1)
- Firestore rules for admin-only collections (T2)
- Admin CI/CD pipeline (T3)
- Sentry error monitoring for Flutter and admin (T4)
- Dependabot configuration for dependency scanning (T5)
- Terraform infrastructure as code (T7)
- Versioning and rollback strategy documentation (T8)
- Centralized logging and monitoring setup (T9)
- Rate limiting on auth endpoints via Cloud Functions (T10)
- Semantic versioning and changelog (T11)
- Incident response runbook (T12)

### Security
- Fixed: Admin dashboard now requires authentication
- Fixed: Products, categories, bundles, coupons, recipes, offers now require admin role for writes
- Added: Rate limiting on login, signup, and password reset endpoints
- Added: Password strength validation
- Added: Account lockout protection

### Changed
- Updated Firestore rules to use `isAdmin()` function
- Updated admin dashboard to use Firebase Admin SDK for auth verification

### Fixed
- Security vulnerability: Any user could access admin dashboard
- Security vulnerability: Any authenticated user could modify products
- Security vulnerability: No rate limiting on auth endpoints

## [1.0.0] - 2026-07-22

### Added
- Initial release of Pro Grocery
- Flutter e-commerce template for African markets
- M-Pesa integration
- Swahili localization (237+ strings)
- WCAG 2.1 Level AA accessibility compliance
- Dark mode support
- Responsive design for mobile/tablet/desktop
- Firebase authentication (email/password, Google)
- Firestore database integration
- Push notifications via FCM
- Hive local cache for offline support
- Admin dashboard with Next.js
- Product management
- Order management
- User management
- Coupon management
- Analytics dashboard

### Security
- Firebase security rules for all collections
- Role-based access control (admin/customer/vendor)
- Environment variable protection
- Secure payment processing

### Documentation
- Comprehensive CLAUDE.md
- Firebase setup guide
- Accessibility audit checklist
- Responsive testing guide
- Firestore collections contract

## [0.9.0] - 2026-07-15

### Added
- Beta release for internal testing
- Basic authentication flow
- Product catalog
- Shopping cart
- Checkout process
- Order history

### Fixed
- Various bug fixes and improvements

## [0.8.0] - 2026-07-01

### Added
- Alpha release for development team
- Core app structure
- Basic UI components
- Theme system
- Localization framework

---

## Version History

| Version | Date | Description |
|---------|------|-------------|
| 1.0.0 | 2026-07-22 | Production release |
| 0.9.0 | 2026-07-15 | Beta release |
| 0.8.0 | 2026-07-01 | Alpha release |

---

## Release Process

See [VERSIONING_ROLLBACK.md](./docs/VERSIONING_ROLLBACK.md) for detailed release and rollback procedures.

### Quick Release Commands

```bash
# Update version
flutter pub get
cd admin && npm version patch

# Create release branch
git checkout -b release/v1.0.0

# Run quality checks
dart analyze lib
dart format --set-exit-if-changed lib
flutter test --coverage

# Build release
flutter build apk --release
flutter build ios --release
flutter build web --release
cd admin && npm run build

# Tag and push
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# Deploy
firebase deploy --only hosting
cd admin && vercel --prod
```
