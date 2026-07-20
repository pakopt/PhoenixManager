#!/usr/bin/env bash
# Teste rápido Android: saves release (requer emulador ou dispositivo).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "════════════════════════════════════════"
echo "  Teste Android — Phoenix Manager"
echo "════════════════════════════════════════"

echo ""
echo "==> Saves release (integration_test + SharedPreferences)"
"$ROOT/scripts/test_release_saves.sh" android

echo ""
echo "==> Instalar APK release no dispositivo"
"$ROOT/scripts/install_android.sh" 2>/dev/null || echo "  (install_android.sh opcional — APK já testado via integration_test)"
