#!/usr/bin/env bash
# Estado consolidado da Fase E — lançamento.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PRIVACY="https://pakopt.github.io/PhoenixManager/privacy.html"
# shellcheck source=read_app_version.sh
source "$ROOT/scripts/read_app_version.sh"

echo "════════════════════════════════════════"
echo "  Fase E — Estado do lançamento"
echo "  Versão: $VERSION_FULL · $(date '+%Y-%m-%d %H:%M')"
echo "════════════════════════════════════════"

section() { echo ""; echo "==> $1"; }

section "Plataformas locais"
for item in \
  "macOS:/Applications/Phoenix Manager.app" \
  "AAB:$ROOT/build/release/mobile/android/phoenix_manager.aab" \
  "APK:$ROOT/build/release/mobile/android/phoenix_manager.apk" \
  "Beta ZIP:$ROOT/build/release/beta/phoenix-manager-beta.zip"; do
  label="${item%%:*}"
  path="${item#*:}"
  if [[ -e "$path" ]]; then
    echo "  OK   $label"
  else
    echo "  --   $label (em falta)"
  fi
done

section "Loja App Store (prep)"
ios_shots=0
[[ -d "$ROOT/build/release/store/ios/screenshots" ]] && \
  ios_shots=$(ls "$ROOT/build/release/store/ios/screenshots"/*.png 2>/dev/null | wc -l | tr -d ' ')
echo "  OK   Screenshots iOS: $ios_shots"
[[ -f "$ROOT/build/release/store/ios/phoenix-manager-app-store-prep.zip" ]] && \
  echo "  OK   ZIP prep: build/release/store/ios/phoenix-manager-app-store-prep.zip" || \
  echo "  --   ZIP — ./scripts/package_app_store.sh"

section "Loja Play Store"
shots=0
[[ -d "$ROOT/build/release/store/android/screenshots" ]] && \
  shots=$(ls "$ROOT/build/release/store/android/screenshots"/*.png 2>/dev/null | wc -l | tr -d ' ')
echo "  OK   Privacidade: $PRIVACY"
echo "  OK   Screenshots: $shots"
[[ -f "$ROOT/build/release/store/android/phoenix-manager-play-upload.zip" ]] && \
  echo "  OK   ZIP upload: build/release/store/android/phoenix-manager-play-upload.zip" || \
  echo "  --   ZIP — ./scripts/package_play_store.sh"

section "Loja Microsoft Store"
if "$ROOT/scripts/msix_doctor.sh" >/dev/null 2>&1; then
  echo "  OK   Doctor MSIX: configuração válida"
else
  echo "  --   Doctor MSIX: rever ./scripts/msix_doctor.sh"
fi
if compgen -G "$ROOT/build/release/store/windows/*.msix" >/dev/null 2>&1; then
  count_msix=$(ls "$ROOT"/build/release/store/windows/*.msix 2>/dev/null | wc -l | tr -d ' ')
  echo "  OK   Pacotes MSIX: $count_msix em build/release/store/windows/"
else
  echo "  --   MSIX em falta — ./scripts/build_msix.sh (em Windows)"
fi
[[ -f "$ROOT/build/release/store/windows/phoenix-manager-msix-store-upload.zip" ]] && \
  echo "  OK   ZIP upload: build/release/store/windows/phoenix-manager-msix-store-upload.zip" || \
  echo "  --   ZIP — ./scripts/package_msix_store.sh"

section "Git"
if git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1; then
  branch="$(git -C "$ROOT" rev-parse --abbrev-ref HEAD)"
  remote="$(git -C "$ROOT" rev-parse --abbrev-ref @{u} 2>/dev/null || echo 'sem remote')"
  echo "  OK   branch $branch ($remote)"
else
  echo "  --   sem git"
fi

section "Bloqueantes"
echo "  🔄  Play — ≥12 opted-in × 14 dias → candidatar produção"
echo "      ./scripts/play_14day_tracker.sh   ·  ./scripts/play_testers_invite.sh URL"
echo "  ⏳  Microsoft Store — upload do .msix no Partner Center"
echo "  ⏳  Apple Developer — App Store / TestFlight (opcional)"

section "Trabalho activo"
cat <<EOF
  ./scripts/play_14day_tracker.sh     # checklist 12×14 + follow-up
  ./scripts/play_testers_invite.sh    # mensagem de convite
  ./scripts/play_production_apply.sh  # rascunhos questionário produção
  ./scripts/play_console_brief.sh     # textos copy-paste
  ./scripts/msix_doctor.sh            # validar msix_config / identidade
  ./scripts/build_msix.sh             # gerar .msix (Windows)
  ./scripts/package_msix_store.sh     # ZIP para Partner Center
  ./scripts/msix_partner_brief.sh     # textos Microsoft Store
  ./scripts/check_app_version_sync.sh # AppVersion = pubspec
  ./scripts/qa_manual.sh              # roteiro QA manual
  ./scripts/local_beta.sh             # ZIP APK para testadores
EOF

section "Comandos úteis"
cat <<EOF
  ./scripts/play_console_brief.sh     # textos Play Store
  ./scripts/play_console_day1.sh    # guia upload dia 1
  ./scripts/package_play_store.sh     # ZIP AAB + gráficos
  ./scripts/msix_doctor.sh            # validar Microsoft Store
  ./scripts/build_msix.sh             # build MSIX (Windows)
  ./scripts/package_msix_store.sh     # ZIP MSIX para upload
  ./scripts/test_mac.sh               # validar Mac
  ./scripts/test_release_saves.sh android   # validar Android
  ./scripts/repair_gradle.sh          # cache Gradle após limpeza
  ./scripts/launch_doctor.sh          # checklist completo
  docs/STORE.md                       # guia upload
EOF

section "Diagnóstico rápido"
avail_mb="$(df -k /System/Volumes/Data 2>/dev/null | awk 'NR==2 {print int($4/1024)}')"
if [[ -n "$avail_mb" ]]; then
  if [[ "$avail_mb" -lt 3000 ]]; then
    echo "  ⚠️  Disco: ~${avail_mb} MiB livres (Android precisa ≥ 3000 MiB)"
    echo "      ./scripts/clean_dev_artifacts.sh  |  CLEAN_GRADLE=1 ..."
  else
    echo "  OK   Disco: ~${avail_mb} MiB livres"
  fi
fi
"$ROOT/scripts/mobile_doctor.sh" 2>&1 | tail -3
