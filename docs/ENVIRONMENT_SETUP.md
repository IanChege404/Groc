# Environment Setup Guide

## Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| Flutter SDK | 3.9+ | App framework |
| Dart SDK | 3.5+ | Language runtime |
| Node.js | 20+ | Firebase Cloud Functions |
| Firebase CLI | Latest | Firebase deployment |
| Android Studio | Latest | Android builds |
| Xcode | 14+ (macOS) | iOS builds |
| Git | Latest | Version control |

## Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/yourusername/pro-grocery.git
cd pro-grocery

# 2. Install Flutter dependencies
flutter pub get

# 3. Install Cloud Functions dependencies
cd functions && npm install && cd ..

# 4. Copy environment template
cp .env.example .env.development

# 5. Run the app
flutter run
```

## Environment Files

The app loads config from `.env.{APP_ENV}` files via `flutter_dotenv`:

| File | Purpose | Committed to Git |
|------|---------|-------------------|
| `.env.example` | Template with placeholder values | Yes |
| `.env.development` | Local dev credentials | No (gitignored) |
| `.env.production` | Production credentials | No (gitignored) |

## Required Environment Variables

### Firebase Configuration
```env
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_app_id
FIREBASE_DATABASE_URL=https://your_project.firebaseio.com
```

### M-Pesa (Daraja API)
```env
MPESA_CONSUMER_KEY=your_mpesa_consumer_key
MPESA_CONSUMER_SECRET=your_mpesa_consumer_secret
MPESA_SHORTCODE=123456
MPESA_PASSKEY=your_mpesa_passkey
MPESA_BUSINESS_SHORT_CODE=123456
```

### Flutterwave
```env
FLUTTERWAVE_PUBLIC_KEY=your_flutterwave_public_key
FLUTTERWAVE_SECRET_KEY=your_flutterwave_secret_key
```

### AI/LLM (Optional)
```env
ANTHROPIC_API_KEY=sk-ant-your-api-key-here
```

### App Configuration
```env
APP_ENV=development
API_BASE_URL=http://localhost:8000/api
```

### Feature Flags
```env
ENABLE_DARK_MODE=true
ENABLE_ANALYTICS=true
ENABLE_CRASH_REPORTING=false
```

## Firebase Project Setup

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create new project (or use existing)
3. Note the project ID

### 2. Enable Services
- **Authentication:** Enable Email/Password and Google sign-in
- **Firestore Database:** Create in production mode (rules deployed separately)
- **Cloud Messaging:** Enabled by default

### 3. Download Config Files
```bash
# Android
# Download google-services.json → android/app/google-services.json

# iOS
# Download GoogleService-Info.plist → ios/Runner/GoogleService-Info.plist

# Or use FlutterFire CLI:
flutterfire configure
```

### 4. Deploy Firestore Rules
```bash
firebase deploy --only firestore:rules
```

## Cloudinary Setup (for images)

1. Create account at [cloudinary.com](https://cloudinary.com)
2. Note your Cloud Name, API Key, and API Secret
3. Add to `.env.development`:
```env
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
CLOUDINARY_FOLDER=pro-grocery
```

4. Validate credentials:
```bash
dart run bin/validate_cloudinary.dart
```

## Platform-Specific Setup

### Android

Ensure `android/app/google-services.json` exists.

In `android/local.properties`:
```properties
sdk.dir=/path/to/android/sdk
flutter.buildMode=debug
```

### iOS

Ensure `ios/Runner/GoogleService-Info.plist` exists.

In Xcode, verify:
- Bundle Identifier matches Firebase config
- Minimum deployment target: iOS 12.0
- Background Modes enabled for remote notifications

### Web

No additional setup required. Firebase JS SDK auto-configures.

## Verifying Setup

```bash
# Check Flutter doctor
flutter doctor -v

# Analyze code (should be clean)
dart analyze lib

# Run tests
flutter test

# Run the app
flutter run
```

## Troubleshooting

### "Missing plugin" errors
```bash
flutter clean
flutter pub get
flutter run
```

### Firebase not connecting
- Verify config files are in correct locations
- Check `firebase_options.dart` matches your project
- Ensure Firebase services are enabled in console

### .env not loading
- Ensure `flutter_dotenv` is in `pubspec.yaml`
- Verify `main.dart` calls `FlutterDotEnv.load(fileName: '.env.$APP_ENV')`
- Check file is in project root (not a subdirectory)

### Hive box errors
```bash
flutter clean
# Re-run app — Hive auto-initializes on first run
```
