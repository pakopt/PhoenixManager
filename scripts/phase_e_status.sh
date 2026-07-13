#!/usr/bin/env bash
# Estado consolidado da Fase E — lançamento.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PRIVACY="https://pakopt.github.io/PhoenixManager/privacy.html"

echo "════════════════════════════════════════"
echo "  Fase E — Estado do lançamento"
echo "  $(date '+%Y-%m-%d %H:%M')"
echo "════════════════════════════════════════"

section() { echo ""; echo "==> $1"; }

section "Plataformas locais"
for item in \
  "macOS:/Applications/Phoenix Manager.app" \
  "AAB:$ROOT/build/release/mobile/android/phoenix_manager.aab" \
  "APK:$ROOT/build/release/mobile/android/phoenix_manager.apk"; do
  label="${item%%:*}"
  path="${item#*:}"
  if [[ -e "$path" ]]; then
    echo "  OK   $label"
  else
    echo "  --   $label (em falta)"
  fi
done

section "Loja Play Store"
shots=0
[[ -d "$ROOT/build/release/store/android/screenshots" ]] && \
  shots=$(ls "$ROOT/build/release/store/android/screenshots"/*.png 2>/dev/null | wc -l | tr -d ' ')
echo "  OK   Privacidade: $PRIVACY"
echo "  OK   Screenshots: $shots"
[[ -f "$ROOT/build/release/store/android/phoenix-manager-play-upload.zip" ]] && \
  echo "  OK   ZIP upload: build/release/store/android/phoenix-manager-play-upload.zip" || \
  echo "  --   ZIP — ./scripts/package_play_store.sh"

section "Git"
if git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1; then
  branch="$(git -C "$ROOT" rev-parse --abbrev-ref HEAD)"
  remote="$(git -C "$ROOT" rev-parse --abbrev-ref @{u} 2>/dev/null || echo 'sem remote')"
  echo "  OK   branch $branch ($remote)"
else
  echo "  --   sem git"
fi

section "Bloqueantes"
echo "  ⏳  Play Console — conta em verificação Google"
echo "  ⏳  Teste interno — após aprovação da conta"
echo "  ⏳  Apple Developer — App Store / TestFlight (opcional)"

section "Comandos úteis"
cat <<EOF
  ./scripts/play_console_brief.sh     # textos Play Store
  ./scripts/package_play_store.sh     # ZIP AAB + gráficos
  ./scripts/test_mac.sh               # validar Mac
  ./scripts/test_release_saves.sh android   # validar Android
  ./scripts/launch_doctor.sh          # checklist completo
  docs/STORE.md                       # guia upload
EOF

section "Diagnóstico rápido"
"$ROOT/scripts/mobile_doctor.sh" 2>&1 | tail -3
