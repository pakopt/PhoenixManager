#!/usr/bin/env bash
# Captura screenshots desktop (macOS) — Steam / site / marketing.
# Flutter desktop não suporta integration_test takeScreenshot;
# capturamos o ecrã principal com a app em frente (abre em fullscreen).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/build/release/store/desktop"
SCREENSHOTS="$OUT/screenshots"
SITE_IMG="$ROOT/docs/site/img"
SYNC_SITE="${SYNC_SITE:-1}"
APP_NAME="Phoenix Manager"
BATCH=1
AUTO_MENU=0
SINGLE_NAME=""

usage() {
  cat <<EOF
Usage: $0 [options]

Captura PNGs do ecrã principal com o Phoenix Manager em primeiro plano (macOS).

Options:
  --batch         Modo guiado: 5 ecrãs sugeridos (default)
  --auto-menu     Lança a app e captura só o menu carreira
  --name <slug>   Uma captura com nome fixo
  --no-site       Não copiar dashboard/express/plantel para docs/site/img
  -h              Ajuda

Ecrãs sugeridos (batch):
  1. menu-carreira
  2. dashboard
  3. plantel
  4. classificacao
  5. express

Pré-requisito: \`./scripts/install_local.sh\` (ou app já em /Applications).

Saída: build/release/store/desktop/screenshots/
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --batch) BATCH=1; shift ;;
    --auto-menu) AUTO_MENU=1; BATCH=0; shift ;;
    --name) SINGLE_NAME="${2:?}"; shift 2 ;;
    --no-site) SYNC_SITE=0; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Opção desconhecida: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "ERRO: screenshots desktop só em macOS." >&2
  exit 1
fi

app_running() {
  pgrep -x phoenix_manager >/dev/null 2>&1
}

ensure_app_front() {
  osascript <<EOF >/dev/null 2>&1 || true
tell application "$APP_NAME" to activate
delay 0.5
EOF
}

launch_app_if_needed() {
  if app_running; then
    return 0
  fi
  if [[ -d "/Applications/Phoenix Manager.app" ]]; then
    echo "==> A abrir /Applications/Phoenix Manager.app"
    open -a "$APP_NAME"
  elif [[ -d "$ROOT/apps/phoenix_manager/build/macos/Build/Products/Release/phoenix_manager.app" ]]; then
    echo "==> A abrir build Release local"
    open "$ROOT/apps/phoenix_manager/build/macos/Build/Products/Release/phoenix_manager.app"
  else
    echo "ERRO: Phoenix Manager não encontrado." >&2
    echo "  ./scripts/install_local.sh" >&2
    exit 1
  fi
  for _ in $(seq 1 40); do
    sleep 1
    if app_running; then
      sleep 2
      return 0
    fi
  done
  echo "ERRO: a app não arrancou a tempo." >&2
  exit 1
}

capture_screen() {
  local slug="$1"
  local file="$SCREENSHOTS/${slug}.png"
  ensure_app_front
  sleep 0.4
  # -D1 = ecrã principal; a app abre em fullscreen por defeito.
  if ! screencapture -x -D1 "$file"; then
    echo "  FAIL screencapture ($slug)" >&2
    return 1
  fi
  if [[ ! -s "$file" ]]; then
    echo "  FAIL ficheiro vazio ($slug)" >&2
    return 1
  fi
  if command -v sips >/dev/null 2>&1; then
    local w h
    w="$(sips -g pixelWidth "$file" 2>/dev/null | awk '/pixelWidth/{print $2}')"
    h="$(sips -g pixelHeight "$file" 2>/dev/null | awk '/pixelHeight/{print $2}')"
    echo "  OK   ${slug}.png (${w}×${h})"
  else
    echo "  OK   ${slug}.png"
  fi
}

sync_site_images() {
  [[ "$SYNC_SITE" == "1" ]] || return 0
  mkdir -p "$SITE_IMG"
  for name in dashboard express plantel; do
    local src="$SCREENSHOTS/${name}.png"
    if [[ -f "$src" ]]; then
      cp "$src" "$SITE_IMG/${name}.png"
      echo "  OK   docs/site/img/${name}.png"
    fi
  done
}

write_readme() {
  mkdir -p "$OUT"
  # shellcheck source=read_app_version.sh
  source "$ROOT/scripts/read_app_version.sh"
  cat > "$OUT/README.txt" <<EOF
Phoenix Manager — screenshots desktop
Gerado: $(date -u +"%Y-%m-%d %H:%M UTC")
Versão: $VERSION_NAME ($VERSION_CODE)

Pasta: screenshots/
Método: screencapture do ecrã principal (app em fullscreen)

Ecrãs típicos:
  menu-carreira, dashboard, plantel, classificacao, express

Regenerar:
  ./scripts/capture_desktop_screenshots.sh
  ./scripts/capture_desktop_screenshots.sh --auto-menu

Dica: esconde o Dock (Cmd+Opt+D) antes de capturar para um ecrã limpo.

Mobile (Play): ./scripts/capture_play_screenshots_auto.sh
iOS (App Store): ./scripts/capture_app_store_screenshots.sh
EOF
}

batch_loop() {
  local -a labels=(
    "menu-carreira:Menu carreira (slots / nova carreira)"
    "dashboard:Dashboard da carreira (NavigationRail)"
    "plantel:Plantel / lista de jogadores"
    "classificacao:Tabela (Liga ou Taça)"
    "express:Modo Express ou resultado de jornada"
  )
  local entry slug hint
  echo ""
  echo "Modo batch — prepara cada ecrã no jogo (fullscreen) e prime Enter."
  echo "Dica: Cmd+Opt+D esconde o Dock."
  echo ""
  for entry in "${labels[@]}"; do
    slug="${entry%%:*}"
    hint="${entry#*:}"
    read -r -p "[$slug] $hint — Enter capturar, s saltar: " ans || true
    [[ "$ans" == "s" || "$ans" == "S" ]] && continue
    capture_screen "$slug" || true
  done
}

mkdir -p "$SCREENSHOTS"
launch_app_if_needed
ensure_app_front

echo "==> App: $APP_NAME"
echo "==> Saída: $SCREENSHOTS"

if [[ -n "$SINGLE_NAME" ]]; then
  slug="$(echo "$SINGLE_NAME" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9._-')"
  capture_screen "$slug"
elif [[ "$AUTO_MENU" == "1" ]]; then
  echo "==> Auto: menu carreira (espera 2s)"
  sleep 2
  capture_screen "menu-carreira"
elif [[ "$BATCH" == "1" ]]; then
  batch_loop
fi

echo ""
echo "==> Site (docs/site/img)"
sync_site_images
write_readme

echo ""
echo "Concluído: $OUT"
ls -lh "$SCREENSHOTS"/*.png 2>/dev/null || true
open "$OUT" 2>/dev/null || true
