# Troubleshooting Pro Grocery Flutter App

## Common Build Failures

### 1. "The Dart compiler exited unexpectedly" / "Gradle task failed with exit code 143"

**Symptom**: Build fails mid-compilation with:
```
The Dart compiler exited unexpectedly.
Error: Gradle task assembleDebug failed with exit code 143
```

**Root Cause**: The Dart AOT compiler (`frontend_server`) or Gradle daemon ran out of memory and was killed by the OS (SIGTERM = signal 143).

**Solutions** (in order):

#### Solution A: Stop Gradle daemons and rebuild
```bash
cd android/
./gradlew --stop
cd ..
flutter clean
flutter pub get
flutter run
```

#### Solution B: Reduce Gradle JVM heap
Edit `android/gradle.properties` and set lower memory:
```properties
## Lower memory footprint for resource-constrained machines
org.gradle.jvmargs=-Xmx512M -XX:MaxMetaspaceSize=256m -XX:ReservedCodeCacheSize=128m
```

Then retry:
```bash
cd android/ && ./gradlew --stop && cd ..
flutter run
```

#### Solution C: Disable Gradle daemon (for CI or very constrained environments)
Edit `android/gradle.properties`:
```properties
org.gradle.daemon=false
```

#### Solution D: Build web or another platform first
Web builds skip native compilation and are much faster:
```bash
flutter run -d chrome
```

If web works, the Dart code is sound. Android build failure is likely environment/toolchain.

#### Solution E: Build APK directly (skip hot reload)
```bash
flutter build apk --debug --target-platform=android-x64
# Install manually:
adb install build/app/outputs/apk/debug/app-debug.apk
```

---

### 2. Gradle daemon conflicts

**Symptom**: Gradle reports old JVM settings or builds slowly.

**Solution**:
```bash
cd android/
./gradlew --stop
cd ..
rm -rf build/  # optional: clean build artifacts
flutter pub get
flutter run
```

---

### 3. Android SDK / NDK issues

**Symptom**: Errors like `Build failed`, `SDK not found`, or C++ compilation errors.

**Solutions**:
- Open Android Studio → SDK Manager and install:
  - Android SDK Platform 34+
  - Android NDK 27+
  - CMake 3.22+
- Verify `local.properties` in android/ folder has correct SDK path:
  ```
  sdk.dir=/path/to/Android/Sdk
  ```

---

### 4. Dependency or plugin errors

**Symptom**: `Unsupported class version`, `dependency X is incompatible`, or plugin errors.

**Solutions**:
```bash
flutter pub get
flutter pub upgrade
flutter clean
flutter pub get
flutter run
```

If a specific package is broken, try:
```bash
# Remove the problematic package
flutter pub remove package_name

# Or downgrade to a known-good version
flutter pub add package_name:^1.0.0
```

---

### 5. Memory full (low storage / low RAM)

**Symptom**: Build hangs or crashes with OOM errors.

**Solutions**:
- Free up disk space (build artifacts can be large):
  ```bash
  flutter clean
  rm -rf build/ android/build/ ios/Pods/
  ```
- Add swap on Linux (if available):
  ```bash
  # Create a 4GB swap file (example)
  sudo fallocate -l 4G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  ```
- Reduce Gradle heap even further (e.g., `-Xmx256M` for very constrained systems).

---

## Recommended Build Targets

If Android native builds consistently fail on your machine:

1. **Web** (recommended for development):
   ```bash
   flutter run -d chrome
   ```
   - Fastest feedback loop
   - No native compilation
   - Good for debugging UI and Dart logic

2. **iOS** (macOS only):
   ```bash
   flutter run -d ios
   ```

3. **Linux** (if running Linux):
   ```bash
   flutter run -d linux
   ```

---

## Scaffold Rebuild

If you inherited old platform configs (android/, ios/, etc.) that conflict with your Flutter/Dart version:

```bash
bash scripts/rebuild_scaffold.sh
```

This creates fresh platform scaffolding while preserving your app code (`lib/`, `assets/`, `pubspec.yaml`).

---

## Questions or Issues?

If issues persist:
1. Check Flutter version: `flutter --version`
2. Check doctor: `flutter doctor`
3. Run with verbose output: `flutter run -v > debug.log 2>&1`
4. Share the last 100 lines of `debug.log` in an issue.
