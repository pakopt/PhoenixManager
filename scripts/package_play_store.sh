#!/usr/bin/env bash
# ZIP com AAB + gráficos para upload manual na Play Console.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/build/release/store/android"
ZIP="$OUT/phoenix-manager-play-upload.zip"
AAB="$ROOT/build/release/mobile/android/phoenix_manager.aab"
STAGE="$OUT/_upload_staging"

rm -rf "$STAGE" "$ZIP"
mkdir -p "$STAGE/screenshots"

[[ -f "$AAB" ]] || { echo "ERRO: AAB em falta — ./scripts/build_mobile.sh android" >&2; exit 1; }
cp "$AAB" "$STAGE/phoenix_manager.aab"
[[ -f "$OUT/icon-512.png" ]] && cp "$OUT/icon-512.png" "$STAGE/"
[[ -f "$OUT/feature-graphic.png" ]] && cp "$OUT/feature-graphic.png" "$STAGE/"
if [[ -d "$OUT/screenshots" ]]; then
  cp "$OUT/screenshots"/*.png "$STAGE/screenshots/" 2>/dev/null || true
fi

cat > "$STAGE/README.txt" <<EOF
Project Phoenix Manager — upload Play Console
Package: com.phoenix.manager
Version: 0.8.0-alpha (code 1)
Privacidade: https://pakopt.github.io/PhoenixManager/privacy.html

phoenix_manager.aab  → Teste interno → Carregar
icon-512.png         → Presença na loja → Ícone
feature-graphic.png  → Presença na loja → Feature graphic
screenshots/         → Presença na loja → Capturas de ecrã

Textos e Data safety: ./scripts/play_console_brief.sh
Guia: docs/STORE.md
EOF

(
  cd "$STAGE"
  zip -r "$ZIP" . -x "._*" >/dev/null
)
rm -rf "$STAGE"

echo "OK   $ZIP"
ls -lh "$ZIP"
echo ""
echo "Abrir pasta: open \"$OUT\""
