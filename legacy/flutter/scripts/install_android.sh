#!/usr/bin/env bash
# Instala APK no Android (USB ou emulador).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APK="$ROOT/build/release/mobile/android/phoenix_manager.apk"
PKG="com.phoenix.manager"
EMULATOR="${ANDROID_EMULATOR:-medium_phone}"
LAUNCH_EMULATOR="${LAUNCH_EMULATOR:-1}"

find_adb() {
  if command -v adb >/dev/null 2>&1; then command -v adb; return; fi
  if [[ -x "${ANDROID_HOME:-}/platform-tools/adb" ]]; then echo "${ANDROID_HOME}/platform-tools/adb"; return; fi
  if [[ -x "$HOME/Library/Android/sdk/platform-tools/adb" ]]; then echo "$HOME/Library/Android/sdk/platform-tools/adb"; return; fi
  echo "adb não encontrado. Instala Android SDK platform-tools." >&2
  exit 1
}

find_emulator_bin() {
  if command -v emulator >/dev/null 2>&1; then command -v emulator; return; fi
  if [[ -x "${ANDROID_HOME:-}/emulator/emulator" ]]; then echo "${ANDROID_HOME}/emulator/emulator"; return; fi
  if [[ -x "$HOME/Library/Android/sdk/emulator/emulator" ]]; then echo "$HOME/Library/Android/sdk/emulator/emulator"; return; fi
  return 1
}

ADB="$(find_adb)"

if [[ ! -f "$APK" ]]; then
  echo "APK em falta. A construir..."
  "$ROOT/scripts/build_mobile.sh" android
fi

device_ready() {
  "$ADB" devices | grep -qE '^\S+\s+device$'
}

wait_for_boot() {
  echo "A aguardar Android arrancar..."
  for _ in $(seq 1 60); do
    if device_ready; then
      boot="$("$ADB" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')"
      if [[ "$boot" == "1" ]]; then
        return 0
      fi
    fi
    sleep 2
  done
  return 1
}

launch_emulator() {
  echo "A iniciar emulador: $EMULATOR"
  flutter emulators --launch "$EMULATOR" &
  for _ in $(seq 1 15); do
    if device_ready; then return 0; fi
    sleep 2
  done
  EMU_BIN="$(find_emulator_bin || true)"
  if [[ -n "$EMU_BIN" ]] && "$EMU_BIN" -list-avds 2>/dev/null | grep -qx "$EMULATOR"; then
    echo "flutter emulators não ligou ao adb — a usar SDK emulator..."
    "$EMU_BIN" -avd "$EMULATOR" -no-snapshot-load >/dev/null 2>&1 &
  fi
}

if ! device_ready; then
  if [[ "$LAUNCH_EMULATOR" == "1" ]]; then
    launch_emulator
  fi
  wait_for_boot || true
fi

if ! device_ready || ! wait_for_boot; then
  echo ""
  echo "Nenhum dispositivo Android."
  echo "  USB: liga telemóvel + Depuração USB"
  echo "  Emulador: flutter emulators --launch medium_phone"
  echo "  Depois: $0"
  "$ADB" devices
  exit 1
fi

echo "A instalar $APK"
install_apk() {
  "$ADB" install -r "$APK" 2>&1
}

if install_apk; then
  echo "Phoenix Manager instalado no Android."
  "$ADB" shell am start -n "$PKG/$PKG.MainActivity" 2>/dev/null || true
  exit 0
fi

echo ""
echo "Assinatura incompatível — versão Play Store ou debug no dispositivo."
echo "A desinstalar $PKG e a reinstalar APK local (saves do telemóvel serão apagados)..."
"$ADB" uninstall "$PKG" >/dev/null 2>&1 || true

if install_apk; then
  echo "Phoenix Manager instalado no Android."
  "$ADB" shell am start -n "$PKG/$PKG.MainActivity" 2>/dev/null || true
  exit 0
fi

echo "Instalação falhou. Manualmente:"
echo "  \"$ADB\" uninstall $PKG"
echo "  \"$ADB\" install -r \"$APK\""
exit 1
