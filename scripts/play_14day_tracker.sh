#!/usr/bin/env bash
# Tracker do requisito Google: ≥12 testadores opted-in × 14 dias contínuos.
# Estado local (gitignored): .play_tracker.env
#
# Uso:
#   ./scripts/play_14day_tracker.sh
#   ./scripts/play_14day_tracker.sh --follow-up
#   DAY=3 OPTED_IN=12 ./scripts/play_14day_tracker.sh --save
#   ./scripts/play_14day_tracker.sh --save DAY=3 OPTED_IN=12 PLAY_OPT_IN_URL='https://…'
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=read_app_version.sh
source "$ROOT/scripts/read_app_version.sh"

CONTACT="pakopt7@gmail.com"
STATE_FILE="$ROOT/.play_tracker.env"
FOLLOW_UP=0
DO_SAVE=0

# Overrides (env + args) — o ficheiro de estado só preenche o que ficar vazio.
OV_DAY="${DAY-}"
OV_OPTED_IN="${OPTED_IN-}"
OV_URL="${PLAY_OPT_IN_URL-}"
OV_CLOCK="${CLOCK_START-}"

usage() {
  cat <<EOF
Uso: ./scripts/play_14day_tracker.sh [--follow-up] [--save] [DAY=N] [OPTED_IN=N] [PLAY_OPT_IN_URL=url]

  --save       Grava DAY / OPTED_IN / PLAY_OPT_IN_URL / CLOCK_START em .play_tracker.env
  --follow-up  Copia mensagem de lembrete (macOS)

Env (ou KEY=valor como argumentos):
  DAY=N              Dia actual da contagem (1–14)
  OPTED_IN=N         Nº de testadores opted-in agora
  PLAY_OPT_IN_URL=…  Link de adesão da Play Console
  CLOCK_START=AAAA-MM-DD  Dia em que ≥12 opted-in (início dos 14 dias)
EOF
}

for arg in "$@"; do
  case "$arg" in
    --follow-up|-f) FOLLOW_UP=1 ;;
    --save|-s) DO_SAVE=1 ;;
    --help|-h) usage; exit 0 ;;
    DAY=*) OV_DAY="${arg#DAY=}" ;;
    OPTED_IN=*) OV_OPTED_IN="${arg#OPTED_IN=}" ;;
    PLAY_OPT_IN_URL=*) OV_URL="${arg#PLAY_OPT_IN_URL=}" ;;
    CLOCK_START=*) OV_CLOCK="${arg#CLOCK_START=}" ;;
    *)
      echo "Argumento desconhecido: $arg" >&2
      usage >&2
      exit 1
      ;;
  esac
done

DAY=""
OPTED_IN=""
PLAY_OPT_IN_URL=""
CLOCK_START=""

if [[ -f "$STATE_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$STATE_FILE"
fi

[[ -n "$OV_DAY" ]] && DAY="$OV_DAY"
[[ -n "$OV_OPTED_IN" ]] && OPTED_IN="$OV_OPTED_IN"
[[ -n "$OV_URL" ]] && PLAY_OPT_IN_URL="$OV_URL"
[[ -n "$OV_CLOCK" ]] && CLOCK_START="$OV_CLOCK"

# Se --save e ≥12 opted-in sem CLOCK_START, regista hoje como início do relógio.
if [[ "$DO_SAVE" -eq 1 && -n "$OPTED_IN" && "$OPTED_IN" -ge 12 && -z "$CLOCK_START" ]]; then
  CLOCK_START="$(date +%Y-%m-%d)"
fi

# Dia sugerido a partir de CLOCK_START (se DAY vazio).
if [[ -z "$DAY" && -n "$CLOCK_START" ]]; then
  if date -j -f '%Y-%m-%d' "$CLOCK_START" '+%s' >/dev/null 2>&1; then
    start_s="$(date -j -f '%Y-%m-%d' "$CLOCK_START" '+%s')"
    now_s="$(date '+%s')"
    DAY="$(( (now_s - start_s) / 86400 + 1 ))"
    if [[ "$DAY" -lt 1 ]]; then DAY=1; fi
  fi
fi

if [[ "$DO_SAVE" -eq 1 ]]; then
  cat >"$STATE_FILE" <<EOF
# Estado local Play 12×14 — não commitar (ver .gitignore)
DAY=${DAY:-}
OPTED_IN=${OPTED_IN:-}
PLAY_OPT_IN_URL=${PLAY_OPT_IN_URL:-}
CLOCK_START=${CLOCK_START:-}
EOF
  echo "Estado gravado em .play_tracker.env"
  echo ""
fi

echo "════════════════════════════════════════"
echo "  Play — tracker 12 × 14 dias"
echo "  Versão: $VERSION_FULL"
echo "════════════════════════════════════════"
echo ""
echo "==> Estado"
cat <<EOF
  Opted-in agora:     ${OPTED_IN:-[ ? ]}  (meta ≥ 12)
  Dia da contagem:    ${DAY:-[ ? ]} / 14
  Início relógio:     ${CLOCK_START:-[ ? ]}  (data com ≥12 opted-in)
  Link adesão:        ${PLAY_OPT_IN_URL:-[Play Console → Teste fechado → Testadores]}
  AAB:                build/release/mobile/android/phoenix_manager.aab
  Estado local:       ${STATE_FILE#"$ROOT/"}
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

  Gravar progresso:
    DAY=$([ -n "$DAY" ] && echo "$DAY" || echo N) OPTED_IN=$([ -n "$OPTED_IN" ] && echo "$OPTED_IN" || echo N) ./scripts/play_14day_tracker.sh --save
EOF

echo ""
echo "==> Mensagem follow-up (D3 / D7 / se alguém vacilar)"
echo "────────────────────────────────────────"
FOLLOW_MSG=$(cat <<EOF
Olá — só um lembrete rápido do teste Phoenix Manager.

Para a Google contar o teu teste, mantém a app instalada pela Play Store
e não saias do programa de testadores (14 dias).

Se ainda não tinhas aceite: abre o link de adesão e toca em «Tornar-me testador».
Bugs: $CONTACT (versão $VERSION_NAME + modelo do telemóvel).

Obrigado!
EOF
)
echo "$FOLLOW_MSG"
echo "────────────────────────────────────────"

if [[ "$FOLLOW_UP" -eq 1 ]] && [[ "$(uname -s)" == "Darwin" ]] && command -v pbcopy >/dev/null 2>&1; then
  printf '%s\n' "$FOLLOW_MSG" | pbcopy
  echo ""
  echo "(mensagem follow-up copiada para a área de transferência)"
fi

echo ""
echo "Comandos: ./scripts/play_testers_invite.sh · ./scripts/play_production_apply.sh · ./scripts/phase_e_status.sh"
