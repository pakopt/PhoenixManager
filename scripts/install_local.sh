#!/usr/bin/env bash
# Instala Phoenix Manager no Mac e prepara APK Android (sem Steam).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/apps/phoenix_manager"
APK_OUT="$ROOT/build/release/mobile/android/phoenix_manager.apk"
MAC_APP="$ROOT/build/release/macos/phoenix_manager.app"
INSTALL_MAC="${INSTALL_MAC:-1}"
BUILD="${BUILD:-1}"

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

  echo ""
  echo "==> Build Android APK"
  flutter build apk --release
  mkdir -p "$(dirname "$APK_OUT")"
  cp build/app/outputs/flutter-apk/app-release.apk "$APK_OUT"
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
echo "APK: $APK_OUT"
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

echo ""
echo "Pronto. Jogar no Mac: abre 'Phoenix Manager' em Aplicações."
