#!/usr/bin/env bash
# Exporta feature graphic 1024×500 para Google Play Store.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE="$ROOT/docs/store/feature-graphic.html"
OUT="$ROOT/build/release/store/android/feature-graphic.png"
ICON="$ROOT/apps/phoenix_manager/assets/branding/icon.png"

usage() {
  echo "Usage: $0 [--simple]"
  echo "  (default) Chrome headless → feature-graphic.png"
  echo "  --simple  fundo 1024×500 apenas (sem logo/texto)"
}

mkdir -p "$(dirname "$OUT")"

if [[ ! -f "$ICON" ]]; then
  echo "ERRO: $ICON em falta" >&2
  exit 1
fi

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ "${1:-}" == "--simple" ]]; then
  echo "==> Feature graphic (fundo 1024×500)"
  python3 - <<'PY' "$OUT"
import struct, zlib, sys
w, h = 1024, 500
path = sys.argv[1]
row = b"\x00" + bytes([10, 14, 20]) * w
raw = row * h
def chunk(tag, data):
    import binascii
    crc = binascii.crc32(tag + data) & 0xffffffff
    return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", crc)
ihdr = struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0)
png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr) + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b"")
open(path, "wb").write(png)
PY
  echo "  OK   $OUT"
  echo "  Dica: edita no Figma ou abre docs/store/feature-graphic.html no browser."
  exit 0
fi

CHROME=""
for c in \
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  "/Applications/Chromium.app/Contents/MacOS/Chromium"; do
  if [[ -x "$c" ]]; then CHROME="$c"; break; fi
done

if [[ -z "$CHROME" ]]; then
  echo "Chrome/Chromium não encontrado."
  echo "  open \"$TEMPLATE\""
  echo "  ou: $0 --simple"
  exit 1
fi

TMP_HTML="$(mktemp -t phoenix-fg.XXXXXX.html)"
ICON_URI="file://${ICON}"
sed "s|__ICON_PATH__|${ICON_URI}|g" "$TEMPLATE" > "$TMP_HTML"

echo "==> A renderizar com Chrome headless"
"$CHROME" \
  --headless=new \
  --disable-gpu \
  --hide-scrollbars \
  --window-size=1024,500 \
  --screenshot="$OUT" \
  "file://${TMP_HTML}" 2>/dev/null || true

rm -f "$TMP_HTML"

if [[ -f "$OUT" ]] && [[ -s "$OUT" ]]; then
  w="$(sips -g pixelWidth "$OUT" 2>/dev/null | awk '/pixelWidth/{print $2}')"
  h="$(sips -g pixelHeight "$OUT" 2>/dev/null | awk '/pixelHeight/{print $2}')"
  echo "  OK   $OUT (${w}×${h})"
else
  echo "ERRO: render falhou. Abre manualmente:" >&2
  echo "  open \"$TEMPLATE\"" >&2
  exit 1
fi
