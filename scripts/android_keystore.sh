#!/usr/bin/env bash
# Gera keystore de release Android (correr uma vez, guardar passwords em local seguro).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KEYSTORE_DIR="$ROOT/apps/phoenix_manager/android/keystore"
KEYSTORE="$KEYSTORE_DIR/phoenix-manager-release.jks"
ALIAS="phoenix-manager"

mkdir -p "$KEYSTORE_DIR"

if [[ -f "$KEYSTORE" ]]; then
  echo "Keystore já existe: $KEYSTORE"
  exit 1
fi

echo "Vais criar o keystore de release Android."
echo "Guarda as passwords — não há recuperação se perderes."
echo ""

keytool -genkey -v \
  -keystore "$KEYSTORE" \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias "$ALIAS" \
  -dname "CN=Phoenix Manager, OU=Mobile, O=Phoenix, L=Lisbon, ST=Lisbon, C=PT"

echo ""
echo "Keystore criado: $KEYSTORE"
echo "Copia android/key.properties.example → android/key.properties e preenche as passwords."
echo "Nota: `storeFile` deve ser: keystore/phoenix-manager-release.jks"
echo "Depois: ./scripts/build_mobile.sh android"
