#!/usr/bin/env bash
# ZIP com AAB + gráficos para upload manual na Play Console.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/build/release/store/android"
ZIP="$OUT/phoenix-manager-play-upload.zip"
AAB="$ROOT/build/release/mobile/android/phoenix_manager.aab"
STAGE="$OUT/_upload_staging"

# shellcheck source=read_app_version.sh
source "$ROOT/scripts/read_app_version.sh"

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
Phoenix Manager — upload Play Console
Package: com.phoenix.manager
Version: $VERSION_NAME (code $VERSION_CODE)
Privacidade: https://pakopt.github.io/PhoenixManager/privacy.html

phoenix_manager.aab  → Teste fechado → Criar versão → Carregar
icon-512.png         → Presença na loja → Ícone
feature-graphic.png  → Presença na loja → Feature graphic
screenshots/         → Presença na loja → Capturas de ecrã

Notas da versão (exemplo):
v$VERSION_NAME — Táctica FootSim × Phoenix (build $VERSION_CODE).
- Formação, mentalidade, ritmo e bolas paradas
- XI automático + campo visual
- Ficha de jogador · A Coruja na liga
- Saves locais · sem conta · sem anúncios

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
