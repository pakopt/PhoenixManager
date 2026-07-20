#!/usr/bin/env bash
# Captura screenshots Play Store via flutter drive + integration_test.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/apps/phoenix_manager"
OUT="$ROOT/build/release/store/android"
SCREENSHOTS="$OUT/screenshots"
EMULATOR="${ANDROID_EMULATOR:-medium_phone}"

pick_device() {
  flutter devices --machine 2>/dev/null | ruby -rjson -e '
    d = JSON.parse(STDIN.read)
    a = d.find { |x| %w[android-arm64 android-x64 android-x86 android].include?(x["targetPlatform"]) }
    puts(a ? a["id"] : "")
  ' || true
}

ensure_device() {
  local id
  id="$(pick_device)"
  if [[ -n "$id" ]]; then
    echo "$id"
    return 0
  fi
  echo "==> A arrancar emulador $EMULATOR…" >&2
  flutter emulators --launch "$EMULATOR" >/dev/null 2>&1 || true
  for _ in $(seq 1 45); do
    sleep 2
    id="$(pick_device)"
    if [[ -n "$id" ]]; then
      echo "$id"
      return 0
    fi
  done
  return 1
}

export_icon_512() {
  local src="$ROOT/apps/phoenix_manager/assets/branding/icon.png"
  local dest="$OUT/icon-512.png"
  cp "$src" "$dest"
  if command -v sips >/dev/null 2>&1; then
    sips -z 512 512 "$dest" >/dev/null
  fi
  echo "  OK   icon-512.png"
}

verify_screenshots() {
  mkdir -p "$SCREENSHOTS"
  local names=(menu-carreira dashboard plantel classificacao express)
  local ok=0
  for name in "${names[@]}"; do
    local f="$SCREENSHOTS/${name}.png"
    if [[ -f "$f" ]] && [[ "$(wc -c < "$f" | tr -d ' ')" -gt 1000 ]]; then
      echo "  OK   ${name}.png"
      ok=$((ok + 1))
    else
      rm -f "$f"
      echo "  WARN ${name}.png — em falta (opcional: express)"
    fi
  done
  if [[ $ok -lt 2 ]]; then
    echo "ERRO: menos de 2 screenshots válidos." >&2
    return 1
  fi
}

DEVICE="$(ensure_device || true)"
if [[ -z "$DEVICE" ]]; then
  echo "ERRO: nenhum dispositivo Android." >&2
  exit 1
fi

mkdir -p "$SCREENSHOTS"
echo "==> Dispositivo: $DEVICE"
echo "==> flutter drive → $SCREENSHOTS"

(
  cd "$APP"
  flutter pub get >/dev/null
  STORE_SCREENSHOT_DIR="$SCREENSHOTS" flutter drive \
    --driver=test_driver/store_screenshots_driver.dart \
    --target=integration_test/store_screenshots_test.dart \
    -d "$DEVICE"
)

echo ""
echo "==> Verificar screenshots"
verify_screenshots

echo ""
echo "==> Assets estáticos"
export_icon_512
"$ROOT/scripts/export_feature_graphic.sh" 2>/dev/null || true

echo ""
echo "Concluído: $OUT"
ls -lh "$SCREENSHOTS"/*.png 2>/dev/null || true
