#!/usr/bin/env bash
# Diagnóstico completo antes de lançamento (Steam + mobile + branding + testes).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0
STEAM_UPLOAD_READY=1

section() {
  echo ""
  echo "════════════════════════════════════════"
  echo "  $1"
  echo "════════════════════════════════════════"
}

section "Branding"
ICON="$ROOT/apps/phoenix_manager/assets/branding/icon.png"
SPLASH="$ROOT/apps/phoenix_manager/assets/branding/splash.png"
for f in "$ICON" "$SPLASH"; do
  if [[ -f "$f" ]]; then
    echo "  OK   $(basename "$f")"
  else
    echo "  FAIL $(basename "$f") em falta"
    FAIL=$((FAIL + 1))
  fi
done

section "Steam (local — upload pendente é normal)"
if "$ROOT/scripts/steam_doctor.sh" local; then
  :
else
  FAIL=$((FAIL + 1))
fi

section "Steam upload (estrito)"
if "$ROOT/scripts/steam_doctor.sh" upload; then
  echo "  OK   pronto para ./scripts/upload_steam.sh"
else
  STEAM_UPLOAD_READY=0
  echo "  INFO upload Steam ainda não configurado (ver avisos acima)"
fi

section "Mobile"
if "$ROOT/scripts/mobile_doctor.sh"; then
  :
else
  FAIL=$((FAIL + 1))
fi

section "Testes"
if "$ROOT/scripts/test_all.sh" >/dev/null 2>&1; then
  echo "  OK   test_all.sh passou"
else
  echo "  FAIL testes — corre ./scripts/test_all.sh"
  FAIL=$((FAIL + 1))
fi

if [[ "${SAVE_TEST:-0}" == "1" ]]; then
  section "Saves release (integration_test)"
  if "$ROOT/scripts/test_release_saves.sh" all >/dev/null 2>&1; then
    echo "  OK   test_release_saves.sh passou"
  else
    echo "  FAIL saves — corre ./scripts/test_release_saves.sh"
    FAIL=$((FAIL + 1))
  fi
else
  echo ""
  echo "  INFO saves release: SAVE_TEST=1 ./scripts/launch_doctor.sh"
fi

echo ""
echo "────────────────────────────────────────"
if [[ $FAIL -gt 0 ]]; then
  echo "Launch doctor: $FAIL área(s) com problemas reais."
  exit 1
fi
if [[ $STEAM_UPLOAD_READY -eq 0 ]]; then
  echo "Launch doctor: OK para jogar e builds mobile/desktop."
  echo "               Steam upload pendente — preenche steam/steam.env"
  exit 0
fi
echo "Launch doctor: tudo pronto, incluindo upload Steam."
