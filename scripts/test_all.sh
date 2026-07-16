#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "==> Version sync"
"$ROOT/scripts/check_app_version_sync.sh"

echo "==> Dart packages"
dart pub get
dart analyze
dart test packages/phoenix_core packages/phoenix_data packages/phoenix_engine packages/phoenix_tools

echo "==> Flutter UI"
cd packages/phoenix_ui
flutter pub get
flutter test

echo "==> Flutter app"
cd "$ROOT/apps/phoenix_manager"
flutter pub get
flutter analyze

echo "All tests passed."
