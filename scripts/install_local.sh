#!/usr/bin/env bash
# Instala Phoenix Manager no Mac e prepara APK Android (sem Steam).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/apps/phoenix_manager"
APK_OUT="$ROOT/build/release/mobile/android/phoenix_manager.apk"
MAC_APP="$ROOT/build/release/macos/phoenix_manager.app"
INSTALL_MAC="${INSTALL_MAC:-1}"
BUILD="${BUILD:-1}"
BUILD_ANDROID="${BUILD_ANDROID:-1}"
MIN_DISK_MB_ANDROID="${MIN_DISK_MB_ANDROID:-3000}"

disk_free_mb() {
  df -k /System/Volumes/Data 2>/dev/null | awk 'NR==2 {print int($4/1024)}'
}

require_disk_for_android() {
  local avail
  avail="$(disk_free_mb)"
  if [[ -z "$avail" || "$avail" -lt "$MIN_DISK_MB_ANDROID" ]]; then
    echo ""
    echo "ERRO: Pouco espaço em disco (~${avail:-?} MiB livres; Android precisa ≥ ${MIN_DISK_MB_ANDROID} MiB)."
    echo ""
    echo "Liberta espaço e tenta de novo:"
    echo "  ./scripts/clean_dev_artifacts.sh"
    echo "  CLEAN_GRADLE=1 ./scripts/clean_dev_artifacts.sh"
    echo ""
    echo "Mac já instalado? Só Android:"
    echo "  BUILD=0 INSTALL_MAC=0 ./scripts/install_local.sh   # se APK já existir"
    echo "  cd apps/phoenix_manager && flutter build apk --release"
    exit 1
  fi
}

echo "==> Phoenix Manager — instalação local (Mac + Android APK)"
echo ""

if [[ "$BUILD" == "1" ]]; then
  echo "==> Build macOS release"
  cd "$APP"
  flutter pub get
  flutter build macos --release
  mkdir -p "$ROOT/build/release/macos"
  rm -rf "$MAC_APP"
  cp -R build/macos/Build/Products/Release/phoenix_manager.app "$MAC_APP"
  echo "==> Libertar espaço (build macOS intermediário)"
  rm -rf build/macos

  if [[ "$BUILD_ANDROID" == "1" ]]; then
    require_disk_for_android
    echo ""
    echo "==> Build Android APK"
    flutter build apk --release
    mkdir -p "$(dirname "$APK_OUT")"
    cp build/app/outputs/flutter-apk/app-release.apk "$APK_OUT"
  else
    echo ""
    echo "==> Build Android APK — omitido (BUILD_ANDROID=0)"
  fi
fi

if [[ "$(uname -s)" == "Darwin" && "$INSTALL_MAC" == "1" ]]; then
  echo ""
  echo "==> Instalar no Mac"
  if [[ ! -d "$MAC_APP" ]]; then
    echo "ERRO: $MAC_APP não encontrado"
    exit 1
  fi
  DEST="/Applications/Phoenix Manager.app"
  rm -rf "$DEST"
  cp -R "$MAC_APP" "$DEST"
  echo "Instalado em: $DEST"
  echo "A abrir..."
  open "$DEST"
fi

find_adb() {
  if command -v adb >/dev/null 2>&1; then
    command -v adb
    return 0
  fi
  if [[ -x "${ANDROID_HOME:-}/platform-tools/adb" ]]; then
    echo "${ANDROID_HOME}/platform-tools/adb"
    return 0
  fi
  if [[ -x "$HOME/Library/Android/sdk/platform-tools/adb" ]]; then
    echo "$HOME/Library/Android/sdk/platform-tools/adb"
    return 0
  fi
  return 1
}

echo ""
echo "==> Android"
if [[ ! -f "$APK_OUT" ]]; then
  echo "APK em falta: $APK_OUT"
  echo "Corre com espaço livre: ./scripts/install_local.sh"
  echo "Ou só Android (Mac já OK): BUILD=0 INSTALL_MAC=0 ./scripts/install_local.sh"
else
  echo "APK: $APK_OUT"
fi
if [[ -f "$APK_OUT" ]]; then
  ADB="$(find_adb || true)"
  if [[ -n "$ADB" ]]; then
    if "$ADB" devices | grep -qE 'device$'; then
      echo "Dispositivo detectado — a instalar..."
      "$ADB" install -r "$APK_OUT"
      echo "Instalado no telemóvel."
    else
      echo "Nenhum telemóvel USB ligado (adb OK)."
      echo "  1. Activa Depuração USB no Android"
      echo "  2. Liga o cabo USB e aceita 'Confiar neste computador'"
      echo "  3. Corre: \"$ADB\" install -r \"$APK_OUT\""
    fi
  else
    echo "adb não está no PATH."
    echo ""
    echo "Opções para instalar no Android:"
    echo "  A) Android Studio → SDK Manager → instala platform-tools"
    echo "     export PATH=\"\$PATH:\$HOME/Library/Android/sdk/platform-tools\""
    echo "     adb install -r \"$APK_OUT\""
    echo ""
    echo "  B) Copia o APK para o telemóvel (AirDrop, Google Drive, email)"
    echo "     e abre no telemóvel (permite 'fontes desconhecidas' se pedido)"
    echo ""
    echo "  C) Emulador: flutter emulators && flutter emulators --launch <id>"
    echo "     depois: adb install -r \"$APK_OUT\""
  fi
fi

echo ""
echo "Pronto. Jogar no Mac: abre 'Phoenix Manager' em Aplicações."
