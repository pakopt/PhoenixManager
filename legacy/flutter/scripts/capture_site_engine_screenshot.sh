#!/usr/bin/env bash
# Gera docs/site/motor-pse.svg (+ PNG via qlmanage) a partir do motor PSE headless.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "════════════════════════════════════════"
echo "  Arte motor PSE → docs/site/"
echo "════════════════════════════════════════"

dart run bin/export_site_engine_svg.dart

echo ""
ls -lh docs/site/motor-pse.svg docs/site/motor-pse.png 2>/dev/null || true
echo ""
echo "Também disponíveis (UI do jogo):"
ls -lh docs/site/img/*.png 2>/dev/null || true
open "$ROOT/docs/site/motor-pse.svg" 2>/dev/null || true
open "$ROOT/docs/site/motor-pse.png" 2>/dev/null || true
