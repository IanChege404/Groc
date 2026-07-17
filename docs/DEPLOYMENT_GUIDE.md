# Deployment Guide

## Build Commands

### Android

```bash
# Debug APK (for development)
flutter build apk --debug

# Release APK (for direct install)
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release
```

**Output locations:**
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

### iOS

```bash
# Debug (for development)
flutter build ios --debug

# Release (for App Store)
flutter build ios --release
```

Then open `ios/Runner.xcworkspace` in Xcode to:
1. Set your Development Team
2. Update Bundle Identifier if needed
3. Archive and upload to App Store Connect

### Web

```bash
flutter build web --release
```

Output: `build/web/` — deploy to any static hosting (Firebase Hosting, Vercel, Netlify).

### Desktop

```bash
flutter build macos --release
flutter build windows --release
flutter build linux --release
```

## Firebase Deployment

### Firestore Rules
```bash
firebase deploy --only firestore:rules
```

### Cloud Functions
```bash
cd functions
npm install
npm run build
firebase deploy --only functions
```

### Firebase Hosting (Web)
```bash
flutter build web --release
firebase deploy --only hosting
```

## Admin Dashboard Deployment

The admin dashboard is a Next.js app in `admin/`:

```bash
cd admin
npm install
npm run build
```

### Vercel Deployment
```bash
cd admin
vercel --prod
```

### Environment Variables for Admin
```env
NEXT_PUBLIC_FIREBASE_API_KEY=...
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=...
NEXT_PUBLIC_FIREBASE_PROJECT_ID=...
```

## CI/CD Pipeline

GitHub Actions workflow at `.github/workflows/ci.yml`:

**On every PR:**
1. `dart analyze lib` — Lint check
2. `flutter test` — Run all tests
3. `flutter build apk --debug` — Build verification

**On merge to main:**
1. All PR checks pass
2. Build release artifacts
3. (Optional) Auto-deploy to stores

## Pre-Deployment Checklist

### Code Quality
- [ ] `dart analyze lib` — 0 issues
- [ ] `dart format --set-exit-if-changed lib` — All formatted
- [ ] `flutter test` — All tests pass
- [ ] `flutter test --coverage` — Coverage ≥ 60%

### Build Verification
- [ ] Android APK builds successfully
- [ ] iOS builds successfully (macOS only)
- [ ] Web build completes without errors

### Environment
- [ ] `.env.production` configured with production credentials
- [ ] Firebase production project selected
- [ ] M-Pesa production credentials (not sandbox)
- [ ] Flutterwave production keys

### Firebase
- [ ] Firestore rules deployed
- [ ] Firestore data seeded
- [ ] Firebase Auth configured (production project)
- [ ] FCM configured for production

### Store Preparation
- [ ] App icon (1024x1024) set
- [ ] Splash screen configured
- [ ] Store screenshots taken (phone + tablet)
- [ ] Store description written
- [ ] Privacy policy URL ready
- [ ] Terms of service URL ready

### Testing
- [ ] Tested on Android (API 24+)
- [ ] Tested on iOS (12.0+)
- [ ] Tested dark mode
- [ ] Tested responsive layouts (360px, 390px, 414px, 768px+)
- [ ] Tested accessibility (TalkBack/VoiceOver)
- [ ] M-Pesa payment flow tested (sandbox)
- [ ] Flutterwave payment flow tested (sandbox)

## Play Store Submission

1. Build App Bundle: `flutter build appbundle --release`
2. Sign with release keystore
3. Upload to [Google Play Console](https://play.google.com/console)
4. Complete store listing
5. Submit for review

### Keystore Setup
```bash
# Generate release keystore (one-time)
keytool -genkey -v -keystore release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias prod-grocery

# Configure in android/key.properties
storePassword=<password>
keyPassword=<password>
keyAlias=prod-grocery
storeFile=<path-to-release-key.jks>
```

## App Store (iOS) Submission

1. Build: `flutter build ios --release`
2. Open `ios/Runner.xcworkspace` in Xcode
3. Product → Archive
4. Upload to App Store Connect
5. Complete store listing
6. Submit for review

## Version Management

Update version in `pubspec.yaml`:
```yaml
version: 1.0.0+1    # format: major.minor.patch+buildNumber
```

- **major.minor.patch:** Semantic version (user-visible)
- **buildNumber:** Integer, incremented each release (used by stores)

```bash
# Auto-increment build number
flutter build apk --build-number=$(($(cat build_number.txt) + 1)) && echo $(($(cat build_number.txt) + 1)) > build_number.txt
```

## Rollback

### Code Rollback
```bash
git revert <commit-hash>
git push origin main
```

### Firebase Rollback
```bash
# Restore previous Firestore rules
firebase deploy --only firestore:rules --force
```

### Store Rollback
- **Android:** Roll back to previous version in Play Console
- **iOS:** Use App Store Connect to revert to previous build

## Monitoring

### Crash Reporting
- Firebase Crashlytics (enable in `firebase_options.dart`)
- Check: Firebase Console → Crashlytics

### Performance
- Firebase Performance Monitoring
- Check: Firebase Console → Performance

### Analytics
- Firebase Analytics
- Check: Firebase Console → Analytics
