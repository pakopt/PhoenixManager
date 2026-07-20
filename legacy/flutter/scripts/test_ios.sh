#!/usr/bin/env bash
# Teste rápido iOS: build + screenshots prep (simulador).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "════════════════════════════════════════"
echo "  Teste iOS — Phoenix Manager"
echo "════════════════════════════════════════"

echo ""
echo "==> Build iOS (sem codesign)"
"$ROOT/scripts/build_mobile.sh" ios 2>&1 | tail -5

echo ""
echo "==> Screenshots App Store (simulador)"
"$ROOT/scripts/capture_app_store_screenshots.sh" 2>&1 | tail -12

echo ""
echo "==> Pacote prep"
"$ROOT/scripts/package_app_store.sh" 2>&1 | tail -3

echo ""
echo "Dev simulador: ./scripts/run_dev.sh ios"
echo "App Store:     ./scripts/app_store_brief.sh"
