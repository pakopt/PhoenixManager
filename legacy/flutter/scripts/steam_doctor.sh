#!/usr/bin/env bash
# Verifica pré-requisitos Steam antes de build/upload.
# Uso: steam_doctor.sh [local|upload]
#   local  — MVP: macOS depot pronto; placeholders Steamworks = aviso
#   upload — estrito: exige App ID, SDK e depots configurados
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="${STEAM_ENV:-$ROOT/steam/steam.env}"
MODE="${1:-local}"
OK=0
WARN=0
FAIL=0

pass() { echo "  OK   $1"; OK=$((OK + 1)); }
warn() { echo "  WARN $1"; WARN=$((WARN + 1)); }
fail() { echo "  FAIL $1"; FAIL=$((FAIL + 1)); }

block_upload() {
  if [[ "$MODE" == "upload" ]]; then
    fail "$1"
  else
    warn "$1 (só necessário para upload Steam)"
  fi
}

echo "==> Modo: $MODE"

echo ""
echo "==> Flutter"
if command -v flutter >/dev/null 2>&1; then
  pass "flutter no PATH ($(flutter --version 2>/dev/null | head -1))"
else
  fail "flutter não encontrado — instala Flutter SDK"
fi

echo ""
echo "==> macOS build (só relevante em Darwin)"
if [[ "$(uname -s)" == "Darwin" ]]; then
  if xcode-select -p >/dev/null 2>&1; then
    pass "xcode-select: $(xcode-select -p)"
  else
    fail "Xcode Command Line Tools em falta — corre: xcode-select --install"
  fi
  if command -v xcodebuild >/dev/null 2>&1; then
    pass "xcodebuild disponível"
  else
    fail "xcodebuild em falta — instala Xcode completo (App Store)"
  fi
else
  warn "Não estás em macOS — build macOS tem de correr num Mac"
fi

STEAM_PLATFORMS="macos"

echo ""
echo "==> steam/steam.env"
if [[ -f "$ENV_FILE" ]]; then
  pass "steam.env existe"
  # shellcheck disable=SC1090
  set -a
  source "$ENV_FILE"
  set +a

  STEAM_PLATFORMS="${STEAM_PLATFORMS:-macos}"
  STEAM_PLATFORMS="${STEAM_PLATFORMS// /}"
  pass "STEAM_PLATFORMS=$STEAM_PLATFORMS"

  if [[ "${STEAM_APP_ID:-}" =~ ^[0-9]+$ && "${STEAM_APP_ID:-}" != "0000000" ]]; then
    pass "STEAM_APP_ID=$STEAM_APP_ID"
  else
    block_upload "STEAM_APP_ID ainda é placeholder"
  fi

  if [[ -d "${STEAM_SDK_ROOT:-}/tools/ContentBuilder" ]]; then
    pass "STEAM_SDK_ROOT=$STEAM_SDK_ROOT"
  else
    block_upload "STEAM_SDK_ROOT inválido (${STEAM_SDK_ROOT:-não definido})"
    if [[ "$MODE" == "upload" ]]; then
      echo "         Descarrega SDK em partner.steamgames.com → Downloads"
    fi
  fi

  if [[ -n "${STEAM_USERNAME:-}" && "${STEAM_USERNAME}" != "your_build_account" ]]; then
    pass "STEAM_USERNAME definido"
  else
    warn "STEAM_USERNAME ainda é placeholder"
  fi

  if [[ ",$STEAM_PLATFORMS," == *",windows,"* ]]; then
    if [[ "${STEAM_DEPOT_WINDOWS:-}" =~ ^[0-9]+$ && "${STEAM_DEPOT_WINDOWS:-}" != "0000001" ]]; then
      pass "STEAM_DEPOT_WINDOWS=$STEAM_DEPOT_WINDOWS"
    else
      block_upload "STEAM_DEPOT_WINDOWS placeholder"
    fi
  fi
  if [[ ",$STEAM_PLATFORMS," == *",macos,"* ]]; then
    if [[ "${STEAM_DEPOT_MACOS:-}" =~ ^[0-9]+$ && "${STEAM_DEPOT_MACOS:-}" != "0000002" ]]; then
      pass "STEAM_DEPOT_MACOS=$STEAM_DEPOT_MACOS"
    else
      block_upload "STEAM_DEPOT_MACOS placeholder — cria depot macOS no Steamworks"
    fi
  fi
  if [[ ",$STEAM_PLATFORMS," == *",linux,"* ]]; then
    if [[ "${STEAM_DEPOT_LINUX:-}" =~ ^[0-9]+$ && "${STEAM_DEPOT_LINUX:-}" != "0000003" ]]; then
      pass "STEAM_DEPOT_LINUX=$STEAM_DEPOT_LINUX"
    else
      block_upload "STEAM_DEPOT_LINUX placeholder"
    fi
  fi
else
  fail "steam.env em falta — corre: cp steam/steam.env.example steam/steam.env"
fi

echo ""
echo "==> Conteúdo staged (build/steam/content)"
IFS=',' read -r -a PLATFORM_LIST <<< "${STEAM_PLATFORMS// /}"
for platform in "${PLATFORM_LIST[@]}"; do
  dir="$ROOT/build/steam/content/$platform"
  if [[ -d "$dir" && -n "$(ls -A "$dir" 2>/dev/null)" ]]; then
    pass "$platform depot tem ficheiros"
  else
    if [[ "$MODE" == "upload" ]]; then
      fail "$platform depot vazio — corre ./scripts/build_steam.sh $platform"
    else
      warn "$platform depot vazio — corre ./scripts/build_steam.sh $platform antes do upload"
    fi
  fi
done
for platform in windows macos linux; do
  if [[ ",$STEAM_PLATFORMS," != *",$platform,"* ]]; then
    pass "$platform omitido (STEAM_PLATFORMS)"
  fi
done

echo ""
if [[ $FAIL -gt 0 ]]; then
  echo "Resultado: $FAIL erro(s), $WARN aviso(s), $OK OK"
  exit 1
fi
if [[ "$MODE" == "local" && $WARN -gt 0 ]]; then
  echo "Resultado: $OK OK, $WARN aviso(s) — pronto para build local; upload Steam pendente."
  echo "  Para validar upload: ./scripts/steam_doctor.sh upload"
  exit 0
fi
echo "Resultado: $OK OK, $WARN aviso(s) — pronto para upload Steam."
