#!/usr/bin/env bash
# Abre ou instala o build release mais recente.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLATFORM="${1:-auto}"

usage() {
  echo "Usage: $0 [auto|macos|android|linux|web]"
}

open_macos() {
  local candidates=(
    "$ROOT/build/steam/content/macos/phoenix_manager.app"
    "$ROOT/build/release/macos/phoenix_manager.app"
    "$ROOT/apps/phoenix_manager/build/macos/Build/Products/Release/phoenix_manager.app"
  )
  for app in "${candidates[@]}"; do
    if [[ -d "$app" ]]; then
      echo "Abrindo $app"
      open "$app"
      return 0
    fi
  done
  echo "Nenhum .app encontrado. Corre: ./scripts/build_release.sh"
  return 1
}

install_android() {
  local apk="$ROOT/build/release/mobile/android/phoenix_manager.apk"
  if [[ ! -f "$apk" ]]; then
    apk="$ROOT/apps/phoenix_manager/build/app/outputs/flutter-apk/app-release.apk"
  fi
  if [[ ! -f "$apk" ]]; then
    echo "APK em falta. Corre: ./scripts/build_mobile.sh android"
    return 1
  fi
  if command -v adb >/dev/null 2>&1; then
    echo "Instalando $apk"
    adb install -r "$apk"
  else
    echo "APK pronto: $apk"
    echo "Instala com adb ou copia para o telemóvel."
  fi
}

run_linux() {
  local bin="$ROOT/apps/phoenix_manager/build/linux/x64/release/bundle/phoenix_manager"
  if [[ ! -x "$bin" ]]; then
    echo "Binary Linux em falta. Corre: flutter build linux --release"
    return 1
  fi
  echo "A executar $bin"
  exec "$bin"
}

open_web() {
  local index="$ROOT/build/release/web/index.html"
  if [[ ! -f "$index" ]]; then
    echo "Build web em falta. Corre: ./scripts/build_release.sh"
    return 1
  fi
  open "$index"
}

case "$PLATFORM" in
  auto)
    case "$(uname -s)" in
      Darwin) open_macos ;;
      Linux) run_linux ;;
      *) install_android || open_web ;;
    esac
    ;;
  macos) open_macos ;;
  android) install_android ;;
  linux) run_linux ;;
  web) open_web ;;
  -h|--help|help) usage; exit 0 ;;
  *) usage; exit 1 ;;
esac
