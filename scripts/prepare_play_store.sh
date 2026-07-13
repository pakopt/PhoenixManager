#!/usr/bin/env bash
# Prepara pacote completo para Google Play (build + gráficos + checklist).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKIP_BUILD="${SKIP_BUILD:-0}"

echo "════════════════════════════════════════"
echo "  Prepare Play Store — Phoenix Manager"
echo "════════════════════════════════════════"

if [[ "$SKIP_BUILD" != "1" ]]; then
  echo ""
  echo "==> Build AAB/APK release"
  "$ROOT/scripts/build_mobile.sh" android
else
  echo ""
  echo "==> Build ignorado (SKIP_BUILD=1)"
fi

echo ""
echo "==> Screenshots automáticos + gráficos"
chmod +x "$ROOT/scripts/capture_play_screenshots_auto.sh" \
  "$ROOT/scripts/export_feature_graphic.sh" 2>/dev/null || true
"$ROOT/scripts/capture_play_screenshots_auto.sh"

echo ""
echo "==> Brief + pacote ZIP"
chmod +x "$ROOT/scripts/play_console_brief.sh" \
  "$ROOT/scripts/package_play_store.sh" 2>/dev/null || true
"$ROOT/scripts/play_console_brief.sh" 2>&1 | tail -8
"$ROOT/scripts/package_play_store.sh" 2>&1 | tail -3

echo ""
echo "==> Diagnóstico mobile"
"$ROOT/scripts/mobile_doctor.sh" || true

STORE="$ROOT/build/release/store/android"
MOBILE="$ROOT/build/release/mobile/android"

cat <<EOF

────────────────────────────────────────
Pacote Play Store pronto em:
  AAB:  $MOBILE/phoenix_manager.aab
  Store: $STORE/

Upload + ficha: docs/STORE.md
Plano:          docs/plano.md

Pendente (manual):
  [ ] Conta Play Developer activa (verificação Google)
  [ ] Play Console → teste interno
  URL privacidade: https://pakopt.github.io/PhoenixManager/privacy.html
EOF

ls -lh "$MOBILE/phoenix_manager.aab" "$STORE"/*.png "$STORE/screenshots"/*.png 2>/dev/null || true
