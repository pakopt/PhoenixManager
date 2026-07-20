#!/usr/bin/env bash
# Build Flutter desktop binaries and stage them for SteamPipe depots.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/apps/phoenix_manager"
STAGE="$ROOT/build/steam/content"
OS="$(uname -s)"

cd "$APP"
flutter pub get

apply_steam_macos_entitlements() {
  local entitlements="$APP/macos/Runner/Release.entitlements"
  local steam="$APP/macos/Runner/Release-Steam.entitlements"
  local backup="$APP/macos/Runner/Release.entitlements.bak"
  if [[ -f "$entitlements" && ! -f "$backup" ]]; then
    cp "$entitlements" "$backup"
    cp "$steam" "$entitlements"
    echo "Applied Release-Steam.entitlements (no App Sandbox)"
  fi
}

restore_macos_entitlements() {
  local entitlements="$APP/macos/Runner/Release.entitlements"
  local backup="$APP/macos/Runner/Release.entitlements.bak"
  if [[ -f "$backup" ]]; then
    mv "$backup" "$entitlements"
    echo "Restored Release.entitlements"
  fi
}

stage_windows() {
  echo "==> Windows release"
  flutter build windows --release
  rm -rf "$STAGE/windows"
  mkdir -p "$STAGE/windows"
  cp -R build/windows/x64/runner/Release/. "$STAGE/windows/"
  echo "Staged: $STAGE/windows/phoenix_manager.exe"
}

stage_macos() {
  echo "==> macOS release (Steam entitlements)"
  if ! command -v xcodebuild >/dev/null 2>&1; then
    echo ""
    echo "ERRO: xcodebuild não encontrado."
    echo "  1. Instala Xcode (App Store) ou Command Line Tools: xcode-select --install"
    echo "  2. Se Xcode já está instalado:"
    echo "     sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
    echo "  3. Verifica: xcodebuild -version && flutter doctor"
    exit 1
  fi
  apply_steam_macos_entitlements
  trap restore_macos_entitlements EXIT
  flutter build macos --release
  rm -rf "$STAGE/macos"
  mkdir -p "$STAGE/macos"
  local app_path
  app_path="$(find build/macos/Build/Products/Release -maxdepth 1 -name '*.app' | head -1)"
  if [[ -z "$app_path" ]]; then
    echo "macOS .app not found under build/macos/Build/Products/Release"
    exit 1
  fi
  cp -R "$app_path" "$STAGE/macos/"
  echo "Staged: $STAGE/macos/$(basename "$app_path")"
}

stage_linux() {
  echo "==> Linux release"
  flutter build linux --release
  rm -rf "$STAGE/linux"
  mkdir -p "$STAGE/linux"
  cp -R build/linux/x64/release/bundle/. "$STAGE/linux/"
  echo "Staged: $STAGE/linux/phoenix_manager"
}

mkdir -p "$STAGE"

TARGET="${1:-auto}"
case "$TARGET" in
  auto)
    case "$OS" in
      Darwin) stage_macos ;;
      Linux) stage_linux ;;
      MINGW*|MSYS*|CYGWIN*) stage_windows ;;
      *)
        echo "Unknown OS: $OS — pass windows|macos|linux explicitly"
        exit 1
        ;;
    esac
    ;;
  windows) stage_windows ;;
  macos) stage_macos ;;
  linux) stage_linux ;;
  all)
    echo "Building all platforms requires separate runners (Windows/macOS/Linux)."
    echo "Run on each OS: ./scripts/build_steam.sh windows|macos|linux"
    exit 1
    ;;
  *)
    echo "Usage: $0 [auto|windows|macos|linux]"
    exit 1
    ;;
esac

echo ""
echo "Steam content staged under $STAGE"
echo "Next: ./steam/scripts/generate_vdfs.sh && ./scripts/upload_steam.sh"
