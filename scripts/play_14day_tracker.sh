#!/usr/bin/env bash
# Tracker do requisito Google: ≥12 testadores opted-in × 14 dias contínuos.
# Uso:
#   ./scripts/play_14day_tracker.sh
#   ./scripts/play_14day_tracker.sh --follow-up
#   DAY=3 OPTED_IN=12 ./scripts/play_14day_tracker.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=read_app_version.sh
source "$ROOT/scripts/read_app_version.sh"

CONTACT="pakopt7@gmail.com"
DAY="${DAY:-}"
OPTED_IN="${OPTED_IN:-}"
FOLLOW_UP=0

for arg in "$@"; do
  case "$arg" in
    --follow-up|-f) FOLLOW_UP=1 ;;
    --help|-h)
      cat <<EOF
Uso: ./scripts/play_14day_tracker.sh [--follow-up]
Env: DAY=N  OPTED_IN=N  PLAY_OPT_IN_URL=url

Imprime checklist dos 14 dias + mensagem de follow-up para testadores.
EOF
      exit 0
      ;;
  esac
done

echo "════════════════════════════════════════"
echo "  Play — tracker 12 × 14 dias"
echo "  Versão: $VERSION_FULL"
echo "════════════════════════════════════════"
echo ""
echo "==> Estado (preenche na Console e aqui)"
cat <<EOF
  Opted-in agora:     ${OPTED_IN:-[ ? ]}  (meta ≥ 12)
  Dia da contagem:    ${DAY:-[ ? ]} / 14
  Link adesão:        ${PLAY_OPT_IN_URL:-[Play Console → Teste fechado → Testadores]}
  AAB:                build/release/mobile/android/phoenix_manager.aab
EOF

if [[ -n "$OPTED_IN" && "$OPTED_IN" -lt 12 ]]; then
  echo ""
  echo "  ⚠️  Abaixo de 12 — o relógio dos 14 dias NÃO corre (ou arrisca reiniciar)."
fi

if [[ -n "$DAY" && "$DAY" -ge 14 && -n "$OPTED_IN" && "$OPTED_IN" -ge 12 ]]; then
  echo ""
  echo "  ✅  Pronto para candidatar acesso a produção no Dashboard."
  echo "      ./scripts/play_production_apply.sh"
fi

echo ""
echo "==> Checklist diário"
cat <<EOF
  [ ] Abrir Play Console → Teste fechado → Testadores
  [ ] Contar opted-in / joined (≥12?)
  [ ] Se alguém saiu: reenviar convite (./scripts/play_testers_invite.sh URL)
  [ ] Dia $([ -n "$DAY" ] && echo "$DAY" || echo N)/14 anotado
  [ ] Após dia 14 com ≥12: Dashboard → candidatar produção
  Guia: docs/STORE.md §9c
EOF

echo ""
echo "==> Mensagem follow-up (D3 / D7 / se alguém vacilar)"
echo "────────────────────────────────────────"
cat <<EOF
Olá — só um lembrete rápido do teste Phoenix Manager.

Para a Google contar o teu teste, mantém a app instalada pela Play Store
e não saias do programa de testadores (14 dias).

Se ainda não tinhas aceite: abre o link de adesão e toca em «Tornar-me testador».
Bugs: $CONTACT (versão $VERSION_NAME + modelo do telemóvel).

Obrigado!
EOF
echo "────────────────────────────────────────"

if [[ "$FOLLOW_UP" -eq 1 ]] && [[ "$(uname -s)" == "Darwin" ]] && command -v pbcopy >/dev/null 2>&1; then
  cat <<EOF | pbcopy
Olá — só um lembrete rápido do teste Phoenix Manager.

Para a Google contar o teu teste, mantém a app instalada pela Play Store
e não saias do programa de testadores (14 dias).

Se ainda não tinhas aceite: abre o link de adesão e toca em «Tornar-me testador».
Bugs: $CONTACT (versão $VERSION_NAME + modelo do telemóvel).

Obrigado!
EOF
  echo ""
  echo "(mensagem follow-up copiada para a área de transferência)"
fi

echo ""
echo "Comandos: ./scripts/play_testers_invite.sh · ./scripts/play_production_apply.sh · ./scripts/phase_e_status.sh"
