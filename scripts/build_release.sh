#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/apps/phoenix_manager"
OUT="$ROOT/build/release"

cd "$APP"
flutter pub get

mkdir -p "$OUT"

echo "==> Web release"
flutter build web --release
rm -rf "$OUT/web"
cp -R build/web "$OUT/web"

if [[ "$(uname)" == "Darwin" ]]; then
  echo "==> macOS release"
  flutter build macos --release
  rm -rf "$OUT/macos"
  cp -R build/macos/Build/Products/Release/phoenix_manager.app "$OUT/macos" 2>/dev/null || \
    cp -R build/macos/Build/Products/Release/*.app "$OUT/macos"
fi

if [[ "${BUILD_MOBILE:-}" == "1" ]]; then
  "$ROOT/scripts/build_mobile.sh" all
fi

echo "Build artifacts in $OUT"
echo "Mobile: ./scripts/build_mobile.sh [android|ios|all]"
