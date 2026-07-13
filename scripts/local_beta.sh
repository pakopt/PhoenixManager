#!/usr/bin/env bash
# Pacote beta local (APK + instruções) — sem Play Store.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APK="$ROOT/build/release/mobile/android/phoenix_manager.apk"
OUT="$ROOT/build/release/beta"
ZIP="$OUT/phoenix-manager-beta.zip"
STAGE="$OUT/_staging"

mkdir -p "$OUT"
rm -rf "$STAGE" "$ZIP"
mkdir -p "$STAGE"

if [[ ! -f "$APK" ]]; then
  echo "APK em falta — a construir..."
  "$ROOT/scripts/build_mobile.sh" android
fi

cp "$APK" "$STAGE/phoenix_manager.apk"

cat > "$STAGE/LEIA-ME.txt" <<'EOF'
Project Phoenix Manager — beta local (Android)

1. Transfere este ZIP para o telemóvel Android
2. Descompacta e abre phoenix_manager.apk
3. Se necessário: Definições → permitir fontes desconhecidas
4. Abre a app e testa uma carreira

Versão: 0.8.1
Package: com.phoenix.manager
Contacto: pakopt7@gmail.com
Privacidade: https://pakopt.github.io/PhoenixManager/privacy.html

Roteiro QA: docs/BETA.md
EOF

(
  cd "$STAGE"
  zip -r "$ZIP" . -x "._*" >/dev/null
)
rm -rf "$STAGE"

echo "════════════════════════════════════════"
echo "  Beta local — Android"
echo "════════════════════════════════════════"
echo ""
echo "  ZIP:  $ZIP"
ls -lh "$ZIP"
echo ""
echo "Partilha o ZIP com testadores (email, Drive, AirDrop…)."
echo ""
echo "Mac release:"
if [[ -d "/Applications/Phoenix Manager.app" ]]; then
  echo "  OK   /Applications/Phoenix Manager.app"
  echo "       Copia a .app para outro Mac (ver docs/BETA.md)"
else
  echo "  --   ./scripts/install_local.sh"
fi
echo ""
echo "QA manual: docs/BETA.md"
echo "Testes:    ./scripts/test_mac.sh  |  ./scripts/test_android.sh"

if [[ "$(uname -s)" == "Darwin" ]]; then
  open "$OUT" 2>/dev/null || true
fi
