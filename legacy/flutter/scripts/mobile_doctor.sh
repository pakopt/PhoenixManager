#!/usr/bin/env bash
# Verifica pré-requisitos para builds Android/iOS.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/apps/phoenix_manager"
OK=0
WARN=0
FAIL=0

pass() { echo "  OK   $1"; OK=$((OK + 1)); }
warn() { echo "  WARN $1"; WARN=$((WARN + 1)); }
fail() { echo "  FAIL $1"; FAIL=$((FAIL + 1)); }

echo "==> Flutter"
if command -v flutter >/dev/null 2>&1; then
  pass "flutter no PATH"
else
  fail "flutter não encontrado"
fi

echo ""
echo "==> Android"
if [[ -n "${ANDROID_HOME:-}" || -d "$HOME/Library/Android/sdk" ]]; then
  pass "Android SDK presente"
else
  fail "Android SDK em falta — instala Android Studio"
fi
ADB_BIN=""
if command -v adb >/dev/null 2>&1; then
  ADB_BIN="$(command -v adb)"
elif [[ -x "${ANDROID_HOME:-}/platform-tools/adb" ]]; then
  ADB_BIN="${ANDROID_HOME}/platform-tools/adb"
elif [[ -x "$HOME/Library/Android/sdk/platform-tools/adb" ]]; then
  ADB_BIN="$HOME/Library/Android/sdk/platform-tools/adb"
fi
if [[ -n "$ADB_BIN" ]]; then
  pass "adb: $ADB_BIN"
else
  warn "adb não no PATH — export PATH=\"\$PATH:\$HOME/Library/Android/sdk/platform-tools\""
fi
if command -v java >/dev/null 2>&1; then
  pass "Java: $(java -version 2>&1 | head -1)"
else
  warn "Java não encontrado no PATH"
fi
if [[ -d "${ANDROID_HOME:-$HOME/Library/Android/sdk}/cmdline-tools" ]]; then
  pass "Android cmdline-tools instalados"
else
  warn "cmdline-tools em falta — AAB pode avisar sobre debug symbols"
  echo "         Android Studio → SDK Manager → Android SDK Command-line Tools"
fi

echo ""
echo "==> Android signing (Play Store)"
KEYSTORE="$ROOT/apps/phoenix_manager/android/keystore/phoenix-manager-release.jks"
KEY_PROPS="$ROOT/apps/phoenix_manager/android/key.properties"
if [[ -f "$KEYSTORE" && -f "$KEY_PROPS" ]]; then
  pass "keystore + key.properties configurados"
elif [[ -f "$KEYSTORE" ]]; then
  warn "keystore existe — falta android/key.properties"
  echo "         cp apps/phoenix_manager/android/key.properties.example → key.properties"
elif [[ -f "$KEY_PROPS" ]]; then
  warn "key.properties existe — keystore em falta (./scripts/android_keystore.sh)"
else
  warn "Release Play Store: ./scripts/android_keystore.sh (AAB usa debug key por agora)"
fi

echo ""
echo "==> iOS (macOS + Xcode)"
if [[ "$(uname -s)" == "Darwin" ]]; then
  if command -v xcodebuild >/dev/null 2>&1; then
    pass "xcodebuild: $(xcodebuild -version | head -1)"
  else
    fail "xcodebuild em falta"
  fi
  if xcrun simctl list devices available 2>/dev/null | grep -q "iPhone"; then
    pass "Simuladores iOS disponíveis"
  else
    warn "Nenhum simulador iOS — instala runtime no Xcode"
  fi
  if [[ -f "$APP/ios/Podfile" ]]; then
    warn "ios/Podfile presente — projecto usa SwiftPM; considera pod deintegrate"
  else
    pass "iOS via Swift Package Manager (sem CocoaPods)"
  fi
  warn "Codesign: builds locais usam --no-codesign; TestFlight exige Apple Developer"
else
  warn "iOS build só em macOS"
fi

echo ""
echo "==> Artefactos staged"
MOBILE="$ROOT/build/release/mobile"
for f in "$MOBILE/android/phoenix_manager.apk" "$MOBILE/android/phoenix_manager.aab" "$MOBILE/ios/Runner.app"; do
  if [[ -e "$f" ]]; then
    pass "$(basename "$f") existe"
  else
    warn "$(basename "$f") em falta — corre ./scripts/build_mobile.sh"
  fi
done

echo ""
echo "==> Documentação / lojas"
PRIVACY_SITE="$ROOT/docs/site/privacy.html"
PLANO="$ROOT/docs/plano.md"
if [[ -f "$PRIVACY_SITE" ]]; then
  pass "docs/site/privacy.html (Play Store URL)"
else
  warn "docs/site/privacy.html em falta"
fi
if [[ -f "$PLANO" ]]; then
  pass "docs/plano.md"
else
  warn "docs/plano.md em falta"
fi
STORE_ASSETS="$ROOT/build/release/store/android/screenshots"
if [[ -d "$STORE_ASSETS" ]] && ls "$STORE_ASSETS"/*.png >/dev/null 2>&1; then
  pass "screenshots Play Store ($(ls "$STORE_ASSETS"/*.png 2>/dev/null | wc -l | tr -d ' ') ficheiros)"
else
  warn "screenshots em falta — ./scripts/capture_play_screenshots_auto.sh"
fi
if [[ -d "$ROOT/.git" ]] || git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1; then
  pass "repositório git inicializado"
else
  warn "sem git — ./scripts/setup_github_pages.sh"
fi
pass "privacidade https://pakopt.github.io/PhoenixManager/privacy.html"
if [[ -f "$ROOT/build/release/mobile/android/phoenix_manager.aab" ]]; then
  pass "Play Console brief — ./scripts/play_console_brief.sh"
fi

echo ""
if [[ $FAIL -gt 0 ]]; then
  echo "Resultado: $FAIL erro(s), $WARN aviso(s), $OK OK"
  exit 1
fi
echo "Resultado: $OK OK, $WARN aviso(s) — pronto para build mobile."
