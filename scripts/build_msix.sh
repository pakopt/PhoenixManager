#!/usr/bin/env bash
# Build MSIX para Microsoft Store (requer Windows).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/apps/phoenix_manager"
OUT="$ROOT/build/release/store/windows"
# shellcheck source=msix_version.sh
source "$ROOT/scripts/msix_version.sh"

"$ROOT/scripts/msix_doctor.sh" || true

OS="$(uname -s)"
case "$OS" in
  MINGW*|MSYS*|CYGWIN*) ;;
  *)
    echo "ERRO: build MSIX só em Windows." >&2
    echo "Neste Mac/Linux a config foi validada por msix_doctor." >&2
    echo "Em Windows:" >&2
    echo "  cd \"$ROOT\"" >&2
    echo "  ./scripts/build_msix.sh" >&2
    echo "Versão MSIX prevista: $MSIX_VERSION" >&2
    exit 1
    ;;
esac

cd "$APP"
flutter pub get
flutter build windows --release
dart run msix:create --store --version "$MSIX_VERSION"

mkdir -p "$OUT"
# msix coloca o .msix sob build/windows/... — procurar e copiar
MSIX_SRC="$(find build -name '*.msix' -type f | head -1)"
if [[ -z "$MSIX_SRC" ]]; then
  echo "ERRO: .msix não encontrado após msix:create" >&2
  exit 1
fi
cp "$MSIX_SRC" "$OUT/phoenix_manager.msix"
echo "OK   $OUT/phoenix_manager.msix"
echo "     msix_version=$MSIX_VERSION"
ls -lh "$OUT/phoenix_manager.msix"
