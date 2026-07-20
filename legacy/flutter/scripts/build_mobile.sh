#!/usr/bin/env bash
# Build Android/iOS release artifacts and stage under build/release/mobile/.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/apps/phoenix_manager"
OUT="$ROOT/build/release/mobile"

usage() {
  echo "Usage: $0 [android|ios|all]"
  echo ""
  echo "  android  APK + AAB (Play Store)"
  echo "  ios      Runner.app (requires macOS + Xcode)"
  echo "  all      both platforms"
}

require_macos_for_ios() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "ERRO: build iOS só corre em macOS com Xcode."
    exit 1
  fi
  if ! command -v xcodebuild >/dev/null 2>&1; then
    echo "ERRO: xcodebuild em falta — instala Xcode."
    exit 1
  fi
}

build_android() {
  local sdk_root="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
  local keystore_path="android/keystore/phoenix-manager-release.jks"
  echo "==> Android APK"
  if [[ -f android/key.properties ]]; then
    if [[ -f "$keystore_path" ]]; then
      echo "    (release keystore configurado)"
    else
      echo "ERRO: android/key.properties existe, mas o keystore não foi encontrado em:"
      echo "      $APP/$keystore_path"
      echo ""
      echo "Corrige assim:"
      echo "  1) rm apps/phoenix_manager/android/key.properties  # volta a debug signing"
      echo "  2) ou gera o keystore: ./scripts/android_keystore.sh"
      exit 1
    fi
  else
    echo "    (sem key.properties — APK assinado com chave debug)"
  fi
  if [[ ! -d "$sdk_root/cmdline-tools" ]]; then
    echo "    AVISO: cmdline-tools em falta — o AAB pode avisar sobre debug symbols."
    echo "           Corrigir: Android Studio → SDK Manager → Android SDK Command-line Tools"
    echo "           ou: ./scripts/setup_android_cmdline_tools.sh"
  fi
  # Regenera GeneratedPluginRegistrant sem dev_dependencies (ex. integration_test)
  # — evita falha de compileRelease com Flutter ≥3.32.
  flutter build apk --config-only
  flutter build apk --release
  echo "==> Android App Bundle (Play Store)"
  local aab_path="build/app/outputs/bundle/release/app-release.aab"
  set +e
  flutter build appbundle --release
  local bundle_exit=$?
  set -e
  if [[ $bundle_exit -ne 0 ]]; then
    if [[ -f "$aab_path" ]]; then
      echo "AVISO: flutter build appbundle saiu com código $bundle_exit (strip debug symbols)."
      echo "       O AAB foi gerado na mesma — OK para testes; corrige cmdline-tools antes da Play Store."
    else
      echo "ERRO: AAB não gerado."
      exit 1
    fi
  fi
  mkdir -p "$OUT/android"
  cp build/app/outputs/flutter-apk/app-release.apk "$OUT/android/phoenix_manager.apk"
  if [[ -f build/app/outputs/bundle/release/app-release.aab ]]; then
    cp build/app/outputs/bundle/release/app-release.aab "$OUT/android/phoenix_manager.aab"
  fi
  echo "Staged: $OUT/android/"
  ls -lh "$OUT/android/"
}

build_ios() {
  require_macos_for_ios
  echo "==> iOS (sem codesign — para TestFlight/App Store assina depois)"
  flutter build ios --release --no-codesign
  mkdir -p "$OUT/ios"
  rm -rf "$OUT/ios/Runner.app"
  cp -R build/ios/iphoneos/Runner.app "$OUT/ios/"
  echo "Staged: $OUT/ios/Runner.app"
  du -sh "$OUT/ios/Runner.app"
  echo ""
  echo "Para IPA/TestFlight: abre ios/Runner.xcworkspace no Xcode e Archive,"
  echo "ou configura signing e corre: flutter build ipa"
}

cd "$APP"
flutter pub get
mkdir -p "$OUT"

TARGET="${1:-all}"
case "$TARGET" in
  android) build_android ;;
  ios) build_ios ;;
  all)
    build_android
    build_ios
    ;;
  -h|--help|help) usage; exit 0 ;;
  *)
    usage
    exit 1
    ;;
esac

echo ""
echo "Mobile artifacts in $OUT"
