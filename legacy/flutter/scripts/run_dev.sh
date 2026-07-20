#!/usr/bin/env bash
# Corre o jogo em modo desenvolvimento (hot reload).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/apps/phoenix_manager"
TARGET="${1:-macos}"

pick_ios_simulator_id() {
  flutter devices --machine 2>/dev/null | ruby -rjson -e '
    d = JSON.parse(STDIN.read)
    a = d.find { |x| x["targetPlatform"] == "ios" && x["emulator"] == true }
    puts(a ? a["id"] : "")
  ' || true
}

pick_android_device_id() {
  flutter devices --machine 2>/dev/null | ruby -rjson -e '
    d = JSON.parse(STDIN.read)
    a = d.find do |x|
      %w[android-arm64 android-x64 android-x86 android].include?(x["targetPlatform"])
    end
    puts(a ? a["id"] : "")
  ' || true
}

ensure_ios_simulator() {
  local id
  id="$(pick_ios_simulator_id)"
  if [[ -n "$id" ]]; then
    echo "$id"
    return 0
  fi
  echo "==> A arrancar simulador iOS…" >&2
  flutter emulators --launch apple_ios_simulator >/dev/null 2>&1 || true
  open -a Simulator >/dev/null 2>&1 || true
  for _ in $(seq 1 30); do
    sleep 2
    id="$(pick_ios_simulator_id)"
    if [[ -n "$id" ]]; then
      echo "$id"
      return 0
    fi
  done
  return 1
}

ensure_android_device() {
  local id adb_bin="${ANDROID_HOME:-$HOME/Library/Android/sdk}/platform-tools/adb"
  id="$(pick_android_device_id)"
  if [[ -n "$id" ]]; then
    echo "$id"
    return 0
  fi
  echo "==> A arrancar emulador Android…" >&2
  flutter emulators --launch medium_phone >/dev/null 2>&1 || \
    "$HOME/Library/Android/sdk/emulator/emulator" -avd medium_phone -read-only -no-snapshot-load >/dev/null 2>&1 &
  for _ in $(seq 1 45); do
    sleep 2
    if [[ -x "$adb_bin" ]]; then
      "$adb_bin" wait-for-device >/dev/null 2>&1 || true
    fi
    id="$(pick_android_device_id)"
    if [[ -n "$id" ]]; then
      echo "$id"
      return 0
    fi
  done
  return 1
}

cd "$APP"
flutter pub get

case "$TARGET" in
  macos|chrome|web|ios|android|linux)
    if [[ "$TARGET" == web ]]; then
      TARGET=chrome
    fi
    if [[ "$TARGET" == ios ]]; then
      IOS_ID="$(ensure_ios_simulator || true)"
      if [[ -z "${IOS_ID:-}" ]]; then
        echo "ERRO: nenhum simulador iOS detectado."
        echo "      Dica: xcrun simctl list devices available"
        exit 1
      fi
      echo "==> flutter run -d $IOS_ID"
      flutter run -d "$IOS_ID"
      exit 0
    fi
    if [[ "$TARGET" == android ]]; then
      ANDROID_ID="$(ensure_android_device || true)"
      if [[ -z "${ANDROID_ID:-}" ]]; then
        echo "ERRO: nenhum dispositivo Android detectado."
        echo "      Dica: flutter emulators --launch medium_phone"
        exit 1
      fi
      echo "==> flutter run -d $ANDROID_ID"
      flutter run -d "$ANDROID_ID"
      exit 0
    fi
    echo "==> flutter run -d $TARGET"
    flutter run -d "$TARGET"
    ;;
  *)
    echo "Usage: $0 [macos|chrome|web|ios|android|linux]"
    echo ""
    echo "Dispositivos disponíveis:"
    flutter devices
    exit 1
    ;;
esac
