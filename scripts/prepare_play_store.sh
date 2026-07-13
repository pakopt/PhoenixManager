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
  [ ] Conta Play Developer
  [ ] GitHub Pages → URL privacidade (docs/site/README.md)
  [ ] Play Console → teste interno
EOF

ls -lh "$MOBILE/phoenix_manager.aab" "$STORE"/*.png "$STORE/screenshots"/*.png 2>/dev/null || true
