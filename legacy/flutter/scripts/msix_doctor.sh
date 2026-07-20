#!/usr/bin/env bash
# Valida configuração MSIX / Microsoft Store.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PUBSPEC="$ROOT/apps/phoenix_manager/pubspec.yaml"
LOGO="$ROOT/apps/phoenix_manager/assets/branding/icon.png"
OK=0
WARN=0
FAIL=0

pass() { echo "  OK   $1"; OK=$((OK + 1)); }
warn() { echo "  WARN $1"; WARN=$((WARN + 1)); }
fail() { echo "  FAIL $1"; FAIL=$((FAIL + 1)); }

echo "==> msix_doctor — Project Phoenix Manager"
echo ""

echo "==> pubspec"
if grep -qE '^[[:space:]]*msix:' "$PUBSPEC"; then
  pass "dev_dependency msix"
else
  fail "msix em falta em dev_dependencies"
fi

check_cfg() {
  local key="$1" expect="$2"
  if grep -q "$expect" "$PUBSPEC"; then
    pass "$key = $expect"
  else
    fail "$key deve conter: $expect"
  fi
}

check_cfg identity_name "PhoenixManager.PhoenixManager"
check_cfg publisher "CN=4402D5F1-A78E-42D6-B8A3-BAEBB8F0513B"
check_cfg publisher_display_name "Phoenix Manager"
check_cfg display_name "Project Phoenix Manager"
if grep -qE 'store:[[:space:]]*true' "$PUBSPEC"; then
  pass "store: true"
else
  fail "store: true em falta (builds Partner Center)"
fi

if [[ -f "$LOGO" ]]; then
  pass "logo $LOGO"
else
  fail "logo em falta: assets/branding/icon.png"
fi

# shellcheck source=msix_version.sh
source "$ROOT/scripts/msix_version.sh"
pass "msix_version derivado: $MSIX_VERSION"

echo ""
echo "==> OS / build"
OS="$(uname -s)"
case "$OS" in
  MINGW*|MSYS*|CYGWIN*)
    pass "Windows — podes correr ./scripts/build_msix.sh"
    if command -v flutter >/dev/null 2>&1; then
      pass "flutter no PATH"
    else
      fail "flutter não encontrado"
    fi
    ;;
  *)
    warn "OS=$OS — MSIX só se gera em Windows (VS Build Tools)"
    echo "       Em Windows: ./scripts/build_msix.sh"
    ;;
esac

echo ""
echo "Resumo: OK=$OK WARN=$WARN FAIL=$FAIL"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0
