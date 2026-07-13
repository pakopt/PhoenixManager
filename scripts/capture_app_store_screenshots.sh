#!/usr/bin/env bash
# Captura screenshots App Store via simulador iOS + integration_test.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/apps/phoenix_manager"
OUT="$ROOT/build/release/store/ios"
SCREENSHOTS="$OUT/screenshots"

pick_ios_device() {
  flutter devices --machine 2>/dev/null | ruby -rjson -e '
    d = JSON.parse(STDIN.read)
    a = d.find { |x| x["targetPlatform"] == "ios" }
    puts(a ? a["id"] : "")
  ' || true
}

ensure_ios_simulator() {
  local id
  id="$(pick_ios_device)"
  if [[ -n "$id" ]]; then
    echo "$id"
    return 0
  fi
  echo "==> A arrancar simulador iOS…" >&2
  open -a Simulator 2>/dev/null || true
  for _ in $(seq 1 45); do
    sleep 2
    id="$(pick_ios_device)"
    if [[ -n "$id" ]]; then
      echo "$id"
      return 0
    fi
  done
  return 1
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
      echo "  WARN ${name}.png — em falta"
    fi
  done
  if [[ $ok -lt 2 ]]; then
    echo "ERRO: menos de 2 screenshots válidos." >&2
    return 1
  fi
}

DEVICE="$(ensure_ios_simulator || true)"
if [[ -z "$DEVICE" ]]; then
  echo "ERRO: nenhum simulador iOS. Corre: ./scripts/run_dev.sh ios" >&2
  exit 1
fi

mkdir -p "$SCREENSHOTS"
echo "==> Simulador: $DEVICE"
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
echo "Concluído: $OUT"
echo "App Store prep: ./scripts/app_store_brief.sh"
ls -lh "$SCREENSHOTS"/*.png 2>/dev/null || true

if [[ "$(uname -s)" == "Darwin" ]]; then
  open "$OUT" 2>/dev/null || true
fi
