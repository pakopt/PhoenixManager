#!/usr/bin/env bash
# ZIP com screenshots iOS para App Store Connect (prep).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/build/release/store/ios"
ZIP="$OUT/phoenix-manager-app-store-prep.zip"
STAGE="$OUT/_staging"
SCREENSHOTS="$OUT/screenshots"

rm -rf "$STAGE" "$ZIP"
mkdir -p "$STAGE/screenshots"

n=0
if [[ -d "$SCREENSHOTS" ]]; then
  cp "$SCREENSHOTS"/*.png "$STAGE/screenshots/" 2>/dev/null || true
  n=$(ls "$STAGE/screenshots"/*.png 2>/dev/null | wc -l | tr -d ' ')
fi

if [[ "$n" -lt 2 ]]; then
  echo "ERRO: screenshots em falta — ./scripts/capture_app_store_screenshots.sh" >&2
  exit 1
fi

cat > "$STAGE/README.txt" <<EOF
Project Phoenix Manager — App Store Connect (prep)

screenshots/  → App Store Connect → capturas iPhone
Bundle ID:     com.phoenix.manager
Versão:        0.8.1 (build 2)
Privacidade:   https://pakopt.github.io/PhoenixManager/privacy.html

Textos e App Privacy: ./scripts/app_store_brief.sh
Guia: docs/STORE.md
EOF

(
  cd "$STAGE"
  zip -r "$ZIP" . -x "._*" >/dev/null
)
rm -rf "$STAGE"

echo "OK   $ZIP ($n screenshots)"
ls -lh "$ZIP"
