#!/usr/bin/env bash
set -euo pipefail

# rebuild_scaffold.sh
# Creates a fresh Flutter scaffold and replaces platform folders in this repo
# Usage: bash scripts/rebuild_scaffold.sh

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
TMP_DIR="/tmp/pro_grocery_rebuild_$TIMESTAMP"
NEW_PROJECT_DIR="$TMP_DIR/new_proj"
BACKUP_DIR="$REPO_ROOT/.platform_backups_$TIMESTAMP"

# Ensure running from repo root
cd "$REPO_ROOT"

echo "Repo root: $REPO_ROOT"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Error: flutter is not installed or not on PATH. Install Flutter or use FVM and retry." >&2
  exit 2
fi

mkdir -p "$TMP_DIR"
mkdir -p "$BACKUP_DIR"

echo "Creating temporary fresh Flutter project in $NEW_PROJECT_DIR"
flutter create "$NEW_PROJECT_DIR"

# List of platform folders to replace
PLATFORMS=(android ios linux macos web windows)

for p in "${PLATFORMS[@]}"; do
  if [ -d "$REPO_ROOT/$p" ]; then
    echo "Backing up existing $p -> $BACKUP_DIR/$p"
    mv "$REPO_ROOT/$p" "$BACKUP_DIR/"
  fi
  if [ -d "$NEW_PROJECT_DIR/$p" ]; then
    echo "Copying new $p into repo"
    mv "$NEW_PROJECT_DIR/$p" "$REPO_ROOT/"
  fi
done

# Remove tmp project scaffold except kept folders
rm -rf "$TMP_DIR"

echo "Running flutter pub get to fetch dependencies"
flutter pub get

cat <<EOF
Scaffold rebuild complete.
- Backups of previous platform folders are in: $BACKUP_DIR
- Run the app now with: flutter run
If flutter run fails, check the error; common fixes:
- Update Android SDK/NDK in local machine
- If you rely on custom native code, consider the "freeze original environment" approach instead
EOF

exit 0
