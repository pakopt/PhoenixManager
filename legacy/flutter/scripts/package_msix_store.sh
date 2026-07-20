#!/usr/bin/env bash
# ZIP com MSIX + README para upload Partner Center.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/build/release/store/windows"
ZIP="$OUT/phoenix-manager-msix-upload.zip"
MSIX="$OUT/phoenix_manager.msix"
STAGE="$OUT/_upload_staging"
# shellcheck source=msix_version.sh
source "$ROOT/scripts/msix_version.sh"
# shellcheck source=read_app_version.sh
source "$ROOT/scripts/read_app_version.sh"

rm -rf "$STAGE" "$ZIP"
mkdir -p "$STAGE"

[[ -f "$MSIX" ]] || { echo "ERRO: MSIX em falta — ./scripts/build_msix.sh (Windows)" >&2; exit 1; }
cp "$MSIX" "$STAGE/phoenix_manager.msix"

cat > "$STAGE/README.txt" <<EOF
Phoenix Manager — upload Microsoft Partner Center
Identity: PhoenixManager.PhoenixManager
Publisher: CN=4402D5F1-A78E-42D6-B8A3-BAEBB8F0513B
Publisher display: Phoenix Manager
Flutter: $VERSION_NAME+$VERSION_CODE
msix_version: $MSIX_VERSION
Privacidade: https://pakopt.github.io/PhoenixManager/privacy.html
Contacto: pakopt7@gmail.com

phoenix_manager.msix → Partner Center → Packages → Upload

Notas da versão (exemplo):
v$VERSION_NAME — actualização Microsoft Store (msix $MSIX_VERSION).
- Saves locais · sem conta · sem anúncios

Textos: ./scripts/msix_partner_brief.sh
Guia: docs/STORE.md (Microsoft Store)
EOF

(
  cd "$STAGE"
  zip -r "$ZIP" . -x "._*" >/dev/null
)
rm -rf "$STAGE"
echo "OK   $ZIP"
ls -lh "$ZIP"
