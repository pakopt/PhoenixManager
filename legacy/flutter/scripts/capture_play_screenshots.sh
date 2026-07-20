#!/usr/bin/env bash
# Captura screenshots Android para Google Play Store.
# Uso interactivo: navega no emulador/dispositivo e prime Enter para cada captura.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/build/release/store/android"
SCREENSHOTS="$OUT/screenshots"
EMULATOR="${ANDROID_EMULATOR:-medium_phone}"
INSTALL_APK=0
BATCH=0
SINGLE_NAME=""

usage() {
  cat <<EOF
Usage: $0 [options]

Captura PNGs para a ficha Play Store (ratio 9:16 recomendado — emulador medium_phone).

Options:
  --install       Instala APK release antes de capturar (./scripts/install_android.sh)
  --batch         Modo guiado: 5 ecrãs sugeridos (Enter entre cada um)
  --auto          Automático via integration_test (./scripts/capture_play_screenshots_auto.sh)
  --name <slug>   Uma captura com nome fixo (ex: --name dashboard)
  -o <dir>        Pasta de saída (default: build/release/store/android/screenshots)
  -h              Ajuda

Exemplos:
  $0 --install --batch
  $0 --name menu-carreira

Ecrãs sugeridos (batch):
  1. menu-carreira    — slots / nova carreira
  2. dashboard        — painel principal
  3. plantel          — lista de jogadores
  4. express          — simulação Express / resultado jornada
  5. classificacao    — tabela liga ou taça

Saída: build/release/store/android/
  screenshots/*.png
  icon-512.png        (gerado de assets/branding/icon.png)
  README.txt          — checklist Play Console

Ver também: docs/STORE.md
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --install) INSTALL_APK=1; shift ;;
  --batch) BATCH=1; shift ;;
  --auto)
    exec "$ROOT/scripts/capture_play_screenshots_auto.sh"
    ;;
  --name) SINGLE_NAME="${2:?--name requer slug}"; shift 2 ;;
    -o) SCREENSHOTS="$2"; OUT="$(dirname "$2")"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Opção desconhecida: $1" >&2; usage; exit 1 ;;
  esac
done

find_adb() {
  if command -v adb >/dev/null 2>&1; then command -v adb; return; fi
  if [[ -x "${ANDROID_HOME:-}/platform-tools/adb" ]]; then echo "${ANDROID_HOME}/platform-tools/adb"; return; fi
  if [[ -x "$HOME/Library/Android/sdk/platform-tools/adb" ]]; then echo "$HOME/Library/Android/sdk/platform-tools/adb"; return; fi
  echo "adb não encontrado." >&2
  exit 1
}

ADB="$(find_adb)"

device_serial() {
  "$ADB" devices | awk '/\tdevice$/{print $1; exit}'
}

wait_for_device() {
  local serial
  for _ in $(seq 1 45); do
    serial="$(device_serial || true)"
    if [[ -n "$serial" ]]; then
      echo "$serial"
      return 0
    fi
    sleep 2
  done
  return 1
}

ensure_device() {
  local serial
  serial="$(device_serial || true)"
  if [[ -z "$serial" ]]; then
    echo "==> Nenhum dispositivo Android — a arrancar emulador ($EMULATOR)…"
    LAUNCH_EMULATOR=1 "$ROOT/scripts/install_android.sh" 2>/dev/null || true
    flutter emulators --launch "$EMULATOR" >/dev/null 2>&1 || true
    serial="$(wait_for_device || true)"
  fi
  if [[ -z "$serial" ]]; then
    echo "ERRO: liga um dispositivo USB ou arranca o emulador:" >&2
    echo "  flutter emulators --launch $EMULATOR" >&2
    "$ADB" devices >&2
    exit 1
  fi
  echo "$serial"
}

capture_screen() {
  local slug="$1"
  local serial="$2"
  local file="$SCREENSHOTS/${slug}.png"
  local tmp
  tmp="$(mktemp -t phoenix-screenshot.XXXXXX.png)"

  if ! "$ADB" -s "$serial" exec-out screencap -p > "$tmp"; then
    rm -f "$tmp"
    echo "  FAIL captura ($slug)" >&2
    return 1
  fi

  if [[ ! -s "$tmp" ]]; then
    rm -f "$tmp"
    echo "  FAIL ficheiro vazio ($slug)" >&2
    return 1
  fi

  mv "$tmp" "$file"

  if command -v sips >/dev/null 2>&1; then
    local w h
    w="$(sips -g pixelWidth "$file" 2>/dev/null | awk '/pixelWidth/{print $2}')"
    h="$(sips -g pixelHeight "$file" 2>/dev/null | awk '/pixelHeight/{print $2}')"
    echo "  OK   ${slug}.png (${w}×${h})"
  else
    echo "  OK   ${slug}.png"
  fi
}

export_icon_512() {
  local src="$ROOT/apps/phoenix_manager/assets/branding/icon.png"
  local dest="$OUT/icon-512.png"
  if [[ ! -f "$src" ]]; then
    echo "  WARN icon.png em falta — ./scripts/regenerate_branding.sh"
    return 0
  fi
  mkdir -p "$OUT"
  cp "$src" "$dest"
  if command -v sips >/dev/null 2>&1; then
    sips -z 512 512 "$dest" >/dev/null
  fi
  echo "  OK   icon-512.png (512×512 para Play Console)"
}

write_readme() {
  mkdir -p "$OUT"
  cat > "$OUT/README.txt" <<EOF
Project Phoenix Manager — assets Google Play
Gerado: $(date -u +"%Y-%m-%d %H:%M UTC")

Screenshots (telefone):
  Pasta: screenshots/
  Mínimo Play Store: 2 imagens, ratio 9:16 ou 16:9
  Upload: Play Console → Presença na loja → Gráficos

Ícone loja:
  icon-512.png (512×512)

Feature graphic (1024×500):
  Criar manualmente — banner com logo + fundo #0A0E14, verde #2E7D32
  Ver apps/phoenix_manager/BRANDING.md

Guia completo: docs/STORE.md
EOF
}

interactive_loop() {
  local serial="$1"
  local n=1
  echo ""
  echo "Modo interactivo — navega no telemóvel/emulador."
  echo "Enter = capturar | nome + Enter = ficheiro custom | q = terminar"
  echo ""
  while true; do
    read -r -p "Captura #${n} [screenshot-${n}]: " slug || true
    slug="${slug:-screenshot-${n}}"
    [[ "$slug" == "q" || "$slug" == "Q" ]] && break
    slug="$(echo "$slug" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9._-')"
    [[ -z "$slug" ]] && continue
    capture_screen "$slug" "$serial" || true
    n=$((n + 1))
  done
}

batch_loop() {
  local serial="$1"
  local -a labels=(
    "menu-carreira:Menu carreira (slots / nova carreira)"
    "dashboard:Dashboard da carreira"
    "plantel:Plantel / lista de jogadores"
    "express:Modo Express ou resultado de jornada"
    "classificacao:Tabela (Liga ou Taça)"
  )
  local entry slug hint
  echo ""
  echo "Modo batch — ${#labels[@]} ecrãs sugeridos para a Play Store."
  echo "Prepara cada ecrã no emulador e prime Enter para capturar."
  echo ""
  for entry in "${labels[@]}"; do
    slug="${entry%%:*}"
    hint="${entry#*:}"
    read -r -p "[$slug] $hint — Enter para capturar, s para saltar: " ans || true
    [[ "$ans" == "s" || "$ans" == "S" ]] && continue
    capture_screen "$slug" "$serial" || true
  done
}

mkdir -p "$SCREENSHOTS"
SERIAL="$(ensure_device)"

if [[ "$INSTALL_APK" == "1" ]]; then
  echo "==> Instalar APK release"
  LAUNCH_EMULATOR=0 "$ROOT/scripts/install_android.sh"
  SERIAL="$(device_serial)"
fi

echo "==> Dispositivo: $SERIAL"
echo "==> Saída: $SCREENSHOTS"

echo ""
echo "==> Assets estáticos"
export_icon_512
write_readme

if [[ -n "$SINGLE_NAME" ]]; then
  slug="$(echo "$SINGLE_NAME" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9._-')"
  capture_screen "$slug" "$SERIAL"
elif [[ "$BATCH" == "1" ]]; then
  batch_loop "$SERIAL"
else
  interactive_loop "$SERIAL"
fi

echo ""
echo "Concluído. Ficheiros em:"
echo "  $OUT"
ls -lh "$SCREENSHOTS" 2>/dev/null | tail -n +2 || true
echo ""
echo "Próximo: Play Console → Presença na loja → carregar screenshots + icon-512.png"
