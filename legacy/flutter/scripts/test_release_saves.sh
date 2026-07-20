#!/usr/bin/env bash
# Testa persistência de saves em builds release (macOS + Android).
# Usa integration_test com SharedPreferences real (mesmo backend que release).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/apps/phoenix_manager"
PKG_ANDROID="com.phoenix.manager"
MAC_BUNDLE="com.phoenix.manager"
MAC_BUNDLE_LEGACY="com.example.phoenixManager"
APK="$ROOT/build/release/mobile/android/phoenix_manager.apk"
TEST_FILE="integration_test/save_persistence_test.dart"

find_adb() {
  if command -v adb >/dev/null 2>&1; then command -v adb; return; fi
  if [[ -x "${ANDROID_HOME:-}/platform-tools/adb" ]]; then echo "${ANDROID_HOME}/platform-tools/adb"; return; fi
  if [[ -x "$HOME/Library/Android/sdk/platform-tools/adb" ]]; then echo "$HOME/Library/Android/sdk/platform-tools/adb"; return; fi
  return 1
}

log() { printf '\n[%s] %s\n' "$(date +%H:%M:%S)" "$*"; }
fail() { echo "FALHOU: $*" >&2; exit 1; }
pass() { echo "OK: $*"; }

run_integration_test() {
  local device="$1"
  local label="$2"
  log "$label — integration_test (SharedPreferences real)"
  (
    cd "$APP"
    flutter pub get >/dev/null
    flutter test "$TEST_FILE" -d "$device"
  )
  pass "$label — save persiste após reinício"
}

ensure_android_device() {
  ADB="$(find_adb)" || fail "adb não encontrado"
  export ADB

  if "$ADB" devices | grep -qE '^\S+\s+device$'; then
    return 0
  fi

  log "Sem dispositivo Android — a arrancar emulador..."
  EMU="$HOME/Library/Android/sdk/emulator/emulator"
  flutter emulators --launch medium_phone >/dev/null 2>&1 || true
  if [[ -x "$EMU" ]]; then
    "$EMU" -avd medium_phone -read-only -no-snapshot-load -no-boot-anim >/dev/null 2>&1 &
  fi

  for _ in $(seq 1 90); do
    if "$ADB" devices | grep -qE '^\S+\s+device$'; then
      boot="$("$ADB" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')"
      [[ "$boot" == "1" ]] && break
    fi
    sleep 2
  done
  "$ADB" devices | grep -qE '^\S+\s+device$' || fail "Emulador/dispositivo indisponível"
}

test_android() {
  ensure_android_device
  local device
  device="$("$ADB" devices | awk '/device$/{print $1; exit}')"

  if [[ ! -f "$APK" ]]; then
    log "APK em falta — a construir release..."
    "$ROOT/scripts/build_mobile.sh" android
  fi

  log "Instalar APK release no dispositivo..."
  if ! "$ADB" install -r "$APK" >/dev/null 2>&1; then
    log "Assinatura incompatível — a desinstalar versão anterior..."
    "$ADB" uninstall "$PKG_ANDROID" >/dev/null 2>&1 || true
    "$ADB" install -r "$APK" >/dev/null
  fi

  run_integration_test "$device" "Android ($device)"
}

test_macos() {
  [[ -d "/Applications/Phoenix Manager.app" ]] || fail "Instala Mac: ./scripts/install_local.sh"
  run_integration_test macos "macOS"
}

verify_mac_release_prefs() {
  log "macOS — verificar UserDefaults da app release instalada"
  if defaults read "$MAC_BUNDLE" flutter.phoenix_save_v1_0 >/dev/null 2>&1; then
    pass "App release tem save em UserDefaults ($MAC_BUNDLE)"
  elif defaults read "$MAC_BUNDLE_LEGACY" flutter.phoenix_save_v1_0 >/dev/null 2>&1; then
    echo "AVISO: Save encontrado no bundle antigo ($MAC_BUNDLE_LEGACY)."
    echo "       Reinstala com ./scripts/install_local.sh para migrar para $MAC_BUNDLE."
  else
    echo "AVISO: Nenhum save na app release (normal se ainda não jogaste)."
  fi
}

usage() {
  cat <<EOF
Uso: $0 [android|macos|all]

Testa saves com integration_test + SharedPreferences real:
  1. Limpa slots
  2. Inicia carreira Express + simula jornada + guarda
  3. Novo GameController (simula reinício da app)
  4. Verifica tick e clube restaurados

EOF
}

TARGET="${1:-all}"
case "$TARGET" in
  android) test_android ;;
  macos)
    test_macos
    verify_mac_release_prefs
    ;;
  all)
    test_macos
    verify_mac_release_prefs
    test_android
    ;;
  -h|--help) usage ;;
  *) usage; exit 1 ;;
esac

log "Todos os testes de save passaram."
