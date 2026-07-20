#!/usr/bin/env bash
# Teste rápido no Mac: saves release + checklist local.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "════════════════════════════════════════"
echo "  Teste Mac — Phoenix Manager"
echo "════════════════════════════════════════"

echo ""
echo "==> Saves release (integration_test + UserDefaults)"
"$ROOT/scripts/test_release_saves.sh" macos

echo ""
echo "==> App instalada"
if [[ -d "/Applications/Phoenix Manager.app" ]]; then
  echo "  OK   /Applications/Phoenix Manager.app"
  echo ""
  echo "Abrir release:  open -a \"Phoenix Manager\""
  echo "Dev (hot reload): ./scripts/run_dev.sh macos"
else
  echo "  !!   Não instalada — ./scripts/install_local.sh"
fi
